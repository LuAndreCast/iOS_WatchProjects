//
//  HeartRateParser.swift
//  HealthWatchExample
//
//  Created by Luis Castillo on 8/9/16.
//  Copyright © 2016 LC. All rights reserved.
//

import Foundation
import HealthKit

@objc class HeartRateParser: NSObject {
    
    private let heartRateUnit:HKUnit = HKUnit(from: "count/min")
    private let _dateFormatter:DateFormatter = DateFormatter()
    
    func parseFromSamples(samples:[HKSample])->[HeartRate]
    {
        var list:[HeartRate] = []
        
        for sample in samples
        {
            guard let currSample:HKQuantitySample = sample as? HKQuantitySample
            else
            {
                continue
            }
            
            let heartRate:Double = currSample.quantity.doubleValue(for: self.heartRateUnit)
           
            //date
            let endData:Date = sample.endDate
            self._dateFormatter.dateStyle = DateFormatter.Style.medium
            self._dateFormatter.timeStyle = DateFormatter.Style.none
            let dateString:String = self._dateFormatter.string(from: endData)
            
            //time
            self._dateFormatter.dateStyle = DateFormatter.Style.none
            self._dateFormatter.timeStyle = DateFormatter.Style.medium
            let timeString:String = self._dateFormatter.string(from: endData)
            
            let hr:HeartRate = HeartRate(value: heartRate, date:dateString, time: timeString)
            
            list .append(hr)
        }//eofl
        
        return list
    }//eom
    
    
    func parseFromQuantitySamples(samples:[HKQuantitySample])->[HeartRate]
    {
        var list:[HeartRate] = []
        
        for sample:HKQuantitySample in samples
        {
            //hr
            let heartRate:Double = sample.quantity.doubleValue(for: self.heartRateUnit)
            
            //date
            let endData:Date = sample.endDate
            self._dateFormatter.dateStyle = DateFormatter.Style.medium
            self._dateFormatter.timeStyle = DateFormatter.Style.none
            let dateString:String = self._dateFormatter.string(from: endData)
            
            //time
            self._dateFormatter.dateStyle = DateFormatter.Style.none
            self._dateFormatter.timeStyle = DateFormatter.Style.medium
            let timeString:String = self._dateFormatter.string(from: endData)
            
            let hr:HeartRate = HeartRate(value: heartRate, date:dateString, time: timeString)

            list.append(hr)
        }//eofl
        
        return list
    }//eom
    
    func parseFromQuantitySample(sample:HKQuantitySample)->HeartRate
    {
        let heartRate:Double = sample.quantity.doubleValue(for: self.heartRateUnit)
        
        //date
        let endData:Date = sample.endDate
        self._dateFormatter.dateStyle = DateFormatter.Style.medium
        self._dateFormatter.timeStyle = DateFormatter.Style.none
        let dateString:String = self._dateFormatter.string(from: endData)
        
        //time
        self._dateFormatter.dateStyle = DateFormatter.Style.none
        self._dateFormatter.timeStyle = DateFormatter.Style.medium
        let timeString:String = self._dateFormatter.string(from: endData)
        
        let hr:HeartRate = HeartRate(value: heartRate, date:dateString, time: timeString)
        
        return hr
    }//eom
    
}//eoc
