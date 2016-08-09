//
//  InterfaceController.swift
//  HealthWatchExample WatchKit Extension
//
//  Created by Luis Castillo on 2/2/16.
//  Copyright © 2016 LC. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit
import WatchConnectivity


//debuggin?
let verbose = true


class HeartRateInterfaceController: WKInterfaceController, WCSessionDelegate, heartRateMonitorDelegate
{

    @IBOutlet var startStopButton: WKInterfaceButton!
    
    
    private let manager = HeartRateMonitor()
    private var requestStatus = false
    
    
    //properties
    let session:WCSession = WCSession.defaultSession()
    
    
    //MARK: - View Loading
    override func awakeWithContext(context: AnyObject?)
    {
        super.awakeWithContext(context)
        
        if verbose
        {
            print("awakeWithContext \(self)")
        }
        
        //sessions
        session.delegate = self
        session.activateSession()
    }//eom

    override func willActivate()
    {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        if verbose
        {
            print("willActivate \(self)")
        }
        
        self.updateRequestStatus()
        
        //requesting permission
        self.manager.requestPermission()
        self.manager.delegate = self
        
    }//eom

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        if verbose
        {
            print("didDeactivate \(self)")
        }
        
        self.manager.endMonitoring()
    }//eom
    
    
    //MARK: - Start/ Stop
    @IBAction func requestUpdate()
    {
        self.updateRequestStatus()
    }//eo-a
    
    func updateRequestStatus()
    {
        if self.requestStatus
        {
            self.requestStatus = false
            self.startStopButton.setTitle("Start")
            
            //stopping
            self.manager.endMonitoring()
        }
        else
        {
            self.requestStatus = true
            self.startStopButton.setTitle("Stop")
            
            //starting
            self.manager.startMonitoring
            { (newHeartRate) in
                
                if verbose
                {
                    print("new heart Rate: \(newHeartRate)")
                    print("average heart rate: \(self.manager.averageHeartRate)")

                }
            }
        }
    }//eom
    
    //MARK: Heart Rate Monitor Delegates
    func heartRateMonitorStatusChanged(status:monitoringStatus, reason:String?)
    {
        if verbose
        {
            print("heartRateMonitorStatusChanged to \(status.toString()) | reason \(reason)")
        }
        
        //updating status
        switch status {
            case .off:
                self.requestStatus = false
                break
            case .on:
                self.requestStatus = true
                break
        }
        
        self.updateRequestStatus()
    }//eom
    
    func heartRateMonitorPermissionStatusChanged(type:authorizationType, reason:String?)
    {
        if verbose
        {
            print("authorization changed to \(type) | reason \(reason)")
        }
        
    }//eom

}//eoc
