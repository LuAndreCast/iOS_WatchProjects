//
//  ViewController.swift
//  HealthWatchExample
//
//  Created by Luis Castillo on 2/2/16.
//  Copyright © 2016 LC. All rights reserved.
//

import UIKit
import HealthKit
import WatchConnectivity

class ViewController: UIViewController,WCSessionDelegate
{

    //UI
    @IBOutlet weak var healthSegmentedControl: UISegmentedControl!
    @IBOutlet weak var historyContainerView: UIView!
    @IBOutlet weak var streamContainerView: UIView!
    
    //properties
    var historyResultsTable:HistoryResultsTableViewController?
    var streamResultsTable:streamResultsTableViewController?
    //
    let health: HKHealthStore = HKHealthStore()
    //let heartRateUnit:HKUnit = HKUnit.countUnit().unitDividedByUnit(HKUnit.minuteUnit())
    let heartRateUnit:HKUnit = HKUnit(fromString: "count/min")
    let heartRateType:HKQuantityType   = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)!
    var heartRateQuery:HKSampleQuery?
    
    //anchored Query - 
    var anchoredHeartRateQuery:HKQuery?
    var anchor:HKQueryAnchor = HKQueryAnchor(fromValue: 0)
    
    
    let session:WCSession = WCSession.defaultSession()
    
    
    //MARK: - View Loading
    override func viewDidLoad()
    {
        super.viewDidLoad()
//        self.setupResultsTable()
//      
//        self.startHealthKitIfAvaliable()
        
        
        //sessions
        session.delegate = self
        session.activateSession()
    }//eom
    
   
//    //MARK: - Authorization
//    func requestAuthorization()
//    {
//        //reading
//        let readingTypes:Set = Set( [heartRateType] )
//        
//        //writing
//        let writingTypes:Set = Set( [heartRateType] )
//        
//        //auth request
//        health.requestAuthorizationToShareTypes(writingTypes, readTypes: readingTypes) { (success, error) -> Void in
//            
//            if error != nil
//            {
//                print("error \(error?.localizedDescription)")
//            }
//            else if success
//            {
//                self.getTodaysHeartRates()
//            }
//        }//eo-request
//    }//eom
//    
//    //MARK: - HealthKit
//    func startHealthKitIfAvaliable()
//    {
//        if HKHealthStore.isHealthDataAvailable()
//        {
//            self.requestAuthorization()
//        }
//    
//    }//eom
//    
//    @IBAction func healthChoiceChanged(sender: UISegmentedControl)
//    {
//        switch sender.selectedSegmentIndex
//        {
//            case 1:
//                self.historyContainerView.hidden = true
//                self.streamContainerView.hidden = false
//                //
//                self.clearHistoryContent()
//                break
//            case 0:
//                self.historyContainerView.hidden = false
//                self.streamContainerView.hidden = true
//                //
//                self.clearStreamContent()
//                self.getTodaysHeartRates()
//                break
//            default:
//                break
//        }
//    }//eo-a
//  
//    
//    //MARK: History
//    func getTodaysHeartRates()
//    {
//       self.health.getTodayHeartRates(25, isOrderAscending: false)
//        { (success, results, error) -> Void in
//        
//            if let errorFound:NSError = error
//            {
//                print("error: \(errorFound)")
//            }
//            else
//            {
//                //print("results: \(results)")
//                
//                //self.printHeartRateInfo(results)
//
//                self.updateHistoryTableViewContent(results)
//            }
//        }//eo
//    }//eom
//    
//    //MARK: - Results Table
//    func setupResultsTable()
//    {
//        let childs = self.childViewControllers
//        
//        guard childs.count > 0 else { return }
//        
//        for child in childs
//        {
//            if let tbvc = child as? HistoryResultsTableViewController
//            {
//                historyResultsTable = tbvc
//            }
//            else if let tbvc = child as? streamResultsTableViewController
//            {
//                streamResultsTable = tbvc
//            }
//        }//eofl
//        
//    }//eom
//    
//    //MARK: History Table
//    func updateHistoryTableViewContent(samples: [HKSample]?)
//    {
//        guard samples?.count > 0 else { return }
//        
//        historyResultsTable?.updateContent(samples!)
//    }//eom
//    
//    func clearHistoryContent()
//    {
//        historyResultsTable?.clearContent()
//    }//eom
//    
//     //MARK: Stream Table
//    func updateStreamTableViewContent(newSample: NSDictionary)
//    {
//        guard newSample.count > 0 else { return }
//        
//        streamResultsTable?.updateContent(newSample)
//    }//eom
//    
//    func clearStreamContent()
//    {
//        streamResultsTable?.clearContent()
//    }//eom
//    
//    //MARK: - Debug
//    private func printHeartRateInfo(results:[HKSample]?)
//    {
//        for iter in (0  ..< results!.count)
//        {
//            guard let currData:HKQuantitySample = results![iter] as? HKQuantitySample else { return }
//            
//            print("[\(iter)]")
//            print("Heart Rate: \(currData.quantity.doubleValueForUnit(heartRateUnit))")
//            print("quantityType: \(currData.quantityType)")
//            print("Start Date: \(currData.startDate)")
//            print("End Date: \(currData.endDate)")
//            print("Metadata: \(currData.metadata)")
//            print("UUID: \(currData.UUID)")
//            print("Source: \(currData.sourceRevision)")
//            print("Device: \(currData.device)")
//            print("---------------------------------\n")
//        }//eofl
//    }//eom
//    
//    
//    //MARK: Background Sessions
//    func session(session: WCSession,
//        didReceiveApplicationContext applicationContext: [String : AnyObject])
//    {
//        dispatch_async( dispatch_get_main_queue() )
//        {
//            var heartRate:String = ""
//            var time:String = ""
//            var date:String = ""
//            
//            if let heartRateReceived:String = applicationContext[ keys.heartRate.rawValue ] as? String
//            {
//                    heartRate = heartRateReceived
//            }
//            
//            if let timeReceived:String = applicationContext[ keys.time.rawValue ] as? String
//            {
//                time = timeReceived
//            }
//            
//            if let dateReceived:String = applicationContext[ keys.date.rawValue ] as? String
//            {
//                date = dateReceived
//            }
//        
//            let newDict:NSDictionary = NSDictionary(dictionary: [ "rate": heartRate , "time" : time, "date":  date ] )
//            self.updateStreamTableViewContent(newDict)
//        }
//    }//eom
//    
    
    //MARK: Memory
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}//eoc

