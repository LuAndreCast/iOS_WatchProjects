//
//  NotificationController.swift
//  timeNotification WatchKit Extension
//
//  Created by Luis Castillo on 1/20/16.
//  Copyright © 2016 LC. All rights reserved.
//

import WatchKit
import Foundation


class NotificationController: WKUserNotificationInterfaceController {

    //UI Properties
    @IBOutlet var alertTitleLabel: WKInterfaceLabel!
    @IBOutlet var alertBodyLabel: WKInterfaceLabel!
    
    
    //models
    let timezone:timezoneModel = timezoneModel()
    
    //MARK: - Init
    override init() {
        // Initialize variables here.
        super.init()
        
        // Configure interface objects here.
    }//eom

     //MARK: - View Loading
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

     //MARK: - Local Notifications
    override func didReceiveLocalNotification(localNotification: UILocalNotification,
                                        withCompletion completionHandler: ((WKUserNotificationInterfaceType) -> Void))
    {
        // This method is called when a local notification needs to be presented.
        // Implement it if you use a dynamic notification interface.
        // Populate your dynamic notification interface as quickly as possible.
        //
        
        //title
        self.alertTitleLabel.setText(localNotification.alertTitle)
        self.alertBodyLabel.setText(localNotification.alertBody)
        
        // After populating your dynamic notification interface call the completion block.
        completionHandler(.Custom)
    }//eom
    
    
    //MARK: - Remote Notifications
    override func didReceiveRemoteNotification(remoteNotification: [NSObject : AnyObject], withCompletion completionHandler: ((WKUserNotificationInterfaceType) -> Void)) {
        // This method is called when a remote notification needs to be presented.
        // Implement it if you use a dynamic notification interface.
        // Populate your dynamic notification interface as quickly as possible.

        
        if let remoteAps:NSDictionary = remoteNotification["aps"] as? NSDictionary
        {
            if let remoteAlert = remoteAps["alert"] as? NSDictionary
            {
                self.handleNotification(remoteAlert)
            }
        }
        
        // After populating your dynamic notification interface call the completion block.
        completionHandler(.Custom)
    }//eom
    
    func handleNotification( alert : AnyObject? )
    {
        //title
        if let alert:AnyObject = alert , let remoteTitle = alert["title"] as? String
        {
            self.alertTitleLabel.setHidden(false)
            print("didReceiverRemoteNotification :: remoteTitle  \(remoteTitle)")
            self.alertTitleLabel.setText(remoteTitle)
        }
        else
        {
            self.alertTitleLabel.setHidden(true)
        }
        
        //body
        if let alert:AnyObject = alert , let remoteBody = alert["body"] as? String
        {
            self.alertBodyLabel.setHidden(false)
            print("didReceiverRemoteNotification :: remoteBody \(remoteBody)")
            self.alertBodyLabel.setText(remoteBody)
        }
        else
        {
            self.alertBodyLabel.setHidden(true)
        }
    }//eom
    
    
    //MARK: - Update Time Labels
//    func updateAllTimezones()
//    {
//        self.bodyLabel.setHidden(true)
//        
//        //AST
//        var time = ""
//        time = timezone.getTimeZoneByAbbrev("AST")
//        self.ast_Label.setText(time)
//        self.ast_Label.setHidden(false)
//        
//        //EST
//        time = ""
//        time = timezone.getTimeZoneByAbbrev("EST")
//        self.est_Label.setText(time)
//        self.est_Label.setHidden(false)
//        
//        //CST
//        time = ""
//        time = timezone.getTimeZoneByAbbrev("CST")
//        self.cst_Label.setText(time)
//        self.cst_Label.setHidden(false)
//        
//        //PST
//        time = ""
//        time = timezone.getTimeZoneByAbbrev("PST")
//        self.pst_Label.setText(time)
//        self.pst_Label.setHidden(false)
//        
//    }//eom
//
   
    
}//eoc
