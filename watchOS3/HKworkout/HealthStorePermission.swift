//
//  Created by Luis Castillo on 8/5/16.
//  Copyright © 2016 LC. All rights reserved.
//

import Foundation
import HealthKit

class HealthStorePermission: NSObject
{
    //MARK: - Permission Request
    func requestPermission(healthStore:HKHealthStore,
                           types:[HKQuantityType],
                           withWriting:Bool = false,
                           completionHandler:@escaping (Bool, Error?)->Void )
    {
        //health data available?
        if HKHealthStore.isHealthDataAvailable()
        {
            var readingSets:Set<HKObjectType> = []
            var writingSets:Set<HKSampleType> = []
        
            for currType:HKQuantityType in types
            {
                //reading rights
                let currObjectType:HKObjectType = currType
                readingSets.insert(currObjectType)
                
                //writing rights
                if withWriting == true
                {
                    let currSampleType:HKSampleType = currType
                    writingSets.insert(currSampleType)
                }
            }//eom
            
            let writing:Set<HKSampleType>? = writingSets as Set<HKSampleType>
            let reading:Set<HKObjectType>? = readingSets as Set<HKObjectType>

            //auth request
            healthStore.requestAuthorization(toShare: writing, read: reading, completion:
            { (success:Bool, error:Error?) in
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
