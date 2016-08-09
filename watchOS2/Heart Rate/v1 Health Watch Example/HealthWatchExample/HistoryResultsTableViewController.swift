//
//  HealthResultsTableViewController.swift
//  HealthWatchExample
//
//  Created by Luis Castillo on 2/3/16.
//  Copyright © 2016 LC. All rights reserved.
//

import UIKit
import HealthKit

class HistoryResultsTableViewController: UITableViewController {

    //properties
    var results:[HKSample]?
    let heartRateUnit:HKUnit = HKUnit(fromString: "count/min")
    
    
    //MARK: - View Loading
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //register NIB
        let myNIB:UINib = UINib(nibName: "resultsTableViewCell", bundle: nil)
        self.tableView .registerNib(myNIB, forCellReuseIdentifier: "resultCell")
        
    }

    func updateContent(newContent: [HKSample])
    {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.results = newContent
            self.tableView.reloadData()
        }
    }//eom
    
    
    func clearContent()
    {
        self.results?.removeAll()
        self.tableView.reloadData()
    }//eom
    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }//eom

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard results?.count > 0 else {  return 0 }
        
        return results!.count
    }//eom

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell:resultsTableViewCell = (tableView.dequeueReusableCellWithIdentifier("resultCell") as? resultsTableViewCell)!
        
        let index = indexPath.row
        guard let currData:HKQuantitySample = results?[index] as? HKQuantitySample else { return cell }
        
        //date
        let currDate:NSDate = currData.startDate
        let dateFormatter:NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM-dd-yy"
        let date:String = dateFormatter.stringFromDate(currDate)
        cell.dateLabel.text = date
        
        //time
         dateFormatter.dateFormat = "HH:mm:ss a"
        let time:String = dateFormatter.stringFromDate(currDate)
        cell.timeLabel.text = time
        
        //heart rate
        cell.heartRateLabel.text = "\(currData.quantity.doubleValueForUnit(heartRateUnit))"
        
        return cell
    }//eom
    


    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

    
    
    //MARK: Memory
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
