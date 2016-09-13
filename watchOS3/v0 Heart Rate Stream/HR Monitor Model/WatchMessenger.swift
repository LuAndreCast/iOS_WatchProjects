//
//  PhoneMessenger.swift
//  HealthWatchExample
//
//  Created by Luis Castillo on 8/5/16.
//  Copyright © 2016 LC. All rights reserved.
//

import Foundation
import WatchConnectivity

@objc
protocol watchMessengerDelegate
{
    /* Activation */
    func watchMessenger_startResults(error:NSError?)
    
    @available(iOS 9.3, watchOSApplicationExtension 2.2, *)
    optional func watchMessenger_activationCompletedWithState(activationState: WCSessionActivationState, error: NSError?)
    
    /* Watch Only */
    #if os(watchOS)
    @available(watchOSApplicationExtension 2.2 , *)
    optional func watchMessenger_sessionStateChanged(state: WCSessionActivationState)
    optional func watchMessenger_watchStatesChanged(states:NSDictionary)
    #endif
    
    /* iphone Only */
    
    
    /* Reachability */
    func watchMessenger_reachabilityStateChanged(reachable:Bool)
    
    /* Interactive messaging */
    func watchMessenger_didReceiveMessage(message:[String:AnyObject])

}//eo-delegate


@objc
class WatchMessenger: NSObject, WCSessionDelegate
{
    static let shared = WatchMessenger()
    
    var delegate:watchMessengerDelegate?
    
    private let session:WCSession = WCSession.defaultSession()
    
    func getSessionInfo()->NSDictionary
    {
        var activationState = "' '"
        var reachableState = "' '"
        var pairedState = "' '"
        var watchAppInstalledState = "' '"
        
        if #available(iOS 9.3, *)
        {
            if #available(watchOSApplicationExtension 2.2, *) {
                switch self.session.activationState
                {
                case .NotActivated:
                    activationState = "'NotActivated'"
                    break
                case .Inactive:
                    activationState = "'Inactive'"
                    break
                case .Activated:
                    activationState = "'Activated'"
                    break
                }
            }
            
            #if os(iOS)
                watchAppInstalledState = self.session.watchAppInstalled ? "Yes" : "No"
                pairedState = self.session.paired ? "Yes" : "No"
            #endif
        }
            reachableState = self.session.reachable ? "Yes" : "No"
            
        #if DEBUG
            print("activation? \(activationState)")
            print("Reachable? \(reachableState)")
            print("Watch App Installed? \(watchAppInstalledState)")
            print("Paired? \(pairedState)")
        #endif
        
        let states:NSDictionary = [
            "activation":activationState,
            "reachable":reachableState,
            "paired":pairedState,
            "watchAppInstalled":watchAppInstalledState
        ]
        
