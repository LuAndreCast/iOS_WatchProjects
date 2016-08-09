//
//  healthStore+deleteAllSample.swift
//  HealthWatchExample
//
//  Created by Luis Castillo on 2/16/16.
//  Copyright © 2016 LC. All rights reserved.
//

import UIKit
import Foundation
import HealthKit

extension HKHealthStore
{
    
    func getTodayHeartRates(limitDesired: Int,
                    isOrderAscending:Bool,
                            withCompletion completion: (success: Bool, results: [HKSample]?, error: NSError?) -> Void)
    {
        let calendar = NSCalendar.currentCalendar()
        let now = NSDate()
        let components = calendar.components([.Year,.Month,.Day], fromDate: now)
        if let startDate:NSDate = calendar.dateFromComponents(components)
        {
            if let heartRateType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)
            {
                let predicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: nil, options: .None)
                
                //sorting
                var sortDescriptor:[NSSortDescriptor]?
                if isOrderAscending == true
                {
                    sortDescriptor = [ NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: true) ]
                }
                else
                {
                    sortDescriptor = [ NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false) ]
                }
                
                let heartRateQuery:HKSampleQuery = HKSampleQuery(sampleType: heartRateType,
                                                                 predicate: predicate,
                                                                 limit: limitDesired,
                                                                 sortDescriptors: sortDescriptor,
                                                                 resultsHandler:
                { (query:HKSampleQuery, results:[HKSample]?, error:NSError?) -> Void in
                    
                    //error
                    if let errorFound:NSError = error
                    {
                        completion(success: false, results: nil, error: errorFound)
                    }
                    else
                    {
                        completion(success: true, results: results, error: nil)
                    }
                })
                self.executeQuery(heartRateQuery)
            }
            else
            {
                let error:NSError = NSError(domain: "unable get heart rate quantity type", code: 122, userInfo: nil)
                completion(success: false,  results: nil, error: error)
            }
        }
        else
        {
            let error:NSError = NSError(domain: "unable get today's date", code: 12, userInfo: nil)
            completion(success: false, results: nil, error: error)
        }
    }//eom


    
    
    /* The below methods ONLY APPLIES TO DATA THAT YOU SAVED with .SaveObject */
    func saveHeartRateData(heartRateQuantity:HKQuantity, startDate:NSDate, endDate:NSDate)
    {
        let heartRateType   = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)!
        
        let heartRateSample = HKQuantitySample(type: heartRateType, quantity: heartRateQuantity, startDate: startDate, endDate: endDate)
        self.saveObject(heartRateSample)
            { (success, error) -> Void in
                
                if let errorFound:NSError = error
                {
                    print("errorFound: \(errorFound.localizedDescription)")
                }
                else
                {
                    print("heartRate Sample saved!!!")
                }
        }//eo-
    }///eom
    
    func deleteAllHeartRateData()
    {
        let heartRateType   = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)!
        let predicate       = HKQuery.predicateForSamplesWithStartDate(nil, endDate: nil, options: .None)
        
        self.deleteObjectsOfType(heartRateType, predicate: predicate, withCompletion:
            { (success, count, error) -> Void in
                
                if error != nil
                {
                    print("error \(error?.localizedDescription)")
                }
                else if success
                {
                    print("deleted '\(count)' objects ")
                }
        })//eo-
    }///eom

//    /* Experimental Deletion */
//    func deleteSamplesOfType(sampleType: HKSampleType,
//        predicate: NSPredicate,
//        withCompletion completion: (success: Bool, count: Int, error: NSError?) -> Void)
//    {
//        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: 0, sortDescriptors: nil)
//            { (query:HKSampleQuery, results:[HKSample]?, error:NSError?) -> Void in
//                
//                if let _ = error
//                {
//                    completion(success: false, count: 0, error: error)
//                    return
//                }//eo-error
//                
//                print("\n results: \(results) \n")
//                if let objectsFound:[HKSample] = results
//                {
//                    
//                    print("\n objectsFound: \(objectsFound) \n")
//                    if objectsFound.count == 0
//                    {
//                        print("zero objects found")
//                        completion(success: true, count: 0, error: nil)
//                    }
//                    else
//                    {
//                        
//                        print("attempting to delete objects found")
//                        
//                        self.deleteObjects(objectsFound, withCompletion:
//                            { (success, error) -> Void in
//
//                                completion(success: error == nil, count: objectsFound.count, error: error)
//                        })
//
//                        for currObject in objectsFound
//                        {
//                            print("\ncurrObject: \(currObject)")
//                            
//                            self.deleteObject(currObject, withCompletion: { (isDeleted:Bool, error:NSError?) -> Void in
//                                print("isDeleted? \(isDeleted)")
//                            })
//                        }
//                        
//                    }
//                }//eo-results
//                else
//                {
//                    print("No results for query\n")
//                    completion(success: true, count: 0, error: nil)
//                }
//        }
//        self.executeQuery(query)
//    }//eom
    
    
    //    private func deleteAllSamples()
    //    {
    //        print("\n\ndeleteAllSamples")
    //
    //        let calendar = NSCalendar.currentCalendar()
    //        let now = NSDate()
    //        let components = calendar.components([.Year,.Month,.Day], fromDate: now)
    //        guard let startDate:NSDate = calendar.dateFromComponents(components) else { return }
    //        let endDate:NSDate? = calendar.dateByAddingUnit(.Day, value: 1, toDate: startDate, options: [])
    //
    //        print("startDate \(startDate)")
    //        print("startDate \(endDate)")
    //
    //        let sampleType: HKSampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)!
    //        let predicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: .None)
    //
    //        self.deleteSamplesOfType(sampleType, predicate: predicate, withCompletion:
    //            { (success, count, error) -> Void in
    //
    //                if  let errorFound:NSError = error
    //                {
    //                    print("error: '\(errorFound.localizedDescription)' ")
    //                }
    //
    //                if success
    //                {
    //                    NSLog("deleted \(count)")
    //                    print("successfully delete objects!!")
    //                }
    //                print("\n\n\n\n")
    //        })
    //        
    //    }//eom
    //    
    //
    
}//eo-extension
