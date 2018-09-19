//
//  HeartRateParser.swift
//  HealthWatchExample
//
//  Created by Luis Castillo on 8/9/16.
//  Copyright © 2016 LC. All rights reserved.
//

import Foundation
import HealthKit

class HeartRateParser: NSObject {
    
    fileprivate let heartRateUnit:HKUnit = HKUnit(from: "count/min")
    
    func parse(_ samples:[HKSample])->[HeartRate]
    {
        var list:[HeartRate] = []
        
        for sample in samples
        {
            guard let currSample:HKQuantitySample = sample as? HKQuantitySample
            else
            {
                continue
            }
            
           if verbose
           {
//                print("Heart Rate: \(currSample.quantity.doubleValueForUnit(self.heartRateUnit))")
//                print("quantityType: \(currSample.quantityType)")
//                print("Start Date: \(currSample.startDate)")
//                print("End Date: \(currSample.endDate)")
//                print("Metadata: \(currSample.metadata)")
//                print("UUID: \(currSample.UUID)")
//                print("Source: \(currSample.sourceRevision)")
//                print("Device Name: \(currSample.device?.name)")
//                print("Device Model: \(currSample.device?.model)")
//                print("Device Manufacturer: \(currSample.device?.manufacturer)")
//                print("Device OS: \(currSample.device?.softwareVersion)")
//                print("---------------------------------\n")
            }
           
            let heartRate:Double = currSample.quantity.doubleValue(for: self.heartRateUnit)
            let endData:Date = currSample.endDate

            let hr:HeartRate = HeartRate(value: heartRate, date: endData)
            list .append(hr)
        }//eofl
        
        return list
    }//eom
    
}//eoc
