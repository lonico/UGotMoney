//
//  AddTransactionViewController.swift
//  UGotMoney
//
//  Created by Laurent Nicolas on 11/1/15.
//  Copyright © 2015 Laurent Nicolas. All rights reserved.
//

import UIKit

class AddTransactionViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var editButton: UIBarButtonItem!
    
    @IBOutlet var toolBar: UIToolbar!
    @IBOutlet var saveButton: UIBarButtonItem!
    
    
    enum FieldType {
        case datePicker
        case namePicker
        case textView
        case textField
    }
    
    struct Choices {
        var clients: [String]
        var paymentValues: [Float]
        var paymentTypes: [String]
        var ICDs: [String]
        var ICDDescriptions: [String: String]
    }
    
    var transactionDict: [Transaction.FieldName: AnyObject!] = [:]
    
    var choices: Choices!
    
    var clientNamePickerView: UIPickerView!
    var paymentValuePickerView: UIPickerView!
    var paymentTypePickerView: UIPickerView!
    var ICDPickerView: UIPickerView!
    var noteTextView: UITextView!
    
    // The UI is a table.  Each section contains 1 or 2 rows:
    //   the first row is a label and a value
    //   the second row is hidden by default.  It provides a widget
    //    to enter data (pickerView, textView), ...
    
    // if showSecondRow is false, the other variables are undefined
    // if true, they are used to manage the section
    var showSecondRow = false
    var selectedIndexPath: NSIndexPath! = nil
    var secondRowCellIndex: NSIndexPath!
    var secondRowCellFieldName: Transaction.FieldName!
    
    // For each section, the field being edited and
    // the type of the UIControl for the second row
    let sections: [(Transaction.FieldName, FieldType)] = [
        (.paymentDate, .datePicker),
        (.clientName, .namePicker),
        (.paymentValue, .namePicker),
        (.paymentType, .namePicker),
        (.icd10, .namePicker),
        (.serviceDate, .datePicker),
        (.notes, .textView)
    ]
    
    var origin_y: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
        origin_y = view.frame.origin.y

        clientNamePickerView = UIPickerView()
        clientNamePickerView.dataSource = self
        clientNamePickerView.delegate = self
        
        paymentValuePickerView = UIPickerView()
        paymentValuePickerView.dataSource = self
        paymentValuePickerView.delegate = self
        
        paymentTypePickerView = UIPickerView()
        paymentTypePickerView.dataSource = self
        paymentTypePickerView.delegate = self
        
        ICDPickerView = UIPickerView()
        ICDPickerView.dataSource = self
        ICDPickerView.delegate = self
        
        noteTextView = UITextView()
        noteTextView.delegate = self
        
        resetValues()
    }
    
    override func viewWillAppear(animated: Bool) {
        print(">>> \(__FUNCTION__)")
        
        super.viewWillAppear(animated)
        choices = Choices(clients: Person.getClientNames(activeOnly: true),
                          paymentValues: PersistentData.getFees(),
                          paymentTypes: PersistentData.getPaymentTypes(),
                          ICDs: PersistentData.getICDs(),
                          ICDDescriptions: PersistentData.getICDDescriptions())
        tableView.setEditing(false, animated: true)
        editButton.tintColor = UIColor.blueColor()
        enableSaveButton()
        showSecondRow = false
        
        tableView.reloadData()
        clientNamePickerView.reloadAllComponents()
        paymentValuePickerView.reloadAllComponents()
        paymentTypePickerView.reloadAllComponents()
        ICDPickerView.reloadAllComponents()
    }
    
    // MARK: DatePicker and PickerView actions
    
    func dateValueChanged(sender: UIDatePicker) {
        
        print(">>> dateValueChanged")
        if selectedIndexPath == nil {
            print("Unexpected selectedIndexPath (nil)")
        }
        if secondRowCellFieldName == nil {
            print("Unexpected secondRowCellType (nil) for \(selectedIndexPath)")
            return
        }
        switch secondRowCellFieldName! {
        case .paymentDate:
            transactionDict[.paymentDate] = sender.date
        case .serviceDate:
            transactionDict[.serviceDate] = sender.date
        default:
            print("Unexpected UIDatePicker dateValueChanged for \(selectedIndexPath)")
        }
        tableView.reloadRowsAtIndexPaths([selectedIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)

    }

    func longPressActionPickerView(sender: UIPickerView) {
        
        // Close a pickerView on a long press
        if showSecondRow {
            showSecondRow = false
            setValueFromSecondRow(secondRowCellIndex, name: secondRowCellFieldName)
            tableView.reloadRowsAtIndexPaths([selectedIndexPath, secondRowCellIndex], withRowAnimation: UITableViewRowAnimation.Fade)
        }
     }
    
    // MARK: action buttons
    
    @IBAction func EditButtonAction(sender: UIBarButtonItem) {

        tableView.setEditing(!tableView.editing, animated: true)
        if tableView.editing {
            editButton.tintColor = UIColor.redColor()
        } else {
            editButton.tintColor = UIColor.blueColor()
        }
    }

    @IBAction func organizeButtonTouchUp(sender: UIBarButtonItem) {
        // present transaction table VC
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("transactionTable")
        navigationController?.pushViewController(vc!, animated: true)
    }

    @IBAction func showClientsTouchUp(sender: UIBarButtonItem) {
        // present client table VC
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("clientTableViewController")
        navigationController?.pushViewController(vc!, animated: true)
    }

    @IBAction func saveButtonTouchUp(sender: UIBarButtonItem) {
        
        //print(">>> Saving transaction")
        let context = CoreDataStackManager.sharedInstance().managedObjectContext
        _ = Transaction(transactionDict: transactionDict, context: context)
        //print(">>> transaction: \(transaction)")
        let nserror = CoreDataStackManager.sharedInstance().saveContext()
        var alert: AlertController.Alert
        if nserror == nil {
            alert = AlertController.Alert(msg: "Saved!", title: AlertController.AlertTitle.Success) { action in
                self.resetValues()
                self.tableView.reloadData()
            }
        } else {
            alert = AlertController.Alert(msg: nserror.localizedDescription, title: "Error!")
        }
        alert.showAlert(self)
    }
    
    func enableSaveButton() {
        
        saveButton.enabled = transactionDict[.clientName] as! String != "" &&
                             transactionDict[.paymentValue] != nil &&
                             transactionDict[.paymentType] as! String != ""
    }
    
    func printInternalError(from: String) {
        
        let msg = "ERROR: unexpected pickerView in \(from)"
        print(msg)
    }

}

