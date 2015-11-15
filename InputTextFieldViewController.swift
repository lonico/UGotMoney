//
//  InputTextFieldViewController.swift
//  UGotMoney
//
//  Created by Laurent Nicolas on 11/14/15.
//  Copyright © 2015 Laurent Nicolas. All rights reserved.
//

import UIKit

protocol InputTextFieldViewControllerDelegate {
    func didFinishEditingInputTextField(controller: InputTextFieldViewController, value: String!)
}

class InputTextFieldViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet var label: UILabel!
    @IBOutlet var textField: UITextField!
    
    var delegate: InputTextFieldViewControllerDelegate! = nil
    var labelText: String!
    var value: String!
    var keyBoardType: UIKeyboardType!
    
    override func viewWillAppear(animated: Bool) {
        
        label.text = labelText
        textField.keyboardType = keyBoardType
        textField.delegate = self
        textField.becomeFirstResponder()
    }
    
    @IBAction func doneButtonTouchUp(sender: UIButton) {
        
        value = textField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        print(">>> value: \(value)")
        delegate.didFinishEditingInputTextField(self, value: value)
    }
    
    @IBAction func cancelButtonTouchUp(sender: UIButton) {
        
        delegate.didFinishEditingInputTextField(self, value: nil)
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        
        value = textField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        print("done with editing: \(value)")
        return true
    }

}