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

    override func viewDidAppear(_ animated: Bool)
    {
        self.requestHeartRatePermission()
    }//eom

    //MARK: - Actions
    @IBAction func startEndMonitoring(_ sender: AnyObject)
    {
        if self.startEndMonitoringButton.isSelected
        {
            self.startEndMonitoringButton.isSelected = false
            self.end()
        }
        else
        {
            self.startEndMonitoringButton.isSelected = true
            self.start()
        }
    }//eom
    
    //MARK: Start / End Monitoring
    func start()
    {
        let messageFromPhone = [ keys.command.toString() : command.startMonitoring.toString() ]
        wMessenger.sendMessage(messageFromPhone as [String : AnyObject])
        { (reply:[String : Any]?, error:Error?) in
            
            if error != nil
            {
                self.startEndMonitoringButton.isSelected = false
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
        let messageFromPhone = [ keys.command.toString() : command.endMonitoring.toString() ]
        wMessenger.sendMessage(messageFromPhone as [String : AnyObject])
        { (reply:[String : Any]?, error:Error?) in
            
            if error != nil
            {
                self.startEndMonitoringButton.isSelected = true
                self.updateUI()
                
                //show error
            }
            else
            {
                
            }
        }
    }//eom
    
    
    fileprivate func updateUI()
    {
        if self.startEndMonitoringButton.isSelected
        {
            self.messageLabel.text = "Started Monitoring"
            self.startEndMonitoringButton.setTitle("End Monitoring", for: UIControlState())
        }
        else
        {
            self.messageLabel.text = "Ended Monitoring"
            self.startEndMonitoringButton.setTitle("Start Monitoring", for: UIControlState())
        }
    }//eom
    
    //MARK: - Messenger Delegates
    func watchMessenger_didReceiveMessage(_ message: [String : AnyObject])
    {
        DispatchQueue.main.async {
            
            //reponses
            if let commandReceived:String = message[keys.response.toString()] as? String
            {
                switch commandReceived
                {
                    case response.startedMonitoring.toString():
                        self.startEndMonitoringButton.isSelected = true
                        self.updateUI()
                        break
                    case response.endedMonitoring.toString():
                        self.startEndMonitoringButton.isSelected = false
                        self.updateUI()
                        break
                    case response.data.toString():
                        let hrValue:Double? = message[keys.heartRate.toString()] as? Double
                        let hrTime:String? = message[keys.time.toString()] as? String
                        let hrDate:String? = message[keys.date.toString()] as? String
                        
                        if hrValue != nil && hrTime != nil && hrDate != nil
                        {
                            self.messageLabel.text = "Heart rate Data:\n \(hrValue!) \n at \(hrTime!) \n on \(hrDate!)"
                        }
                        
                        break
                    case response.errorHealthKit.toString():
                        self.messageLabel.text = "Error with HealthKit"
                            break
                    case response.errorMonitoring.toString():
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
    
    func watchMessenger_startResults(_ started: Bool, error: NSError?)
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
