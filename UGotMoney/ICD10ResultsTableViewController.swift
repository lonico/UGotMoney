//
//  ICD10ResultsTableViewController.swift
//  UGotMoney
//
//  Created by Laurent Nicolas on 11/22/15.
//  Copyright © 2015 Laurent Nicolas. All rights reserved.
//

import UIKit

class ICD10ResultsTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var results: [[String: String]]!
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return results.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let record = results[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("ICD10ResultCell")!
        cell.textLabel?.text = record["name"]
        cell.detailTextLabel?.text = record["description"]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let urlString = results[indexPath.row]["url"] {
            AquaClient.shared_instance().lookUpICD10CodesWithURL(urlString) { details, error in
                
                if error != nil {
                    print("Error: \(error)")
                    AlertController.Alert(msg: error, title: AlertController.AlertTitle.QueryError).dispatchAlert(self)
                } else {
                    // print(">>> \(details)")
                    if details != nil {
                        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("icd10DetailsVC") as! ICD10DetailsTableViewController
                        vc.details = [details]
                        vc.mainTitle = details["name"] as! String
                        vc.subtitle = details["description"] as! String
                        dispatch_async(dispatch_get_main_queue()) {
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                }
            }
        }
    }
}


