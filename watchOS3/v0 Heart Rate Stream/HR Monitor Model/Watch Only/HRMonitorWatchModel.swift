//
//  HRMonitorWatchModel.swift
//  HealthWatchExample
//
//  Created by Luis Castillo on 9/6/16.
//  Copyright © 2016 LC. All rights reserved.
//

import WatchKit
import WatchConnectivity
import HealthKit

@objc protocol HRMonitorWatchModelDelegate
{
    func HRMonitorStatusChanged(isMonitoring:Bool)
    func HRMonitorErrorOccurred(error:NSString)
    func HRMonitorReachabilityStatusChanged(isReachable:Bool)
}


@objc class HRMonitorWatchModel: NSObject, watchMessengerDelegate, HealthStoreWorkoutDelegate {
    
    static let sharedInstance = HRMonitorWatchModel()
    
    //models
    let wMessenger:WatchMessenger = WatchMessenger.sharedInstance
    let hkWorkout:HealthStoreWorkout = HealthStoreWorkout.sharedInstance
    
    var delegate:HRMonitorWatchModelDelegate?
    
    var isMonitoring:Bool
        {
    
        return hkWorkout.isMonitoring
    }
    
    
    //MARK: - Setup
    func setup()
    {
        hkWorkout.delegate = self
        wMessenger.delegate = self
        wMessenger.start
        { (error:NSError?) in
            if error != nil
            {
                //TODO: handle error
                print("\(self) error: \(error)")
            }
        }
    }//eom
    
    
    //MARK: - Start / End Monitoring
    func startMonitoring()
    {
        if hkWorkout.isMonitoring == false
        {
            hkWorkout.start()
            self.delegate?.HRMonitorStatusChanged(true)
        }
    }//eom
    
    @available(watchOSApplicationExtension 3.0, *)
    func startMonitoringWithConfig(workout:HKWorkoutConfiguration)
    {
        if hkWorkout.isMonitoring == false
        {
            hkWorkout.startWithWorkOutConfig(workout)
            self.delegate?.HRMonitorStatusChanged(true)
        }
    }//eom
    
    func endMonitoring()
    {
        if hkWorkout.isMonitoring
        {
            hkWorkout.endWorkout()
            self.delegate?.HRMonitorStatusChanged(false)
        }
    }//eom
    
    
    //MARK: - Health Store Workout Delegates
    func healthStoreWorkout_error(error: NSError)
    {
        let errorsToSend:[String:String] = [
                                                keys.Response.toString(): response.ErrorWorkout.toString(),
                                                keys.ErrorDescription.toString(): error.localizedDescription
                                            ]
        
        self.updateErrorToPhone(errorsToSend)
        self.delegate?.HRMonitorErrorOccurred(error.localizedDescription)
    }//eom
    
    func healthStoreWorkout_stateChanged(state: HKWorkoutSessionState)
    {
        switch state
        {
            case .Ended:
                self.updateStatusToPhone(false)
                self.delegate?.HRMonitorStatusChanged(false)
                break
            case .Paused:
                self.updateStatusToPhone(false)
                self.delegate?.HRMonitorStatusChanged(false)
                break
            case .Running:
                self.updateStatusToPhone(true)
                self.delegate?.HRMonitorStatusChanged(true)
                break
            case .NotStarted:
                self.updateStatusToPhone(false)
                self.delegate?.HRMonitorStatusChanged(false)
                break
        }
    }//eom
    
    
    //MARK: - Watch Messenger Helpers
    private func updateStatusToPhone(isMonitoring:Bool)
    {
        var messageToSend:[String:AnyObject] = [:]
        
        if isMonitoring
        {
            messageToSend = [keys.Response.toString():response.StartedMonitoring.toString()]
        }
        else
        {
            messageToSend = [keys.Response.toString():response.EndedMonitoring.toString()]
        }
        
        wMessenger.sendMessage(messageToSend)
        { (reply:[String : AnyObject]?, error:NSError?) in
            if error != nil {
                //TODO: handle error
            }
        }
    }//eom

    
    private func updateErrorToPhone(errorsToSend:[String:AnyObject])
    {
        self.wMessenger.sendMessage(errorsToSend)
        { (reply:[String : AnyObject]?, error:NSError?) in
            if error != nil
            {
                //TODO: handle error
            }
        }
    }//eom
    
    //MARK: - Watch Messenger Delegates
    func watchMessenger_watchStatesChanged(states: NSDictionary) {
        
    }//eom
    
    func watchMessenger_reachabilityStateChanged(reachable: Bool) {
        if reachable
        {
            self.delegate?.HRMonitorReachabilityStatusChanged(true)
        }
        else
        {
            self.delegate?.HRMonitorReachabilityStatusChanged(false)
        }
        
        #if DEBUG
            print("\(self) ")
        #endif
    }//eom
    
    @available(watchOSApplicationExtension 2.2, *)
    func watchMessenger_sessionStateChanged(state: WCSessionActivationState)
    {
        switch state {
        case .Activated:
            break
        case .Inactive:
            break
        case .NotActivated:
            break
        }
    }//eom
    
    func watchMessenger_didReceiveMessage(message: [String : AnyObject])
    {
        if let commandReceived:String = message[keys.Command.toString()] as? String
        {
            switch commandReceived
            {
                case command.StartMonitoring.toString():
                    self.startMonitoring()
                    break
                case command.EndMonitoring.toString():
                   self.endMonitoring()
                    break
                default:
                    break
            }
        }
        else
        {
           //received something but cant find type
        }
    }//eom
    
    @available(watchOSApplicationExtension 2.2, *)
    func watchMessenger_activationCompletedWithState(activationState: WCSessionActivationState,
                                                     error: NSError?)
    {
        if error != nil
        {
            print("\(self) \(error?.localizedDescription)")
        }
        
        switch activationState
        {
            case .Activated:
                break
            case .NotActivated:
                break
            case .Inactive:
                break
        }
    }//eom
    
}//eom
