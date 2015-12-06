//
//  NamePickerViewCell.swift
//  pickerViews
//
//  Created by Laurent Nicolas on 11/4/15.
//  Copyright © 2015 Laurent Nicolas. All rights reserved.
//

import UIKit

class NamePickerViewCell: UITableViewCell {
    
    var cellPickerView: UIPickerView!
    
    static func getCellForNamePickerView(tableView: UITableView, pickerView: UIPickerView, controller: AddTransactionViewController, selected: Int?) -> UITableViewCell {
        let identifier = "namePickerViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier) as! NamePickerViewCell
        cell.cellPickerView = pickerView
        cell.cellPickerView.showsSelectionIndicator = true
        if selected != nil {
            cell.cellPickerView.selectRow(selected!, inComponent: 0, animated: true)
        }
        // Adding a long gesture to close the pickerView
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: controller, action: "longPressActionPickerView:")
        cell.cellPickerView.addGestureRecognizer(longPressGestureRecognizer)
        cell.addSubview(cell.cellPickerView)
        return cell
    }
}
