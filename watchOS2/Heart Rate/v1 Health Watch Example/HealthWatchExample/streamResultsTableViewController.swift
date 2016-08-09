//
//  streamResultsTableViewController.swift
//  HealthWatchExample
//
//  Created by Luis Castillo on 2/8/16.
//  Copyright © 2016 LC. All rights reserved.
//

import UIKit

class streamResultsTableViewController: UITableViewController {

    
    var results:NSMutableArray = NSMutableArray()
    
    
    
    //MARK: - View Loading
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        //register NIB
        let myNIB:UINib = UINib(nibName: "resultsTableViewCell", bundle: nil)
        self.tableView .registerNib(myNIB, forCellReuseIdentifier: "resultCell")
        
    }//eom

    // MARK: - Add / Removing Content
    func updateContent(newContent:NSDictionary)
    {
        results.insertObject(newContent, atIndex: 0)
        
        self.tableView.reloadData()
    }//eom

    
    func clearContent()
    {
        results.removeAllObjects()
        self.tableView.reloadData()
    }//eom
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return results.count
    }//eom

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell:resultsTableViewCell = (tableView.dequeueReusableCellWithIdentifier("resultCell") as? resultsTableViewCell)!

        let index:Int = indexPath.row
        if let currResult:NSDictionary = results .objectAtIndex(index) as? NSDictionary
        {
            //date
            if let date = currResult.objectForKey("date") as? String
            {
                cell.dateLabel.text = date
            }
            
            //time
            if let time = currResult.objectForKey("time") as? String
            {
                cell.timeLabel.text = time
            }
     
            //heart rate
            if let rate = currResult.objectForKey("rate")
            {
                cell.heartRateLabel.text = "\(rate)"
            }
        }
        
        return cell
    }//eom
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
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
