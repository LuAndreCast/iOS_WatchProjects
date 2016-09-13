//
//  HeartRate.swift
//  HealthWatchExample
//
//  Created by Luis Castillo on 8/5/16.
//  Copyright © 2016 LC. All rights reserved.
//

//import Foundation
import HealthKit

protocol healthStoreMonitorDelegate {
    func healthStoreMonitorResults(results:[HKSample])
    func healthStoreMonitorError(error:NSError)
}


@objc
class HealthStoreMonitor: NSObject {
    
    var delegate:healthStoreMonitorDelegate?
    
    /* time looking back (in seconds) when performing sample query */
    private let dateInterval:TimeInterval = -40.0
    
    /* Polling time (in seconds) */
    private let pollingInterval:TimeInterval = 1.5
    private var continuePolling:Bool = true
    
    private var sampleType:HKSampleType?
    private var healthStore:HKHealthStore?
    
    //limit
    var limit:Int = Int(HKObjectQueryNoLimit)
    
    //ascending
    var ascending:Bool = true
    
    
    //MARK: - Start / End Monitoring
    func startMonitoring(healthStore:HKHealthStore, sampleType:HKSampleType)
    {
        self.continuePolling = true
        self.healthStore = healthStore
        self.sampleType = sampleType
        
        self.scheduleNextPoll()
    }//eom
    
    func endMonitoring()
    {
        self.continuePolling = false
        self.healthStore = nil
    }//eom
    
    //MARK: - Polling
    
    private func scheduleNextPoll()
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if self.continuePolling
            {
                self.querySample()
                self.scheduleNextPoll()
            }
        }
    }//eom
    
    //MARK: - Query
    private func querySample()
    {
        //type
        guard let queryType:HKSampleType = self.sampleType
        else
        {
            let error = NSError(domain: Errors.monitoring.domain, code: Errors.monitoring.type.code, userInfo:Errors.monitoring.type.description )
            
            self.sendError(error: error)
            return
        }
        
        //date (predicate)
        let startDate:NSDate?  = NSDate(timeIntervalSinceNow: self.dateInterval)
        let endDate:NSDate?    = nil
        let queryOptions:HKQueryOptions = []
        let datePredicate = HKQuery.predicateForSamples(withStart: startDate as Date?, end: endDate as Date?, options: queryOptions)
        
        /*
        //device (predicate)
        let device:HKDevice = HKDevice.localDevice()
        let devicePredicate = HKQuery.predicateForObjectsFromDevices([device])
        
        //final predicate
        let predicate:NSCompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate])
        */
        
        //sorting
        let sorting:NSSortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: self.ascending)
        
        //query
        let query:HKSampleQuery = HKSampleQuery(sampleType: queryType,
                                                predicate: datePredicate,
                                                limit: self.limit,
                                                sortDescriptors: [sorting])
        { (query:HKSampleQuery, samples:[HKSample]?, error:Error?) in
            
            //errors
            if error != nil
            {
                let error = NSError(domain: Errors.monitoring.domain, code: Errors.monitoring.query.code, userInfo:Errors.monitoring.query.description )
                self.sendError(error: error)
            }
            else
            {
                //data
                if let queryResults:[HKSample] = samples
                {
                    #if DEBUG
                        print("[\(self)] results:  \(queryResults.count) samples")
                    #endif
                    
                    if queryResults.count > 0
                    {
                        self.delegate?.healthStoreMonitorResults(results: queryResults)
                    }
                    else
                    {
                        //no sample data
                    }
                }
                else
                {
                    //empty results
                }
            }
        }//eo-query
    
        self.healthStore?.execute(query)
    }//eom
    
    
    //MARK: - Error
    func sendError(error:NSError)
    {
        #if DEBUG
            print("[\(self)] ERROR: \(error.localizedDescription)")
        #endif
        
        self.endMonitoring()
        
        self.delegate?.healthStoreMonitorError(error: error)
    }//eom
    
}//eoc
