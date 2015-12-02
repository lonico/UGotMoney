//
//  LabelAndTextFieldCell.swift
//  pickerViews
//
//  Created by Laurent Nicolas on 11/3/15.
//  Copyright © 2015 Laurent Nicolas. All rights reserved.
//

import UIKit

class LabelAndTextFieldCell: UITableViewCell {

    @IBOutlet var cellLabel: UILabel!
    @IBOutlet var cellTextField: UITextField!
    @IBOutlet var cellDoneButton: RoundedButton!

    static func getCellForLabelAndText(tableView: UITableView, name: String, type: AddTransactionViewController.FieldType) -> UITableViewCell {
        let identifier = "LabelAndTextFieldCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier) as! LabelAndTextFieldCell
        cell.cellLabel.text = name
        cell.editingAccessoryType = .DetailDisclosureButton
        if cell.cellDoneButton != nil {
            cell.cellDoneButton.hidden = true
            cell.cellDoneButton.enabled = false
        }
        switch type {
        case .datePicker:
            cell.cellTextField.text = Formatting.formattedDate(NSDate())
            //print(">>>>", Formatting.formattedDate(NSDate()))
        default:
            cell.cellTextField.text = ""
        }
        //print(">>> Identifier \(identifier)")
        return cell
    }

}
