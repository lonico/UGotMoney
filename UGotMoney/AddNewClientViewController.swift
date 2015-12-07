//
//  AddNewClientViewController.swift
//  UGotMoney
//
//  Created by Laurent Nicolas on 11/15/15.
//  Copyright © 2015 Laurent Nicolas. All rights reserved.
//

import UIKit

protocol AddNewClientViewControllerDelegate {
    func didFinishAddingClient(value: Person!)
}

// Controller to enter client data
class AddNewClientViewController: UIViewController {
    
    @IBOutlet var firstNameLabel: UILabel!
    @IBOutlet var lastNameLabel: UILabel!
    
    @IBOutlet var firstNameTF: UITextField!
    @IBOutlet var middleNameTF: UITextField!
    @IBOutlet var lastNameTF: UITextField!
    
    @IBOutlet var addButton: UIBarButtonItem!
    
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
    
    @IBAction func addButtonTouchUp(sender: UIBarButtonItem) {
        
        let firstName = firstNameTF.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        let middleName = middleNameTF.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        let lastName = lastNameTF.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        let name = Person.name(firstName, middleName: middleName, lastName: lastName)
        if Person.getClientNamesLowerCase(activeOnly: true).contains(name.lowercaseString) {
            AlertController.Alert(msg: "A person with the same name already exists", title: AlertController.AlertTitle.DuplicateEntry).showAlert(self)
            return
        }
        if Person.getClientNamesLowerCase(activeOnly: false).contains(name.lowercaseString) {
            let alert = AlertController.Alert(msg: "An inactive person with the same name already exists - do you want to reactivate this client?", title: AlertController.AlertTitle.DuplicateEntry, style: .ActionSheet, actionTitle: AlertController.AlertActionTitle.Enable) { action in
    
                if action.title == AlertController.AlertActionTitle.Enable {
                    let person = Person.getPerson(name, activeOnly: false)
                    person.activate()
                    let nserror = CoreDataStackManager.sharedInstance().saveContext()
                    if nserror != nil {
                        AlertController.Alert(msg: nserror.localizedDescription, title: "Error!").showAlert(self)
                    } else {
                        self.delegate.didFinishAddingClient(person)
                    }
                }
            }
            alert.showAlert(self)
            return
        }
        let context = CoreDataStackManager.sharedInstance().managedObjectContext
        let person = Person(firstName: firstName, middleName: middleName, lastName: lastName, id: nil, context: context)
        //print(person)
        let nserror = CoreDataStackManager.sharedInstance().saveContext()
        if nserror != nil {
            AlertController.Alert(msg: nserror.localizedDescription, title: "Error!").showAlert(self)
            return
        }
        CoreDataStackManager.sharedInstance().saveContext()
        delegate.didFinishAddingClient(person)
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