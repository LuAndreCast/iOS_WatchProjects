//
//  StreamResultsTableViewController.swift
//  HealthWatchExample
//
//  Created by Luis Castillo on 2/5/16.
//  Copyright © 2016 LC. All rights reserved.
//

import UIKit
import HealthKit

class StreamResultsTableViewController: UITableViewController {

    let results:NSArray?
    let heartRateUnit:HKUnit = HKUnit(fromString: "count/min")
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

    }//eom


    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return results?.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }


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
