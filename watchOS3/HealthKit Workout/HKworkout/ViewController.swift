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

class ViewController: UIViewController, WCSessionDelegate, healthStoreMonitorDelegate {
    
    //MARK: - Models
    let hkMonitor:HealthStoreMonitor = HealthStoreMonitor()
    let hrParser:HeartRateParser = HeartRateParser()
    
    //MARK: - UI Properties
    @IBOutlet var workoutSessionState: UILabel!
    @IBOutlet var heartRateInfoLabel: UILabel!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet weak var startAppButton: UIButton!
    
    
    //MARK: - Properties
    var configuration:HKWorkoutConfiguration?
    let healthStore:HKHealthStore = HKHealthStore()
    var wcSessionActivationCompletion: ( (WCSession)->Void  )?
    
    var session:WCSession?
    {
        if WCSession.isSupported()
        {
            return WCSession.default()
        }
        
        return nil
    }
    
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        hkMonitor.delegate = self
        
        session?.delegate = self
        session?.activate()
    }//eom
   
    //MARK: - Actions
    @IBAction func startApp(_ sender: AnyObject) {
        self.startWatchApp()
    }//eo-a
    
    //MARK: - Workout
    func startWatchApp()
    {
        self.messageLabel.text = " "
        
        guard  let wcsession:WCSession = self.session
            else
            {
                self.updateMessage(message: "WCSession is not supported!")
                return
            }
        
        if (wcsession.activationState == .activated) && (wcsession.isWatchAppInstalled)
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
                        }
                        else if success
                        {
                            self.updateMessage(message: "started watch app")
                            self.startMonitoringHR()
                        }
                        else
                        {
                            self.updateMessage(message: "What happen with start watch app!?")
                        }
                })
            }
            else
            {
                //send a message to watch
            }
        }
        else
        {
            if wcsession.isReachable == false
            {
                self.updateMessage(message: "watch is not reachable")
            }
            else if wcsession.isWatchAppInstalled == false
            {
                self.updateMessage(message: "watch app is not installed")
            }
            else
            {
                self.updateMessage(message: "un-able to communicate with watch")
            }
        }
    }//eom
    
    
    //MARK: - WCSession helpers
    func getActiveWCSession( completion:(WCSession)->Void )
    {
        
        if WCSession.isSupported()
        {
            let wcSession = WCSession.default()
            wcSession.delegate = self
            
            if wcSession.activationState == .activated
            {
                completion(wcSession)
            }
            else
            {
                wcSession.activate()
//                wcSessionActivationCompletion = completion
                print("wcSession activated, pending results")
            }
        }
        else
        {
            //notify user watch app is not supported
        }
    }//eom
    
    
    
    //MARK: - UI Helpers
    func updateSessionState(_ state:String)
    {
        DispatchQueue.main.async
        {
            print("updated state: \(state)")
            
            self.workoutSessionState.text = state
            
            if state == "running"
            {
                self.startMonitoringHR()
            }
            else
            {
                self.endMonitoringHR()
            }
        }
    }//eom
    
    func updateResults(results:[HeartRate])
    {
        let firstSample:HeartRate = results.first!
        let hrDate = firstSample.dateString
        let hrTime = firstSample.timeString
        let hrValue = firstSample.value
        
        DispatchQueue.main.async {
            self.heartRateInfoLabel.text = "\(hrValue) bpm \n\(hrTime) \n\(hrDate)"
            print("\(hrValue) bpm | \(hrTime) | \(hrDate) \n")
        }
    }//eom
    
    func updateMessage(message:String)
    {
        print("\(message)")
        
        DispatchQueue.main.sync {
            self.messageLabel.text = "\(message)"
        }
    }//eom
    
    //MARK: - WCSession Delegates
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?)
    {
        if error != nil
        {
            self.updateMessage(message: error!.localizedDescription)
        }
        
        switch activationState
        {
            case .activated:
                print("activationDidCompleteWith, wcSession activated")
                
                if let activationCompletion = wcSessionActivationCompletion
                {
                    activationCompletion(session)
                    wcSessionActivationCompletion = nil
                }
                break
            default:
                break
        }
        
    }//eom
    
    func session(_ session: WCSession,
                 didReceiveMessage message: [String : Any])
    {
        if let state = message["State"] as? String
        {
            updateSessionState(state)
        }
    }//eom
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("sessionDidBecomeInactive")
    }//eom
    
    func sessionDidDeactivate(_ session: WCSession) {
        
        print("sessionDidDeactivate")
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

