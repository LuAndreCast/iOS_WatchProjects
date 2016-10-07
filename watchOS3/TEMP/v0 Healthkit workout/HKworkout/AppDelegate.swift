//
//  AppDelegate.swift
//  HKworkout
//
//  Created by Luis Castillo on 9/12/16.
//  Copyright © 2016 LC. All rights reserved.
//

import UIKit

import HealthKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    
    let hkStore:HKHealthStore = HKHealthStore()
    
    
    //MARK: - Lifecycle

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        return true
    }//eom

    
    func applicationShouldRequestHealthAuthorization(_ application: UIApplication)
    {
        hkStore .handleAuthorizationForExtension
            { (success:Bool, error:Error?) in
            
                if error != nil
                {
                    print(error?.localizedDescription)
                }
        }
    }//eom

}

