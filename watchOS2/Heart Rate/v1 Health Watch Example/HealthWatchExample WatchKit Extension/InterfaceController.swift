//
//  InterfaceController2.swift
//  HealthWatchExample
//
//  Created by Luis Castillo on 8/1/16.
//  Copyright © 2016 LC. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    
    @IBOutlet var table: WKInterfaceTable!
    
    
    
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        print("awakeWithContext \(self)")
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        self.tableSetup()
        print("willActivate \(self)")
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        print("didDeactivate \(self)")
    }

    
    //MARK: - Table setup
    func tableSetup()  {
        
        let options = ["stream", "request"]
        
        self.table.setRowTypes(options)
    }//eom
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int)
    {
        if rowIndex == 0
        {
            self.pushControllerWithName("streamController", context: nil)
        }
        else if rowIndex == 1
        {
            self.pushControllerWithName("requestController", context: nil)
        }
    }//eom
    
}
