//
//  CommunicatorUtilities.swift
//  HKworkout
//
//  Created by Luis Castillo on 9/13/16.
//  Copyright © 2016 LC. All rights reserved.
//

import Foundation


//MARK: - Keys
let key_state:String = "State"
let key_messageDelivery:String = "messageDelivery"

//MARK: - Errors
let error_unreachable = NSError(domain: "unreachable device", code: 900, userInfo: nil)

//MARK: - States
@objc enum connectionState:Int {
    case notSupported
    case activated
    case notActivated
    case deactivated
    case inactive
    case reachable
    case unreachable
    case unknownActivation
    
    func toString()->String
    {
        switch self {
            case .notSupported:
                return "notSupported"
            case .activated:
                return "activated"
            case .notActivated:
                return "notActivated"
            case .deactivated:
                return "deactivated"
            case .inactive:
                return "inactive"
            case .reachable:
                return "reachable"
            case .unreachable:
                return "unreachable"
            case .unknownActivation:
                return "unknownActivation"
        }
    }//eom
}


//MARK: Watch States
@objc class watchStates:NSObject
{
    var isReachable:Bool = false
    var isPaired:Bool = false
    var isWatchAppInstalled:Bool = false
    
    var hasContentPending:Bool = false
    var isComplicationEnabled:Bool = false
    var state:connectionState = connectionState.unknownActivation
    
}//eoc
