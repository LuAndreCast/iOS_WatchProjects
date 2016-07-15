//
//  FirstViewController.swift
//  toDoList
//
//  Created by Luis Castillo on 1/7/16.
//  Copyright © 2016 Luis Castillo. All rights reserved.
//

import UIKit

var toDoList = [String]()

var defaults = NSUserDefaults(suiteName: "group.com.lac.toDoList")

let storageKey:String = "toDoList"

class FirstViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    //MARK: View Loading
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        
        print("[list] \(toDoList.debugDescription)")
        
        self.tableView.reloadData()
        
    }//eom

    //MARK: Memory
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: Get List
    func getList()
    {
        if defaults?.objectForKey(storageKey) != nil
        {
            if let list = defaults?.objectForKey(storageKey) as? [String]
            {
                toDoList = list
            }
        
        }//eo
    
    }//eom
    
    
    //MARK: Tableview delegates
    func tableView(tableView: UITableView, numberOfRowsInSection section:Int)->Int
    {
        return toDoList.count
    }//eom
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
    
        //cell
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "toDoCell")
        cell.textLabel?.text = ""
        
        //cell - data
        let index = indexPath.row
        if let currItem:String = toDoList[index]
        {
            cell.textLabel?.text = currItem
         }
        
        return cell
    }//eom
    
    //delete
    func tableView(tableView: UITableView,
        commitEditingStyle editingStyle: UITableViewCellEditingStyle,
        forRowAtIndexPath indexPath: NSIndexPath)
    {
        if editingStyle == UITableViewCellEditingStyle.Delete
        {
            //removing from list
            let index = indexPath.row
            toDoList.removeAtIndex(index)
            
            //updating data stored
            defaults?.setObject(toDoList, forKey: storageKey)
            
            defaults?.synchronize()
            
            //reloading data
            self.tableView.reloadData()
        }
    
    }//eom
}

