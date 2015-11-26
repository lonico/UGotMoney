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
    
    var pickerLabel: Transaction.FieldName!
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
        
        switch pickerLabel! {
        case .clientName:
            let vc = storyboard?.instantiateViewControllerWithIdentifier("addNewClientVC") as! AddNewClientViewController
            vc.delegate = self
            navigationController?.pushViewController(vc, animated: true)
        case .paymentValue, .paymentType:
            let vc = storyboard?.instantiateViewControllerWithIdentifier("inputTextFieldVC") as! InputTextFieldViewController
            vc.labelText = "Add value for \(InputViewController.getFieldLabel(pickerLabel!))"
            vc.keyBoardType = getInputType()
            vc.delegate = self
            navigationController?.pushViewController(vc, animated: true)
        case .icd10:
            let vc = storyboard?.instantiateViewControllerWithIdentifier("searchICDVC") as! SearchICDViewController
            navigationController?.pushViewController(vc, animated: true)
        default:
            print_internal_error("\(__FUNCTION__)")
        }
    }
    
    // MARK: support function for data source
    
    func getCount() -> Int {
        
        var value = 0
        switch pickerLabel! {
        case .clientName:
            value = clients.count
        case .paymentValue:
            value =  paymentValues.count
        case .paymentType:
            value =  paymentTypes.count
        case .icd10:
            value =  ICDs.count
        default:
            print_internal_error("\(__FUNCTION__)")
        }
        return value
    }
    
    func getValue(index: Int) -> String {
        
        var value = ""
        switch pickerLabel! {
        case .clientName:
            value = clients[index]
        case .paymentValue:
            value = Formatting.formattedCurrency(paymentValues[index])
        case .paymentType:
            value = paymentTypes[index]
        case .icd10:
            value = ICDs[index]
        default:
            print_internal_error("\(__FUNCTION__)")
        }
        return value
    }
    
    func deleteElement(index: Int) {
        switch pickerLabel! {
        case .clientName:
            let person = self.clientsDict[self.clients[index]]!
            person.deactivate()
            self.clientsDict.removeValueForKey(self.clients[index])
            self.clients.removeAtIndex(index)
        case .paymentValue:
            paymentValues.removeAtIndex(index)
        case .paymentType:
            paymentTypes.removeAtIndex(index)
        case .icd10:
            ICDs.removeAtIndex(index)
        default:
            print_internal_error("\(__FUNCTION__)")
        }
    }
    
    func insertElement(value: String, index: Int) {
        
        switch pickerLabel! {
        case .clientName:
            //clients.insert(value as! String, atIndex: index)
            break
        case .paymentValue:
            paymentValues.insert(Formatting.floatFromCurrency(value), atIndex: index)
        case .paymentType:
            paymentTypes.insert(value, atIndex: index)
        case .icd10:
            ICDs.insert(value, atIndex: index)
        default:
            print_internal_error("\(__FUNCTION__)")
        }
    }
    
    func addElement(value: AnyObject) {
        
        switch pickerLabel! {
        case .clientName:
            if !clients.contains(value as! String) {
                clients.append(value as! String)
            }
        case .paymentValue:
            let svalue = value
            if !paymentValues.contains(svalue.floatValue) {
                paymentValues.append(svalue.floatValue)
            }
        case .paymentType:
            if !paymentTypes.contains(value as! String) {
                paymentTypes.append(value as! String)
            }
        case .icd10:
            if !ICDs.contains(value as! String) {
                ICDs.append(value as! String)
            }
        default:
            print_internal_error("\(__FUNCTION__)")
        }
    }
    
    func saveData() {
        
        switch pickerLabel! {
        case .clientName:
            let context = CoreDataStackManager.sharedInstance().managedObjectContext
            do {
                try context.save()
            } catch {
                print("ERROR: context.save() failed")
            }
        case .paymentValue:
            PersistentData.storeFees(paymentValues)
        case .paymentType:
            PersistentData.storePaymentTypes(paymentTypes)
        case .icd10:
            PersistentData.storeICDs(ICDs)
        default:
            print_internal_error("\(__FUNCTION__)")
        }
    }
    
    func getInputType() -> UIKeyboardType {
        
        var value: UIKeyboardType
        switch pickerLabel! {
        case .clientName, .paymentType, .icd10:
            value = .ASCIICapable
        case .paymentValue:
            value = .DecimalPad
        default:
            value = .ASCIICapable
            print_internal_error("\(__FUNCTION__)")
        }
        return value
    }
    
    func print_internal_error(from: String) {
        
        let msg = "ERROR: unexpected pickerType: \(pickerLabel) in \(from)"
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
        
        if pickerLabel == nil || pickerLabel! == .clientName {
            return false
        }
        return true
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        
        print(">>> Moving")
        if pickerLabel! == .clientName {
            print("Move not supported for Client name")
            return
        }
        let value = getValue(sourceIndexPath.row)
        deleteElement(sourceIndexPath.row)
        insertElement(value, index: destinationIndexPath.row)
        saveData()
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return "  Editing values for \(InputViewController.getFieldLabel(pickerLabel))"
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
    
    func didFinishEditingInputTextField(value: String!) {
        
        navigationController?.popViewControllerAnimated(true)
        if value != nil {
            addElement(value)
            saveData()
            tableView.reloadData()
        }
    }
}

extension EditPickerValuesViewController: AddNewClientViewControllerDelegate {
    
    func didFinishAddingClient(value: Person!) {
        
        navigationController?.popViewControllerAnimated(true)
        if value != nil {
            addElement(value.name)
            saveData()
            tableView.reloadData()
        }
    }
}

extension EditPickerValuesViewController: ICD10DetailsTableViewControllerDelegate {
    
    func didSelectICD(value: String!) {
        
        navigationController?.popToViewController(self, animated: true)
        if value != nil {
            addElement(value)
            saveData()
            tableView.reloadData()
        }
    }
}