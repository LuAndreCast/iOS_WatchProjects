//
//  timezones.swift
//  timeNotification
//
//  Created by Luis Castillo on 1/21/16.
//  Copyright © 2016 LC. All rights reserved.
//

import UIKit

class timezoneModel: NSObject
{
    private var timezones:NSArray?
    
    override init()
    {
        if let pathOfFile =  NSBundle .mainBundle() .pathForResource("timezones", ofType: "plist")
        {
            if let timezonesFromFile = NSArray(contentsOfFile: pathOfFile)
            {
                timezones = timezonesFromFile
            }//
        }//
    }
    
    
    //MARK: - Load Timezones
    func reloadTimeZones()
    {
        if let pathOfFile =  NSBundle .mainBundle() .pathForResource("timezones", ofType: "plist")
        {
            if let timezonesFromFile = NSArray(contentsOfFile: pathOfFile)
            {
                timezones = timezonesFromFile
            }//
        }//
    }//eom
    
    func getTimeZones()->NSArray?
    {
        let copyOfTimezones:NSArray? =  timezones?.mutableCopy() as? NSArray
        
        return copyOfTimezones
    }
    
    
    func getTimeZoneByAbbrev(abbrev: String)-> String
    {
        var timeString:String           = ""
        //
        let time:NSDate                 = NSDate()
        let timeZone                    = NSTimeZone(abbreviation: abbrev)
        let formatter:NSDateFormatter   = NSDateFormatter()
        formatter.timeZone              = timeZone
        formatter.dateFormat            = "h:mm a"
        timeString                      = formatter.stringFromDate(time)

        return timeString
    }//eom
    
}
