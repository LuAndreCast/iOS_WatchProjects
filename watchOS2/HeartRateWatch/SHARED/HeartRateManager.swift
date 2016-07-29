//
//  HeartRateManager.swift
//  HeartRateWatch
//
//  Created by Luis Castillo on 7/27/16.
//  Copyright © 2016 LC. All rights reserved.
//

import Foundation
import HealthKit


@objc enum health:Int {
    case heartRate
    
    
    func unit()->HKUnit
    {
        switch self {
        case .heartRate:
            return HKUnit(fromString:"count/min")
        }
    }//eom
    
    func type()->HKQuantityType
    {
        switch self {
        case .heartRate:
            return HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)!
        }
    }//eom
}//eo-e


@objc protocol HeartRateManagerDelegate {
    func heartRateManager_results(quantitySample:HKQuantitySample)
}


@objc class HeartRateManager:NSObject
{
    private var _heartRate = health.heartRate
    private var _healthStore:HKHealthStore?
    private var _query:HKQuery?
    
    var delegate:HeartRateManagerDelegate?
    
    
    //MARK: Constructor
    convenience init(healthStore:HKHealthStore)
    {
        self.init()
        
        _healthStore = healthStore
    }//eom
    
    //MARK:
    func start()->Bool
    {
        if HKHealthStore.isHealthDataAvailable() && (self._healthStore != nil)
        {
            self.requestAuthorization()
            return true
        }
        
        return false
    }//eom
    
    private func requestAuthorization()
    {
        //reading
        let readingTypes:Set = Set( [_heartRate.type()] )
        
        //writing
        let writingTypes:Set = Set( [_heartRate.type()] )
        
        //auth request
        _healthStore?.requestAuthorizationToShareTypes(writingTypes, readTypes: readingTypes) { (success, error) -> Void in
            
            if error != nil
            {
                print("error \(error?.localizedDescription)")
            }
        }//eo-request
    }//eom
    
    //MARK: Streaming Query
    func startStreamingQuery()
    {
        let queryPredicate  = HKQuery.predicateForSamplesWithStartDate(NSDate(), endDate: nil, options: .None)
        
        let query:HKAnchoredObjectQuery = HKAnchoredObjectQuery(type: _heartRate.type(), predicate: queryPredicate, anchor: nil, limit: Int(HKObjectQueryNoLimit))
        { (query:HKAnchoredObjectQuery, samples:[HKSample]?, deletedObjects:[HKDeletedObject]?, anchor:HKQueryAnchor?, error:NSError?) -> Void in
            
            if let errorFound:NSError = error
            {
                print("query error: \(errorFound.localizedDescription)")
            }
            else
            {
                self.sendResults(samples)
            }
        }//eo-query
        
        query.updateHandler =
            { (query:HKAnchoredObjectQuery, samples:[HKSample]?, deletedObjects:[HKDeletedObject]?, anchor:HKQueryAnchor?, error:NSError?) -> Void in
                
                if let errorFound:NSError = error
                {
                    print("query-handler error : \(errorFound.localizedDescription)")
                }
                else
                {
                    self.sendResults(samples)
                }//eo-non_error
        }//eo-query-handler
    
        _query = query
    }//eom
    
    func stopQuery()
    {
        if _query != nil {
            _query = nil
        }
    }//eom
    
    
    //MARK:
    private func sendResults(samples: [HKSample]?)
    {
        guard let sampleList = samples as? [HKQuantitySample] else { return }
        guard let currSample:HKQuantitySample = sampleList.last else { return }
        
        self.delegate?.heartRateManager_results(currSample)
    }//eom
    
    //MARK:
    
    
}//eoc