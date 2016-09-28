//
//  PhoneCommunicator.swift
//  HKworkout
//
//  Created by Luis Castillo on 9/13/16.
//  Copyright © 2016 LC. All rights reserved.
//

import Foundation
import WatchConnectivity

//MARK: - PhoneCommunicatorDelegate
@objc protocol PhoneCommunicatorDelegate {
    func phoneCommunicator(watchStatesChanged:watchStates)
    func phoneCommunicator(stateChanged:connectionState)
    func phoneCommunicator(messageReceived:[String:Any]) -> [String : Any]
    func phoneCommunicator(contextReceived:[String:Any])
}


@available(iOS 9.0, *)
@objc class PhoneCommunicator:NSObject, WCSessionDelegate
{
    //MARK: - Properties
    let wcSession:WCSession = WCSession.default()
    
    var delegate:PhoneCommunicatorDelegate? = nil
    var pendingStateToSend:[String] = [String]()
    
    //MARK: - Setup
    func setup()
    {
        if WCSession.isSupported()
        {
            self.setupSession()
        }
        else
        {
            delegate?.phoneCommunicator(stateChanged: connectionState.notSupported)
        }
    }//eom
    
    private func setupSession()
    {
        wcSession.delegate = self
        wcSession.activate()
    }//eom
    
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?)
    {
        if error != nil
        {
            print("error activationDidCompleteWith \(error?.localizedDescription)")
            delegate?.phoneCommunicator(stateChanged: connectionState.unknownActivation)
        }
        else
        {
            switch activationState
            {
                case .activated:
                    delegate?.phoneCommunicator(stateChanged: connectionState.activated)
                    
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
                    delegate?.phoneCommunicator(stateChanged: connectionState.inactive)
                    break
                case .notActivated:
                    delegate?.phoneCommunicator(stateChanged: connectionState.notActivated)
                    break
            }
        }
    }//eom
    
    //MARK: - Watch States
    func getWatchStates()->watchStates
    {
        let updatedStates:watchStates = getWatchStates(sessionProvided: nil)
        return updatedStates
    }//eom
    
    private func getWatchStates(sessionProvided: WCSession?)->watchStates
    {
        var sessionChecking:WCSession = wcSession
        if sessionProvided != nil  {  sessionChecking = sessionProvided!  }
        
        let watchState:watchStates = watchStates()
        watchState.hasContentPending = sessionChecking.hasContentPending
        watchState.isComplicationEnabled = sessionChecking.isComplicationEnabled
        watchState.isPaired = sessionChecking.isPaired
        watchState.isReachable = sessionChecking.isReachable
        watchState.isWatchAppInstalled = sessionChecking.isWatchAppInstalled
        
        let watchActivateState = sessionChecking.activationState
        switch watchActivateState
        {
        case .activated:
            watchState.state = connectionState.activated
            break
        case .notActivated:
            watchState.state = connectionState.notActivated
            break
        case .inactive:
            watchState.state = connectionState.inactive
            break
        }
        
        return watchState
    }//eom

    
    //MARK: - States
    func sessionDidDeactivate(_ session: WCSession) {
        /* The `sessionDidDeactivate(_:)` callback indicates `WCSession` is finished delivering content to
         the iOS app. iOS apps that process content delivered from their Watch Extension should finish
         processing that content and call `activateSession()`. */
        
        delegate?.phoneCommunicator(stateChanged: connectionState.deactivated)
    }//eom
    
    func sessionDidBecomeInactive(_ session: WCSession)
    {
        /*  The `sessionDidBecomeInactive(_:)` callback indicates sending has been disabled. If your iOS app
         sends content to its Watch extension it will need to stop trying at this point. */
        delegate?.phoneCommunicator(stateChanged: connectionState.inactive)
    }//eom
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        if session.isReachable
        {
            delegate?.phoneCommunicator(stateChanged: connectionState.reachable)
        }
        else
        {
            delegate?.phoneCommunicator(stateChanged: connectionState.unreachable)
        }
    }//eom
    
    func sessionWatchStateDidChange(_ session: WCSession)
    {
        let updatedStates = getWatchStates(sessionProvided: session)
        
        delegate?.phoneCommunicator(watchStatesChanged: updatedStates)
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
            replyHander(["Reachable" : "False"])
            errorHandler(error_unreachable)
        }
    }//eom
    
    //MARK: delegates
//    func session(_ session: WCSession,
//                 didReceiveMessage message: [String : Any]) {
//        delegate?.phoneCommunicator(messageReceived: message)
//    }//eom
    
    func session(_ session: WCSession,
                 didReceiveMessage message: [String : Any],
                 replyHandler: @escaping ([String : Any]) -> Void) {
        
        if delegate != nil
        {
            let replyMessage:[String : Any] = delegate!.phoneCommunicator(messageReceived: message)
//            replyHandler([key_messageDelivery : 1])
            replyHandler(replyMessage)
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
        delegate?.phoneCommunicator(contextReceived: applicationContext)
    }//eom
    
    //MARK: - Transfers
    func session(_ session: WCSession,
                 didFinish fileTransfer: WCSessionFileTransfer, error: Error?)
    {
    }//eom
    
    func session(_ session: WCSession,
                 didReceive file: WCSessionFile)
    {
    }//eom
    
    //MARK: - User Info
    func session(_ session: WCSession,
                 didReceiveUserInfo userInfo: [String : Any] = [:])
    {
        //TODO: update me
    }
    
    func session(_ session: WCSession,
                 didFinish userInfoTransfer: WCSessionUserInfoTransfer,
                 error: Error?)
    {
    }//eom
    
    //MARK: - Data
    func session(_ session: WCSession,
                 didReceiveMessageData messageData: Data)
    {
    }//eom
    
    func session(_ session: WCSession,
                 didReceiveMessageData messageData: Data,
                 replyHandler: @escaping (Data) -> Void)
    {
    }//eom
    
    
}//eoc
