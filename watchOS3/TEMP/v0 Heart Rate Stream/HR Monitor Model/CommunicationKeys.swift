//
//  CommunicationKeys.swift
//  HealthWatchExample
//
//  Created by Luis Castillo on 8/9/16.
//  Copyright © 2016 LC. All rights reserved.
//

import Foundation

@objc enum keys:Int
{
    case Command
    case HeartRate
    case Time
    case Date
    case Response
    case ErrorDescription
    
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
        case .ErrorDescription:
            return "ErrorDescription"
        }
    }
}

@objc enum command:Int
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

@objc enum response:Int
{
    case Acknowledge
    case Data
    case StartedMonitoring
    case EndedMonitoring
    case ErrorMonitoring
    case ErrorWorkout
    case ErrorHealthKit
    
    func toString()->String
    {
        switch self
        {
        case .Acknowledge:
            return "Acknowledge"
        case .StartedMonitoring:
            return "StartedMonitoring"
        case .EndedMonitoring:
            return "EndedMonitoring"
        case .Data:
            return "Data"
        case .ErrorMonitoring:
            return "ErrorMonitoring"
        case .ErrorWorkout:
            return "ErrorWorkout"
        case .ErrorHealthKit:
            return "ErrorHealthKit"
        }
    }
}
