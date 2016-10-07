//
//  HeartRate.swift
//  HealthWatchExample
//
//  Created by Luis Castillo on 8/5/16.
//  Copyright © 2016 LC. All rights reserved.
//

import Foundation

@objc
class HeartRate:NSObject {
    private var _value:Double
    private var _dateString:String
    private var _timeString:String
    
    var value: Double
    {
        let places:Double = 2.0
        let power:Double = pow(10.0, places)
        let roundAnswer:Double = (_value * power) / power
        
        return roundAnswer
    }
    
    var dateString:String
    {
        return _dateString
    }
    
    var timeString:String
    {
        return _timeString
    }
    
    override init() {
        self._value = 0
        self._dateString = ""
        self._timeString = ""
    }//eom
    
    init(value:Double, date:String, time:String) {
        self._value = value
        self._dateString = date
        self._timeString = time
    }
}//eoc
