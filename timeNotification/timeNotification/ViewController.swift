//
//  ViewController.swift
//  timeNotification
//
//  Created by Luis Castillo on 1/20/16.
//  Copyright © 2016 LC. All rights reserved.
//

import UIKit

//for sessions
import WatchConnectivity

class ViewController: UIViewController, WCSessionDelegate
{

    //UI Properties
    @IBOutlet weak var totalNotificationsLabel: UILabel!
    @IBOutlet var mainTimezoneButtons: [UIButton]!
    @IBOutlet weak var allTimezoneButton: UIButton!
    
    //properties
    let fireTime:NSTimeInterval = 10
    
    
    //let mainTimezones:[String] = ["AST","EST","CST","PST"]
    
    
    var listOfTimezones:NSArray  = NSArray()
    
    //models
    let timezone:timezoneModel = timezoneModel()
    
    
    let session:WCSession = WCSession.defaultSession()
    
    //MARK: - View Loading
    override func viewDidLoad()
    {
        super.viewDidLoad()
        //session setup
        session.delegate = self
        session.activateSession()
        
        //setting timezones
        if let timezonesObtained = timezone.getTimeZones()
        {
            listOfTimezones = timezonesObtained
            
            //setting buttons
            for (var iter = 0 ;
                (iter < listOfTimezones.count) || (iter < mainTimezoneButtons.count) ;
                iter++ )
            {
                if let currTimezone = listOfTimezones .objectAtIndex(iter) as? NSDictionary
                {
                    let currButton = mainTimezoneButtons[iter]
                    
                    //button title
                    if let currTimezoneAbbrev = currTimezone .objectForKey("abbreviation") as? String
                    {
                        currButton.setTitle(currTimezoneAbbrev, forState: UIControlState.Normal)
                    }
                    
                    //button setup
                    currButton.layer.cornerRadius   = currButton.frame.height/2.0
                    currButton.layer.borderColor    = UIColor.lightGrayColor().CGColor
                    currButton.layer.borderWidth    = 3.5
                }//eo
            }//eofl
            
            //delete all button
            allTimezoneButton.layer.cornerRadius   = allTimezoneButton.frame.height/2.0
            allTimezoneButton.layer.borderColor    = UIColor.lightGrayColor().CGColor
            allTimezoneButton.layer.borderWidth    = 3.5
        }
        
        
        //total count timer setup
        let timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("updateNotificationCount"), userInfo: nil, repeats: true)
        timer.fire()
        
        
    }//eom
    
    override func viewDidAppear(animated: Bool)
    {
        self.updateNotificationCount()
    }//eom
    
    //MARK: - UISetup
    
    func updateNotificationCount()
    {
        let totalCount:Int? =  UIApplication.sharedApplication().scheduledLocalNotifications?.count
        
        if let count:Int = totalCount
        {
            self.totalNotificationsLabel.text = "\(count) Notifications"
        }
        else
        {
            self.totalNotificationsLabel.text = "UNK Notifications"
        }
    }//eom
    
    
    //MARK: - Notifications
    func deleteAllNotifications()
    {
        UIApplication.sharedApplication().scheduledLocalNotifications?.removeAll()
        
        self.updateNotificationCount()
    }//eom
    
    func scheduleNotification(titleDesired:String, actionDesired:String, bodyDesired: String)
    {
        let localNotification = UILocalNotification()
        
        //title
        if titleDesired.isEmpty
        {
            localNotification.alertTitle = "Timezone info:"
        }
        else
        {
            localNotification.alertTitle = titleDesired
        }
        
        //action
        if titleDesired.isEmpty
        {
            localNotification.alertAction = "Notification"
        }
        else
        {
            localNotification.alertAction = actionDesired
        }
        
        
        localNotification.category  = "myTimezone"
        localNotification.alertBody = bodyDesired
        
        localNotification.fireDate = NSDate(timeIntervalSinceNow: fireTime)
        
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        
    }//eom
    
    func scheduleAllNotifications()
    {
        let allTimeZonesAbbrev = NSTimeZone .abbreviationDictionary()
        for currTimezoneAbbrev in allTimeZonesAbbrev
        {
            let time = timezone.getTimeZoneByAbbrev(currTimezoneAbbrev.0 as String)
            let title = "\(currTimezoneAbbrev.1)"
            let message = "\(currTimezoneAbbrev.0) : \(time)"
            
            self.scheduleNotification(title, actionDesired: "", bodyDesired: message)
        }//eofl
        
        self.updateNotificationCount()
    }//eom

  
    @IBAction func deleteAllNotifications(sender: AnyObject)
    {
        self.deleteAllNotifications()
    }//eo-a
    
    //MARK: - Custom Timezone Actions
    @IBAction func sendATimezone(sender: AnyObject)
    {
        let tagNum:Int = sender.tag
        
        //valid button
        if (tagNum < mainTimezoneButtons.count) && (tagNum < listOfTimezones.count)
        {
            //timezone info
            if let currTimezone = listOfTimezones .objectAtIndex(tagNum) as? NSDictionary
            {
                var title:String    = ""
                var body:String     = ""
                
                //abbreviation - body
                if let timezoneAbbrev:String = currTimezone .objectForKey("abbreviation") as? String
                {
                    body = timezoneAbbrev
                }
                
                //location - title
                if let timezoneLocation:String = currTimezone .objectForKey("location")as? String
                {
                    title = timezoneLocation
                }
                
                
                let time    = timezone.getTimeZoneByAbbrev(body)
                let message = "\(body) : \(time)"
                
                self.scheduleNotification(title, actionDesired: "", bodyDesired: message)
                
            }//eo-timezone
        }
    }//eo-a
    
    
    @IBAction func scheduleAllNotifications(sender: AnyObject)
    {
            self.scheduleAllNotifications()
    }//eo-a
    
    
    //MARK: - Session Delegates
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject])
    {
        guard message["request"] as? String == "fireLocalNotification" else {  return }
        
        if let desiredTimeZoneAbbrev = message["timezone"] as? String
        {
            let time = timezone.getTimeZoneByAbbrev(desiredTimeZoneAbbrev)
            let message = "\(desiredTimeZoneAbbrev) : \(time)"
            
            self.scheduleNotification("", actionDesired: "", bodyDesired: message)
        }
    }//eom
    
    
    //MARK: - Memory
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }//eom
    
    
}//eoc


