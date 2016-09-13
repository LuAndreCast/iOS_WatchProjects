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

class HeartRateInterfaceController: WKInterfaceController, HKWorkoutSessionDelegate {

//    let heartRate:HKQuantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
    
    //MARK: - Models
    let parentConnector = ParentConnector()
    
    
    //MARK: -Properties
    let healthStore = HKHealthStore()
    var workoutSession : HKWorkoutSession?
    
    var activeDataQueries = [HKQuery]()
    
    var workoutStartDate : Date?
    var workoutEndDate : Date?
    
    var workoutEvents = [HKWorkoutEvent]()
    var metadata = [String: AnyObject]()
    
    //var timer : Timer?
    var isPaused = false
    
    // MARK: IBOutlets
    @IBOutlet var heartRateLabel: WKInterfaceLabel!
    @IBOutlet var messageLabel: WKInterfaceLabel!
    
    @IBOutlet var markerLabel: WKInterfaceLabel!
    
    @IBOutlet var pauseResumeButton : WKInterfaceButton!
    @IBOutlet var stopButton: WKInterfaceButton!
    @IBOutlet var startButton: WKInterfaceButton!
    
    
    // MARK: Interface Controller Overrides
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        /* */
        self.heartRateLabel.setText(" ")
        self.messageLabel.setText(" ")
        
        /* Start a workout session with the configuration */
        if #available(watchOSApplicationExtension 3.0, *)
        {
            let workoutConfiguration:HKWorkoutConfiguration? = context as! HKWorkoutConfiguration?
            self.prepWorkoutConfigAndAttemptToStartWorkout(workoutConfig: workoutConfiguration)
        }
        else
        {
            self.prepDefaultAndStartWorkout()
        }
        
    }//eom
    
    // MARK: UI Actions
    @IBAction func didTapPauseResumeButton()
    {
        if let session = workoutSession
        {
            switch session.state
            {
                case .running:
                    healthStore.pause(_: session)
                case .paused:
                    healthStore.resumeWorkoutSession(_: session)
                default:
                    break
            }
        }
    }
    
    @IBAction func didTapStopButton()
    {
        self.workoutEndDate = Date()
        
        // End the Workout Session
        self.healthStore.end(workoutSession!)
    }
    
    @IBAction func didTapStartButton()
    {
        self.prepDefaultAndStartWorkout()
    }//eom
    
    @available(watchOSApplicationExtension 2.0, *)
    private func prepDefaultAndStartWorkout()
    {
        let workoutActivity:HKWorkoutActivityType = HKWorkoutActivityType.other
        let workoutLocation:HKWorkoutSessionLocationType = HKWorkoutSessionLocationType.unknown
        
        self.workoutSession = HKWorkoutSession(activityType: workoutActivity, locationType: workoutLocation)
        
        self.startWorkoutSession()
    }//eom
    
    
    @available(watchOSApplicationExtension 3.0, *)
    private func prepWorkoutConfigAndAttemptToStartWorkout(workoutConfig:HKWorkoutConfiguration?)
    {
        /* attempting to set workout with workconfig provided */
        if workoutConfig != nil
        {
            do
            {
                self.workoutSession = try HKWorkoutSession(configuration: workoutConfig!)
                self.startWorkoutSession()
            }
            catch
            {
                self.messageLabel.setText("un-able to start workout")
                
                /* provided workout config failed, attempting generic/defualt config */
                self.prepDefaultAndStartWorkout()
            }
        }
        /* no config, resorting to default config */
        else
        {
            self.prepDefaultAndStartWorkout()
        }
    }//eom
    
    private func startWorkoutSession()
    {
        self.workoutSession?.delegate = self
        
        self.workoutStartDate = Date()
        self.healthStore.start(workoutSession!)
        
        self.messageLabel.setText("workout setup")
    }//eom
    
    // MARK: Convenience
    func updateState() {
        if let session = workoutSession
        {
            switch session.state {
            case .running:
                setTitle("Active Workout")
                parentConnector.send(state: "running")
                pauseResumeButton.setTitle("Pause")
                
                self.messageLabel.setText("workout: running")
            case .paused:
                setTitle("Paused Workout")
                parentConnector.send(state: "paused")
                pauseResumeButton.setTitle("Resume")
                self.messageLabel.setText("workout: paused")
                
            case .notStarted, .ended:
                setTitle("Workout")
                parentConnector.send(state: "ended")
                self.messageLabel.setText("workout: ended")
            }
        }
    }
    
    func notifyEvent(_: HKWorkoutEvent)
    {
        weak var weakSelf = self
        
        DispatchQueue.main.async
        {
            weakSelf?.markerLabel.setAlpha(1)
            WKInterfaceDevice.current().play(.notification)
            DispatchQueue.main.asyncAfter (deadline: .now()+1) {
                weakSelf?.markerLabel.setAlpha(0)
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
                        print("unknown type! \(quantityTypeIdentifier) with sample: \(sample)")
                        
                        strongSelf.messageLabel.setText("unknown type! \(quantityTypeIdentifier)")
                    }
                }//eofl
            }
        }
    }//eom
    
    //MARK: (Start/Stop/Pause|Resume) Data Queries
    func startAccumulatingData(startDate: Date) {
        startQuery(quantityTypeIdentifier: HKQuantityTypeIdentifier.heartRate)
        
        //startTimer()
    }//eom
    
    func stopAccumulatingData() {
        for query in activeDataQueries {
            healthStore.stop(query)
        }
        
        activeDataQueries.removeAll()
        //stopTimer()
        
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
//    func startTimer() {
//        timer = Timer.scheduledTimer(timeInterval: 1,
//                                     target: self,
//                                     selector: #selector(timerDidFire),
//                                     userInfo: nil,
//                                     repeats: true)
//    }//eom
//    
//    func timerDidFire(timer: Timer) {
//        
//    }//eom
//    
//    func stopTimer() {
//        timer?.invalidate()
//    }//eom
    
    // MARK: - HKWorkoutSessionDelegate
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("workout session did fail with error: \(error)")
        
        //notify iphone
        self.messageLabel.setText("workout error: \(error.localizedDescription)")
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
    
    
    
}//eoc
