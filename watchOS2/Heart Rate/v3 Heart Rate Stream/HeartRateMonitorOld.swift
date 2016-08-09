//
//  HeartRateMonitor.swift
//  HealthWatchExample
//
//  Created by Luis Castillo on 8/1/16.
//  Copyright © 2016 LC. All rights reserved.
//

import HealthKit

enum monitoringStatus:Int {
    case on
    case off
    
    func toString()->String
    {
        switch self {
        case .off:
            return "Off"
        case .on:
            return "On"
        }
    }//eom
}

enum authorizationType:Int {
    case authorized
    case notAuthorize
    
    func toString()->String
    {
        switch self {
        case .authorized:
            return "Authorized"
        case .notAuthorize:
            return "Not Authorized"
        }
    }//eom
}

protocol heartRateMonitorDelegate {
    func heartRateMonitorPermissionStatusChanged(type:authorizationType, reason:String?)
    func heartRateMonitorStatusChanged(status:monitoringStatus, reason:String?)
    func heartRateMonitorData(heartRate:HeartRate)
    func heartRateMonitorError(error:String)
}



final class HeartRateMonitorOld: NSObject, HKWorkoutSessionDelegate
{
    //private properties
    private static let PollInterval: NSTimeInterval = 1.0
    private var continuePolling             = true
    private var heartRatesValues: [Double]  = []
    private var _heartRates:[HeartRate]     = []
    
