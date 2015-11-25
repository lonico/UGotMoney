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
    
    var clientsDict: [String: Person]!
    var clients: [String]!
    var paymentValues: [Float]!
    var paymentTypes: [String]!
    var ICDs: [String]!

    override func viewWillAppear(animated: Bool) {
        
        print(">>> editPickerValues \(__FUNCTION__)")
        clientsDict = Person.getClientNamesDict()
        clients = Person.getClientNames()
        paymentValues = PersistentData.getFees()
        paymentTypes = PersistentData.getPaymentTypes()
        ICDs = PersistentData.getICDs()
        tableView.setEditing(true, animated: true)
    }
    
    @IBAction func addButtonTouchUp(sender: UIBarButtonItem) {
        
        switch pickerType {
        case "Client name":
            let vc = storyboard?.instantiateViewControllerWithIdentifier("addNewClientVC") as! AddNewClientViewController
            vc.delegate = self
            presentViewController(vc, animated: true, completion: nil)
        case "Amount paid", "Payment type":
            let vc = storyboard?.instantiateViewControllerWithIdentifier("inputTextFieldVC") as! InputTextFieldViewController
            vc.labelText = "Add value for \(pickerType)"
            vc.keyBoardType = getInputType()
            vc.delegate = self
            presentViewController(vc, animated: true, completion: nil)
        case "ICD":
            print("TODO")
            let vc = storyboard?.instantiateViewControllerWithIdentifier("searchICDVC") as! SearchICDViewController
            navigationController?.pushViewController(vc, animated: true)
            //presentViewController(vc, animated: true, completion: nil)
        default:
            print_internal_error("\(__FUNCTION__)")
        }
    }
    
    // MARK: support function for data source
    
    func getCount() -> Int {
        
        var value = 0
        switch pickerType {
        case "Client name":
            value = clients.count
        case "Amount paid":
            value =  paymentValues.count
        case "Payment type":
            value =  paymentTypes.count
        case "ICD":
            value =  ICDs.count
        default:
            print_internal_error("\(__FUNCTION__)")
        }
        return value
    }
    
    func getValue(index: Int) -> String {
        
        var value = ""
        switch pickerType {
        case "Client name":
            value = clients[index]
        case "Amount paid":
            value = Formatting.formattedCurrency(paymentValues[index])
        case "Payment type":
            value = paymentTypes[index]
        case "ICD":
            value = ICDs[index]
        default:
            print_internal_error("\(__FUNCTION__)")
        }
        return value
    }
    
    func deleteElement(index: Int) {
        switch pickerType {
        case "Client name":
            let context = CoreDataStackManager.sharedInstance().managedObjectContext
            context.performBlockAndWait() {
                context.deleteObject(self.clientsDict[self.clients[index]]!)
                self.clientsDict.removeValueForKey(self.clients[index])
                self.clients.removeAtIndex(index)
            }
        case "Amount paid":
            paymentValues.removeAtIndex(index)
        case "Payment type":
            paymentTypes.removeAtIndex(index)
        case "ICD":
            ICDs.removeAtIndex(index)
        default:
            print_internal_error("\(__FUNCTION__)")
        }
    }
    
    func insertElement(value: String, index: Int) {
        
        switch pickerType {
        case "Client name":
            //clients.insert(value as! String, atIndex: index)
            break
        case "Amount paid":
            paymentValues.insert(Formatting.floatFromCurrency(value), atIndex: index)
        case "Payment type":
            paymentTypes.insert(value, atIndex: index)
        case "ICD":
            ICDs.insert(value, atIndex: index)
        default:
            print_internal_error("\(__FUNCTION__)")
        }
    }
    
    func addElement(value: AnyObject) {
        
        switch pickerType {
        case "Client name":
            if !clients.contains(value as! String) {
                clients.append(value as! String)
            }
        case "Amount paid":
            let svalue = value as! NSString
            if !paymentValues.contains(svalue.floatValue) {
                paymentValues.append(svalue.floatValue)
            }
        case "Payment type":
            if !paymentTypes.contains(value as! String) {
                paymentTypes.append(value as! String)
            }
        case "ICD":
            if !ICDs.contains(value as! String) {
                ICDs.append(value as! String)
            }
        default:
            print_internal_error("\(__FUNCTION__)")
        }
    }
    
    func saveData() {
        
        switch pickerType {
        case "Client name":
            let context = CoreDataStackManager.sharedInstance().managedObjectContext
            do {
                try context.save()
            } catch {
                print("ERROR: context.save() failed")
            }
        case "Amount paid":
            PersistentData.storeFees(paymentValues)
        case "Payment type":
            PersistentData.storePaymentTypes(paymentTypes)
        case "ICD":
            PersistentData.storeICDs(ICDs)
        default:
            print_internal_error("\(__FUNCTION__)")
        }
    }
    
    func getInputType() -> UIKeyboardType {
        
        var value: UIKeyboardType
        switch pickerType {
        case "Client name":
            value = .ASCIICapable
        case "Amount paid":
            value = .DecimalPad
        case "Payment type":
            value = .ASCIICapable
        case "ICD":
            value = .ASCIICapable
        default:
            value = .ASCIICapable
            print_internal_error("\(__FUNCTION__)")
        }
        return value
    }
    
    func print_internal_error(from: String) {
        
        let msg = "ERROR: unexpected pickerType: \(pickerType) in \(from)"
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
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        if pickerType == "Client name" {
            return false
        }
        return true
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        
        print(">>> Moving")
        if pickerType == "Client name" {
            print("Move not supported for Client name")
            return
        }
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

extension EditPickerValuesViewController: AddNewClientViewControllerDelegate {
    
    func didFinishAddingClient(controller: AddNewClientViewController, value: Person!) {
        
        controller.dismissViewControllerAnimated(true, completion: nil)
        if value != nil {
            addElement(value.name)
            saveData()
            tableView.reloadData()
        }
    }
}

extension EditPickerValuesViewController: ICD10DetailsTableViewControllerDelegate {
    
    func didSelectICD(controller: ICD10DetailsTableViewController, value: String!) {
        
        controller.navigationController?.popToViewController(self, animated: true)
        if value != nil {
            addElement(value)
            saveData()
            tableView.reloadData()
        }
    }
}