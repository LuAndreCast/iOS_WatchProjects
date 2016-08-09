//
//  Workout.swift
//  HealthWatchExample
//
//  Created by Luis Castillo on 8/5/16.
//  Copyright © 2016 LC. All rights reserved.
//

import Foundation
import HealthKit


protocol HealthStoreWorkoutDelegate {
    func healthStoreWorkout_stateChanged(state:HKWorkoutSessionState)
    func healthStoreWorkout_error(error:NSError)
}

@objc
final class HealthStoreWorkout: NSObject, HKWorkoutSessionDelegate
{
    private var session: HKWorkoutSession?
        {
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
    
    var isMonitoring:Bool
    {
        if session != nil {
            return true
        }
        
        return false
    }
    
    var delegate:HealthStoreWorkoutDelegate?
    
    //MARK: - Start Workout
    func startWorkout(workoutSession:HKWorkoutSession = HKWorkoutSession(activityType: .Running, locationType: .Indoor) )
    {
        //health data avaliable?
        guard HKHealthStore.isHealthDataAvailable() else
        {
            //notify listener
            let error = NSError(domain: Errors.healthStore.domain,
                                code: Errors.healthStore.avaliableData.code,
                                userInfo:Errors.healthStore.avaliableData.description )
            self.delegate?.healthStoreWorkout_error(error)
            return
        }
        
        //valid session?
        self.session = workoutSession
        guard let currSession = self.session
        else
        {   //notify listener
            let error:NSError = NSError(domain: Errors.workOut.domain,
                                        code: Errors.workOut.start.code,
                                        userInfo:Errors.workOut.start.description )
            self.delegate?.healthStoreWorkout_error(error)
            
            return
        }
    
        //starting session
        self.healthStore?.startWorkoutSession(currSession)
    }//eom
    
    //MARK: - End Workout
    func endWorkout()
    {
        //health data avaliable?
        guard HKHealthStore.isHealthDataAvailable() else
        {
            //notify listener
            let error = NSError(domain: Errors.healthStore.domain,
                                code: Errors.healthStore.avaliableData.code,
                                userInfo:Errors.healthStore.avaliableData.description )
            self.delegate?.healthStoreWorkout_error(error)
            
            return
        }
        
        //valid session?
        guard let currSession = self.session
            else
        {
            //notify listener
            let error:NSError = NSError(domain: Errors.workOut.domain,
                                        code: Errors.workOut.end.code,
                                        userInfo:Errors.workOut.end.description )
            self.delegate?.healthStoreWorkout_error(error)
        
            return
        }
        
        //ending session
        self.healthStore?.endWorkoutSession(currSession)
    }//eom
    
    
    //MARK: Delegates
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
                    if verbose {  print("workoutSession Changed to 'Not Started'") }
                    
                    //notify listener
                    self.delegate?.healthStoreWorkout_stateChanged(HKWorkoutSessionState.NotStarted)
                    break
                case .Running:
                    if verbose {  print("workoutSession Changed to 'Running'") }
                    
                    //notify listener
                    self.delegate?.healthStoreWorkout_stateChanged(HKWorkoutSessionState.Running)
                case .Ended:
                    if verbose {  print("workoutSession Changed to 'Ended'") }
                    
                    //notify listener
                    self.delegate?.healthStoreWorkout_stateChanged(HKWorkoutSessionState.Ended)
            }
            
        }
    }//eom
    
    func workoutSession(workoutSession: HKWorkoutSession,
                        didFailWithError error: NSError)
    {
        //notify listener
        self.delegate?.healthStoreWorkout_error(error)
    }//eom

    
}//eoc