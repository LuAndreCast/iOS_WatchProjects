//
//  InterfaceController.swift
//  HKworkout WatchKit Extension
//
//  Created by Luis Castillo on 9/12/16.
//  Copyright © 2016 LC. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit

class HeartRateInterfaceController: WKInterfaceController, HKWorkoutSessionDelegate, WatchCommunicatorDelegate {

    //MARK: - Models
    let watchCom:WatchCommunicator = WatchCommunicator()
    
    //MARK: -Properties
    let healthStore = HKHealthStore()
    var workoutSession : HKWorkoutSession?
    
    var activeDataQueries = [HKQuery]()
    
    var workoutStartDate : Date?
    var workoutEndDate : Date?
    
    var workoutEvents = [HKWorkoutEvent]()
    var metadata = [String: AnyObject]()
    
    var timer : Timer?
    var isPaused = false
    
    // MARK: IBOutlets
    @IBOutlet var heartRateLabel: WKInterfaceLabel!
    @IBOutlet var messageLabel: WKInterfaceLabel!
    @IBOutlet var workoutStateLabel: WKInterfaceLabel!
    
    @IBOutlet var pauseResumeButton : WKInterfaceButton!
    @IBOutlet var stopButton: WKInterfaceButton!
    @IBOutlet var startButton: WKInterfaceButton!
    
    
    // MARK: - Lifecycle
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        /* UI Setup */
        heartRateLabel.setText(" ")
        messageLabel.setText(" ")
        workoutStateLabel.setText(" ")
        
        /* Communicator Setup */
        watchCom.delegate = self
        watchCom.setup()
        
