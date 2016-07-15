//
//  InterfaceController.swift
//  RandomNumberGenerator WatchKit Extension
//
//  Created by Luis Castillo on 1/4/16.
//  Copyright © 2016 Luis Castillo. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController
{
    
    
    @IBOutlet var tapButton: WKInterfaceButton!
    @IBOutlet var randomNumberLabel: WKInterfaceLabel!
    
    @IBOutlet var decreaseLimitButton: WKInterfaceButton!
    @IBOutlet var increaseLimitButton: WKInterfaceButton!
    @IBOutlet var limitNumberLabel: WKInterfaceLabel!
    
    //Vars
    var limitNum:Int = 50
    
    

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        randomNumberLabel.setText("")
        limitNumberLabel.setText("\(limitNum)")
        // Configure interface objects here.
    }//eom

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }//eom

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }//eom
    
    //MARK: Random Generator
    
    @IBAction func createRandomNumber() {
        
        
        
        let limit:UInt32 = UInt32(limitNum)
        let randomNumber = Int( arc4random_uniform(limit) )
        
        randomNumberLabel.setText("\(randomNumber)")
        
    }//eoa
    
    //MARK: Limit
    
    @IBAction func decreaseLimit() {
    
        limitNum--
        
        if limitNum < 2
        {
            limitNum = 2
        }
        
         limitNumberLabel.setText("\(limitNum)")
        
    }//eoa
    
    @IBAction func increaseLimit() {
       
        limitNum++
        
         limitNumberLabel.setText("\(limitNum)")
        
    }//eoa

}