extension AddTransactionViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let (_, type) = sections[section]
        if type == .datePicker || type == .namePicker || type == .textView {
            return 2
        }
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let section = indexPath.section
        let row = indexPath.row
        let (name, type) = sections[section]
        
        var cell = UITableViewCell()
        if row == 0 {
            cell = LabelAndTextFieldCell.getCellForLabelAndText(tableView, name: Transaction.getFieldLabel(name), type: type)
            let acell = cell as! LabelAndTextFieldCell
            acell.cellTextField.text = getValue(name)
            if showSecondRow {
                acell.cellDoneButton.hidden = selectedIndexPath != indexPath
            }
        } else if row == 1 {
            cell = getCellForSecondRow(tableView, name: name, type: type, isSelected: showSecondRow && secondRowCellIndex == indexPath)
        } else {
            cell = LabelAndTextFieldCell.getCellForLabelAndText(tableView, name: "ERROR: unexpected row: \(row)", type: .textField)
            print("ERROR: unexpected row: \(row)")
        }
        return cell
    }
    
    // MARK: TableViewDelegate
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if secondRowCellIndex != nil && indexPath == secondRowCellIndex {
            if !showSecondRow {
                return 0
            }
            let identifier = "namePickerViewCell"
            let acell = tableView.dequeueReusableCellWithIdentifier(identifier) as! NamePickerViewCell
            return acell.frame.size.height
        } else if indexPath.row == 1 {
            return 0
        }
        return tableView.rowHeight
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(">>> didSelect \(indexPath.section)")
        if indexPath.row == 0 {
            if showSecondRow {
                showSecondRow = false
                setValueFromSecondRow(secondRowCellIndex, name: secondRowCellFieldName)
                let cellsToRefresh = [selectedIndexPath!, secondRowCellIndex!]
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadRowsAtIndexPaths(cellsToRefresh, withRowAnimation: UITableViewRowAnimation.Fade)
                }
                if selectedIndexPath == indexPath {
                    selectedIndexPath = nil
                    secondRowCellFieldName = nil
                    return
                }
            }
            let (name, type) = sections[indexPath.section]
            if getCount(name) == 0 {
                AlertController.Alert(msg: "please add value for \(Transaction.getFieldLabel(name)) using the edit button (bottom left)", title: AlertController.AlertTitle.EmptyList).showAlert(self)
                return
            }
            selectedIndexPath = indexPath
            switch type {
            case .datePicker, .namePicker, .textView:
                showSecondRow = true
                secondRowCellIndex = NSIndexPath(forRow: indexPath.row + 1, inSection: indexPath.section)
                secondRowCellFieldName = name
                let cellsToRefresh = [selectedIndexPath!, secondRowCellIndex!]
                dispatch_async(dispatch_get_main_queue()) {
                    tableView.reloadRowsAtIndexPaths(cellsToRefresh, withRowAnimation: UITableViewRowAnimation.Fade)
                }
            default:
                secondRowCellIndex = nil
                secondRowCellFieldName = nil
                printInternalError("\(__FUNCTION__)")
            }
        }
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
        print(">>> didDeselect \(indexPath.section)")
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .None
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let (_, type) = sections[indexPath.section]
        switch type {
        case .namePicker:
            return true
        default:
            return false
        }
    }
    
    func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        let (name, _) = sections[indexPath.section]
        let vc = storyboard?.instantiateViewControllerWithIdentifier("editAmountsVC") as! EditPickerValuesViewController
        vc.pickerLabel = name
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: utilify functions
    
    func getCellForSecondRow(tableView: UITableView, name: Transaction.FieldName, type: FieldType, isSelected: Bool) -> UITableViewCell {
        var cell: UITableViewCell
        var error: String! = nil
        switch(type) {
        case.textView:
            cell = TextViewCell.getCellForTextView(tableView, textView: noteTextView)
            dispatch_async(dispatch_get_main_queue()) {
                if isSelected {
                    self.noteTextView.becomeFirstResponder()
                } else {
                    self.noteTextView.resignFirstResponder()
                }
            }
        case .datePicker:
            var  initialDate: NSDate
            switch name {
            case .paymentDate:
                initialDate = transactionDict[.paymentDate] as? NSDate ?? NSDate()
            case .serviceDate:
                initialDate = transactionDict[.serviceDate] as? NSDate ?? transactionDict[.paymentDate] as? NSDate ?? NSDate()
            default:
                printInternalError("\(__FUNCTION__)")
                initialDate = NSDate()
            }
            cell = DatePickerViewCell.getCellForDatePickerView(tableView, controller: self, initialDate: initialDate)
        case .namePicker:
            var selection: Int! = nil
            var pickerView: UIPickerView!
            switch name {
            case .clientName:
                pickerView = clientNamePickerView
                if let value = transactionDict[name] as? String {
                    selection = choices.clients.indexOf(value)
                }
            case .paymentValue:
                pickerView = paymentValuePickerView
                if let value = transactionDict[name] as? Float {
                    selection = choices.paymentValues.indexOf(value)
                }
            case .paymentType:
                pickerView = paymentTypePickerView
                if let value = transactionDict[name] as? String {
                    selection = choices.paymentTypes.indexOf(value)
                }
            case .icd10:
                pickerView = ICDPickerView
                if let value = transactionDict[name] as? String {
                    selection = choices.ICDs.indexOf(value)
                }
            default:
                error = "ERROR: unexpected name: \(name)"
                pickerView = nil
            }
            if error == nil {
                cell = NamePickerViewCell.getCellForNamePickerView(tableView, pickerView: pickerView!, controller: self, selected: selection)
            } else {
                cell = LabelAndTextFieldCell.getCellForLabelAndText(tableView, name: error, type: .textField)
            }
        default:
            error = "ERROR: unexpected type: \(type)"
            cell = LabelAndTextFieldCell.getCellForLabelAndText(tableView, name: error, type: .textField)
        }
        return cell
    }
    
    func setValueFromSecondRow(indexPath: NSIndexPath, name: Transaction.FieldName) {
        
        switch (name) {
        case .clientName:
            let row = clientNamePickerView.selectedRowInComponent(0)
            transactionDict[name] = choices.clients[row]
        case .paymentValue:
            let row = paymentValuePickerView.selectedRowInComponent(0)
            transactionDict[name] = choices.paymentValues[row]
        case .paymentType:
            let row = paymentTypePickerView.selectedRowInComponent(0)
            transactionDict[name] = choices.paymentTypes[row]
        case .icd10:
            let row = ICDPickerView.selectedRowInComponent(0)
            transactionDict[name] = choices.ICDs[row]
        case .serviceDate:
            let cell  = tableView.cellForRowAtIndexPath(indexPath) as! DatePickerViewCell
            transactionDict[name] = cell.cellPickerView.date
        default:
            return
        }
        enableSaveButton()
        return
    }
    
    // MARK: keyboard notifications
    
    func keyboardWillShow(sender: NSNotification) {
        let endFrame = (sender.userInfo![UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
        if toolBar != nil {
            view.frame.origin.y -= (endFrame?.size.height)! - toolBar.frame.height
        }
    }
    
    func keyboardWillHide(sender: NSNotification) {
        view.frame.origin.y = origin_y
    }
    
    // MARK: transaction support functions
    
    func resetValues() {
        
        transactionDict[.clientName] = ""
        transactionDict[.paymentValue] = nil
        transactionDict[.paymentType] = ""
        transactionDict[.icd10] = ""
        transactionDict[.paymentDate] = nil
        transactionDict[.serviceDate] = nil
        transactionDict[.notes] = ""
        noteTextView.text = ""
        enableSaveButton()
    }
    
    func getValue(name: Transaction.FieldName) -> String {
        
        var value: String!
        switch name {
        case .clientName, .paymentType, .icd10, .notes:
            value = transactionDict[name] as? String
        case .paymentValue:
            value = Formatting.formattedCurrency(transactionDict[name] as? Float)
        case .serviceDate:
            value = Formatting.formattedDate(transactionDict[name] as? NSDate)
        case .paymentDate:
            var pd = transactionDict[name] as? NSDate
            if pd == nil {
                pd = NSDate()
            }
            value = Formatting.formattedDate(pd)
        }
        return value ?? ""
    }

    // return number of elements for pickerChoices
    // DatePickers arbitrirarly set to 1
    func getCount(name: Transaction.FieldName) -> Int {
        
        var value: Int
        switch name {
        case .clientName:
            value = choices.clients.count
        case .paymentValue:
            value = choices.paymentValues.count
        case .paymentType:
            value = choices.paymentTypes.count
        case .paymentDate:
            value = 1
        case .serviceDate:
            value = 1
        case .icd10:
            value = choices.ICDs.count
        case .notes:
            value = 1
        }
        return value
    }
    
}

extension AddTransactionViewController: UIPickerViewDataSource,  UIPickerViewDelegate {
    
    // MARK: UIPickerViewDataSource
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component != 0 {
            return 0
        }
        switch pickerView {
        case clientNamePickerView:
            return choices.clients.count
        case paymentValuePickerView:
            return choices.paymentValues.count
        case paymentTypePickerView:
            return choices.paymentTypes.count
        case ICDPickerView:
            return choices.ICDs.count
        default:
            return 0
        }
    }
    
    // MARK: UIPickerViewDelegate
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(">>> Selected: \(component) - \(row)")
        if let text = self.pickerView(pickerView, titleForRow: row, forComponent: component) {
            showSecondRow = false
            switch pickerView {
            case clientNamePickerView:
                transactionDict[.clientName] = text
            case paymentValuePickerView:
                transactionDict[.paymentValue] = Formatting.floatFromCurrency(text)
            case paymentTypePickerView:
                transactionDict[.paymentType] = text
            case ICDPickerView:
                transactionDict[.icd10] = text
            default:
                printInternalError("\(__FUNCTION__)")
            }
            enableSaveButton()
        }
        tableView.reloadRowsAtIndexPaths([selectedIndexPath, secondRowCellIndex], withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        var value: String! = nil
        if component != 0 {
            return value
        }
        switch pickerView {
        case clientNamePickerView:
            //print("titleForRow: clientNamePickerView - \(row)")
            if choices.clients.count > 0 {
                value = choices.clients[row]
            }
        case paymentValuePickerView:
            //print("titleForRow: paymentValuePickerView - \(row)")
            if choices.paymentValues.count > 0 {
                value = Formatting.formattedCurrency(choices.paymentValues[row])
            }
        case paymentTypePickerView:
            //print("titleForRow: paymentTypePickerView - \(row)")
            if choices.paymentTypes.count > 0 {
                value = choices.paymentTypes[row]
            }
        case ICDPickerView:
            if choices.ICDs.count > 0 {
                value = choices.ICDs[row] // + " - " + (choices.ICDDescriptions[choices.ICDs[row]] ?? "")
            }
        default:
            break
        }
        return value
    }
}

extension AddTransactionViewController: UITextViewDelegate {
    
    func textViewDidEndEditing(textView: UITextView) {
        
        let text = textView.text
        transactionDict[.notes] = text
    }
}