        return states;
    }//eom
    
    //MARK: - Start
    func start()
    {
        if WCSession.isSupported()
        {
            self.session .delegate = self
            self.session .activateSession()

            self.delegate?.watchMessenger_startResults(nil)
        }
        else
        {
            //notify listener
            let error = NSError(domain: Errors.wcSession.domain, code: Errors.wcSession.supported.code, userInfo:Errors.wcSession.supported.description )
            
            #if DEBUG
                print("[\(self)] error : \(error)")
            #endif
            
            self.delegate?.watchMessenger_startResults(error)
        }
    }//eom
    
    //MARK: - Activation
    @available(iOS 9.3, watchOSApplicationExtension 2.2, *)
    func session(session: WCSession, activationDidCompleteWithState activationState: WCSessionActivationState, error: NSError?)
    {
        self.delegate?.watchMessenger_activationCompletedWithState!(activationState, error: error)
        
        #if DEBUG
            var state = "''"
            switch activationState {
            case .NotActivated:
                state = "'NotActivated'"
                break
            case .Inactive:
                state = "'Inactive'"
                break
            case .Activated:
                state = "'Activated'"
                break
            }
            print("[\(self)] activationDidCompleteWithState: \(state)")
        #endif
    }//eom
    
    //MARK: - Watch Only 
    //MARK: iOS States for watch
        func sessionWatchStateDidChange(session: WCSession)
        {
            let states:NSDictionary = self .getSessionInfo();
            #if os(watchOS)
                self.delegate?.watchMessenger_watchStatesChanged!(states)
            #endif
        }//eom
        
        @available(watchOSApplicationExtension 2.0 , *)
        func sessionDidDeactivate(session: WCSession)
        {
            #if os(watchOS)
                if #available(watchOSApplicationExtension 2.2, *)
                {
                    self.delegate?.watchMessenger_sessionStateChanged!(WCSessionActivationState.NotActivated)
                }
                else
                {
                    // TODO: Fallback on earlier versions
                }
            #endif
            
            #if DEBUG
                print("[\(self)] sessionDidDeactivate")
            #endif
        }//eom
        
        @available(watchOSApplicationExtension 2.0 , *)
        func sessionDidBecomeInactive(session: WCSession)
        {
            #if os(watchOS)
                if #available(watchOSApplicationExtension 2.2, *)
                {
                    self.delegate?.watchMessenger_sessionStateChanged!(WCSessionActivationState.Inactive)
                }
                else
                {
                    //TODO: Fallback on earlier versions
                }
            #endif
            
            #if DEBUG
                print("[\(self)] sessionDidBecomeInactive")
            #endif
        }//eom
    
    //MARK: - Session Reachability
    func sessionReachabilityDidChange(session: WCSession)
    {
        self.delegate?.watchMessenger_reachabilityStateChanged(session.reachable)
        
        #if DEBUG
            let reachableState = session.reachable ? "Yes" : "No"
            print("[\(self)] Reachable? \(reachableState)")
        #endif
    }//eom

    //MARK: - Interactive Messaging
    func sendMessage(messageToSend:[String:AnyObject],
                     completionHandler:([String : AnyObject]?, NSError?)->Void)
    {
        //watch can be reached?
        guard self.session .reachable
            else {
                
                //notify listener
                let error = NSError(domain: Errors.wcSession.domain, code: Errors.wcSession.reachable.code, userInfo:Errors.wcSession.reachable.description )
               
                #if DEBUG
                    print("[\(self)] error : \(error)")
                #endif
                
                completionHandler(nil, error)
                
                return
        }
        
        //send & recieve message
        self.session .sendMessage(messageToSend, replyHandler:
            //reponse
            { (replyFromWatch:[String : AnyObject]) in
                #if DEBUG
                    print("[\(self)] reply message : \(replyFromWatch) | message sent: \(messageToSend)")
                #endif
             completionHandler(replyFromWatch, nil)
            },
            //error
            errorHandler: { (error:NSError) in
                #if DEBUG
                     print("[\(self)] error message : \(error) | message sent: \(messageToSend) ")
                #endif
                
                completionHandler(nil, error)
            })
    }//eom
    
    func session(session: WCSession,
                 didReceiveMessage message: [String : AnyObject],
                                   replyHandler: ([String : AnyObject]) -> Void)
    {
        #if DEBUG
            print("[\(self)] message received: \(message)")
        #endif
        
        self.delegate?.watchMessenger_didReceiveMessage(message)
        
        let message:[String:AnyObject] = [keys.Response.toString(): response.Acknowledge.toString()]
        
        replyHandler(message)
    }//eom
    
    //MARK: - Application Context
    func session(session: WCSession,
         didReceiveApplicationContext applicationContext: [String : AnyObject])
    {
        //TODO: Future release
    }//eom
    
    //MARK: - File
    func session(session: WCSession,
                 didReceiveFile file: WCSessionFile)
    {
        //TODO: Future release
        
    }//eom
    
    func session(session: WCSession,
         didFinishFileTransfer fileTransfer: WCSessionFileTransfer,
                               error: NSError?)
    {
        //TODO: Future release
        
    }//eom
    
    //MARK: - Data
    func session(session: WCSession,
                 didReceiveMessageData messageData: NSData)
    {
        //TODO: Future release
        
    }//eom
    
    func session(session: WCSession,
         didReceiveMessageData messageData: NSData,
        replyHandler: (NSData) -> Void)
    {
        //TODO: Future release
        
    }//eom
    
    //MARK: - User Info
    func session(session: WCSession,
         didReceiveUserInfo userInfo: [String : AnyObject]) {
        
        //TODO: Future release
    }//eom
    
    func session(session: WCSession,
     didFinishUserInfoTransfer userInfoTransfer: WCSessionUserInfoTransfer,
                               error: NSError?) {
        
        //TODO: Future release
    }//eom

}//eoc
