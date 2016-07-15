//
//  InterfaceController.swift
//  tipCalculator WatchKit Extension
//
//  Created by Luis Castillo on 1/20/16.
//  Copyright © 2016 LC. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    
    @IBOutlet var inputAmountLabel: WKInterfaceLabel!
    
    @IBOutlet var decreaseAmountButton: WKInterfaceButton!
    
    @IBOutlet var increaseAmountButton: WKInterfaceButton!
    
    @IBOutlet var percent15Label: WKInterfaceLabel!
    @IBOutlet var percent18Label: WKInterfaceLabel!
    @IBOutlet var percent20Label: WKInterfaceLabel!
    
    var inputAmount:Double = 50.0
    
    //MARK: - View Loading
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }//eom
    
    override func willActivate()
    {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        self.updateLabelAmounts()
        
    }//eom
    
    override func didDeactivate()
    {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }//eom
    
    //MARK: - Label Update
    func updateLabelAmounts()
    {
        let valueToDisplay = "$ \(inputAmount)"
        self.inputAmountLabel.setText(valueToDisplay)
        
        self.updatePercentValues()
    }//eom
    
    //MARK: - Calculations
    
    @IBAction func increaseAmount()
    {
        self.inputAmount += 2.5
        
        self.updateLabelAmounts()
    }//eo-a
    
    
    @IBAction func decreaseAmount()
    {
        inputAmount -= 2.5
        if inputAmount < 0
        {
            inputAmount = 0
        }
        
        self.updateLabelAmounts()
    }//eo-a
    
    
    func updatePercentValues()
    {
        var calcValue = 0.0
        var valueToDisplay = ""
        
        //15
        calcValue = inputAmount * 15 / 100
        valueToDisplay = "$ \(calcValue)"
        self.percent15Label.setText(valueToDisplay)
        
        //18
        calcValue = inputAmount * 18 / 100
        valueToDisplay = "$ \(calcValue)"
        self.percent18Label.setText(valueToDisplay)
        
        //20
        calcValue = inputAmount * 20 / 100
        valueToDisplay = "$ \(calcValue)"
        self.percent20Label.setText(valueToDisplay)
    }//eom

}
