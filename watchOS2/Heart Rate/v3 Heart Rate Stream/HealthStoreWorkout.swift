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
    func healthStoreWorkout_stateChanged(_ state:HKWorkoutSessionState)
    func healthStoreWorkout_error(_ error:NSError)
}

@objc
final class HealthStoreWorkout: NSObject, HKWorkoutSessionDelegate
{
    fileprivate var session: HKWorkoutSession?
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
    func startWorkout(_ workoutSession:HKWorkoutSession = HKWorkoutSession(activityType: .running, locationType: .indoor) )
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
        self.healthStore?.start(currSession)
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
        self.healthStore?.end(currSession)
    }//eom
    
    
    //MARK: Delegates
    func workoutSession(_ workoutSession: HKWorkoutSession,
                        didChangeTo toState: HKWorkoutSessionState,
                                         from fromState: HKWorkoutSessionState,
                                         date: Date)
    {
        DispatchQueue.main.async
        { [unowned self] in
            switch toState
            {
                case .notStarted:
                    if verbose {  print("workoutSession Changed to 'Not Started'") }
                    
                    //notify listener
                    self.delegate?.healthStoreWorkout_stateChanged(HKWorkoutSessionState.notStarted)
                    break
                case .running:
                    if verbose {  print("workoutSession Changed to 'Running'") }
                    
                    //notify listener
                    self.delegate?.healthStoreWorkout_stateChanged(HKWorkoutSessionState.running)
                case .ended:
                    if verbose {  print("workoutSession Changed to 'Ended'") }
                    
                    //notify listener
                    self.delegate?.healthStoreWorkout_stateChanged(HKWorkoutSessionState.ended)
                default:
                    break
            }
            
        }
    }//eom
    
    func workoutSession(_ workoutSession: HKWorkoutSession,
                        didFailWithError error: Error)
    {
        //notify listener
        self.delegate?.healthStoreWorkout_error(error as NSError)
    }//eom

    
}//eoc
