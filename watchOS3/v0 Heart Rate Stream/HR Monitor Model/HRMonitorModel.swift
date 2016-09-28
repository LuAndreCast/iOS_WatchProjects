//
//  HR Monitor Model.swift
//  HealthWatchExample
//
//  Created by Luis Castillo on 9/3/16.
//  Copyright © 2016 LC. All rights reserved.
//

import Foundation
import HealthKit

protocol HRMonitorModelDelegate {
    func HRMonitorResults(heartRates:[HeartRate])
    func HRMonitorStatusChanged(isMonitoring:Bool)
    func HRMonitorErrorOccurred(error:NSString)
    func HRMonitorReachabilityStatusChanged(isReachable:Bool)
}


@objc
class HRMonitorModel: NSObject, healthStoreMonitorDelegate, watchMessengerDelegate
{
    //models
    private let healthStorePermission:HealthStorePermission = HealthStorePermission()
    private let HRMonitor:HealthStoreMonitor = HealthStoreMonitor()
    private let watchMessenger:WatchMessenger = WatchMessenger.sharedInstance
    private let HRparser:HeartRateParser = HeartRateParser()
    
    
    //properties
    private let healthStore:HKHealthStore = HKHealthStore()
    private let heartRateQuantityType:HKQuantityType? = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)
    private var _isMonitoring:Bool = false
    
    
    var isMonitoring:Bool
        {
        return _isMonitoring
    }
    
    var delegate:HRMonitorModelDelegate?
    
    //MARK: Init
    override init()
    {
        super.init()
        HRMonitor.delegate = self
        watchMessenger.delegate = self
        
        watchMessenger.start
        { (error:NSError?) in
            if error != nil
            {
                self.delegate?.HRMonitorReachabilityStatusChanged(false)
            }
        }
    }//eom
    
    //MARK: - Permission
    func requestPermission( completionHandler:(Bool, NSError?)->Void )
    {
        self.requestHealthStorePermission
        { (success:Bool, error:NSError?) in
            completionHandler(success, error)
        }
    }//eom
    
    //MARK: Health Store Permission
    private func requestHealthStorePermission( completionHandler:(Bool, NSError?)->Void )
    {
        if let heartRateType = self.heartRateQuantityType
        {
            self.healthStorePermission.requestPermission(healthStore, type: heartRateType, withWriting: false, completionHandler:
            { (success:Bool, error:NSError?) in
                completionHandler(success, error)
            })
        }
        else
        {
            let error = NSError(domain: Errors.heartRate.domain, code: Errors.heartRate.quantity.code, userInfo:Errors.heartRate.quantity.description )
            completionHandler(false, error)
        }
    }//eom
    
    
    //MARK: - Start Monitoring
    
    /*!
     * @brief 1. Request HR Permission
     * @brief 2. Start Workout & Monitoring HR
     */
    func startHeartRateMonitoring()
    {
        /* 1. Request Heart Rate Permission */
        self.requestHealthStorePermission
        { (success:Bool, error:NSError?) in
            if error != nil
            {
                self.delegate?.HRMonitorErrorOccurred(error!.localizedDescription)
            }
            else
            {
                /* 2. Start Workout & Monitoring HR*/
                self.startHeartRateProcess()
            }
        }
    }//eom
    
    /*!
     * @brief 1. Start Workout
     * @brief 2. Start Monitoring HR
     */
    private func startHeartRateProcess()
    {
        //iphone
        #if os(iOS)
            //open apple watch app
            if #available(iOS 10.0, *)
            {
                /* 1. Start Workout */
                let workOutConfig = HealthKitWorkoutConfig()
                workOutConfig .startWorkOut(self.healthStore, completion:
                { (success:Bool, error:NSError?) in
                    if error != nil
                    {
                        self.delegate?.HRMonitorErrorOccurred(error!.localizedDescription)
                    }
                    else
                    {
                        /* 2. Start Monitoring HR */
                        self.HRMonitor.startMonitoring(self.healthStore, sampleType:self.heartRateQuantityType!)
                    }
                })
            }
            //try to send message to watch app
            else
            {
                /* 1. Start Workout */
                let messageFromPhone = [ keys.Command.toString() : command.StartMonitoring.toString() ]
                self.watchMessenger.sendMessage(messageFromPhone, completionHandler: { (reply:[String : AnyObject]?, error:NSError?) in
                    if error != nil
                    {
                        self.delegate?.HRMonitorErrorOccurred(error!.localizedDescription)
                    }
                    else
                    {
                        /* 2. Start Monitoring HR */
                        self.HRMonitor.startMonitoring(self.healthStore, sampleType:self.heartRateQuantityType!)
                    }
                })
            }
        #elseif os(watchOS)
            //Future release
        #endif
    }//eom
    
    //MARK: - End Monitoring
    func endHeartRateMonitoring()
    {
        #if os(iOS)
            /* 1. End Workout */
            let messageFromPhone = [ keys.Command.toString() : command.EndMonitoring.toString() ]
            self.watchMessenger.sendMessage(messageFromPhone, completionHandler:
                { (reply:[String : AnyObject]?, error:NSError?) in
                    if error != nil
                    {
                        self.delegate?.HRMonitorErrorOccurred(error!.localizedDescription)
                    }
                    else
                    {
                        /* 2. End Monitoring HR */
                        self.HRMonitor.endMonitoring()
                    }
            })
        #elseif os(watchOS)
            //Future release
        #endif
    }//eom
    
    //MARK: - Heart rate Results
    func healthStoreMonitorError(error: NSError)
    {
        self.delegate?.HRMonitorErrorOccurred(error.localizedDescription)
    }//eom
    
    func healthStoreMonitorResults(results: [HKSample])
    {
        let parsedResults:[HeartRate] = HRparser.parse(results)
        if parsedResults.count > 0
        {
            self.delegate?.HRMonitorResults(parsedResults)
        }
    }//eom
    
    //MARK: - Watch Messenger
    func watchMessenger_reachabilityStateChanged(reachable: Bool)
    {
        if reachable
        {
            self.delegate?.HRMonitorReachabilityStatusChanged(true)
        }
        else
        {
            self.delegate?.HRMonitorReachabilityStatusChanged(false)
        }
    }//eom
    
    func watchMessenger_didReceiveMessage(message: [String : AnyObject])
    {
        dispatch_async(dispatch_get_main_queue())
        {
            if let responseReceived:String = message[keys.Response.toString()] as? String
            {
                switch responseReceived
                {
                    case response.StartedMonitoring.toString():
                        self._isMonitoring = true
                        self.delegate?.HRMonitorStatusChanged(self.isMonitoring)
                        break
                    case response.EndedMonitoring.toString():
                        self._isMonitoring = false
                        self.delegate?.HRMonitorStatusChanged(self.isMonitoring)
                        break
                    case response.Data.toString():
//                        let hrValue:Double? = message[keys.HeartRate.toString()] as? Double
//                        let hrTime:String? = message[keys.Time.toString()] as? String
//                        let hrDate:String? = message[keys.Date.toString()] as? String
//
//                        if hrValue != nil && hrTime != nil && hrDate != nil
//                        {
//                            print("Heart rate Data:\n \(hrValue!) \n at \(hrTime!) \n on \(hrDate!)")
//                        }
                        
                        //NO HR Data is going to be send from watch to phone
                        break
                    case response.ErrorHealthKit.toString():
                        if let errorMsg:NSString = message[keys.ErrorDescription.toString()] as? NSString
                        {
                            self.delegate?.HRMonitorErrorOccurred(errorMsg)
                        }
                        
                        break
                    case response.ErrorMonitoring.toString():
                        if let errorMsg:NSString = message[keys.ErrorDescription.toString()] as? NSString
                        {
                            self.delegate?.HRMonitorErrorOccurred(errorMsg)
                        }
                    break
                    case response.ErrorWorkout.toString():
                        if let errorMsg:NSString = message[keys.ErrorDescription.toString()] as? NSString
                        {
                            self.delegate?.HRMonitorErrorOccurred(errorMsg)
                        }
                        
                    break
                    default:
                        // "Unknown response received"
                        break
                
                }
            }
        }//eo-main queue
    }//eom
    
}//eoc

