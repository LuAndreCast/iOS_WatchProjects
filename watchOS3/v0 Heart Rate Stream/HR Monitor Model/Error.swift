//
//  Error.swift
//  HealthWatchExample
//
//  Created by Luis Castillo on 8/5/16.
//  Copyright © 2016 LC. All rights reserved.
//

import Foundation

struct Errors {
    
    
    //MARK: - HealthStore

    struct healthStore
    {
        static let domain:String = "healthkit.healthStore"
        
        struct avaliableData
        {
            static let code         = 101
            static let description  = [NSLocalizedDescriptionKey : "Health Store Data is Not avaliable"]
        }
    }//eo
    
    struct heartRate
    {
        static let domain:String = "healthkit.heartRate"
        struct quantity
        {
            static let code         = 201
            static let description  = [NSLocalizedDescriptionKey : "un-able to create Heart rate quantity type"]
        }
    }//eo
    
    struct workOut
    {
        static let domain:String = "healthkit.workout"
        struct start
        {
            static let code         = 301
            static let description  = [NSLocalizedDescriptionKey : "un-able to start workout"]
        }
        struct end
        {
            static let code         = 302
            static let description  = [NSLocalizedDescriptionKey : "un-able to end workout"]
        }
    }//eo
    
    
    //MARK: - Monitoring
    struct monitoring
    {
        static let domain:String = ""
        struct type
        {
            static let code = 401
            static let description = [ NSLocalizedDescriptionKey: "un-able to init type"]
        }
        struct query
        {
            static let code = 402
            static let description = [ NSLocalizedDescriptionKey: "un-able to query sample"]
        }
    }
    
    
    //MARK: - WCSESSION
    
    struct wcSession
    {
        static let domain:String = "watchconnectivity.wcession"
        struct supported
        {
            static let code         = 501
            static let description  = [NSLocalizedDescriptionKey : "wcsession is not supported"]
        }
        struct reachable
        {
            static let code         = 502
            static let description  = [NSLocalizedDescriptionKey : "wcsession is not reachable"]
        }
    }//eo
    
}
