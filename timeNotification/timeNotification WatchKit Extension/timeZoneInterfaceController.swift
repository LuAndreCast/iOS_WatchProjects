//
//  timeZoneInterfaceController.swift
//  timeNotification
//
//  Created by Luis Castillo on 1/21/16.
//  Copyright © 2016 LC. All rights reserved.
//

import WatchKit
import Foundation

//for sessions
import WatchConnectivity


class timeZoneInterfaceController: WKInterfaceController, WCSessionDelegate
{
    //ui properties
    @IBOutlet var timeZoneAbbrevLabel: WKInterfaceLabel!
    @IBOutlet var timeZoneLocationLabel: WKInterfaceLabel!
    @IBOutlet var timeLabel: WKInterfaceLabel!
    @IBOutlet var scheduleNotficationButton: WKInterfaceButton!
    
    //properties
    var timezoneAbbreviation:String = String()
    var timezoneLocation:String     = String()
    
    
    let session:WCSession = WCSession.defaultSession()
    
    //models
    let timezone:timezoneModel = timezoneModel()
    
    //MARK: View Loading
    override func awakeWithContext(context: AnyObject?)
    {
        super.awakeWithContext(context)
        
        //sessions
        session.delegate = self
        session.activateSession()
        
        //
        self.initalTimezoneSetup(context)
        
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
    
    //MARK: Initial Setup
    func initalTimezoneSetup(context:AnyObject?)
    {
        if let currTimeZone:NSDictionary = context as? NSDictionary
        {
            //location
            if let location:String = currTimeZone .objectForKey("location") as? String
            {
                self.timezoneLocation = location
                self.timeZoneLocationLabel.setText(location)
            }
            
            //abbrev
            if let timezoneAbbrev:String = currTimeZone .objectForKey("abbreviation") as? String
            {
                self.timezoneAbbreviation = timezoneAbbrev
                self.timeZoneAbbrevLabel.setText(timezoneAbbrev)
            }
            
            //timezone
            if let timezone:String = currTimeZone .objectForKey("timezone") as? String
            {
                //self.setTitle(timezone)
            }
            
        }//eo-valid data
        
        self.updateTime()
        self.setupTimer()
        
    }//eom
    
    //MARK: Update Data
    func updateTime()
    {
        let time =   timezone.getTimeZoneByAbbrev(timezoneAbbreviation)
        self.timeLabel.setText(time)
    }//eom

    
    //MARK: - setting up timer
    func setupTimer()
    {
        let timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("updateTime"), userInfo: nil, repeats: true)
        timer.fire()
    }//eom
    
    
    //MARK: Notification
    
    @IBAction func scheduleNotification()
    {
        self.initateTimezoneNotificationFromPhone(self.timezoneAbbreviation)
        
        self.scheduleNotficationButton.setTitle("Scheduled")
        self.scheduleNotficationButton.setBackgroundColor(UIColor.grayColor())
    }//eo-a
    
    
    /*sends a message to the phone , to schedule a notification */
    func initateTimezoneNotificationFromPhone(timezoneAbbrev:String)
    {
        let message = ["request" : "fireLocalNotification" , "timezone" : timezoneAbbrev]
        WCSession.defaultSession().sendMessage(message,
                                                replyHandler: nil,
                                                errorHandler: {
                                                                error in
                                                            print(error.localizedDescription)
                                                })
    }//eom
    
    
    
}//eoc
