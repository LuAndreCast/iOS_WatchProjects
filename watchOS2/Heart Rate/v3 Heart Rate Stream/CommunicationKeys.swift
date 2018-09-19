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
    case command
    case heartRate
    case time
    case date
    case response
    
    func toString()->String
    {
        switch self
        {
        case .command:
            return "Command"
        case .heartRate:
            return "HeartRate"
        case .time:
            return "Time"
        case .date:
            return "Date"
        case .response:
            return "Response"
        }
    }
}

@objc enum command:Int
{
    case startMonitoring
    case endMonitoring
    
    func toString()->String
    {
        switch self
        {
        case .startMonitoring:
            return "StartMonitoring"
        case .endMonitoring:
            return "EndMonitoring"
        }
    }
}

@objc enum response:Int
{
    case acknowledge
    case data
    case startedMonitoring
    case endedMonitoring
    case errorMonitoring
    case errorHealthKit
    
    func toString()->String
    {
        switch self
        {
        case .acknowledge:
            return "Acknowledge"
        case .startedMonitoring:
            return "StartedMonitoring"
        case .endedMonitoring:
            return "EndedMonitoring"
        case .data:
            return "Data"
        case .errorMonitoring:
            return "ErrorMonitoring"
        case .errorHealthKit:
            return "ErrorHealthKit"
        }
    }
}
