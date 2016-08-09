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
    func watchMessenger_startResults(started:Bool, error:NSError?)
    
    /* Interactive messaging */
    func watchMessenger_didReceiveMessage(message:[String:AnyObject])
    optional func watchMessenger_reachabilityStatusChanged(isReachable:Bool)
}


@objc
class WatchMessenger: NSObject, WCSessionDelegate
{
    static let shared = WatchMessenger()
    
    var delegate:watchMessengerDelegate?
    
    private let session:WCSession = WCSession.defaultSession()
    
    
    //MARK: - Start
    func start()
    {
        if WCSession.isSupported()
        {
            self.session .delegate = self
            self.session .activateSession()
            
            if verbose {  print("[\(self)] started successfully") }//debug
            
            //notify listener
            self.delegate?.watchMessenger_startResults(true, error: nil)
        }
        else
        {
            //notify listener
            let error = NSError(domain: Errors.wcSession.domain, code: Errors.wcSession.supported.code, userInfo:Errors.wcSession.supported.description )
            
            if verbose {  print("[\(self)] error : \(error)") }//debug
            
            self.delegate?.watchMessenger_startResults(false, error: error)
        }
    }//eom
    
    
    //MARK: Interactive Messaging
    func sendMessage(messageToSend:[String:AnyObject],
                     completionHandler:([String : AnyObject]?, NSError?)->Void)
    {
        //watch can be reached?
        guard self.session .reachable
            else {
                
                //notify listener
                let error = NSError(domain: Errors.wcSession.domain, code: Errors.wcSession.reachable.code, userInfo:Errors.wcSession.reachable.description )
               
                if verbose {  print("[\(self)] error : \(error)") }//debug
                
                completionHandler(nil, error)
                
                return
        }
        
        //send & recieve message
        self.session .sendMessage(messageToSend, replyHandler:
            //reponse
            { (replyFromWatch:[String : AnyObject]) in
                
                if verbose {  print("[\(self)] reply message : \(replyFromWatch) | message sent: \(messageToSend)") }//debug
                
             completionHandler(replyFromWatch, nil)
            },
            //error
            errorHandler: { (error:NSError) in
                
                if verbose {  print("[\(self)] error message : \(error) | message sent: \(messageToSend) ") }//debug
                
                completionHandler(nil, error)
            })
    }//eom
    
    func session(session: WCSession,
                 didReceiveMessage message: [String : AnyObject],
                                   replyHandler: ([String : AnyObject]) -> Void)
    {
        if verbose {  print("[\(self)] message received: \(message)") }//debug
        
        self.delegate?.watchMessenger_didReceiveMessage(message)
        
        let message:[String:AnyObject] = [keys.Response.toString(): response.Acknowledge.toString()]
        
        replyHandler(message)
    }//eom

    
}//eoc