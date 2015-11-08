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

    static func getCellForLabelAndText(tableView: UITableView, name: String, type: String) -> UITableViewCell {
        let identifier = "LabelAndTextFieldCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier) as! LabelAndTextFieldCell
        cell.cellLabel.text = name
        cell.editingAccessoryType = .DetailDisclosureButton
        switch type {
        case "datePicker":
            cell.cellTextField.text = Formatting.formattedDate(NSDate())
            //print(">>>>", Formatting.formattedDate(NSDate()))
        default: break
        }
        //print(">>> Identifier \(identifier)")
        return cell
    }

}
