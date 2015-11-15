//
//  InputViewController.swift
//  UGotMoney
//
//  Created by Laurent Nicolas on 11/1/15.
//  Copyright © 2015 Laurent Nicolas. All rights reserved.
//

import Foundation
import UIKit

class InputViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var addButton: UIBarButtonItem!
    
    @IBOutlet var toolBar: UIToolbar!
    
    let cogWheel = NSString(string: "\u{2699}") as String
    
    var clients = ["Charlie Brown", "Lucy Ball", "Lucky Luke", "Antonio Banderas", "Patrick Timsit", "Tom Cruise"]
    //var paymentValues = ["60", "100", "130"]
    //var paymentTypes = ["cash (bills)", "Cash (app)", "Square", "check"]
    var paymentValues: [Float]!
    var paymentTypes: [String]!
    
    var clientNamePickerView: UIPickerView!
    var paymentValuePickerView: UIPickerView!
    var paymentTypePickerView: UIPickerView!
    var noteTextView: UITextView!
    var noteIsEmpty = true
    
    var selectedCell: LabelAndTextFieldCell!
    var selectedIndexPath: NSIndexPath! = nil
    var expandedIndexPath: NSIndexPath! = nil
    var showSecondRow = false
    var secondRowCellIndex: NSIndexPath!
    var secondRowCellType = ""
    
    var origin_y: CGFloat!
    
    let sections = [("Payment date", "datePicker"),
        ("Client name", "namePicker"),
        ("Amount Paid", "namePicker"),
        ("Payment type", "namePicker"),
        ("Service date", "datePicker"),
        ("Notes", "textView")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        addButton.setTitleTextAttributes([
//            NSFontAttributeName : UIFont(name: "Symbol", size: 26)!,
//            NSForegroundColorAttributeName : UIColor.redColor(),
//            NSBackgroundColorAttributeName:UIColor.blackColor()],
//            forState: UIControlState.Normal)
        //addButton.title = cogWheel
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
        noteTextView = UITextView()
        noteTextView.delegate = self
        noteIsEmpty = true
        
        }
    
    override func viewWillAppear(animated: Bool) {
        print(">>> \(__FUNCTION__)")
        
        paymentValues = PersistentData.getFees()
        paymentTypes = PersistentData.getPaymentTypes()
        
        tableView.setEditing(false, animated: true)
        addButton.tintColor = UIColor.blueColor()
        
        tableView.reloadData()
        clientNamePickerView.reloadAllComponents()
        paymentValuePickerView.reloadAllComponents()
        paymentTypePickerView.reloadAllComponents()
        
        let msg = "use the + button, then the i button, to add the"
        if paymentValues.count == 0 {
            AlertController.Alert(msg: "\(msg) fee value", title: "no value for fees").dispatchAlert(self)
        } else if paymentTypes.count == 0 {
            AlertController.Alert(msg: "\(msg) payment type value", title: "no value for payment types").dispatchAlert(self)
        }
    }
    
    // MARK: DatePicker actions
    
    @IBAction func dateValueChanged(sender: UIDatePicker) {
        
        print(">>> dateValueChanged")
        selectedCell.cellTextField.text = Formatting.formattedDate(sender.date)
//        selectedCell.selected = false
//        showSecondRow = false
//        tableView.reloadRowsAtIndexPaths([secondRowCellIndex], withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    func datePickerEvent(datePicker: UIDatePicker) {
        
        print("date changed")
    }
    
    
    @IBAction func addButtonAction(sender: UIBarButtonItem) {

        tableView.setEditing(!tableView.editing, animated: true)
        if tableView.editing {
            addButton.tintColor = UIColor.redColor()
        } else {
            addButton.tintColor = UIColor.blueColor()
        }
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
        print(">>> THERE, THERE")
        if selectedCell != nil && indexPath == secondRowCellIndex && secondRowCellType == "textView" {
            print(">>> THERE2, THERE2")
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
            case "Amount Paid":
                pickerView = paymentValuePickerView
                selection = paymentValues.count / 2
            case "Payment type":
                pickerView = paymentTypePickerView
                selection = paymentTypes.count / 2
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
        view.frame.origin.y -= (endFrame?.size.height)! - toolBar.frame.height
    }
    
    func keyboardWillHide(sender: NSNotification) {
        view.frame.origin.y = origin_y
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
        default:
            return 0
        }
    }
    
    // MARK: UIPickerViewDelegate
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(">>> Selected: \(component) - \(row)")
        selectedCell.cellTextField.text = self.pickerView(pickerView, titleForRow: row, forComponent: component)
        selectedCell.selected = false
        showSecondRow = false
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
            let value = NSString(format: "%.2f", paymentValues[row])
            return String(value)
        case paymentTypePickerView:
            //print("titleForRow: paymentTypePickerView - \(row)")
            return paymentTypes[row]
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
    }
}