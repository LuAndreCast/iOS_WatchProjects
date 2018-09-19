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
    fileprivate var _value:Double
    fileprivate var _date:Date
    
    var value: Double
    {
        let places:Double = 2.0
        let power:Double = pow(10.0, places)
        let roundAnswer:Double = (_value * power) / power
        
        return roundAnswer
    }
    
    var date:Date
    {
        return _date
    }
    
    var dateString:String
    {
        let formmater = DateFormatter()
        formmater.timeStyle = DateFormatter.Style.none
        formmater.dateStyle = DateFormatter.Style.medium
        
        return formmater.string(from: _date)
    }
    
    var timeString:String
    {
        let formmater = DateFormatter()
        formmater.timeStyle = DateFormatter.Style.medium
        formmater.dateStyle = DateFormatter.Style.none
        
        return formmater.string(from: _date)
    }
    
    override init() {
        self._value = 0
        self._date = Date()
    }//eom
    
    init(value:Double, date:Date) {
        self._value = value
        self._date = date
    }
}//eoc
