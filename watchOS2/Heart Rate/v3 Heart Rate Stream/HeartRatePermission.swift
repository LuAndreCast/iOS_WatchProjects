//
//  HeartRatePermission.swift
//  HealthWatchExample
//
//  Created by Luis Castillo on 8/5/16.
//  Copyright © 2016 LC. All rights reserved.
//

import Foundation
import HealthKit

class HeartRatePermission: NSObject
{
    let heartRateQuantityType:HKQuantityType?   = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)
    
    func requestPermission(healthStore:HKHealthStore,
                           withWriting:Bool = false,
                           completionHandler:(Bool, NSError?)->Void )
    {
        //health data available?
        if HKHealthStore.isHealthDataAvailable()
        {
            guard let heartRateType = self.heartRateQuantityType
            else
            {
                //notify listener
                let error = NSError(domain: Errors.heartRate.domain, code: Errors.heartRate.quantity.code, userInfo:Errors.heartRate.quantity.description )
                completionHandler(false, error)
                
                return
            }
            
            var writing:Set<HKSampleType>? = [heartRateType]
            let reading:Set<HKObjectType>? = [heartRateType]
            
            if withWriting == false
            {
                writing = []
            }
            
            
            //auth request
            healthStore.requestAuthorizationToShareTypes(writing, readTypes: reading, completion: { (success:Bool, error:NSError?) in
                completionHandler(success, error)
            })
        }
        else
        {
            //notify listener
            let error = NSError(domain: Errors.healthStore.domain, code: Errors.healthStore.avaliableData.code, userInfo:Errors.healthStore.avaliableData.description )
            completionHandler(false, error)
        }
    
    }//eom
    
}//eoc