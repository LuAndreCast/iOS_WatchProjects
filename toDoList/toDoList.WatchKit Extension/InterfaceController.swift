//
//  InterfaceController.swift
//  toDoList.WatchKit Extension
//
//  Created by Luis Castillo on 1/7/16.
//  Copyright © 2016 Luis Castillo. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController
{
    var defaults = NSUserDefaults(suiteName: "group.com.lac.toDoList")
    
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
