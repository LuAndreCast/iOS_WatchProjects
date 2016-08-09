//
//  MainViewController.swift
//  HealthWatchExample
//
//  Created by Luis Castillo on 8/2/16.
//  Copyright © 2016 LC. All rights reserved.
//

import UIKit
import HealthKit

class MainViewController: UIViewController,watchMessengerDelegate
{
    //watch messenger
    let wMessenger = WatchMessenger()
    
    //heart Rate
    let hrPermission = HeartRatePermission()
    let healthStore = HKHealthStore()
    
    
    @IBOutlet weak var startEndMonitoringButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    
    
    //MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.wMessenger.delegate = self
        self.wMessenger.start()
    }//eom

    override func viewDidAppear(animated: Bool)
    {
        self.requestHeartRatePermission()
    }//eom

    //MARK: - Actions
    @IBAction func startEndMonitoring(sender: AnyObject)
    {
        if self.startEndMonitoringButton.selected
        {
            self.startEndMonitoringButton.selected = false
            self.end()
        }
        else
        {
            self.startEndMonitoringButton.selected = true
            self.start()
        }
    }//eom
    
    //MARK: Start / End Monitoring
    func start()
    {
        let messageFromPhone = [ keys.Command.toString() : command.StartMonitoring.toString() ]
        wMessenger.sendMessage(messageFromPhone)
        { (reply:[String : AnyObject]?, error:NSError?) in
            
            if error != nil
            {
                self.startEndMonitoringButton.selected = false
                self.updateUI()
                
                //show error
            }
            else
            {
                
            }
        }
    }//eom
    
    
    func end()
    {
        let messageFromPhone = [ keys.Command.toString() : command.EndMonitoring.toString() ]
        wMessenger.sendMessage(messageFromPhone)
        { (reply:[String : AnyObject]?, error:NSError?) in
            
            if error != nil
            {
                self.startEndMonitoringButton.selected = true
                self.updateUI()
                
                //show error
            }
            else
            {
                
            }
        }
    }//eom
    
    
    private func updateUI()
    {
        if self.startEndMonitoringButton.selected
        {
            self.startEndMonitoringButton.setTitle("End Monitoring", forState: UIControlState.Normal)
        }
        else
        {
            self.startEndMonitoringButton.setTitle("Start Monitoring", forState: UIControlState.Normal)
        }
    }//eom
    
    //MARK: - Messenger Delegates
    func watchMessenger_didReceiveMessage(message: [String : AnyObject])
    {
        dispatch_async(dispatch_get_main_queue()) {
            
            if let commandReceived:String = message[keys.Command.toString()] as? String
            {
                switch commandReceived
                {
                    case command.StartMonitoring.toString():
                        self.messageLabel.text = "Started Monitoring"
                        self.startEndMonitoringButton.selected = true
                        self.updateUI()
                        break
                    case command.EndMonitoring.toString():
                        self.messageLabel.text = "Ended Monitoring"
                        self.startEndMonitoringButton.selected = false
                        self.updateUI()
                        break
                    default:
                        
                        self.messageLabel.text = "Unknown command received"
                        break
                }
            }
            //reponses
            else if let responseReceived:String = message[keys.Response.toString()] as? String
            {
                switch responseReceived
                {
                    case response.Data.toString():
                        
                        let hrValue:Double? = message[keys.HeartRate.toString()] as? Double
                        let hrTime:String? = message[keys.Time.toString()] as? String
                        let hrDate:String? = message[keys.Date.toString()] as? String
                        
                        if hrValue != nil && hrTime != nil && hrDate != nil
                        {
                            self.messageLabel.text = "Heart rate Data:\n \(hrValue!) \n at \(hrTime!) \n on \(hrDate!)"
                        }
                        
                        break
                    case response.ErrorHealthKit.toString():
                        self.messageLabel.text = "Error with HealthKit"
                            break
                    case response.ErrorMonitoring.toString():
                        self.messageLabel.text = "Error with Monitoring"
                        break
                    default:
                        self.messageLabel.text = "Unknown response received"
                        break
                
                }
            }
            else
            {
                self.messageLabel.text = "Unknown received"
            }
        }
    }//eom
    
    func watchMessenger_startResults(started: Bool, error: NSError?)
    {
        if error != nil
        {
            self.messageLabel.text = error?.localizedDescription
        }
    }//eom
    
    //MARK: - Request Heart Rate Permission
    func requestHeartRatePermission()
    {
        hrPermission.requestPermission(healthStore)
        { (success:Bool, error:NSError?) in
        }
    }//eom

}//eoc
