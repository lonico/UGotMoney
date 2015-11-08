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
    
    static func getCellForNamePickerView(tableView: UITableView, pickerView: UIPickerView, selected: Int) -> UITableViewCell {
        var identifier: String
        identifier = "namePickerViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier) as! NamePickerViewCell
        cell.cellPickerView = pickerView
        cell.cellPickerView.showsSelectionIndicator = true
        cell.cellPickerView.selectRow(selected, inComponent: 0, animated: true)
        cell.addSubview(cell.cellPickerView)
        //print(">>> Identifier \(identifier)")
        return cell
    }
}
