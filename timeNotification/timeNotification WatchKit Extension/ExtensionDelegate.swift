//
//  ExtensionDelegate.swift
//  timeNotification WatchKit Extension
//
//  Created by Luis Castillo on 1/20/16.
//  Copyright © 2016 LC. All rights reserved.
//

import WatchKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {

    
    func applicationDidFinishLaunching()
    {
        // Perform any final initialization of your application.
    }//eom

    func applicationDidBecomeActive()
    {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }//eom

    func applicationWillResignActive()
    {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }//eom
    
    
//    //MARK: - Local Notifications
//    func didReceiveLocalNotification(notification: UILocalNotification)
//    {
////        print("[watch extension] didReceiveLocalNotification \(notification)")
////        print(notification.alertTitle)
////        print(notification.alertBody)
//        
//    }//eo
//    
//    //MARK: Local Actions
//    
//    func handleActionWithIdentifier(identifier: String?, forLocalNotification localNotification: UILocalNotification) {
//        
//    }//eom
//    
//    func handleActionWithIdentifier(identifier: String?, forLocalNotification localNotification: UILocalNotification, withResponseInfo responseInfo: [NSObject : AnyObject])
//    {
//        
//    }//eom
//    
//    //MARK: - Remote Notifications
//    
//    func didReceiveRemoteNotification(userInfo: [NSObject : AnyObject])
//    {
//        
//        print("[watch extension] didReceiveRemoteNotification \(userInfo)")
//    }//eo
//
//    //MARK: Remote Actions
//    
//    func handleActionWithIdentifier(identifier: String?, forRemoteNotification remoteNotification: [NSObject : AnyObject]) {
//        
//    }//eom
//    
//    func handleActionWithIdentifier(identifier: String?,
//                    forRemoteNotification remoteNotification: [NSObject : AnyObject],
//                                    withResponseInfo responseInfo: [NSObject : AnyObject])
//    {
//        
//    }//eom
}
