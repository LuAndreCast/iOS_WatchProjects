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
                           type:HKQuantityType,
                           withWriting:Bool = false,
                           completionHandler:(Bool, NSError?)->Void )
    {
        //health data available?
        if HKHealthStore.isHealthDataAvailable()
        {
           var writing:Set<HKSampleType>? = [type]
            let reading:Set<HKObjectType>? = [type]
            
            if withWriting == false { writing = [] }
            
            //auth request
            healthStore.requestAuthorizationToShareTypes(writing, readTypes: reading, completion:
                { (success:Bool, error:NSError?) in
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
