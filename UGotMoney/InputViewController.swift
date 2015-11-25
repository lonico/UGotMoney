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
    
    let cogWheel = NSString(string: "\u{2699}") as String
    
    var clients: [String]!
    //var paymentValues = ["60", "100", "130"]
    //var paymentTypes = ["cash (bills)", "Cash (app)", "Square", "check"]
    var paymentValues: [Float]!
    var paymentTypes: [String]!
    var ICDs: [String]!
    
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
    var secondRowCellType = ""
    
    var clientName = ""
    var paymentAmount: Float!
    var paymentType = ""
    var paymentDate: NSDate!
    var ICD = ""
    var serviceDate: NSDate!
    var notes = ""
    
    var origin_y: CGFloat!
    
    let sections = [("Payment date", "datePicker"),
        ("Client name", "namePicker"),
        ("Amount paid", "namePicker"),
        ("Payment type", "namePicker"),
        ("ICD", "namePicker"),
        ("Service date", "datePicker"),
        ("Notes", "textView")]
    
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
        clients = Person.getClientNames()
        paymentValues = PersistentData.getFees()
        paymentTypes = PersistentData.getPaymentTypes()
        ICDs = PersistentData.getICDs()
        
        tableView.setEditing(false, animated: true)
        editButton.tintColor = UIColor.blueColor()
        saveButton.enabled = false
        
        tableView.reloadData()
        clientNamePickerView.reloadAllComponents()
        paymentValuePickerView.reloadAllComponents()
        paymentTypePickerView.reloadAllComponents()
        ICDPickerView.reloadAllComponents()
        
        let msg = "use the edit button, then the i button, to add "
        if clients.count == 0 {
            AlertController.Alert(msg: "\(msg) client names", title: "no client").dispatchAlert(self)
        } else if paymentValues.count == 0 {
            AlertController.Alert(msg: "\(msg) fees", title: "no value for fees").dispatchAlert(self)
        } else if paymentTypes.count == 0 {
            AlertController.Alert(msg: "\(msg) payment types", title: "no value for payment type").dispatchAlert(self)
        }
    }
    
    // MARK: DatePicker actions
    
    @IBAction func dateValueChanged(sender: UIDatePicker) {
        
        print(">>> dateValueChanged")
        if selectedCell.cellLabel.text == nil {
            print("Unexpected UIDatePicker dateValueChanged (nil) for \(selectedCell)")
            return
        }
        selectedCell.cellTextField.text = Formatting.formattedDate(sender.date)
        switch selectedCell.cellLabel.text! {
        case "Payment date":
            paymentDate = sender.date
            if serviceDate == nil {
                serviceDate = sender.date
            }
        case "Service date":
            serviceDate = sender.date
            if paymentDate == nil {
                paymentDate = sender.date
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
        if paymentDate == nil {
            paymentDate = NSDate()
        }
        if serviceDate == nil {
            serviceDate = paymentDate
        }
        let person = Person.getPerson(clientName)
        print(">>>person: \(person)")
        let context = CoreDataStackManager.sharedInstance().managedObjectContext
        let transaction = Transaction(paymentDate: paymentDate, person: person, amountPaid: paymentAmount, paymentType: paymentType, notes: notes, serviceDate: serviceDate, context: context)
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
        
        saveButton.enabled = clientName != "" && paymentAmount != nil && paymentType != ""
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
        if type == "datePicker" || type == "namePicker" || type == "textView" {
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
            cell = LabelAndTextFieldCell.getCellForLabelAndText(tableView, name: name, type: type)
            let acell = cell as! LabelAndTextFieldCell
            acell.cellTextField.text = getValue(name)
        } else if row == 1 {
            cell = getCellForSecondRow(tableView, name: name, type: type)
        } else {
            cell = LabelAndTextFieldCell.getCellForLabelAndText(tableView, name: "ERROR: unexpected row: \(row)", type: "text")
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
            selectedCell = acell
            let (_, type) = sections[indexPath.section]
            switch type {
            case "datePicker", "namePicker", "textView":
                showSecondRow = true
                secondRowCellIndex = NSIndexPath(forRow: indexPath.row + 1, inSection: indexPath.section)
                tableView.reloadRowsAtIndexPaths([secondRowCellIndex], withRowAnimation: UITableViewRowAnimation.Fade)
                secondRowCellType = type
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
        case "namePicker":
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
        vc.pickerType = name
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if selectedCell != nil && indexPath == secondRowCellIndex && secondRowCellType == "textView" {
            noteTextView.editable = true
            noteTextView.becomeFirstResponder()
        }

    }

    // MARK: utilify functions
    
    func getCellForSecondRow(tableView: UITableView, name: String, type: String) -> UITableViewCell {
        var cell: UITableViewCell
        var error: String! = nil
        if type == "textView" {
            cell = TextViewCell.getCellForTextView(tableView, textView: noteTextView)
        }
        else if type == "datePicker" {
            cell = DatePickerViewCell.getCellForDatePickerView(tableView)
        } else if type == "namePicker" {
            var selection: Int
            var pickerView: UIPickerView!
            switch name {
            case "Client name":
                pickerView = clientNamePickerView
                selection = clients.count / 2
            case "Amount paid":
                pickerView = paymentValuePickerView
                selection = paymentValues.count / 2
            case "Payment type":
                pickerView = paymentTypePickerView
                selection = paymentTypes.count / 2
            case "ICD":
                pickerView = ICDPickerView
                selection = ICDs.count / 2
            default:
                error = "ERROR: unexpected name: \(name)"
                pickerView = nil
                selection = 0
            }
            if error == nil {
                cell = NamePickerViewCell.getCellForNamePickerView(tableView, pickerView: pickerView!, selected: selection)
            } else {
                cell = LabelAndTextFieldCell.getCellForLabelAndText(tableView, name: error, type: "text")
            }
        } else {
            error = "ERROR: unexpected type: \(type)"
            cell = LabelAndTextFieldCell.getCellForLabelAndText(tableView, name: error, type: "text")
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
        clientName = ""
        paymentAmount = nil
        paymentType = ""
        ICD = ""
        serviceDate = nil
        //paymentDate = nil
        notes = ""
        noteIsEmpty = true
        noteTextView.text = ""
    }
    
    func getValue(name: String) -> String {
        
        var value: String!
        switch name {
        case "Client name":
            value = clientName
        case "Amount paid":
            value = Formatting.formattedCurrency(paymentAmount)
        case "Payment type":
            value = paymentType
        case "Service date":
            value = Formatting.formattedDate(serviceDate)
        case "Payment date":
            var pd = paymentDate
            if pd == nil {
                pd = NSDate()
            }
            value = Formatting.formattedDate(pd)
        case "ICD":
            value = ICD
        case "Notes":
            value = notes
        default:
            print_internal_error()
        }
        if value == nil {
            return ""
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
            return clients.count
        case paymentValuePickerView:
            return paymentValues.count
        case paymentTypePickerView:
            return paymentTypes.count
        case ICDPickerView:
            return ICDs.count
        default:
            return 0
        }
    }
    
    // MARK: UIPickerViewDelegate
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(">>> Selected: \(component) - \(row)")
        let text = self.pickerView(pickerView, titleForRow: row, forComponent: component)!
        selectedCell.cellTextField.text = text
        selectedCell.selected = false
        showSecondRow = false
        switch pickerView {
        case clientNamePickerView:
            clientName = text
        case paymentValuePickerView:
            paymentAmount = (text as NSString).floatValue
        case paymentTypePickerView:
            paymentType = text
        case ICDPickerView:
            ICD = text
        default:
            print_internal_error()
        }
        enableSaveButton()
        tableView.reloadRowsAtIndexPaths([secondRowCellIndex], withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component != 0 {
            return nil
        }
        switch pickerView {
        case clientNamePickerView:
            //print("titleForRow: clientNamePickerView - \(row)")
            return clients[row]
        case paymentValuePickerView:
            //print("titleForRow: paymentValuePickerView - \(row)")
            return Formatting.formattedCurrency(paymentValues[row])
        case paymentTypePickerView:
            //print("titleForRow: paymentTypePickerView - \(row)")
            return paymentTypes[row]
        case ICDPickerView:
            return ICDs[row]
        default:
            return nil
        }
    }
}

extension InputViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(textView: UITextView) {
        if noteIsEmpty {
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        print("HERE")
        let text = textView.text
        noteIsEmpty = text == ""
        selectedCell.cellTextField.text = text
        if noteIsEmpty {
            textView.text = "Type here"
        }
        notes = text
    }
}
