//
//  InterfaceController.swift
//  EggTimer WatchKit Extension
//
//  Created by Luis Castillo on 1/4/16.
//  Copyright © 2016 Luis Castillo. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    
    @IBOutlet var image:WKInterfaceImage!
    
    @IBOutlet var titleLabel:WKInterfaceLabel!
    
    @IBOutlet var timerLabel:WKInterfaceTimer!
    
    @IBOutlet var softButton:WKInterfaceButton!
    
    @IBOutlet var mediumButton:WKInterfaceButton!
    
    @IBOutlet var hardButton:WKInterfaceButton!
    
    @IBOutlet var resetButton:WKInterfaceButton!
    
    
    //vars
    var timer:NSTimer!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        //hidden Timer & reset
        timerLabel.setHidden(true)
        resetButton.setHidden(true)
        
    }//eom

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }//eom

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }//eom
    
    
    //MARK:Actions
    @IBAction func softPressed()
    {
        startTimer(30)
    }//eoa

    @IBAction func mediumPressed()
    {
        startTimer(60)
    }//eoa
    
    @IBAction func hardPressed()
    {
        
        startTimer(90)
    }//eoa
    
    @IBAction func resetPressed()
    {
        timerLabel.setHidden(true)
        resetButton.setHidden(true)
        //
        softButton.setHidden(false)
        mediumButton.setHidden(false)
        hardButton.setHidden(false)

    }//eoa
    
    //MARK: Timer
    func startTimer(timeInSeconds:Float)
    {
        let timeDesired:NSTimeInterval = NSTimeInterval(timeInSeconds)
        
        let timeCalc:NSDate = NSDate(timeInterval: timeDesired, sinceDate: NSDate())
        timerLabel.setDate(timeCalc)
        timerLabel.start()
        
        
        timerLabel.setHidden(false)
        softButton.setHidden(true)
        mediumButton.setHidden(true)
        hardButton.setHidden(true)
        resetButton.setHidden(false)
        
        timer = NSTimer.scheduledTimerWithTimeInterval(timeDesired, target: self, selector: Selector("TimerHasStopped"), userInfo: nil, repeats: false)
        
    }//eom
    
    func TimerHasStopped()
    {
        timer.invalidate()
        
        timerLabel.setHidden(true)
        resetButton.setHidden(true)
        //
        softButton.setHidden(false)
        mediumButton.setHidden(false)
        hardButton.setHidden(false)
        
    }//eom
    
    //MARK:

}
