//
//  InterfaceController.swift
//  timesTables WatchKit Extension
//
//  Created by Luis Castillo on 1/6/16.
//  Copyright © 2016 Luis Castillo. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    @IBOutlet var timesSlider: WKInterfaceSlider!
    
    @IBOutlet var timesTable: WKInterfaceTable!
    
    //row info
    let timesRowName:String = "timesRow"
    let numberOfRow:Int = 10
    
    //table info
    let startingValue = 10
    
    override func awakeWithContext(context: AnyObject?)
    {
        super.awakeWithContext(context)
        
        //setting up rows in table
        self.timesTable.setNumberOfRows(numberOfRow, withRowType: timesRowName)
        
        //setting value
        self.timesSlider.setValue( Float(startingValue) )
        
        //updating rows
        self.updateTableRow(startingValue)

    }//eom

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }//eom

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        
    }//eom
    
    //MARK:
    
    func updateTableRow(newTableValue:Int)
    {
        
        for(var iter = 0 ; iter < numberOfRow; iter++)
        {
            let currRowValue = newTableValue * iter
            
            //current row
            let currRow = timesTable.rowControllerAtIndex(iter) as? timesTableRowController
            currRow?.timesLabel.setText("\(newTableValue) X \(iter) = \(currRowValue)")
            
        }//eofl
        
    }//eom
    
    
    @IBAction func timesValueChanged(value: Float)
    {
        let numberChanged:Int = Int(value)
        
        self.updateTableRow(numberChanged)
        
    }//eo-a
    
    
    
}//eoc
