//
//  ICD10DetailsTableViewController.swift
//  UGotMoney
//
//  Created by Laurent Nicolas on 11/22/15.
//  Copyright © 2015 Laurent Nicolas. All rights reserved.
//

import UIKit

protocol ICD10DetailsTableViewControllerDelegate {
    
    func didSelectICD(value: String!, description: String!)
}

class ICD10DetailsTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var details: [[String: AnyObject]]!
    var mainTitle: String!
    var subtitle: String!
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        nameLabel.text = mainTitle
        descriptionLabel.text = subtitle
    }
    
    // MARK: tableview data source and delegates
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return details[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("icd10DetailsViewCell")!
        var (title, subtitle, more) = getDataForIndexPath(indexPath)
        cell.textLabel?.text = title
        if subtitle == nil {
            subtitle = ""
        }
        if more {
            //subtitle = String(format: "%@   %40@", subtitle, "> more")
            cell.accessoryType = .DisclosureIndicator
        } else {
            cell.accessoryType = .None
        }
        cell.detailTextLabel?.text = subtitle
        return cell
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        
        let (type, _, _, _) = getMoreForIndexPath(indexPath)
        if type == .dict || type == .array_of_dict {
            return indexPath
        }
        return nil
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return details.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let (type, _, _, object) = getMoreForIndexPath(indexPath)
        if type == .dict || type == .array_of_dict {
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("icd10DetailsVC") as! ICD10DetailsTableViewController
            if type == .dict {
                let dict = object as! [String: AnyObject]
                vc.details = [dict]
            } else {
                let array_of_dict = object as! [[String: AnyObject]]
                vc.details = array_of_dict
            }
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            vc.mainTitle = self.mainTitle
            vc.subtitle = cell?.textLabel?.text
            dispatch_async(dispatch_get_main_queue()) {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    // MARK: action button
    
    
    @IBAction func addButtonTouchUp(sender: UIBarButtonItem) {
        
        for vc in (navigationController?.viewControllers)! {
            if vc.isKindOfClass(EditPickerValuesViewController) {
                 (vc as! EditPickerValuesViewController).didSelectICD(mainTitle, description: subtitle)
            }
        }
    }
    
    // MARK: support functions
    
    func getDataForIndexPath(indexPath: NSIndexPath) -> (String, String!, Bool) {
        
        let (type, key, value, object) = getMoreForIndexPath(indexPath)
        if type == .array {
            let array = object as! [String]
            return (key, array.joinWithSeparator(" - "), false)
        }
        if type == .dict || type == .array_of_dict {
            return (key, value, true)
        }
        return (key, value, false)
    }
    
    enum Type {
        case isnil
        case isnull
        case empty_string
        case empty_array
        case empty_dict
        case string
        case dict
        case array
        case array_of_dict
        case unknown
    }

    func getMoreForIndexPath(indexPath: NSIndexPath) -> (Type, String, String!, AnyObject!) {
        
        let sectionDict = details[indexPath.section]
        let keys = sectionDict.keys.sort()
        let row = indexPath.row
        let key = keys[row]
        let value = sectionDict[key]
        
        var type: Type = .unknown
        var label: String! = "???"
        var object: AnyObject! = nil
        
        if value == nil {
            type = .isnil
            label =  "<empty>"
        } else if let _ = sectionDict[key] as? NSNull {
            type = .isnull
            label =  "<empty>"
        } else if let value = sectionDict[key] as? String {
            if value == "" {
                type = .empty_string
                label =  "<empty>"
            } else {
                type = .string
                label =  value
                object = value
            }
        } else if let value = sectionDict[key] as? Int {
            type = .string
            label =  "\(value)"
            object = label
        } else if let value = sectionDict[key] as? [String: AnyObject] {
            if value.count == 0 {
                type = .empty_dict
                label =  "<empty>"
            } else {
                type = .dict
                label = value["name"] as? String
                object = value
            }
        } else if let value = sectionDict[key] as? [[String: AnyObject]] {
            if value.count == 0 {
                type = .empty_array
                label =  "<empty>"
            } else {
                type = .array_of_dict
                label = countToLabel(value.count)
                object = value
            }
            
        } else if let value = sectionDict[key] as? [String] {
            if value.count == 0 {
                type = .empty_array
                label =  "<empty>"
            } else {
                type = .array
                label = countToLabel(value.count)
                object = value
            }
        }
        return (type, key, label, object)
    }
    
    func countToLabel(count: Int) -> String {
        
        var label = "<\(count) element"
        if count > 1 {
            label += "s"
        }
        label += ">"
        return label
    }
}
