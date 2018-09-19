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
    func healthStoreMonitorResults(_ results:[HKSample])
    func healthStoreMonitorError(_ error:NSError)
}


@objc
class HealthStoreMonitor: NSObject {
    
    var delegate:healthStoreMonitorDelegate?
    
    /* time looking back (in seconds) when performing sample query */
    fileprivate let dateInterval:TimeInterval = -40.0
    
    /* Polling time (in seconds) */
    fileprivate static let pollingInterval:TimeInterval = 1.5
    fileprivate var continuePolling:Bool = true
    
    fileprivate var sampleType:HKSampleType?
    fileprivate var healthStore:HKHealthStore?
    
    //limit
    var limit:Int = Int(HKObjectQueryNoLimit)
    
    //ascending
    var ascending:Bool = true
    
    
    //MARK: - Start / End Monitoring
    func startMonitoring(_ healthStore:HKHealthStore, sampleType:HKSampleType)
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
    
    fileprivate func scheduleNextPoll()
    {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(type(of: self).pollingInterval * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC))
        {
            if self.continuePolling
            {
                self.querySample()
                self.scheduleNextPoll()
            }
        }
    }//eom
    
    //MARK: - Query
    fileprivate func querySample()
    {
        //type
        guard let queryType:HKSampleType = self.sampleType
        else
        {
            let error = NSError(domain: Errors.monitoring.domain, code: Errors.monitoring.type.code, userInfo:Errors.monitoring.type.description )
            
            self.sendError(error)
            return
        }
        
        //date (predicate)
        let startDate:Date?  = Date(timeIntervalSinceNow: self.dateInterval)
        let endDate:Date?    = nil
        let queryOptions:HKQueryOptions = HKQueryOptions()
        let datePredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: queryOptions)
        
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
                                                limit: limit,
                                                sortDescriptors: [sorting]) { (query:HKSampleQuery, samples:[HKSample]?, error:Error?) in
            //errors
            if error != nil
            {
                let error = NSError(domain: Errors.monitoring.domain, code: Errors.monitoring.query.code, userInfo:Errors.monitoring.query.description )
                self.sendError(error)
            }
            else
            {
                //data
                if let queryResults:[HKSample] = samples
                {

                    if verbose {  print("[\(self)] results:  \(queryResults.count) samples") }
                    
                    if queryResults.count > 0
                    {
                        self.delegate?.healthStoreMonitorResults(queryResults)
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
        }
        
        
        self.healthStore?.execute(query)
    }//eom
    
    
    //MARK: - Error
    func sendError(_ error:NSError)
    {
        if verbose {  print("[\(self)] ERROR: \(error.localizedDescription)") }
        
        self.endMonitoring()
        
        self.delegate?.healthStoreMonitorError(error)
    }//eom
    
}//eoc
