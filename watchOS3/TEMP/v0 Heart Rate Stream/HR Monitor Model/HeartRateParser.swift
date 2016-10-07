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
    
    private let heartRateUnit:HKUnit = HKUnit(fromString: "count/min")
    
    func parse(samples:[HKSample])->[HeartRate]
    {
        var list:[HeartRate] = []
        
        for sample in samples
        {
            guard let currSample:HKQuantitySample = sample as? HKQuantitySample
            else
            {
                continue
            }
            
            let heartRate:Double = currSample.quantity.doubleValueForUnit(self.heartRateUnit)
            let endData:NSDate = currSample.endDate

            let hr:HeartRate = HeartRate(value: heartRate, date: endData)
            list .append(hr)
        }//eofl
        
        return list
    }//eom
    
}//eoc
