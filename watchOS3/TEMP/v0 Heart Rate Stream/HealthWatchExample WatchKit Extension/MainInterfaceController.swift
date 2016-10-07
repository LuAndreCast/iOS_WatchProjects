//
//  MainInterfaceController.swift
//  HealthWatchExample
//
//  Created by Luis Castillo on 8/5/16.
//  Copyright © 2016 LC. All rights reserved.
//

import WatchKit
import Foundation


class MainInterfaceController: WKInterfaceController, HRMonitorWatchModelDelegate
{
    
    //UI Properties
    @IBOutlet var messageLabel: WKInterfaceLabel!
    @IBOutlet var startEndMonitoringButton: WKInterfaceButton!
    
    //models
    let hrMonitor = HRMonitorWatchModel.sharedInstance
    
    
    //MARK: - Loading
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        hrMonitor.delegate = self
    }//eom

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        hrMonitor.setup()
//        hrMonitor.startMonitoring()
    }//eom

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        hrMonitor.endMonitoring()
    }//eom
    
    @IBAction func startEndMonitoring()
    {
        if hrMonitor.isMonitoring
        {
            hrMonitor.startMonitoring()
        }
        else
        {
            hrMonitor.endMonitoring()
        }
        
        self.updateMonitoringBasedOnState(self.hrMonitor.isMonitoring)
    }//eo-a
    
    
    private func updateMonitoringBasedOnState(isMonitoring:Bool)
    {
        if isMonitoring
        {
            self.startEndMonitoringButton.setTitle("Monitoring HR")
            self.startEndMonitoringButton.setTitle("End")
        }
        else
        {
            self.startEndMonitoringButton.setTitle(" ")
            self.startEndMonitoringButton.setTitle("Start")
        }
    }//eom
    
    //MARK: - HR Monitor Watch Model Delegate
    func HRMonitorErrorOccurred(error: NSString)
    {
        print("\(self) error: \(error)")
        
        self.startEndMonitoringButton.setTitle("\(error)")
    }//eom
    
    func HRMonitorReachabilityStatusChanged(isReachable: Bool)
    {
        if isReachable
        {
            self.startEndMonitoringButton.setTitle("Phone is now reachable")
        }
        else
        {
            self.startEndMonitoringButton.setTitle("Phone is no longer reachable")
        }
    }//eom
    
    func HRMonitorStatusChanged(isMonitoring: Bool)
    {
        self.updateMonitoringBasedOnState(isMonitoring)
    }//eom
}//eoc
