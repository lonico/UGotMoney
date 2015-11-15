//
//  EditPickerValuesViewController.swift
//  UGotMoney
//
//  Created by Laurent Nicolas on 11/14/15.
//  Copyright © 2015 Laurent Nicolas. All rights reserved.
//

//import Foundation
import UIKit

class EditPickerValuesViewController: UIViewController {
    
    var pickerType: String!
    @IBOutlet var tableView: UITableView!
    
    var clients = ["Charlie Brown", "Lucy Ball", "Lucky Luke", "Antonio Banderas", "Patrick Timsit", "Tom Cruise"]
    var paymentValues: [Float]!
    var paymentTypes: [String]!

    override func viewWillAppear(animated: Bool) {
        
        paymentValues = PersistentData.getFees()
        paymentTypes = PersistentData.getPaymentTypes()
        tableView.setEditing(true, animated: true)
    }
    
    @IBAction func addButtonTouchUp(sender: UIBarButtonItem) {
        
        let vc = storyboard?.instantiateViewControllerWithIdentifier("inputTextFieldVC") as! InputTextFieldViewController
        vc.labelText = "Add value for \(pickerType)"
        vc.keyBoardType = getInputType()
        vc.delegate = self
        presentViewController(vc, animated: true, completion: nil)
    }
    
    // MARK: support function for data source
    
    func getCount() -> Int {
        
        var value = 0
        switch pickerType {
        case "Client name":
            value = clients.count
        case "Amount Paid":
            value =  paymentValues.count
        case "Payment type":
            value =  paymentTypes.count
        default:
            print_internal_error()
        }
        return value
    }
    
    func getValue(index: Int) -> String {
        
        var value = ""
        switch pickerType {
        case "Client name":
            value = clients[index]
        case "Amount Paid":
            let fvalue = NSString(format: "%.2f", paymentValues[index])
            value = String(fvalue)
        case "Payment type":
            value = paymentTypes[index]
        default:
            print_internal_error()
        }
        return value
    }
    
    func deleteElement(index: Int) {
        switch pickerType {
        case "Client name":
            clients.removeAtIndex(index)
        case "Amount Paid":
            paymentValues.removeAtIndex(index)
        case "Payment type":
            paymentTypes.removeAtIndex(index)
        default:
            print_internal_error()
        }
    }
    
    func insertElement(value: AnyObject, index: Int) {
        
        switch pickerType {
        case "Client name":
            clients.insert(value as! String, atIndex: index)
        case "Amount Paid":
            let svalue = value as! NSString
            paymentValues.insert(svalue.floatValue, atIndex: index)
        case "Payment type":
            paymentTypes.insert(value as! String, atIndex: index)
        default:
            print_internal_error()
        }
    }
    
    func addElement(value: AnyObject) {
        
        switch pickerType {
        case "Client name":
            if !clients.contains(value as! String) {
                clients.append(value as! String)
            }
        case "Amount Paid":
            let svalue = value as! NSString
            if !paymentValues.contains(svalue.floatValue) {
                paymentValues.append(svalue.floatValue)
            }
        case "Payment type":
            if !paymentTypes.contains(value as! String) {
                paymentTypes.append(value as! String)
            }
        default:
            print_internal_error()
        }
    }
    
    func saveData() {
        
        switch pickerType {
        case "Client name":
            break
        case "Amount Paid":
            PersistentData.storeFees(paymentValues)
        case "Payment type":
            PersistentData.storePaymentTypes(paymentTypes)
        default:
            print_internal_error()
        }
    }
    
    func getInputType() -> UIKeyboardType {
        
        var value: UIKeyboardType
        switch pickerType {
        case "Client name":
            value = .ASCIICapable
        case "Amount Paid":
            value = .DecimalPad
        case "Payment type":
            value = .ASCIICapable
        default:
            value = .ASCIICapable
            print_internal_error()
        }
        return value
    }
    
    func print_internal_error() {
        
        let msg = "ERROR: unexpected pickerType: \(pickerType)"
        print(msg)
    }

}

extension EditPickerValuesViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return getCount()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("basicCell")!
        cell.textLabel?.text = getValue(indexPath.row)
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        switch editingStyle {
        case .Delete:
            print(">>> deleting")
            deleteElement(indexPath.row)
            saveData()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        default:
            print("ERROR: unexpected action: \(editingStyle)")
            break
        }
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        
        print(">>> Moving")
        let value = getValue(sourceIndexPath.row)
        deleteElement(sourceIndexPath.row)
        insertElement(value, index: destinationIndexPath.row)
        saveData()
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return "  Editing values for \(pickerType)"
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    
        return true
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        
        return .Delete
    }
    
}

extension EditPickerValuesViewController: InputTextFieldViewControllerDelegate {
    
    func didFinishEditingInputTextField(controller: InputTextFieldViewController, value: String!) {
        
        controller.dismissViewControllerAnimated(true, completion: nil)
        if value != nil {
            addElement(value)
            saveData()
            tableView.reloadData()
        }
    }
}
