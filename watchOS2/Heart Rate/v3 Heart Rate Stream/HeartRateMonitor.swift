//
//  HeartRateMonitor.swift
//  HealthWatchExample
//
//  Created by Luis Castillo on 8/9/16.
//  Copyright © 2016 LC. All rights reserved.
//

import Foundation
import HealthKit


class HeartRateMonitor: NSObject, healthStoreMonitorDelegate, HealthStoreWorkoutDelegate {
    
    let healthStore = HKHealthStore()
    let hrPermission = HeartRatePermission()
    let healthWorkOut = HealthStoreWorkout()
    let healthMonitor = HealthStoreMonitor()
    let hrParser = HeartRateParser()
    
    //handlers
    typealias handlerResponse = (heartRates:[HeartRate])->Void
    typealias handlerError = (error:NSError)->Void
    
    var responseHandler:handlerResponse?
    var errorHandler:handlerError?
    
    
    //MARK: - Constructor
    override init()
    {
        super.init()
        
        self.healthMonitor.delegate = self
        self.healthWorkOut.delegate = self
    }
    
    //MARK: - Monitoring
    func start()
    {
        //requesting permission - just in case
        self.hrPermission.requestPermission(healthStore)
        { (success:Bool, error:NSError?) in
            
            if let errorFound:NSError = error
            {
                self.stopAndSendError(errorFound, endWorkOut: false, endMonitor: false)
            }
            //startWorkout
            else
            {
                self.healthWorkOut.startWorkout()
            }
        }
    }//eom
    
    func end()
    {
        self.healthWorkOut.endWorkout()
        
        self.responseHandler = nil
        self.errorHandler = nil
    }//eom
    
    //MARK: - WorkOut Delegates
    func healthStoreWorkout_error(error: NSError)
    {
        let errorNum:Int = error.code
        switch errorNum
        {
            // ""Health Store Data is Not avaliable""
            case 101:
                self.stopAndSendError(error, endWorkOut: false, endMonitor: false)
                break
            // "un-able to start workout"
            case 301:
                self.stopAndSendError(error, endWorkOut: false, endMonitor: false)
                break
            // "un-able to end workout"
            case 302:
                self.stopAndSendError(error, endWorkOut: false, endMonitor: true)
                break
            default:
                self.stopAndSendError(error, endWorkOut: false, endMonitor: false)
                break
        }
    }//eom
    
    func healthStoreWorkout_stateChanged(state: HKWorkoutSessionState)
    {
        switch state
        {
            case .Running:
                if let hrSampleType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)
                {
                    self.healthMonitor.startMonitoring(healthStore, sampleType: hrSampleType)
                }
                break
            case .Ended:
                    self.healthMonitor.endMonitoring()
                break
            case .NotStarted:
                //nothing to do
                break
        }
    }//eom
    
    //MARK: - Monitoring Delegates
    func healthStoreMonitorResults(results:[HKSample])
    {
        let parsedResults:[HeartRate] = hrParser.parse(results)
        self.responseHandler?(heartRates:parsedResults)
    }//eom
    
    func healthStoreMonitorError(error:NSError)
    {
        let errorNum = error.code
        switch errorNum
        {
            //"un-able to init type"
            case 401:
                self.stopAndSendError(error, endWorkOut: true, endMonitor: false)
                break
            //"un-able to query sample"
            case 402:
                self.stopAndSendError(error, endWorkOut: true, endMonitor: false)
                break
            default:
                self.stopAndSendError(error, endWorkOut: false, endMonitor: false)
                break
        }
    }//eom

    //MARK: - Errors
    private func stopAndSendError(error:NSError, endWorkOut:Bool = false, endMonitor:Bool = false)
    {
        if endWorkOut { self.healthWorkOut.endWorkout() }
        if endMonitor { self.healthMonitor.endMonitoring() }
        
        self.responseHandler = nil
        self.errorHandler = nil
        
        self.errorHandler?(error:error)
    }//eom
}//eoc

