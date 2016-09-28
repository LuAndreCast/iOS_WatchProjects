//
//  ViewController.swift
//  HKworkout
//
//  Created by Luis Castillo on 9/12/16.
//  Copyright © 2016 LC. All rights reserved.
//

import UIKit
import WatchConnectivity
import HealthKit

class ViewController: UIViewController,
healthStoreMonitorDelegate,
PhoneCommunicatorDelegate
{
    //MARK: - Models
    let hkMonitor:HealthStoreMonitor = HealthStoreMonitor()
    let hrParser:HeartRateParser = HeartRateParser()
    let phoneCom:PhoneCommunicator = PhoneCommunicator()
    
    //MARK: - UI Properties
    @IBOutlet var workoutSessionState: UILabel!
    @IBOutlet var heartRateInfoLabel: UILabel!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet weak var startAppButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    //MARK: - Properties
    var configuration:HKWorkoutConfiguration?
    let healthStore:HKHealthStore = HKHealthStore()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        hkMonitor.delegate = self
        
        phoneCom.delegate = self
        phoneCom.setup()
        
        self.pauseButton.isHidden = true
        self.stopButton.isHidden = true
        self.messageLabel.text = " "
    }//eom
   
    //MARK: - UI Actions
    @IBAction func pauseApp(_ sender: AnyObject) {
        self.updateMessage(message: " ")
      self.pauseMonitoringCommand()
    }//eo-a
    
    @IBAction func stopApp(_ sender: AnyObject) {
        self.updateMessage(message: " ")
        self.stopMonitoringCommand()
    }//eo-a
    
    @IBAction func startApp(_ sender: AnyObject) {
        self.updateMessage(message: " ")
        self.startWatchApp()
    }//eo-a
    
    //MARK: - UI Helpers
    func updateSessionState(_ state:String)
    {
        print("updated state: \(state)")
        
        if Thread.isMainThread
        {
            self.workoutSessionState.text = state
            
            if state == workoutState.running.toString()
            {
                self.startMonitoringHR()
                self.pauseButton.isHidden = false
                self.stopButton.isHidden = false
            }
            else if state == workoutState.ended.toString()
            {
                self.endMonitoringHR()
                self.pauseButton.isHidden = true
                self.stopButton.isHidden = true
            }
            else if state == workoutState.notStarted.toString()
            {
                //nothing to do
                self.pauseButton.isHidden = true
                self.stopButton.isHidden = true
            }
            else if state == workoutState.paused.toString()
            {
                self.endMonitoringHR()
                self.pauseButton.isHidden = true
                self.stopButton.isHidden = false
            }
        }
        else
        {
            DispatchQueue.main.async
                {
                    self.workoutSessionState.text = state
                    
                    if state == workoutState.running.toString()
                    {
                        self.startMonitoringHR()
                        self.pauseButton.isHidden = false
                        self.stopButton.isHidden = false
//                        self.startAppButton.isHidden = true
                    }
                    else if state == workoutState.ended.toString()
                    {
                        self.endMonitoringHR()
                        self.pauseButton.isHidden = true
                        self.stopButton.isHidden = true
//                        self.startAppButton.isHidden = false
                    }
                    else if state == workoutState.notStarted.toString()
                    {
                        //nothing to do
                        self.pauseButton.isHidden = true
                        self.stopButton.isHidden = true
//                        self.startAppButton.isHidden = false
                    }
                    else if state == workoutState.paused.toString()
                    {
                        self.endMonitoringHR()
                        self.pauseButton.isHidden = true
                        self.stopButton.isHidden = false
//                        self.startAppButton.isHidden = false
                    }
            }
        }
    }//eom
    
    func updateResults(results:[HeartRate])
    {
        let firstSample:HeartRate = results.first!
        let hrDate:String = firstSample.dateString
        let hrTime:String = firstSample.timeString
        let hrValue:Double = firstSample.value
        
        print("\(hrValue) bpm | \(hrTime) | \(hrDate) \n")
        
        if Thread.isMainThread
        {
            self.heartRateInfoLabel.text = "\(hrValue) bpm \n\(hrTime) \n\(hrDate)"
        }
        else
        {
            DispatchQueue.main.async {
                self.heartRateInfoLabel.text = "\(hrValue) bpm \n\(hrTime) \n\(hrDate)"
            }
        }
    }//eom
    
    func updateMessage(message:String)
    {
        print("\(message)")
        
        if Thread.isMainThread
        {
            self.messageLabel.text = "\(message)"
        }
        else
        {
            DispatchQueue.main.sync {
                self.messageLabel.text = "\(message)"
            }
        }
    }//eom

    
    //MARK: - Start Watch App
    func startWatchApp()
    {
        let watchStates:watchStates = phoneCom.getWatchStates()
        if (watchStates.isWatchAppInstalled) && (watchStates.state == connectionState.activated)
        {
            if #available(iOS 10.0, *)
            {
                let workoutConfiguration = HKWorkoutConfiguration()
                workoutConfiguration.activityType = HKWorkoutActivityType.other
                workoutConfiguration.locationType = HKWorkoutSessionLocationType.indoor
                
                healthStore.startWatchApp(with: workoutConfiguration, completion:
                    { (success:Bool, error:Error?) in
                        if error != nil
                        {
                            self.updateMessage(message: error!.localizedDescription)
                            self.updateSessionState(workoutState.notStarted.toString())
                        }
                        else if success
                        {
                            self.updateMessage(message: "started watch app")
                            self.updateSessionState(workoutState.running.toString())
                            self.startMonitoringHR()
                        }
                        else
                        {
                            self.updateMessage(message: "un-able to start watch app - unknown reason")
                            self.updateSessionState(workoutState.notStarted.toString())
                        }
                })
            }
            else
            {
                self.startMonitoringCommand()
            }
        }
        else
        {
            if watchStates.isReachable == false
            {
                self.updateMessage(message: "watch is not reachable")
            }
            else if watchStates.isWatchAppInstalled == false
            {
                self.updateMessage(message: "watch app is not installed")
            }
            else
            {
                self.updateMessage(message: "un-able to communicate with watch")
            }
        }
    }//eom
    
    
    //MARK: - Workout Commands
    func startMonitoringCommand()
    {
        let messageToSend:[String:Any] = [ "Command": "Start"]
        phoneCom.sendMessage(messageToSend: messageToSend, replyHander:
            { (reply:[String : Any]) in
                self.updateMessage(message: "Start Command Reply: \(reply)")
            }, errorHandler: { (error:Error) in
                self.updateMessage(message: "Start Command Error, \(error.localizedDescription)")
        })
    }//eom
    
    func stopMonitoringCommand()
    {
        let messageToSend:[String:Any] = [ "Command": "Stop"]
        phoneCom.sendMessage(messageToSend: messageToSend, replyHander:
            { (reply:[String : Any]) in
                self.updateMessage(message: "Stop Command Reply: \(reply)")
            }, errorHandler: { (error:Error) in
                self.updateMessage(message: "Stop Command Error, \(error.localizedDescription)")
                
                /* sending background message */
                self.stopBackgroundCommand(message: messageToSend)
        })
    }//eom
    
    func pauseMonitoringCommand()
    {
        let messageToSend:[String:Any] = [ "Command": "Pause"]
        phoneCom.sendMessage(messageToSend: messageToSend, replyHander:
            { (reply:[String : Any]) in
                self.updateMessage(message: "Pause Command Reply: \(reply)")
            }, errorHandler: { (error:Error) in
                self.updateMessage(message: "Pause Command Error, \(error.localizedDescription)")
                
                /* sending background message */
                self.pauseBackgroundCommand(message: messageToSend)
        })
    }//eom
    
    //MARK: - Background Messages
    func pauseBackgroundCommand(message:[String : Any])
    {
        phoneCom.sendBackgroundContext(contextToSend: message)
        { (success:Bool) in
            
        }
    }//eom
    
    func stopBackgroundCommand(message:[String : Any])
    {
        phoneCom.sendBackgroundContext(contextToSend: message)
        { (success:Bool) in
            
        }
    }//eom
    
    
    
    //MARK: - Comminucator Delegates
    func phoneCommunicator(watchStatesChanged: watchStates) {
        
        var messageToDisplay:String = ""
        
        //Paired?
        messageToDisplay = "\(messageToDisplay)\n Paired? \(watchStatesChanged.isPaired)"
        messageToDisplay = "\(messageToDisplay)\n Reachable? \(watchStatesChanged.isReachable)"
        messageToDisplay = "\(messageToDisplay)\n WatchApp Installed? \(watchStatesChanged.isWatchAppInstalled)"
        
        self.updateMessage(message: messageToDisplay)
    }//eom
    
    func phoneCommunicator(stateChanged: connectionState)
    {
        switch stateChanged
        {
            case .activated:
                self.updateMessage(message: "communication activated")
                break
            case .deactivated:
                phoneCom.setup()
                self.updateMessage(message: "communication deactivated")
                break
            case .inactive:
                //stop sending messages
                self.updateMessage(message: "communication inactivate")
                break
        case .notActivated:
            self.updateMessage(message: "communication not activated")
                break
            case .notSupported:
                self.updateMessage(message: "communication not supported")
                break
        case .unknownActivation:
            self.updateMessage(message: "communication unknown")
                break
            default:
                break
        }
    }//eom
    
    func phoneCommunicator(messageReceived: [String : Any]) -> [String : Any]
    {
        if let stateReceived:String = messageReceived["State"] as? String
        {
            self.updateSessionState(stateReceived)
        }
        else if let commandReceived:String = messageReceived["Command"] as? String
        {
           print("command: \(commandReceived)")
        }
        
        let message = ["reply":"msg rcvd"]
        return message
    }//eom
    
    func phoneCommunicator(contextReceived: [String : Any])
    {
        print("context : \(contextReceived)")
    }//eom
    
    //MARK: - Health Store Monitor Helpers
    func startMonitoringHR()
    {
        DispatchQueue.main.async {
            if let sampleHRType:HKSampleType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)
            {
                self.hkMonitor.startMonitoring(healthStore: self.healthStore, sampleType: sampleHRType)
            }
        }
    }//eom
    
    func endMonitoringHR()
    {
        hkMonitor.endMonitoring()
    }//eom
    
    //MARK: - Health Store Monitor Delegates
    func healthStoreMonitorError(error: NSError) {
        self.updateMessage(message: error.localizedDescription)
    }//eom
    
    func healthStoreMonitorResults(results: [HKSample]) {
        if results.count > 0
        {
            let hrSamples:[HeartRate] = hrParser.parseFromSamples(samples: results)
            self.updateResults(results: hrSamples)
        }
    }//eom
    
    //MARK: - Memory
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}//eoc

