//
//  AddNewClientViewController.swift
//  UGotMoney
//
//  Created by Laurent Nicolas on 11/15/15.
//  Copyright © 2015 Laurent Nicolas. All rights reserved.
//

import UIKit

protocol AddNewClientViewControllerDelegate {
    func didFinishAddingClient(controller: AddNewClientViewController, value: Person!)
}

class AddNewClientViewController: UIViewController {
    
    @IBOutlet var firstNameLabel: UILabel!
    @IBOutlet var lastNameLabel: UILabel!
    
    @IBOutlet var firstNameTF: UITextField!
    @IBOutlet var middleNameTF: UITextField!
    @IBOutlet var lastNameTF: UITextField!
    
    @IBOutlet var addButton: UIButton!
    
    var delegate: AddNewClientViewControllerDelegate! = nil
    
    var hasFirstName = false
    var hasLastName = false
    
    override func viewWillAppear(animated: Bool) {
        
        firstNameLabel.textColor = UIColor.redColor()
        lastNameLabel.textColor = UIColor.redColor()
        
        firstNameTF.delegate = self
        middleNameTF.delegate = self
        lastNameTF.delegate = self
        
        firstNameTF.enabled = true
        firstNameTF.enablesReturnKeyAutomatically = true
        lastNameTF.enabled = true
        lastNameTF.enablesReturnKeyAutomatically = true
        
        addButton.enabled = false
        view.endEditing(true)
    }
    
    @IBAction func addButtonTouchUp(sender: UIButton) {
        
        let context = CoreDataStackManager.sharedInstance().managedObjectContext
        let person = Person(firstName: firstNameTF.text!, middleName: middleNameTF.text, lastName: lastNameTF.text!, id: nil, context: context)
        print(person)
        let nserror = CoreDataStackManager.sharedInstance().saveContext()
        if nserror != nil {
            AlertController.Alert(msg: nserror.localizedDescription, title: "Error!").showAlert(self)
            return
        }
        delegate.didFinishAddingClient(self, value: person)
    }
    
    @IBAction func cancelButtonTouchUp(sender: UIButton) {
        view.endEditing(true)
        delegate.didFinishAddingClient(self, value: nil)
    }
}

extension AddNewClientViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        enableAddButton(textField)
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        
        enableAddButton(textField)
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    
        enableAddButton(textField, range: range, replacementString: string)
        return true
    }
    
    func enableAddButton(textField: UITextField) {
        
        let emptyText = textField.text == ""
        enableAddButton(textField, emptyText: emptyText)
    }
    
    func enableAddButton(textField: UITextField, range: NSRange ,replacementString: String) {
        
        let newText = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: replacementString)
        let emptyText = newText == ""
        enableAddButton(textField, emptyText: emptyText)
    }
    
    func enableAddButton(textField: UITextField, emptyText: Bool) {
    
        let color = emptyText ? UIColor.redColor() : UIColor.blueColor()
        if textField == firstNameTF {
            firstNameLabel.textColor = color
            hasFirstName = !emptyText
        } else if textField == lastNameTF {
            lastNameLabel.textColor = color
            hasLastName = !emptyText
        }
        addButton.enabled = hasLastName && hasFirstName
    }
}