//
//  TextViewCell.swift
//  UGotMoney
//
//  Created by Laurent Nicolas on 11/7/15.
//  Copyright © 2015 Laurent Nicolas. All rights reserved.
//

import UIKit

// Customized cell for a TextField.
class TextViewCell: UITableViewCell {
    
    var cellTextView: UITextView!
    
    static func getCellForTextView(tableView: UITableView, textView: UITextView) -> UITableViewCell {
        
        let identifier = "TextViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier) as! TextViewCell
        //print(">>> Identifier \(identifier)")
        if cell.cellTextView == nil {
            textView.frame = cell.contentView.frame.insetBy(dx: 10, dy: 0)
            textView.textContainer.lineBreakMode = .ByWordWrapping
            if textView.frame.width > tableView.frame.width {
                textView.frame = CGRectMake(textView.frame.minX, textView.frame.minY, tableView.frame.width - 20, textView.frame.height)
            }
            cell.cellTextView = textView
        } else {
            cell.cellTextView.removeFromSuperview()
        }
        cell.contentView.addSubview(textView)
        if cell.cellTextView != textView {
            print(">>> Inconsistency in \(__FUNCTION__)")
        }
        return cell
    }
}
