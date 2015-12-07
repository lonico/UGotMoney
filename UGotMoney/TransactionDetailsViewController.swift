//
//  TransactionDetailsViewController.swift
//  UGotMoney
//
//  Created by Laurent Nicolas on 11/27/15.
//  Copyright © 2015 Laurent Nicolas. All rights reserved.
//

import UIKit

// Show the fields associated to a transaction.
class TransactionDetailsViewController: UIViewController {
    
    var transaction: Transaction!
    var ICDDescriptions: [String:String]!
    
    var noteTextView: UITextView!
    var icdTextView: UITextView!
    
    // For each row, the field being edited and
    // the type of the UIControl for the second row
    let rows: [(Transaction.FieldName, AddTransactionViewController.FieldType)] = [
        (.paymentDate, .textField),
        (.clientName, .textField),
        (.paymentValue, .textField),
        (.paymentType, .textField),
        (.icd10, .textField),
        (.icd10, .textView),
        (.serviceDate, .textField),
        (.notes, .textField),
        (.notes, .textView)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ICDDescriptions = PersistentData.getICDDescriptions()
        noteTextView = UITextView()
        //noteTextView.delegate = self
        icdTextView = UITextView()
    }
}

extension TransactionDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: tableview data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return rows.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let row = indexPath.row
        let (name, type) = rows[row]
        
        var cell = UITableViewCell()
        switch type {
        case .textField:
            cell = LabelAndTextFieldCell.getCellForLabelAndText(tableView, name: Transaction.getFieldLabel(name), type: type)
            let acell = cell as! LabelAndTextFieldCell
            acell.cellTextField.text = getValue(name)
        case .textView:
            if name == .icd10 {
                cell = TextViewCell.getCellForTextView(tableView, textView: icdTextView)
                let icdvalue = getValue(name)
                if icdvalue == "" {
                    cell.hidden = true
                } else {
                    let acell = cell as! TextViewCell
                    acell.cellTextView.text = ICDDescriptions[icdvalue] ?? ""
                }
            } else {
                cell = TextViewCell.getCellForTextView(tableView, textView: noteTextView)
                let acell = cell as! TextViewCell
                acell.cellTextView.text = transaction.notes
            }
        default:
            cell = LabelAndTextFieldCell.getCellForLabelAndText(tableView, name: "ERROR: unexpected type: \(type)", type: .textField)
            print("ERROR: unexpected row: \(row)")
        }
        return cell
    }
    
    // MARK: tableview delegates
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let (name, type) = rows[indexPath.row]
        if name == .notes && type == .textView {
            let identifier = "TextViewCell"
            let acell = tableView.dequeueReusableCellWithIdentifier(identifier) as! TextViewCell
            return acell.frame.size.height
        }
        if name == .icd10 && type == .textView {
            if getValue(name) == "" {
                return 0
            }
        }
        return tableView.rowHeight
    }
    
    // MARK: Utilities
    
    func getValue(name: Transaction.FieldName) -> String {
        
        var value: String
        switch name {
        case .clientName:
            value = transaction.person.name
        case .paymentValue:
            value = Formatting.formattedCurrency(transaction.amountPaid)
        case .paymentType:
            value = transaction.paymentType
        case .icd10:
            value = transaction.icd10
        case .serviceDate:
            value = Formatting.formattedDate(transaction.serviceDate)
        case .paymentDate:
            value = Formatting.formattedDate(transaction.paymentDate)
        case .notes:
            value = ""
        }

        return value
    }
}
