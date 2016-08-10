//
//  HeartRateMonitor.swift
//  HealthWatchExample
//
//  Created by Luis Castillo on 8/9/16.
//  Copyright © 2016 LC. All rights reserved.
//

import Foundation
import HealthKit

protocol heartRateMonitorDelegate {
    func heartRateMonitorStateChanged(isMonitoring:Bool)
    func heartRateMonitorError(error:NSError)
    func heartRateMonitorResponse(heartRates:[HeartRate])
}

class HeartRateMonitor: NSObject, healthStoreMonitorDelegate, HealthStoreWorkoutDelegate {
    
    let healthStore = HKHealthStore()
    let hrPermission = HeartRatePermission()
    let healthWorkOut = HealthStoreWorkout()
    let healthMonitor = HealthStoreMonitor()
    let hrParser = HeartRateParser()
    
    private var _isMonitoring = false
    
    var isMonitoring:Bool{
        return _isMonitoring
    }
    
    var delegate:heartRateMonitorDelegate?
    
    
    //MARK: - Constructor
    override init()
    {
        super.init()
        
        self.healthMonitor.delegate = self
        self.healthWorkOut.delegate = self
    }//eom
    
    //MARK: - Monitoring
    func start()
    {
        if self._isMonitoring == false
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
                    self._isMonitoring = true
                    self.delegate?.heartRateMonitorStateChanged(true)
                }
            }
        }
    }//eom
    
    func end()
    {
        if self._isMonitoring
        {
            self.healthWorkOut.endWorkout()
            self._isMonitoring = false
            self.delegate?.heartRateMonitorStateChanged(false)
        }
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
                //nothing to do - just incase
                self._isMonitoring = false
                self.delegate?.heartRateMonitorStateChanged(false)
                break
        }
    }//eom
    
    //MARK: - Monitoring Delegates
    func healthStoreMonitorResults(results:[HKSample])
    {
        let parsedResults:[HeartRate] = hrParser.parse(results)
        
        self.delegate?.heartRateMonitorResponse(parsedResults)
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
        self._isMonitoring = false
        self.delegate?.heartRateMonitorStateChanged(false)
        
        if endWorkOut { self.healthWorkOut.endWorkout() }
        if endMonitor { self.healthMonitor.endMonitoring() }
        
        self.delegate?.heartRateMonitorError(error)
    }//eom
}//eoc

