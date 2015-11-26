//
//  InputViewController.swift
//  UGotMoney
//
//  Created by Laurent Nicolas on 11/1/15.
//  Copyright © 2015 Laurent Nicolas. All rights reserved.
//

import UIKit

class InputViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var editButton: UIBarButtonItem!
    
    @IBOutlet var toolBar: UIToolbar!
    @IBOutlet var saveButton: UIBarButtonItem!
    
    
    enum FieldType {
        case datePicker
        case namePicker
        case textField
        case textLabel
    }
    
    struct Choices {
        var clients: [String]
        var paymentValues: [Float]
        var paymentTypes: [String]
        var ICDs: [String]
    }
    
    var transactionDict: [Transaction.FieldName: AnyObject!] = [:]
    
    var choices: Choices!
    
    var clientNamePickerView: UIPickerView!
    var paymentValuePickerView: UIPickerView!
    var paymentTypePickerView: UIPickerView!
    var ICDPickerView: UIPickerView!
    var noteTextView: UITextView!
    var noteIsEmpty = true
    
    var selectedCell: LabelAndTextFieldCell!
    var selectedIndexPath: NSIndexPath! = nil
    var expandedIndexPath: NSIndexPath! = nil
    var showSecondRow = false
    var secondRowCellIndex: NSIndexPath!
    var secondRowCellFieldName: Transaction.FieldName!
    var secondRowCellFieldType: FieldType!
    
    var origin_y: CGFloat!
    
    let sections: [(Transaction.FieldName, FieldType)] = [
        (.paymentDate, .datePicker),
        (.clientName, .namePicker),
        (.paymentValue, .namePicker),
        (.paymentType, .namePicker),
        (.icd10, .namePicker),
        (.serviceDate, .datePicker),
        (.notes, .textField)
    ]
    
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
        choices = Choices(clients: Person.getClientNames(),
                          paymentValues: PersistentData.getFees(),
                          paymentTypes: PersistentData.getPaymentTypes(),
                          ICDs: PersistentData.getICDs())
        tableView.setEditing(false, animated: true)
        editButton.tintColor = UIColor.blueColor()
        saveButton.enabled = false
        
        tableView.reloadData()
        clientNamePickerView.reloadAllComponents()
        paymentValuePickerView.reloadAllComponents()
        paymentTypePickerView.reloadAllComponents()
        ICDPickerView.reloadAllComponents()
    }
    
    // MARK: DatePicker actions
    
    @IBAction func dateValueChanged(sender: UIDatePicker) {
        
        print(">>> dateValueChanged")
        if selectedCell.cellLabel.text == nil {
            print("Unexpected UIDatePicker dateValueChanged (nil) for \(selectedCell)")
            return
        }
        if secondRowCellFieldName == nil {
            print("Unexpected secondRowCellType (nil) for \(selectedCell)")
            return
        }
        selectedCell.cellTextField.text = Formatting.formattedDate(sender.date)
        switch secondRowCellFieldName! {
        case .paymentDate:
            transactionDict[.paymentDate] = sender.date
            if transactionDict[.serviceDate] == nil {
                transactionDict[.serviceDate] = sender.date
            }
        case .serviceDate:
            transactionDict[.serviceDate] = sender.date
            if transactionDict[.paymentDate] == nil {
                transactionDict[.paymentDate] = sender.date
            }
        default:
            print("Unexpected UIDatePicker dateValueChanged for \(selectedCell)")
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
        
        print(">>> Saving transaction")
        view.endEditing(true)
        let context = CoreDataStackManager.sharedInstance().managedObjectContext
        let transaction = Transaction(transactionDict: transactionDict, context: context)
        print("transaction: \(transaction)")
        let nserror = CoreDataStackManager.sharedInstance().saveContext()
        var alert: AlertController.Alert
        if nserror == nil {
            alert = AlertController.Alert(msg: "", title: "Saved!") { action in
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
    
    func print_internal_error() {
        
        let msg = "ERROR: unexpected pickerView"
        print(msg)
    }

}

extension InputViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let (_, type) = sections[section]
        if type == .datePicker || type == .namePicker || type == .textField {
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
            cell = LabelAndTextFieldCell.getCellForLabelAndText(tableView, name: InputViewController.getFieldLabel(name), type: type)
            let acell = cell as! LabelAndTextFieldCell
            acell.cellTextField.text = getValue(name)
        } else if row == 1 {
            cell = getCellForSecondRow(tableView, name: name, type: type)
        } else {
            cell = LabelAndTextFieldCell.getCellForLabelAndText(tableView, name: "ERROR: unexpected row: \(row)", type: .textLabel)
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
        tableView.endEditing(true)
        if indexPath.row == 0 {
            let acell = tableView.cellForRowAtIndexPath(indexPath) as! LabelAndTextFieldCell
            if showSecondRow {
                showSecondRow = false
                tableView.reloadRowsAtIndexPaths([secondRowCellIndex], withRowAnimation: UITableViewRowAnimation.Fade)
                if selectedCell == acell {
                    selectedCell = nil
                    return
                }
            }
            //let acell = tableView.cellForRowAtIndexPath(indexPath) as! LabelAndTextFieldCell
            let (name, type) = sections[indexPath.section]
            if getCount(name) == 0 {
                AlertController.Alert(msg: "please add value for \(InputViewController.getFieldLabel(name)) using the edit button (bottom left)", title: AlertController.AlertTitle.EmptyList).showAlert(self)
                return
            }
            selectedCell = acell
            switch type {
            case .datePicker, .namePicker, .textField:
                showSecondRow = true
                secondRowCellIndex = NSIndexPath(forRow: indexPath.row + 1, inSection: indexPath.section)
                tableView.reloadRowsAtIndexPaths([secondRowCellIndex], withRowAnimation: UITableViewRowAnimation.Fade)
                secondRowCellFieldName = name
                secondRowCellFieldType = type
            default:
                break
            }
        }
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
        print(">>> tapped!")
        let (name, _) = sections[indexPath.section]
        let vc = storyboard?.instantiateViewControllerWithIdentifier("editAmountsVC") as! EditPickerValuesViewController
        vc.pickerLabel = name
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if selectedCell != nil && indexPath == secondRowCellIndex && secondRowCellFieldName == Transaction.FieldName.notes {
            noteTextView.editable = true
            noteTextView.becomeFirstResponder()
        }

    }

    // MARK: utilify functions
    
    func getCellForSecondRow(tableView: UITableView, name: Transaction.FieldName, type: FieldType) -> UITableViewCell {
        var cell: UITableViewCell
        var error: String! = nil
        switch(type) {
        case.textField:
            cell = TextViewCell.getCellForTextView(tableView, textView: noteTextView)
        case .datePicker:
            cell = DatePickerViewCell.getCellForDatePickerView(tableView)
        case .namePicker:
            var selection: Int
            var pickerView: UIPickerView!
            switch name {
            case .clientName:
                pickerView = clientNamePickerView
                selection = choices.clients.count / 2
            case .paymentValue:
                pickerView = paymentValuePickerView
                selection = choices.paymentValues.count / 2
            case .paymentType:
                pickerView = paymentTypePickerView
                selection = choices.paymentTypes.count / 2
            case .icd10:
                pickerView = ICDPickerView
                selection = choices.ICDs.count / 2
            default:
                error = "ERROR: unexpected name: \(name)"
                pickerView = nil
                selection = 0
            }
            if error == nil {
                cell = NamePickerViewCell.getCellForNamePickerView(tableView, pickerView: pickerView!, selected: selection)
            } else {
                cell = LabelAndTextFieldCell.getCellForLabelAndText(tableView, name: error, type: .textLabel)
            }
        default:
            error = "ERROR: unexpected type: \(type)"
            cell = LabelAndTextFieldCell.getCellForLabelAndText(tableView, name: error, type: .textLabel)
        }
        return cell
    }
    
    func keyboardWillShow(sender: NSNotification) {
        let endFrame = (sender.userInfo![UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
        if toolBar != nil {
            view.frame.origin.y -= (endFrame?.size.height)! - toolBar.frame.height
        }
    }
    
    func keyboardWillHide(sender: NSNotification) {
        view.frame.origin.y = origin_y
    }
    
    func resetValues() {
        
        transactionDict[.clientName] = ""
        transactionDict[.paymentValue] = nil
        transactionDict[.paymentType] = ""
        transactionDict[.icd10] = ""
        transactionDict[.serviceDate] = nil
        //paymentDate = nil
        transactionDict[.notes] = ""
        noteIsEmpty = true
        noteTextView.text = ""
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
    
    // return number of elements for pickerChoices
    // DatePickers arbitrirarly set to 1
    static func getFieldLabel(name: Transaction.FieldName) -> String {
        
        var value: String
        switch name {
        case .clientName:
            value = "Client name"
        case .paymentValue:
            value = "Amount paid"
        case .paymentType:
            value = "Payment type"
        case .paymentDate:
            value = "Payment date"
        case .serviceDate:
            value = "Service date"
        case .icd10:
            value = "ICD-10"
        case .notes:
            value = "Notes"
        }
        return value
    }
    

}

extension InputViewController: UIPickerViewDataSource,  UIPickerViewDelegate {
    
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
            selectedCell.cellTextField.text = text
            selectedCell.selected = false
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
                print_internal_error()
            }
            enableSaveButton()
        }
        tableView.reloadRowsAtIndexPaths([secondRowCellIndex], withRowAnimation: UITableViewRowAnimation.Fade)
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
                value = choices.ICDs[row]
            }
        default:
            break
        }
        return value
    }
}

extension InputViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(textView: UITextView) {
        if noteIsEmpty {
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        let text = textView.text
        noteIsEmpty = text == ""
        selectedCell.cellTextField.text = text
        if noteIsEmpty {
            textView.text = "Type here"
        }
        transactionDict[.notes] = text
    }
}