        /* Start a workout session with the configuration */
        if #available(watchOSApplicationExtension 3.0, *)
        {
            if context != nil
            {
                let workoutConfiguration:HKWorkoutConfiguration? = context as! HKWorkoutConfiguration?
                self.prepWorkoutConfigAndAttemptToStartWorkout(workoutConfig: workoutConfiguration)
            }
        }
        else
        {
            self.prepDefaultAndStartWorkout()
        }
    }//eom
    
    override func willDisappear() {
        super.willDisappear()
        
    }//eom
    
    // MARK: - UI Actions
    @IBAction func didTapPauseResumeButton()
    {
        self.pauseWorkoutSession()
    }//eo-a
    
    @IBAction func didTapStopButton()
    {
        self.stopWorkoutSession()
    }//eo-a
    
    @IBAction func didTapStartButton()
    {
        self.prepDefaultAndStartWorkout()
    }//eo-a
    
    
    // MARK: - UI Helpers
    func updateLabels()
    {
        let duration = computeDurationOfWorkout(withEvents: workoutEvents, startDate: workoutStartDate, endDate: workoutEndDate)
        print("duration \(duration)")
    }//eom
    
    func updateState()
    {
        if let session = workoutSession
        {
            switch session.state {
            case .running:
                setTitle("Active Workout")
                watchCom.sendState(state:workoutState.running.toString())
                pauseResumeButton.setTitle("Pause")
                self.workoutStateLabel.setText("workout: running")
            case .paused:
                setTitle("Paused Workout")
                watchCom.sendState(state:workoutState.paused.toString())
                pauseResumeButton.setTitle("Resume")
                self.workoutStateLabel.setText("workout: paused")
                
            case .ended:
                setTitle("Workout")
                watchCom.sendState(state:workoutState.ended.toString())
                self.workoutStateLabel.setText("workout: ended")
                workoutEvents .removeAll()
            case .notStarted:
                setTitle("Workout")
                watchCom.sendState(state:workoutState.notStarted.toString())
                self.workoutStateLabel.setText("workout: notStarted")
            }
        }
    }//eom
 
    
    // MARK: - Data Queries
    func startQuery(quantityTypeIdentifier: HKQuantityTypeIdentifier)
    {
        let datePredicate = HKQuery.predicateForSamples(withStart: workoutStartDate, end: nil, options: .strictStartDate)
        let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
        let queryPredicate = NSCompoundPredicate(andPredicateWithSubpredicates:[datePredicate, devicePredicate])
        
        let updateHandler: ((HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void) =
            { query, samples, deletedObjects, queryAnchor, error in
            self.process(samples: samples, quantityTypeIdentifier: quantityTypeIdentifier)
        }
        
        let query = HKAnchoredObjectQuery(type: HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier)!,
                                          predicate: queryPredicate,
                                          anchor: nil,
                                          limit: HKObjectQueryNoLimit,
                                          resultsHandler: updateHandler)
        query.updateHandler = updateHandler
        healthStore.execute(query)
        
        activeDataQueries.append(query)
    }//eom
    
    func process(samples: [HKSample]?, quantityTypeIdentifier: HKQuantityTypeIdentifier)
    {
        DispatchQueue.main.async
        {
            [weak self] in
            
            guard let strongSelf = self, !strongSelf.isPaused else { return }
            
            if let quantitySamples = samples as? [HKQuantitySample]
            {
                for sample in quantitySamples
                {
                    if quantityTypeIdentifier == HKQuantityTypeIdentifier.heartRate
                    {
                        let hrUnit = HKUnit(from: "count/min")
                        let heartRate = sample.quantity.doubleValue(for: hrUnit)
                        strongSelf.heartRateLabel.setText("\(heartRate) bpm")
                    }
                    else
                    {
                        strongSelf.messageLabel.setText("unknown type! \(quantityTypeIdentifier)")
                    }
                }//eofl
            }//eo-samples
            strongSelf.updateLabels()
        }
    }//eom
    
    //MARK: (Start/Stop/Pause|Resume) Data Queries
    func startAccumulatingData(startDate: Date) {
        startQuery(quantityTypeIdentifier: HKQuantityTypeIdentifier.heartRate)
        
        startTimer()
    }//eom
    
    func stopAccumulatingData() {
        for query in activeDataQueries {
            healthStore.stop(query)
        }
        
        activeDataQueries.removeAll()
        stopTimer()
        
        if self.workoutSession != nil
        {
            self.workoutSession = nil
        }
        
    }//eom
    
    func pauseAccumulatingData() {
        DispatchQueue.main.sync {
            isPaused = true
        }
    }//eom
    
    func resumeAccumulatingData() {
        DispatchQueue.main.sync {
            isPaused = false
        }
    }//eom
    
    // MARK: - Timer
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1,
                                     target: self,
                                     selector: #selector(timerDidFire),
                                     userInfo: nil,
                                     repeats: true)
    }//eom
    
    func timerDidFire(timer: Timer) {
         updateLabels()
    }//eom
    
    func stopTimer() {
        timer?.invalidate()
    }//eom
    
    //MARK: - Current State
    func sendCurrentState()
    {
        func updateState()
        {
            if let session = workoutSession
            {
                switch session.state {
                case .running:
                    watchCom.sendState(state:workoutState.running.toString())
                case .paused:
                    watchCom.sendState(state:workoutState.paused.toString())
                case .ended:
                    watchCom.sendState(state:workoutState.ended.toString())
                case .notStarted:
                    watchCom.sendState(state:workoutState.notStarted.toString())
                }
            }
        }//eom
    }//eom
    
    //MARK: - Workout Handlers
    func handleWorkoutCommand(commandReceived:String)
    {
        switch commandReceived
        {
            case "Start":
                self.prepDefaultAndStartWorkout()
                break
                
            case "Stop":
                self.stopWorkoutSession()
                break
                
            case "Pause":
                self.pauseWorkoutSession()
                break
            
            case "Info":
                self.sendCurrentState()
                break
            default:
                break
        }
    }//eom
    
    //MARK: - Workout Session (Stop / Pause)
    private func stopWorkoutSession()
    {
        messageLabel.setText(" ")
        workoutStateLabel.setText(" ")
        
        workoutEndDate = Date()
        healthStore.end(workoutSession!)
    }//eom
    
    private func pauseWorkoutSession()
    {
        workoutStateLabel.setText(" ")
        
        if let session = workoutSession
        {
            switch session.state
            {
                case .running:
                    if #available(watchOSApplicationExtension 3.0, *) {
                        healthStore.pause(_: session)
                    } else {
                        // Fallback on earlier versions
                }
                case .paused:
                    if #available(watchOSApplicationExtension 3.0, *) {
                        healthStore.resumeWorkoutSession(_: session)
                    } else {
                        // Fallback on earlier versions
                }
                default:
                    break
            }
        }
    }//eom
    
    //MARK: Workout Session (Start)
    @available(watchOSApplicationExtension 2.0, *)
    private func prepDefaultAndStartWorkout()
    {
//        guard workoutSession == nil else
//        {
//            messageLabel.setText("wk. alr. started")
//            return
//        }
        
        messageLabel.setText(" ")
        
        let workoutActivity:HKWorkoutActivityType = HKWorkoutActivityType.other
        let workoutLocation:HKWorkoutSessionLocationType = HKWorkoutSessionLocationType.unknown
        
        workoutSession = HKWorkoutSession(activityType: workoutActivity, locationType: workoutLocation)
        
        workoutSession?.delegate = self
        
        workoutStartDate = Date()
        healthStore.start(workoutSession!)
        
        messageLabel.setText("workout setup")

    }//eom
    
    
    @available(watchOSApplicationExtension 3.0, *)
    private func prepWorkoutConfigAndAttemptToStartWorkout(workoutConfig:HKWorkoutConfiguration?)
    {
//        guard workoutSession == nil else
//        {
//            messageLabel.setText("wk. alr. started")
//            return
//        }
        
        /* attempting to set workout with workconfig provided */
        if workoutConfig != nil
        {
            do
            {
                workoutSession = try HKWorkoutSession(configuration: workoutConfig!)
                workoutSession?.delegate = self
                
                workoutStartDate = Date()
                healthStore.start(workoutSession!)
                
                messageLabel.setText("workout setup")
            }
            catch
            {
                messageLabel.setText("un-able to start workout")
                
                /* provided workout config failed, attempting generic/defualt config */
                prepDefaultAndStartWorkout()
            }
        }
        /* no config, resorting to default config */
        else
        {
            prepDefaultAndStartWorkout()
        }
    }//eom
    
    // MARK: - HKWorkoutSessionDelegate
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        //notify iphone
        messageLabel.setText("wk error: \(error.localizedDescription)")
    }//eom
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didGenerate event: HKWorkoutEvent) {
        workoutEvents.append(event)
    }//eom
    
    func workoutSession(_ workoutSession: HKWorkoutSession,
                        didChangeTo toState: HKWorkoutSessionState,
                        from fromState: HKWorkoutSessionState,
                        date: Date)
    {
        switch toState
        {
            case .running:
                if fromState == .notStarted
                {
                    startAccumulatingData(startDate: workoutStartDate!)
                } else {
                    resumeAccumulatingData()
                }
                
            case .paused:
                pauseAccumulatingData()
                
            case .ended:
                stopAccumulatingData()
                
            default:
                break
        }
        
        updateState()
    }//eom
    
    // MARK: - Communicator Delegates
    func watchCommunicator(stateChanged: connectionState) {
        switch stateChanged
        {
            case .activated:
                messageLabel.setText("comm activated")
                break
            case .deactivated:
                messageLabel.setText("comm deactived")
                watchCom.setup()
                break
            case .inactive:
                //stop sending messages
                messageLabel.setText("comm inactive")
                break
            case .notActivated:
                messageLabel.setText("comm not actived")
                break
            case .notSupported:
                messageLabel.setText("comm not supported")
                //let user know
                break
            case .unknownActivation:
                messageLabel.setText("comm unknown")
                break
            default:
                break
        }
    }//eom
    
    func watchCommunicator(messageReceived: [String : Any] )->[String : Any]
    {
        print("message Received \(messageReceived)")
        
        if let commandRcvd:String = messageReceived["Command"] as! String?
        {
            handleWorkoutCommand(commandReceived: commandRcvd)
        }//eo-command
        
        let message = ["reply":"msg rcvd"]
        return message
        
    }//eom
    
    func watchCommunicator(contextReceived: [String : Any] )
    {
        print("context received \(contextReceived)")
        
        if let commandRcvd:String = contextReceived["Command"] as! String?
        {
            self.handleWorkoutCommand(commandReceived: commandRcvd)
        }//eo-command
    }//eom
    
}//eoc
