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
                           types:[HKObjectType],
                           withWriting:Bool = false,
                           completionHandler:@escaping (Bool, Error?)->Void )
    {
        //health data available?
        if HKHealthStore.isHealthDataAvailable()
        {
            var readingSets:Set<HKObjectType> = []
            var writingSets:Set<HKSampleType> = []
        
            for currType:HKObjectType in types
            {
                //reading rights
                readingSets.insert(currType)
                
                //writing rights
                if withWriting == true
                {
                    if let currSampleType:HKSampleType = currType as? HKSampleType
                    {
                        writingSets.insert(currSampleType)
                    }
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
