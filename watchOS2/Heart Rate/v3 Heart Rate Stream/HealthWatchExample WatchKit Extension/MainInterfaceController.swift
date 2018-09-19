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
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
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
    func heartRateMonitorError(_ error: NSError) {
        self.messageLabel.setText("Sending Error: \(error.localizedDescription)")
        
        let errorSending:String = "\(response.errorMonitoring.toString()) | \(error.localizedDescription)"
        
        let messageFromWatch = [ keys.response.toString(): errorSending ]
        wMessenger.sendMessage(messageFromWatch as [String : AnyObject])
        { (reply:[String : Any]?, error:Error?) in
            
        }
    }//eom
    
    func heartRateMonitorStateChanged(_ isMonitoring: Bool)
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
    
    func heartRateMonitorResponse(_ result: [HeartRate]) {
        if result.count > 0
        {
            let lastHr:HeartRate = result.last!
            
            print(lastHr)
            
            self.messageLabel.setText("Sending Result")
            
            let messageFromWatch:[String:AnyObject] =
                [
                    keys.response.toString() : response.data.toString() as AnyObject,
                    keys.heartRate.toString() : lastHr.value as AnyObject,
                    keys.time.toString() : lastHr.timeString as AnyObject,
                    keys.date.toString() : lastHr.dateString as AnyObject
            ]
            
            wMessenger.sendMessage(messageFromWatch)
            { (reply:[String : Any]?, error:Error?) in
                
            }
            
        }
        else
        {
            //no data
        }
    }//eom
    
    
    //MARK: - Messeger
    func updateStatusToPhone(_ isMonitoring:Bool)
    {
        var messageToSend:[String:AnyObject] = [:]
        
        if isMonitoring
        {
            messageToSend = [keys.response.toString():response.startedMonitoring.toString() as AnyObject]
        }
        else
        {
            messageToSend = [keys.response.toString():response.endedMonitoring.toString() as AnyObject]
        }
        
        wMessenger.sendMessage(messageToSend)
        { (reply:[String : Any]?, error:Error?) in
            
        }
    
    }//eom
    
    //MARK: - Messeger Delegates
    func watchMessenger_didReceiveMessage(_ message: [String : AnyObject]) {
        
        if let commandReceived:String = message[keys.command.toString()] as? String
        {
            switch commandReceived
            {
                case command.startMonitoring.toString():
                    self.start()
                    break
                case command.endMonitoring.toString():
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
    
    func watchMessenger_startResults(_ started: Bool, error: NSError?) {
        
    }//eom
}//eoc
