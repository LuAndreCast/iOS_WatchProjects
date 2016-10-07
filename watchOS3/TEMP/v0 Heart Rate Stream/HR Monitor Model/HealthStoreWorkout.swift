//
//  HealthStoreWorkout.swift
//  HealthWatchExample
//
//  Created by Luis Castillo on 9/3/16.
//  Copyright © 2016 LC. All rights reserved.
//

import Foundation
import HealthKit

@objc protocol HealthStoreWorkoutDelegate {
    func healthStoreWorkout_stateChanged(state:HKWorkoutSessionState)
    func healthStoreWorkout_error(error:NSError)
}

@objc
final class HealthStoreWorkout: NSObject, HKWorkoutSessionDelegate
{
    static let sharedInstance = HealthStoreWorkout()
    
    
    private var session: HKWorkoutSession? {
        didSet
        {
            self.session?.delegate = self
        }
    }//
    
    let healthStore: HKHealthStore? = {
        guard HKHealthStore.isHealthDataAvailable() else
        {
            return nil
        }
        return HKHealthStore()
    }()
    
    var isMonitoring:Bool {
        if session != nil {
            return true
        }
        
        return false
    }
    
    var delegate:HealthStoreWorkoutDelegate?
    
    
    //MARK: - Start Workout
    @available(watchOSApplicationExtension 2.0, *)
    func start()
    {
        let workActivityType:HKWorkoutActivityType = HKWorkoutActivityType.Other
        let workActivityLocation:HKWorkoutSessionLocationType = HKWorkoutSessionLocationType.Unknown
        
        self.session = HKWorkoutSession(activityType: workActivityType, locationType: workActivityLocation)
        self.healthStore?.startWorkoutSession(session!)
    }//eom
    
    
    @available(watchOSApplicationExtension 3.0, *)
    func startWithWorkOutConfig(workOut:HKWorkoutConfiguration)
    {
        do
        {
            self.session = try HKWorkoutSession(configuration: workOut)
            self.healthStore?.startWorkoutSession(session!)
        }
        catch
        {
          //TODO: handle error
        }
    }//eom
    
    
    //MARK: - End Workout
    func endWorkout()
    {
        if self.session != nil
        {
            self.healthStore?.endWorkoutSession(self.session!)
        }
    }//eom
    
    //MARK: - Delegates
    func workoutSession(workoutSession: HKWorkoutSession,
                        didChangeToState toState: HKWorkoutSessionState,
                                         fromState: HKWorkoutSessionState,
                                         date: NSDate)
    {
        dispatch_async(dispatch_get_main_queue())
        { [unowned self] in
            switch toState
            {
            case .NotStarted:
                //notify listener
                self.delegate?.healthStoreWorkout_stateChanged(HKWorkoutSessionState.NotStarted)
                break
            case .Running:
                //notify listener
                self.delegate?.healthStoreWorkout_stateChanged(HKWorkoutSessionState.Running)
            case .Ended:
                //notify listener
                self.delegate?.healthStoreWorkout_stateChanged(HKWorkoutSessionState.Ended)
            default:
                break;
            }
            
        }//eo-main queue
        
        #if DEBUG
            var stateString = "'Unknown'"
            
            switch toState
            {
            case .NotStarted:
                stateString = "'Not Started'"
                
                break
            case .Running:
                stateString = "'Running'"
                break
            case .Ended:
                stateString = "'Ended'"
                break
            default:
                break;
            }//eo
            
            print("workoutSession Changed to \(stateString)")
        #endif
    }//eom
    
    func workoutSession(workoutSession: HKWorkoutSession,
                        didFailWithError error: NSError)
    {
        //notify listener
        self.delegate?.healthStoreWorkout_error(error)
        
        #if DEBUG
            print("error: \(error.localizedDescription)")
        #endif
    }//eom
    
    
    
}//eoc
