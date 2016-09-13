//
//  HealthKitWorkoutConfig.swift
//  HealthWatchExample
//
//  Created by Luis Castillo on 9/6/16.
//  Copyright © 2016 LC. All rights reserved.
//

import Foundation
import HealthKit


@available(iOS 10.0, *)
@objc
class HealthKitWorkoutConfig: NSObject
{
    //singleton
    static let sharedInstance = HealthKitWorkoutConfig()
    
    private var watchWorkOut:HKWorkoutConfiguration?
    
    
    func startWorkOut(healthStore:HKHealthStore, completion:(Bool, NSError?)->Void )
    {
        self.watchWorkOut = HKWorkoutConfiguration()
        self.watchWorkOut?.locationType = HKWorkoutSessionLocationType.Unknown
        self.watchWorkOut?.activityType = HKWorkoutActivityType.Other
        
        healthStore.startWatchAppWithWorkoutConfiguration(self.watchWorkOut!)
        { (success:Bool, error:NSError?) in
            completion(success, error)
        }
    }//eom
    
    func endWorkOut(healthStore:HKHealthStore)
    {
       // healthStore .endWorkoutSession(self.watchWorkOut)
    }//eom
    
}//eom
