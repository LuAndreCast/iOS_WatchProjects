//
//  ExtensionDelegate.swift
//  HKworkout WatchKit Extension
//
//  Created by Luis Castillo on 9/12/16.
//  Copyright © 2016 LC. All rights reserved.
//

import WatchKit

import HealthKit


@available(watchOSApplicationExtension 3.0, *)
class ExtensionDelegate: NSObject, WKExtensionDelegate {

    //MARK: - Workout Configuration
    @available(iOS 10.0, *)
    func handle(_ workoutConfiguration: HKWorkoutConfiguration)
    {
        let controllerNames = ["HeartRateInterfaceController"]
        let contextPassing = [workoutConfiguration]
        
        WKInterfaceController.reloadRootControllers(withNames: controllerNames, contexts: contextPassing)
    }//eom
    
    //MARK: - Lifecycle
    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        self.requestPermission()
    }//eom

    //MARK: - Healthstore
    func requestPermission()
    {
        if let hrQuantityType:HKQuantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate),
            let distanceQuantityType:HKQuantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning),
            let energyQuantityType:HKQuantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)
        {
            let healthStore:HKHealthStore = HKHealthStore()
            let hkPermission:HealthStorePermission = HealthStorePermission()
            
            //            let hkQuantities:[HKObjectType] = [ hrQuantityType,
            //                                                distanceQuantityType,
            //                                                energyQuantityType,
            //                                                HKObjectType.workoutType() ]
            
            let hkQuantities:[HKObjectType] = [ hrQuantityType,
                                                distanceQuantityType,
                                                energyQuantityType ]
            
            hkPermission.requestPermission(healthStore: healthStore,
                                           types: hkQuantities,
                                           withWriting: false)
            { (success:Bool, error:Error?) in
                if error != nil
                {
                    print("\(error!.localizedDescription)")
                }
            }
        }
    }//eom



}
