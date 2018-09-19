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
    func watchMessenger_startResults(_ started:Bool, error:NSError?)
    
    /* Interactive messaging */
    func watchMessenger_didReceiveMessage(_ message:[String:AnyObject])
}


@objc
class WatchMessenger: NSObject, WCSessionDelegate
{

    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(watchOS 2.2, *)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    static let shared = WatchMessenger()
    
    var delegate:watchMessengerDelegate?
    
    fileprivate let session:WCSession = WCSession.default()
    
    
    //MARK: - Start
    func start()
    {
        if WCSession.isSupported()
        {
            self.session .delegate = self
            self.session .activate()
            
            if verbose {  print("[\(self.debugDescription)] started successfully") }//debug
            
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
    func sendMessage(_ messageToSend:[String:AnyObject],
                     completionHandler:@escaping ([String : Any]?, Error?)->Void)
    {
        //watch can be reached?
        guard self.session .isReachable
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
            { (replyFromWatch:[String : Any]) in
                
                if verbose {  print("[\(self)] reply message : \(replyFromWatch) | message sent: \(messageToSend)") }//debug
                
             completionHandler(replyFromWatch, nil)
            },
            //error
            errorHandler: { (error:Error) in
                
                if verbose {  print("[\(self)] error message : \(error) | message sent: \(messageToSend) ") }//debug
                
                completionHandler(nil, error)
            })
    }//eom
    
    func session(_ session: WCSession,
                 didReceiveMessage message: [String : Any],
                                   replyHandler: @escaping ([String : Any]) -> Void)
    {
        if verbose {  print("[\(self)] message received: \(message)") }//debug
        
        self.delegate?.watchMessenger_didReceiveMessage(message as [String : AnyObject])
        
        let message:[String:AnyObject] = [keys.response.toString(): response.acknowledge.toString() as AnyObject]
        
        replyHandler(message)
    }//eom

    
}//eoc
