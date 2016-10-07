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
    private var _date:NSDate
    
    var value: Double
    {
        let places:Double = 2.0
        let power:Double = pow(10.0, places)
        let roundAnswer:Double = (_value * power) / power
        
        return roundAnswer
    }
    
    var date:NSDate
    {
        return _date
    }
    
    var dateString:String
    {
        let formmater = NSDateFormatter()
        formmater.timeStyle = NSDateFormatterStyle.NoStyle
        formmater.dateStyle = NSDateFormatterStyle.MediumStyle
        
        return formmater.stringFromDate(_date)
    }
    
    var timeString:String
    {
        let formmater = NSDateFormatter()
        formmater.timeStyle = NSDateFormatterStyle.MediumStyle
        formmater.dateStyle = NSDateFormatterStyle.NoStyle
        
        return formmater.stringFromDate(_date)
    }
    
    override init() {
        self._value = 0
        self._date = NSDate()
    }//eom
    
    init(value:Double, date:NSDate) {
        self._value = value
        self._date = date
    }
}//eoc