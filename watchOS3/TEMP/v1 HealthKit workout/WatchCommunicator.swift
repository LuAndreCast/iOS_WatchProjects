//
//  WatchCommunicator.swift
//  HKworkout
//
//  Created by Luis Castillo on 9/13/16.
//  Copyright © 2016 LC. All rights reserved.
//

import Foundation
import WatchConnectivity


@objc protocol WatchCommunicatorDelegate {
    func watchCommunicator(stateChanged:connectionState)
    func watchCommunicator(messageReceived:[String : Any]) -> [String : Any]
    func watchCommunicator(contextReceived:[String:Any])
}


@available(watchOSApplicationExtension 2.0, *)
class WatchCommunicator:NSObject, WCSessionDelegate
{
    //MARK: - Properties
    let wcSession:WCSession = WCSession.default()

    var delegate:WatchCommunicatorDelegate? = nil
    var pendingStateToSend:[String] = [String]()
    
    
    //MARK: - Setup
    func setup()
    {
        if WCSession.isSupported()
        {
            setupSession()
        }
        else
        {
            delegate?.watchCommunicator(stateChanged: connectionState.notSupported)
        }
    }//eom

    private func setupSession()
    {
        wcSession.delegate = self
        wcSession.activate()
    }//eom
    
    @available(watchOSApplicationExtension 2.2, *)
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?)
    {
        if error != nil
        {
            print("error activationDidCompleteWith \(error?.localizedDescription)")
            delegate?.watchCommunicator(stateChanged: connectionState.unknownActivation)
        }
        else
        {
            switch activationState
            {
                case .activated:
                    delegate?.watchCommunicator(stateChanged: connectionState.activated)
                    
                    /* resending messages */
                    if pendingStateToSend.count > 0
                    {
                        for currState:String in pendingStateToSend
                        {
                            sendState(state: currState)
                        }//eofl
                        
                        pendingStateToSend.removeAll()
                    }

                    
                    break
                case .inactive:
                    delegate?.watchCommunicator(stateChanged: connectionState.inactive)
                    break
                case .notActivated:
                    delegate?.watchCommunicator(stateChanged: connectionState.notActivated)
                    break
            }
        }
    }//eom
    
    //MARK: - States
    func sessionReachabilityDidChange(_ session: WCSession)
    {
        if session.isReachable
        {
            delegate?.watchCommunicator(stateChanged: connectionState.reachable)
        }
        else
        {
            delegate?.watchCommunicator(stateChanged: connectionState.unreachable)
        }
    }//eom
    
    
    //MARK: - Interactive (LIVE) Messaging
    func sendState(state:String,
                   resendAttempt:Bool = false)
    {
        
        let messageToSend = [key_state:state]
        
        if wcSession.isReachable
        {
            wcSession.sendMessage(messageToSend, replyHandler: nil)
        }
        else
        {
            if resendAttempt
            {
                setupSession()
                pendingStateToSend.append(state)
            }
        }
    }//eom
    
    func sendStateWithReply(state:String,
                            replyHander: @escaping ( ([String:Any])->Void),
                            errorHandler: @escaping ( (Error)->Void),
                            resendAttempt:Bool = false)
    {
        
        let messageToSend = [key_state:state]
        
        if wcSession.isReachable
        {
            wcSession.sendMessage(messageToSend, replyHandler: replyHander, errorHandler: errorHandler)
        }
        else
        {
            if resendAttempt
            {
                setupSession()
                pendingStateToSend.append(state)
            }
            else
            {
                errorHandler(error_unreachable)
            }
        }
    }//eom
    
    func sendMessage(messageToSend:[String:Any],
                     replyHander:@escaping (([String:Any])->Void),
                     errorHandler:@escaping ((Error)->Void) )
    {
        if wcSession.isReachable
        {
            wcSession.sendMessage(messageToSend, replyHandler: replyHander, errorHandler: errorHandler)
        }
        else
        {
            errorHandler(error_unreachable)
        }
    }//eom
    
    //MARK: delegates
//    func session(_ session: WCSession,
//                 didReceiveMessage message: [String : Any]) {
//        delegate?.watchCommunicator(messageReceived: message)
//    }//eom
    
    func session(_ session: WCSession,
                 didReceiveMessage message: [String : Any],
                 replyHandler: @escaping ([String : Any]) -> Void) {
        
        if delegate != nil
        {
            let replyMessage:[String : Any] = delegate!.watchCommunicator(messageReceived: message)
            replyHandler(replyMessage)  
            //replyHandler([key_messageDelivery : 1])
        }
        else
        {
            replyHandler([key_messageDelivery : 0])
        }
    }//eom
    
    //MARK: - Application Context
    func sendBackgroundContext(contextToSend:[String:Any], completion:( (Bool)->Void))
    {
        do
        {
            try wcSession.updateApplicationContext(contextToSend)
            completion(true)
        }
        catch
        {
            print("error: \(error)")
            completion(false)
        }
    }//eom
    
    //MARK: delegates
    func session(_ session: WCSession,
                 didReceiveApplicationContext applicationContext: [String : Any])
    {
         delegate?.watchCommunicator(contextReceived: applicationContext)
    }//eom
    
    //MARK: - Transfers
    func session(_ session: WCSession,
                 didFinish fileTransfer: WCSessionFileTransfer,
                 error: Error?) {
        //TODO: update me
    }//eom
    
    func session(_ session: WCSession,
                 didReceive file: WCSessionFile) {
        //TODO: update me
    }//eom
    
    //MARK: - User Info
    func session(_ session: WCSession,
                 didReceiveUserInfo userInfo: [String : Any] = [:]) {
        //TODO: update me
    }//eom
    
    func session(_ session: WCSession,
                 didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
        //TODO: update me
    }//eom
    
    //MARK: - Data
    func session(_ session: WCSession,
                 didReceiveMessageData messageData: Data) {
        //TODO: update me
    }//eom
    
    func session(_ session: WCSession,
                 didReceiveMessageData messageData: Data,
                 replyHandler: @escaping (Data) -> Void)
    {
        //TODO: update me
    }//eom
    
}//eoc
