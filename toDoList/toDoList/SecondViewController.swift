//
//  SecondViewController.swift
//  toDoList
//
//  Created by Luis Castillo on 1/7/16.
//  Copyright © 2016 Luis Castillo. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController, UITextFieldDelegate {

    //properties
    @IBOutlet weak var itemToAddTextfield: UITextField!
    
    @IBOutlet weak var addItemButton: UIButton!
    
    
    //MARK: View Loading
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        print("[edit] \(toDoList.debugDescription)")
        
    }//eom
    
    //MARK: Memory
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: Add Item
    
    @IBAction func addItem(sender: AnyObject) {
        
       if let itemToAdd:String = itemToAddTextfield.text
       {
            //adding to list
            toDoList.append(itemToAdd)
        
            //clearing textfield
            itemToAddTextfield.text = ""
            
            //saving data on storage
            defaults?.setObject(toDoList, forKey: storageKey)
            defaults?.synchronize()
        }
        
    }//eo-a
    
    
    //MARK: Textfield delegates
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }//eom
    
    //MARK: dissmiss keyboard
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        
        self.view.endEditing(true)
    }//eom

}