    private var heartRateUnit:HKUnit            = HKUnit(fromString: "count/min")
    private var heartRateType:HKQuantityType?   = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)
    
    private var session: HKWorkoutSession?
        {
        didSet
        {
            self.session?.delegate = self
        }
    }//
    
    
    //public properties
    var delegate:heartRateMonitorDelegate?
    
    let healthStore: HKHealthStore? = {
        guard HKHealthStore.isHealthDataAvailable() else { return nil }
        return HKHealthStore()
    }()
    
    //getters
    var averageHeartRate: Double
    {
        return self.heartRatesValues.reduce(0.0, combine: +) / max(Double(self.heartRatesValues.count), 1.0)
    }
    
    var heartRates:[HeartRate]
    {
        return _heartRates
    }
    
    var isMonitoring:Bool
        {
        
        if session != nil {
            return true
        }
        
        return false
    }
    
    // MARK: - Permission Request
    func requestPermission()
    {
        //health store setup?
        guard let healthStore = self.healthStore else {
            let authReason:String? = "No Health Store"
            self.delegate?.heartRateMonitorPermissionStatusChanged(authorizationType.notAuthorize,reason: authReason)
            return
        }
        
        //heart rate type?
        guard let heartRateType:HKObjectType = self.heartRateType
            else
            {
                let authReason:String? = "Unable to create heart rate type"
                self.delegate?.heartRateMonitorPermissionStatusChanged(authorizationType.notAuthorize,reason: authReason)
           return
        }
        
        //auth request?
        healthStore.requestAuthorizationToShareTypes(nil, readTypes: [heartRateType]) { (success, error) in
            if success
            {
                let authReason:String? = "permission granted"
                self.delegate?.heartRateMonitorPermissionStatusChanged(authorizationType.authorized,reason: authReason)
            }
            else
            {
                let authReason:String? = "permission error: \(error)"
                self.delegate?.heartRateMonitorPermissionStatusChanged(authorizationType.notAuthorize,reason: authReason)
            }
        }
    }//eom
    
    // MARK: - Monitoring
    func startMonitoring()
    {
        self.session = HKWorkoutSession(activityType: .Running, locationType: .Indoor)
        
        guard let session = self.session else { return }

        self.healthStore?.startWorkoutSession(session)
    }//eom
    
    
    func stopMonitoring()
    {
        guard let session = self.session else { return }
        
        self.healthStore?.endWorkoutSession(session)
    }//eom
    
        // MARK: Polling
    private func startPollingHeartRate()
    {
        self.continuePolling = true
        
        self.scheduleNextPoll()
    }//eom
    
    private func endPollingHeartRate()
    {
        self.continuePolling = false
    }//eom
    
    private func scheduleNextPoll()
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(self.dynamicType.PollInterval * Double(NSEC_PER_SEC))), dispatch_get_main_queue())
        {
            guard self.continuePolling else { return }
            
            self.sendHeartRateReading()
            
            self.scheduleNextPoll()
        }
    }//eom
    
    //MARK: - Heart Rate
    private func sendHeartRateReading()
    {
        //type
        guard let heartRateType:HKSampleType = self.heartRateType
        else
        {
            let reason:String = "Unable to create heart rate type"
            self.delegate?.heartRateMonitorError(reason)
            
            return
        }
        
        //date
        let datePredicate = HKQuery.predicateForSamplesWithStartDate(self.session?.startDate, endDate: self.session?.endDate ?? NSDate(), options: .None)
        
        //device
        let device = HKDevice.localDevice()
        let devicePredicate = HKQuery.predicateForObjectsFromDevices([device])
        
        //predicate
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate, devicePredicate])
        
        //sorting
        let sortByDate = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        
        //query
        let query = HKSampleQuery(sampleType: heartRateType,
                                  predicate: predicate,
                                  limit: Int(HKObjectQueryNoLimit),
                                  sortDescriptors: [sortByDate])
        { (_, returnedSamples, error) -> Void in
            
            //valid data?
            guard let samples:[HKQuantitySample] = returnedSamples as? [HKQuantitySample]
            else
            {
                //stop heart rate monitoring
                self.stopMonitoring()
                
                //notify VC of errors
                let errorFound:String? = error?.localizedDescription
                self.delegate?.heartRateMonitorStatusChanged(monitoringStatus.off, reason: errorFound)
                
                return
            }
            
            //data?
            if samples.count > 0
            {
                //send current data to listeners
                self.sendDataToListerners(samples)
                
//                //adding all heart rates to list
//                self.appendNewDataToList(samples)
            }
            else
            {
                if verbose
                {
                    print("no data")
                }
            }
        }//eo
        
        self.healthStore?.executeQuery(query)
    }//eom
    
    
    private func sendDataToListerners(list:[HKQuantitySample])
    {
        let lastItem = list.last!
        
        let quantity:Double = lastItem.quantity.doubleValueForUnit(self.heartRateUnit)
        let date:NSDate = lastItem.endDate
        let newHeartRate:HeartRate = HeartRate(value: quantity, date: date)
        
        delegate?.heartRateMonitorData(newHeartRate)
    }//eom
    
    
    //adding all of the hearts to list
    private func appendNewDataToList(list:[HKQuantitySample])
    {
        for sample:HKQuantitySample in list
        {
            //heart rate value for average calculation
            let quantity:Double = sample.quantity.doubleValueForUnit(self.heartRateUnit)
            self.heartRatesValues.append(quantity)
            
            //all date about current heart rate to list
            let newHeartRate:HeartRate = HeartRate(value: quantity, date: sample.endDate)
            
            self._heartRates.append(newHeartRate)
        }//eofl
        
    }//eom
    
    
    // MARK: - Workout Delegates
    func workoutSession(workoutSession: HKWorkoutSession, didChangeToState toState: HKWorkoutSessionState, fromState: HKWorkoutSessionState, date: NSDate)
    {
        dispatch_async(dispatch_get_main_queue())
        { [unowned self] in
            
            switch toState
            {
            case .NotStarted:
                if verbose {  print("workoutSession Changed to 'Not Started'") }
                
                break
            case .Running:
                if verbose {  print("workoutSession Changed to 'Running'") }
                
                self.startPollingHeartRate()
            case .Ended:
                if verbose {  print("workoutSession Changed to 'Ended'") }
                
                self.endPollingHeartRate()
            }
            
        }
    }//eom
    
    func workoutSession(workoutSession: HKWorkoutSession, didFailWithError error: NSError)
    {
        let errorFound = error.localizedDescription
        delegate?.heartRateMonitorStatusChanged(monitoringStatus.off, reason: errorFound)
        
        self.endPollingHeartRate()
    }//eom
    

}//eoc



/*

    var handler: HeartRateHandler?
    typealias HeartRateHandler = (newHeartRate: Double) -> Void
    func startMonitoringWithHandler(handler: HeartRateHandler)
    {
        self.handler = handler

        self.session = HKWorkoutSession(activityType: .Running, locationType: .Indoor)

        guard let session = self.session else { return }

        self.healthStore?.startWorkoutSession(session)
    }//eom


func endMonitoring()
{
    self.handler = nil
    
    guard let session = self.session else { return }
    
    self.healthStore?.endWorkoutSession(session)
}//eom

*/

