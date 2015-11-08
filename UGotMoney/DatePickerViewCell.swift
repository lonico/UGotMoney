//
//  DatePickerViewCell.swift
//  pickerViews
//
//  Created by Laurent Nicolas on 11/4/15.
//  Copyright © 2015 Laurent Nicolas. All rights reserved.
//

import UIKit

class DatePickerViewCell: UITableViewCell {
    var cellPickerView: UIDatePicker!
    
    static func getCellForDatePickerView(tableView: UITableView) -> UITableViewCell {
        let identifier = "datePickerViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier) as! DatePickerViewCell
        //print(">>> Identifier \(identifier)")
        return cell
    }
}
