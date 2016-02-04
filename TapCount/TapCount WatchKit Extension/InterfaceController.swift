//
//  InterfaceController.swift
//  TapCount WatchKit Extension
//
//  Created by Luis Castillo on 12/31/15.
//  Copyright © 2015 Luis Castillo. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    var tapCount:Int = 0
    
    @IBOutlet var fingerTapButton: WKInterfaceButton!
    
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
    
    @IBAction func tapTrigger()
    {
        tapCount++
        print("tap count \(tapCount)")
        fingerTapButton.setTitle("\(tapCount)")
        
    }//eoa

}
