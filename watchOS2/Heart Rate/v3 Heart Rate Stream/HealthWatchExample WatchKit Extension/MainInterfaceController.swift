//
//  MainInterfaceController.swift
//  HealthWatchExample
//
//  Created by Luis Castillo on 8/5/16.
//  Copyright © 2016 LC. All rights reserved.
//

import WatchKit
import Foundation


class MainInterfaceController: WKInterfaceController, watchMessengerDelegate {

    @IBOutlet var messageLabel: WKInterfaceLabel!
    @IBOutlet var startEndMonitoring: WKInterfaceButton!
    
    let wMessenger = WatchMessenger()
    let hrMonitor = HeartRateMonitor()
    
    var isMonitoring = false
    
    //MARK: - Loading
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }//eom

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        self.wMessenger.delegate = self
        self.wMessenger.start()
        
    }//eom

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }//eom
    
    //MARK: - Actions
    
    @IBAction func changeMonitoringState()
    {
        if self.isMonitoring == true
        {
            self.isMonitoring = false
            self.end()
            self.updateStatusToPhone()
        }
        else
        {
            self.isMonitoring = true
            self.start()
            self.updateStatusToPhone()
        }
        
       self.updateUI()
    }//eo-a
    
    private func updateUI()
    {
        if self.isMonitoring == true
        {
            self.startEndMonitoring.setTitle("Stop")
            self.messageLabel.setText("Started Monitoring")
        }
        else
        {
            self.startEndMonitoring.setTitle("Start")
            self.messageLabel.setText("Ended Monitoring")
        }
    
    }//eom
    
    //MARK: Start / End Monitoring
    func start()
    {
        //error
        self.hrMonitor.errorHandler =
            {  (error:NSError) in
                self.processErrors(error)
        }
        
        //response
        self.hrMonitor.responseHandler =
            {  (heartRates:[HeartRate]) in
                self.proccessResults(heartRates)
        }
        
        self.hrMonitor.start()
    }//eom
    
    func end()
    {
         self.hrMonitor.end()
    }//eom
    
    //MARK: - Messeger
    func updateStatusToPhone()
    {
        var messageToSend:[String:AnyObject] = [:]
        
        if isMonitoring
        {
            messageToSend = [keys.Command.toString():command.StartMonitoring.toString()]
        }
        else
        {
            messageToSend = [keys.Command.toString():command.EndMonitoring.toString()]
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
                    
                    self.isMonitoring = true
                    self.start()
                    self.updateUI()
                    
                    self.messageLabel.setText("Starting Monitoring")
                    break
                case command.EndMonitoring.toString():
                   
                   self.isMonitoring = false
                   self.end()
                   self.updateUI()
                   
                    self.messageLabel.setText("Ending Monitoring")
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
    
    
    //MARK: - Error
    private func processErrors(error:NSError)
    {
        self.messageLabel.setText("Sending Error: \(error.localizedDescription)")
        
        let errorSending:String = "\(response.ErrorMonitoring.toString()) | \(error.localizedDescription)"
        
        let messageFromWatch = [ keys.Response.toString(): errorSending ]
        wMessenger.sendMessage(messageFromWatch)
        { (reply:[String : AnyObject]?, error:NSError?) in
            
        }
    }//eom
    
    
    //MARK: - Results
    private func proccessResults(result:[HeartRate])
    {
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
    

}//eoc
