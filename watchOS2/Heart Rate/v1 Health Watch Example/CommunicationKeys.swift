//
//  CommunicationKeys.swift
//  HealthWatchExample
//
//  Created by Luis Castillo on 2/5/16.
//  Copyright © 2016 LC. All rights reserved.
//

enum keys:String
{
    case Command        = "command"
    case Ack            = "ack"
    case heartRate      = "heartRate"
    case time           = "time"
    case date           = "date"
}//eo


enum command:String
{
    case SendStatus     = "sendStatus"
    case StartUpdating  = "startUpdating"
    case StopUpdating   = "stopUpdating"
}//eo
