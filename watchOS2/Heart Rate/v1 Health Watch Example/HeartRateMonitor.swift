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
}



final class HeartRateMonitor: NSObject, HKWorkoutSessionDelegate
{
    typealias HeartRateHandler = (newHeartRate: Double) -> Void
 
    //properties
    private static let PollInterval: NSTimeInterval = 1.0
    
    private var handler: HeartRateHandler?
    private var session: HKWorkoutSession?
        {
        didSet
        {
            self.session?.delegate = self
        }
    }
    
    private var continuePolling = true
    private var heartRates: [Double] = []
    
    let healthStore: HKHealthStore? = {
        guard HKHealthStore.isHealthDataAvailable() else { return nil }
        return HKHealthStore()
    }()
    
    var averageHeartRate: Double
    {
        return self.heartRates.reduce(0.0, combine: +) / max(Double(self.heartRates.count), 1.0)
    }
    
    var delegate:heartRateMonitorDelegate?
    
    // MARK: - Permission Request
    func requestPermission()
    {
        
        guard let healthStore = self.healthStore else {
            let authReason:String? = "No Health Store"
            self.delegate?.heartRateMonitorPermissionStatusChanged(authorizationType.notAuthorize,reason: authReason)
            return
        }
        
        guard let heartRateType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)
            else
            {
                let authReason:String? = "Unable to create heart rate type"
                self.delegate?.heartRateMonitorPermissionStatusChanged(authorizationType.notAuthorize,reason: authReason)
           return
        }
        
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
    
    
    // MARK: - Start/Stop Request
    func startMonitoring(handler: HeartRateHandler)
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
    
    // MARK: - Workout Delegates
    func workoutSession(workoutSession: HKWorkoutSession, didChangeToState toState: HKWorkoutSessionState, fromState: HKWorkoutSessionState, date: NSDate)
    {
        print("workoutSession didChangeToState \(toState)")
        
        switch toState
        {
            case .NotStarted:
                break
            case .Running:
                self.startPollingHeartRate()
            case .Ended:
                self.endPollingHeartRate()
        }
    }//eom
    
    func workoutSession(workoutSession: HKWorkoutSession, didFailWithError error: NSError)
    {
        if verbose
        {
            print("HKWorkoutSession error: \(error)")
        }
        
        let errorFound = error.localizedDescription
        delegate?.heartRateMonitorStatusChanged(monitoringStatus.off, reason: errorFound)
        
        self.endPollingHeartRate()
    }//eom
    
    // MARK: - Polling
    
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
        guard let heartRateType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate) else { fatalError("unable to create heart rate type") }
        
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
            
            guard let samples = returnedSamples as? [HKQuantitySample]
            else
            {
                
                if verbose
                {
                    print("*** an error occurred: \(error?.localizedDescription) ***")
                }
                
                let errorFound:String? = error?.localizedDescription
                self.stopMonitoringAndNotifyListeners(errorFound)
                
                return
            }
            
            let unit = HKUnit(fromString: "count/min")
            let heartRates = samples.map { $0.quantity.doubleValueForUnit(unit) }
            
            guard let heartRate = heartRates.last else
            {
                if verbose
                {
                    print("no heart found")
                }
                return
            }
            
            self.heartRates.append(heartRate)
            
            //calling handler to update results
            self.handler?(newHeartRate: heartRate)
        }
        
        self.healthStore?.executeQuery(query)
    }//eom
    
    //MARK: Error Handling
    private func stopMonitoringAndNotifyListeners(error:String?)
    {
        self.endMonitoring()
        
        delegate?.heartRateMonitorStatusChanged(monitoringStatus.off, reason: error)
    }//eom
    
}//eoc
