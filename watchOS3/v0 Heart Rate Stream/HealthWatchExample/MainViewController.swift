//
//  MainViewController.swift
//  HealthWatchExample
//
//  Created by Luis Castillo on 8/2/16.
//  Copyright © 2016 LC. All rights reserved.
//

import UIKit
import HealthKit
import WatchConnectivity

class MainViewController: UIViewController, HRMonitorModelDelegate
{
    //models
    let hrMonitorModel:HRMonitorModel = HRMonitorModel()
    
    //ui properties
    @IBOutlet weak var startEndMonitoringButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    
    //MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hrMonitorModel.delegate = self
    }//eom


    //MARK: - Actions
    @IBAction func startEndMonitor(sender: UIButton)
    {
        if self.startEndMonitoringButton.selected == false
        {
            self.startEndMonitoringButton.selected = true
            self.hrMonitorModel.startHeartRateMonitoring()
        }
        else
        {
            self.startEndMonitoringButton.selected = false
            self.hrMonitorModel.endHeartRateMonitoring()
        }
    }//eo-a

    private func updateUI()
    {
        dispatch_async(dispatch_get_main_queue()) {
            if self.startEndMonitoringButton.selected
            {
                self.messageLabel.text = "Started Monitoring"
                self.startEndMonitoringButton.setTitle("End Monitoring", forState: UIControlState.Normal)
            }
            else
            {
                self.messageLabel.text = "Ended Monitoring"
                self.startEndMonitoringButton.setTitle("Start Monitoring", forState: UIControlState.Normal)
            }
        }
    }//eom
   
    //MARK: HR Monitor Delegates
    func HRMonitorErrorOccurred(error: NSString) {
        dispatch_async(dispatch_get_main_queue()) {
            self.startEndMonitoringButton.selected = false
            self.startEndMonitoringButton.setTitle("Start Monitoring", forState: UIControlState.Normal)
            self.messageLabel.text = "ERROR: \(error)"
        }
    }//eom
    
    func HRMonitorResults(heartRates: [HeartRate]) {
        dispatch_async(dispatch_get_main_queue())
        {
            if let lastHR:HeartRate = heartRates.last
            {
                let info = "Heart rate: \(lastHR.value)  \n Time: \(lastHR.timeString) \n Date: \(lastHR.dateString)"
                
                self.messageLabel.text = info
            }
        }
    }//eom
    
    func HRMonitorStatusChanged(isMonitoring: Bool) {
        if isMonitoring
        {
            self.startEndMonitoringButton.selected = true
        }
        else
        {
            self.startEndMonitoringButton.selected = false
        }
        
        self.updateUI()
    }//eom
    
    func HRMonitorReachabilityStatusChanged(isReachable: Bool) {
        if isReachable
        {
        
        }
        else
        {
        
        }
    }//eom
    
    
}//eoc
