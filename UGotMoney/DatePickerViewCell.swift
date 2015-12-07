//
//  DatePickerViewCell.swift
//  pickerViews
//
//  Created by Laurent Nicolas on 11/4/15.
//  Copyright © 2015 Laurent Nicolas. All rights reserved.
//

import UIKit

// Customized cell for DatePicker
class DatePickerViewCell: UITableViewCell {
    
    var cellPickerView: UIDatePicker! = nil
    
    static func getCellForDatePickerView(tableView: UITableView, controller: UIViewController, initialDate: NSDate) -> UITableViewCell {
        let identifier = "datePickerViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier) as! DatePickerViewCell
        //print(">>> Identifier \(identifier)")
        if cell.cellPickerView == nil {
            cell.cellPickerView =  UIDatePicker()
            cell.cellPickerView.datePickerMode = .Date
            cell.cellPickerView.addTarget(controller, action: "dateValueChanged:", forControlEvents: .ValueChanged)
            cell.addSubview(cell.cellPickerView)
        }
        cell.cellPickerView.setDate(initialDate, animated: true)
        return cell
    }
}
