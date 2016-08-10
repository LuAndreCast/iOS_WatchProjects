//
//  MainInterfaceController.swift
//  HealthWatchExample
//
//  Created by Luis Castillo on 8/5/16.
//  Copyright © 2016 LC. All rights reserved.
//

import WatchKit
import Foundation


class MainInterfaceController: WKInterfaceController, watchMessengerDelegate, heartRateMonitorDelegate {

    @IBOutlet var messageLabel: WKInterfaceLabel!
    @IBOutlet var startEndMonitoring: WKInterfaceButton!
    
    let wMessenger = WatchMessenger.shared
    let hrMonitor = HeartRateMonitor()
    
    
    //MARK: - Loading
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }//eom

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        self.wMessenger.delegate = self
        self.hrMonitor.delegate = self
        
        self.wMessenger.start()
        
    }//eom

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }//eom
    
    //MARK: - Actions
    
    @IBAction func changeMonitoringState()
    {
        if self.hrMonitor.isMonitoring
        {
            self.end()
        }
        else
        {
            self.start()
        }
    }//eo-a
    
    //MARK: Start / End Monitoring
    func start()
    {
        self.hrMonitor.start()
    }//eom
    
    func end()
    {
        self.hrMonitor.end()
    }//eom
    
    
    //MARK: - Monitoring Delegates
    func heartRateMonitorError(error: NSError) {
        self.messageLabel.setText("Sending Error: \(error.localizedDescription)")
        
        let errorSending:String = "\(response.ErrorMonitoring.toString()) | \(error.localizedDescription)"
        
        let messageFromWatch = [ keys.Response.toString(): errorSending ]
        wMessenger.sendMessage(messageFromWatch)
        { (reply:[String : AnyObject]?, error:NSError?) in
            
        }
    }//eom
    
    func heartRateMonitorStateChanged(isMonitoring: Bool)
    {
        if isMonitoring
        {
            self.startEndMonitoring.setTitle("Stop")
            self.messageLabel.setText("Started Monitoring")
        }
        else
        {
            self.startEndMonitoring.setTitle("Start")
            self.messageLabel.setText("Ended Monitoring")
        }
        
        
        self.updateStatusToPhone(isMonitoring)
    }//eom
    
    func heartRateMonitorResponse(result: [HeartRate]) {
        if result.count > 0
        {
            let lastHr:HeartRate = result.last!
            
            print(lastHr)
            
            self.messageLabel.setText("Sending Result")
            
            let messageFromWatch:[String:AnyObject] =
                [
                    keys.Response.toString() : response.Data.toString(),
                    keys.HeartRate.toString() : lastHr.value,
                    keys.Time.toString() : lastHr.timeString,
                    keys.Date.toString() : lastHr.dateString
            ]
            
            wMessenger.sendMessage(messageFromWatch)
            { (reply:[String : AnyObject]?, error:NSError?) in
                
            }
            
        }
        else
        {
            //no data
        }
    }//eom
    
    
    //MARK: - Messeger
    func updateStatusToPhone(isMonitoring:Bool)
    {
        var messageToSend:[String:AnyObject] = [:]
        
        if isMonitoring
        {
            messageToSend = [keys.Response.toString():response.StartedMonitoring.toString()]
        }
        else
        {
            messageToSend = [keys.Response.toString():response.EndedMonitoring.toString()]
        }
        
        wMessenger.sendMessage(messageToSend)
        { (reply:[String : AnyObject]?, error:NSError?) in
            
        }
    
    }//eom
    
    //MARK: - Messeger Delegates
    func watchMessenger_didReceiveMessage(message: [String : AnyObject]) {
        
        if let commandReceived:String = message[keys.Command.toString()] as? String
        {
            switch commandReceived
            {
                case command.StartMonitoring.toString():
                    self.start()
                    break
                case command.EndMonitoring.toString():
                   self.end()
                    break
                default:
                    break
            }
        }
        else
        {
            self.messageLabel.setText("received something but cant find type")
        }
    }//eom
    
    func watchMessenger_startResults(started: Bool, error: NSError?) {
        
    }//eom
}//eoc
