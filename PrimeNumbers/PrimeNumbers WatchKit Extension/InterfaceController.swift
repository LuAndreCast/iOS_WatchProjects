//
//  InterfaceController.swift
//  PrimeNumbers WatchKit Extension
//
//  Created by Luis Castillo on 1/6/16.
//  Copyright © 2016 Luis Castillo. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    
    @IBOutlet var numberSlider: WKInterfaceSlider!
    
    @IBOutlet var primeQLabel: WKInterfaceLabel!
    
    @IBOutlet var Updatebutton: WKInterfaceButton!
    
    @IBOutlet var resultLabel: WKInterfaceLabel!
    
    var number:Int = 50
    
    override func awakeWithContext(context: AnyObject?)
    {
        super.awakeWithContext(context)
        
        numberSlider.setValue( Float(number) )
        
        primeQLabel.setText("is \(number) prime?")
        resultLabel.setText("")
    }//eom

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }//eom

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }//eom
    
    @IBAction func sliderValueChanged(value: Float)
    {
        number = Int(value)
        
        //setting up new question
        primeQLabel.setText("is \(number) Prime?")
        
        //clearing results since its a new Question
        resultLabel.setText("")
    }//eo-a
    
    
    
    @IBAction func findOut()
    {
        //checking if prime
        var isPrime:Bool = true
        if number == 1 || number == 0
        {
            isPrime = false
        }
        
        if number != 2 && number != 1
        {
            for (var iter = 2; iter < number ;iter++)
            {
                if number % iter == 0
                {
                    isPrime = false
                }
            }//eofl
        }
        
        //print("is prime? \(isPrime)")//testing
        
        //update result
        if isPrime
        {
            resultLabel.setText("\(number) is Prime")
        }
        else
        {
            resultLabel.setText("\(number) is NOT Prime")
        }
        
    }//eo-a
    
    
    
    
    
    
    
    
    
    
}
