//
//  StreamingHeartRateController.swift
//  HealthWatchExample
//
//  Created by Luis Castillo on 8/1/16.
//  Copyright © 2016 LC. All rights reserved.
//

import WatchKit
import HealthKit
import WatchConnectivity

class StreamingHeartRateController: WKInterfaceController, WCSessionDelegate
{

    //UI
    @IBOutlet var imageView: WKInterfaceImage!
    @IBOutlet var heartRateLabel: WKInterfaceLabel!
    @IBOutlet var startStopRateButton: WKInterfaceButton!
    @IBOutlet var streamToPhoneSwitch: WKInterfaceSwitch!
    
    //properties
    let health: HKHealthStore = HKHealthStore()
    //let heartRateUnit:HKUnit = HKUnit.countUnit().unitDividedByUnit(HKUnit.minuteUnit())
    let heartRateUnit:HKUnit = HKUnit(fromString: "count/min")
    let heartRateType:HKQuantityType   = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)!
    var heartRateQuery:HKQuery?
    
    let session:WCSession = WCSession.defaultSession()
    
    var isStreaming:Bool = false
    
    
    //
    let manager = HeartRateMonitor()
    
    //MARK: - View Loading
    override func awakeWithContext(context: AnyObject?)
    {
        super.awakeWithContext(context)
        
        self.startHealthKitIfAvaliable()
      
        
        print("awakeWithContext \(self)")
        
        //sessions
        session.delegate = self
        session.activateSession()
        
    }//eom
    
    override func willActivate()
    {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        print("willActivate \(self)")
        
        self.manager.requestPermission()
    }//eom
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        print("didDeactivate \(self)")
    }//eom
    
    //MARK: - Authorization
    func checkAuthorization()
    {
        //        self.requestAuthorization()
    }//eom
    
    func requestAuthorization()
    {
        //reading
        let readingTypes:Set = Set( [heartRateType] )
        
        //writing
        let writingTypes:Set = Set( [heartRateType] )
        
        //auth request
        health.requestAuthorizationToShareTypes(writingTypes, readTypes: readingTypes) { (success, error) -> Void in
            
            if error != nil
            {
                print("error \(error?.localizedDescription)")
            }
            else if success
            {
                print("ready to call heart rate class!")
            }
        }//eo-request
    }//eom
    
    //MARK: - HealthKit
    func startHealthKitIfAvaliable()
    {
        if HKHealthStore.isHealthDataAvailable()
        {
            self.checkAuthorization()
        }
    }//eom
    
        private func createStreamingQuery() -> HKQuery
        {
            let queryPredicate  = HKQuery.predicateForSamplesWithStartDate(NSDate(), endDate: nil, options: .None)
    
            let query:HKAnchoredObjectQuery = HKAnchoredObjectQuery(type: self.heartRateType, predicate: queryPredicate, anchor: nil, limit: Int(HKObjectQueryNoLimit))
            { (query:HKAnchoredObjectQuery, samples:[HKSample]?, deletedObjects:[HKDeletedObject]?, anchor:HKQueryAnchor?, error:NSError?) -> Void in
    
                if let errorFound:NSError = error
                {
                    print("query error: \(errorFound.localizedDescription)")
                }
                else
                {
                    self.addSamples(samples)
                }
    
            }//eo-query
    
            query.updateHandler =
                { (query:HKAnchoredObjectQuery, samples:[HKSample]?, deletedObjects:[HKDeletedObject]?, anchor:HKQueryAnchor?, error:NSError?) -> Void in
    
                    if let errorFound:NSError = error
                    {
                        print("query-handler error : \(errorFound.localizedDescription)")
                    }
                    else
                    {
                        self.addSamples(samples)
                    }//eo-non_error
            }//eo-query-handler
    
            return query
        }//eom
    
        private func addSamples(samples: [HKSample]?)
        {
            guard let samples = samples as? [HKQuantitySample] else { return }
            guard let quantity = samples.last?.quantity else { return }
    
            self.heartRateLabel.setText("\(quantity.doubleValueForUnit(heartRateUnit))")
            //printHeartRateInfo(samples)
    
            if isStreaming
            {
                //send to phone
                self.sendDataToPhone(samples.last!)
            }
    
        }//eom
    
    
        //MARK: - Streaming
        func sendDataToPhone(dataSending:HKQuantitySample)
        {
            do
            {
                //heart rate
                let heartRate:String = "\(dataSending.quantity.doubleValueForUnit(heartRateUnit))"
    
                //date
                let currDate:NSDate = dataSending.startDate
                let dateFormatter:NSDateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "MMM-dd-yy"
                let date:String = dateFormatter.stringFromDate(currDate)
    
                //time
                dateFormatter.dateFormat = "HH:mm:ss a"
                let time:String = dateFormatter.stringFromDate(currDate)
    
                //sending message to Phone
                let messageToSend:[String:AnyObject] = [
                                                            keys.heartRate.rawValue: heartRate,
                                                            keys.time.rawValue: time,
                                                            keys.date.rawValue: date,
                                                        ]
    
                print("sending to phone: \n \(messageToSend)")
    
                try session.updateApplicationContext(messageToSend)
            }
            catch let error as NSError
            {
                print("Error when updating application context:  \(error)")
            }
    
        }//eom
    
    
        //MARK: Session Delegates
        func session(session: WCSession,
            didReceiveApplicationContext applicationContext: [String : AnyObject])
        {
            dispatch_async( dispatch_get_main_queue() )
            {
    
            }
        }//eom
    
    
        //MARK:  Stream options
        @IBAction func startStopStream()
        {
            if heartRateQuery != nil
            {
                self.heartRateQuery = nil
                self.imageView.stopAnimating()
    
                self.startStopRateButton.setTitle("Start")
                self.heartRateLabel.setText("- -")
            }
            else
            {
                heartRateQuery = self.createStreamingQuery()
                health.executeQuery(heartRateQuery!)
    
                self.imageView.setImageNamed("Heart")
                self.imageView.startAnimating()
    
                self.startStopRateButton.setTitle("Stop")
            }
        }//eom
    
        @IBAction func streamToPhoneSelectionChanged(value: Bool)
        {
            if value
            {
                isStreaming = true
            }
            else
            {
                isStreaming = false
            }
        }//eo-a
    
    
        //MARK: - Debug
        private func printHeartRateInfo(results:[HKSample]?)
        {
            for iter in (0  ..< results!.count)
            {
                guard let currData:HKQuantitySample = results![iter] as? HKQuantitySample else { return }
    
                print("[\(iter)]")
                print("Heart Rate: \(currData.quantity.doubleValueForUnit(heartRateUnit))")
                print("quantityType: \(currData.quantityType)")
                print("Start Date: \(currData.startDate)")
                print("End Date: \(currData.endDate)")
                print("Metadata: \(currData.metadata)")
                print("UUID: \(currData.UUID)")
                print("Source: \(currData.sourceRevision)")
                print("Device: \(currData.device)")
                print("---------------------------------\n")
            }//eofl
        }//eom

    
}//eoc
