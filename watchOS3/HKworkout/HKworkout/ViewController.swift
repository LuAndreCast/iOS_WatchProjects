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

class ViewController: UIViewController, WCSessionDelegate {
    
    //MARK: - Models
    
    //MARK: - UI Properties
    @IBOutlet var workoutSessionState: UILabel!
    @IBOutlet weak var startAppButton: UIButton!
    
    //MARK: - Properties
    var configuration:HKWorkoutConfiguration?
    let healthStore:HKHealthStore = HKHealthStore()
    var wcSessionActivationCompletion: ( (WCSession)->Void  )?
    
    
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }//eom
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }//eom

    
    @IBAction func startApp(_ sender: AnyObject) {
        self.startWatchApp()
    }
    
    
    //MARK: - Workout
    func startWatchApp()
    {
       getActiveWCSession
        { (session:WCSession) in
            if (session.activationState == .activated) && (session.isWatchAppInstalled)
            {
                if #available(iOS 10.0, *)
                {
                    let workoutConfiguration = HKWorkoutConfiguration()
                    workoutConfiguration.activityType = HKWorkoutActivityType.other
                    workoutConfiguration.locationType = HKWorkoutSessionLocationType.indoor
                    
                    self.healthStore.startWatchApp(with: workoutConfiguration, completion:
                        { (success:Bool, error:Error?) in
                            if error != nil
                            {
                                print("\(error?.localizedDescription)")
                            }
                            else if success
                            {
                                print("Started watch app!")
                            }
                            else
                            {
                                print("what happen!?")
                            }
                    })
                }
                else
                {
                    //send message to phone
                }
            }
            else
            {
                // notify user watch app is not installed
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
                //wcSessionActivationCompletion = completion
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
        DispatchQueue.main.async {
            self.workoutSessionState.text = state
        }
    }//eom
    
    //MARK: - WCSession Delegates
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?)
    {
        if error != nil
        {
            print("\(error?.localizedDescription)")
        }
        
        switch activationState
        {
            case .activated:
                
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
    
    
    //MARK: - Memory
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}//eoc

