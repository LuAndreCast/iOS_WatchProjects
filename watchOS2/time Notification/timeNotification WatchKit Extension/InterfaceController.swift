//
//  InterfaceController.swift
//  timeNotification WatchKit Extension
//
//  Created by Luis Castillo on 1/20/16.
//  Copyright © 2016 LC. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController
{
    //ui properties
    @IBOutlet var timezoneTable: WKInterfaceTable!
    
    //properties
    var listOfTimezones:NSArray      = NSArray()
    let timezonesControllerID:String = "timeZoneController"
    
    
    //model
    let timezoneAPI:timezoneModel = timezoneModel()
    
    override init()
    {
        if let timeZonesFromDevice = timezoneAPI.getTimeZones()
        {
            listOfTimezones = timeZonesFromDevice
        }
    }//eo
    
    
    //MARK: - View Loading
    override func awakeWithContext(context: AnyObject?)
    {
        super.awakeWithContext(context)
        
        if let vcID = self.valueForKey("_viewControllerID") as? NSString
        {
            print("page \(vcID)")
        }
        
        
        self.loadTables()
        
    }//eom

    override func willActivate()
    {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
    }//eom

    override func didDeactivate()
    {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
    }//eom
    
 
    //MARK: Table
    override func table(table: WKInterfaceTable,
        didSelectRowAtIndex rowIndex: Int)
    {
        if let currTimeZone:NSDictionary = listOfTimezones .objectAtIndex(rowIndex) as? NSDictionary
        {
            dispatch_async( dispatch_get_main_queue() )
            {
                //self.pushControllerWithName(self.timezonesControllerID, context: currTimeZone)
                
                self.presentControllerWithName(self.timezonesControllerID, context: currTimeZone)
            }
        }//eo-curr time zone
    }//eom
    
    func loadTables()
    {
        //init table setup - rows
        let totalRows = listOfTimezones.count
        
        self.timezoneTable .setNumberOfRows(totalRows, withRowType: "TimeZoneCell")
        
        //pop row data
        for (var iter = 0 ; iter < listOfTimezones.count; iter++)
        {
            if let currRow:timezoneRowController = self.timezoneTable .rowControllerAtIndex(iter) as? timezoneRowController
            {
                if let currTimezone:NSDictionary = listOfTimezones .objectAtIndex(iter) as? NSDictionary
                {
                    //abbrev
                    if let timezoneAbbreviation:String = currTimezone .objectForKey("abbreviation") as? String
                    {
                        currRow.abbreviationLabel.setText(timezoneAbbreviation)
                    }
                    
                    //location
                    if let timezoneLocation:String = currTimezone .objectForKey("location") as? String
                    {
                        currRow.timezoneLocation.setText(timezoneLocation)
                    }
                }//eo-curr time zone
            }//eo-row
        }//eofl
    }//eom
   
    
    
    
   
}//eoc
