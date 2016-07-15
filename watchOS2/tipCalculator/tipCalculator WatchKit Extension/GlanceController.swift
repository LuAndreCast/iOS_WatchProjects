//
//  GlanceController.swift
//  tipCalculator WatchKit Extension
//
//  Created by Luis Castillo on 1/20/16.
//  Copyright © 2016 LC. All rights reserved.
//

import WatchKit
import Foundation


class GlanceController: WKInterfaceController
{

    @IBOutlet var factLabel: WKInterfaceLabel!
    
    
    
    //MARK: View Loading
    override func awakeWithContext(context: AnyObject?)
    {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }//eom

    override func willActivate()
    {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        self.loadFact()
    }//eom

    override func didDeactivate()
    {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }//eom
    
    
    //MARK: 
    func loadFact()
    {
        let pathOfFile = NSBundle .mainBundle() .pathForResource("TippingFacts", ofType: "plist")
        if pathOfFile?.isEmpty == false
        {
            if let facts:NSArray = NSArray(contentsOfFile: pathOfFile!)
            {
                if facts.count > 0
                {
                    let randomFact = facts.objectAtIndex(0)
                    //print("facts \(randomFact)")
                    
                    self.factLabel.setText("\(randomFact)")
                }
            }
        }
        
    }//eom

}
