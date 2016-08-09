//
//  CommunicationKeys.swift
//  HealthWatchExample
//
//  Created by Luis Castillo on 8/9/16.
//  Copyright © 2016 LC. All rights reserved.
//

import Foundation

enum keys:Int
{
    case Command
    case HeartRate
    case Time
    case Date
    case Response
    
    func toString()->String
    {
        switch self
        {
            case .Command:
                return "Command"
            case .HeartRate:
                return "HeartRate"
            case .Time:
                return "Time"
            case .Date:
                return "Date"
            case .Response:
                return "Response"
        }
    }
}

enum command:Int
{
    case StartMonitoring
    case EndMonitoring
    
    func toString()->String
    {
        switch self
        {
            case .StartMonitoring:
                return "StartMonitoring"
            case .EndMonitoring:
                return "EndMonitoring"
        }
    }
}

enum response:Int
{
    case Acknowledge
    case Data
    case ErrorMonitoring
    case ErrorHealthKit
    
    func toString()->String
    {
        switch self
        {
            case .Acknowledge:
                return "Acknowledge"
            case .Data:
                return "Data"
            case .ErrorMonitoring:
                return "ErrorMonitoring"
            case .ErrorHealthKit:
                return "ErrorHealthKit"
        }
    }
}