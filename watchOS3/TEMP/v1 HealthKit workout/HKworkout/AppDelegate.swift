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

    
    //MARK: - Health Store Handler
    func applicationShouldRequestHealthAuthorization(_ application: UIApplication)
    {
        let healthStore:HKHealthStore = HKHealthStore()
        healthStore .handleAuthorizationForExtension(completion:
            { (success:Bool, error:Error?) in
                
                if error != nil
                {
                    print(error?.localizedDescription)
                }
        });
    }//eom
    
    //MARK: - Lifecycle

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        return true
    }//eom

}

