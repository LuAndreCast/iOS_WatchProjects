//
//  ExtensionDelegate.swift
//  HealthWatchExample WatchKit Extension
//
//  Created by Luis Castillo on 2/2/16.
//  Copyright © 2016 LC. All rights reserved.
//


import Foundation
import WatchKit
import HealthKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {

    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

    @available(watchOSApplicationExtension 3.0, *)
    func handle( workoutConfiguration: HKWorkoutConfiguration)
    {
        WKInterfaceController.reloadRootControllersWithNames(["MainInterfaceController"], contexts: nil)
    }//eom
    
}//eoc