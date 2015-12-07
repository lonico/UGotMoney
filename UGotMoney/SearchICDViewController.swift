//
//  SearchICDViewController.swift
//  UGotMoney
//
//  Created by Laurent Nicolas on 11/21/15.
//  Copyright © 2015 Laurent Nicolas. All rights reserved.
//

import UIKit

// Controller to look-up a know ICD-10 code, or to perform a partial search.
// For a succesful look-up, the detail view will be shown.
// For a succesful search, a list of ICD-10 will be shown.
class SearchICDViewController: UIViewController {
    
    var isAuthenticated = false
    
    @IBOutlet var activityIndicatorLookUp: UIActivityIndicatorView!
    @IBOutlet var activityIndicatorSearch: UIActivityIndicatorView!
    
    @IBOutlet var nameLookUp: UITextField!
    @IBOutlet var nameSearch: UITextField!
    @IBOutlet var descriptionSearch: UITextField!
    
    @IBOutlet var lookUpButton: UIButton!
    @IBOutlet var searchButton: UIButton!
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        activityIndicatorLookUp.hidesWhenStopped = true
        activityIndicatorSearch.hidesWhenStopped = true
        
        if isAuthenticated {
            readyForBusiness()
        } else {
            waitingForResponse()
            AquaClient.shared_instance().getClientToken() { error in
                
                dispatch_async(dispatch_get_main_queue()) {
                    if error != nil {
                        print("Error: \(error)")
                        
                        let alert = AlertController.Alert(msg: error, title: AlertController.AlertTitle.AuthenticationError) { action in
                            self.navigationController?.popViewControllerAnimated(true)
                        }
                        
                        alert.dispatchAlert(self)
                    } else {
                        //print("DONE with authentication")
                        self.isAuthenticated = true
                        self.lookUpButton.enabled = true
                        self.searchButton.enabled = true
                    }
                    self.activityIndicatorLookUp.stopAnimating()
                    self.activityIndicatorSearch.stopAnimating()
                }
            }
        }
    }

    // MARK: action buttons
    
    @IBAction func lookUpButtonTouchUp(sender: UIButton) {
        
        let name = nameLookUp.text
        if name != nil && name != "" {
            waitingForResponse()
            AquaClient.shared_instance().lookUpICD10CodesWithName(sanitizeName(name!)) { details, error in
                
                dispatch_async(dispatch_get_main_queue()) {
                    if error != nil {
                        print("Error: \(error)")
                        AlertController.Alert(msg: "\(error) for \(name!)", title: AlertController.AlertTitle.QueryError).showAlert(self)
                        self.readyForBusiness()
                    } else if details == nil {
                        AlertController.Alert(msg: "no results", title: AlertController.AlertTitle.QueryError).showAlert(self)
                        self.readyForBusiness()
                    } else {
                        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("icd10DetailsVC") as! ICD10DetailsTableViewController
                        vc.details = [details]
                        vc.mainTitle = details["name"] as? String
                        vc.subtitle = details["description"] as? String
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        } else {
            AlertController.Alert(msg: "please give a valid code name", title: AlertController.AlertTitle.EmptyName).showAlert(self)
        }
    }
    
    @IBAction func searchButtonTouchUp(sender: UIButton) {
        
        let name = nameSearch.text!
        let description = descriptionSearch.text!
        let query = buildQuery(name, description: description)
        
        waitingForResponse()
        
        AquaClient.shared_instance().queryICD10Codes(query) { results, error in
            
            dispatch_async(dispatch_get_main_queue()) {
                if error != nil {
                    print("Error: \(error)")
                    AlertController.Alert(msg: error, title: AlertController.AlertTitle.QueryError).showAlert(self)
                    self.readyForBusiness()
                } else if results == nil || results.count == 0 {
                    AlertController.Alert(msg: "no results for name: \(name), description: \(description)", title: AlertController.AlertTitle.QueryError).showAlert(self)
                    self.readyForBusiness()
                } else {
                    let vc = self.storyboard?.instantiateViewControllerWithIdentifier("icd10ResultsTableVC") as! ICD10ResultsTableViewController
                    vc.results = results
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    func waitingForResponse() {
        lookUpButton.enabled = false
        searchButton.enabled = false
        activityIndicatorLookUp.startAnimating()
        activityIndicatorSearch.startAnimating()
    }
    
    func readyForBusiness() {
        lookUpButton.enabled = true
        searchButton.enabled = true
        activityIndicatorLookUp.stopAnimating()
        activityIndicatorSearch.stopAnimating()
    }
    
    // MARK: support functions
    
    func buildQuery(name: String!, description: String!) -> [String: String]! {
        
        var qtype: String! = nil
        var query: [String: String]! = [:]
        if name != nil && name != "" {
            let (value, suffix) = getSuffixFromWilcards(name, defaultChoice: "start")
            if (value != "") {
                qtype = "q[name\(suffix)]"
                query[qtype] = value
            }
        }
        if description != nil && description != "" {
            let (value, suffix) = getSuffixFromWilcards(description, defaultChoice: "cont")
            if (value != "") {
                qtype = "q[description\(suffix)]"
                query[qtype] = value
            }
        }
        if query.count > 0 {
            return query
        }
        return nil
    }
    
    func getSuffixFromWilcards(aString: String, defaultChoice: String) -> (String, String) {
        
        var newString = aString
        var has_prefix = false
        var has_suffix = false
        var query_suffix = ""
        
        if newString.hasPrefix("%") {
            has_prefix = true
            newString = newString.substringFromIndex(newString.startIndex.advancedBy(1))
            //print(">>>\(newString)")
        }
        if newString.hasSuffix("%") {
            has_suffix = true
            newString = newString.substringToIndex(newString.endIndex.advancedBy(-1))
            //print(">>>\(newString)")
        }
        if has_prefix && has_suffix {
            query_suffix = "_cont"
        } else if has_prefix {
            query_suffix = "_end"
        } else if has_suffix {
            query_suffix = "_start"
        } else {
            if defaultChoice == "start" {
                query_suffix = "_start"
            } else {
                query_suffix = "_cont"
            }
        }
        return (newString, query_suffix)
    }
    
    func sanitizeName(name: String) -> String {
        
        return name.stringByReplacingOccurrencesOfString(".", withString: "-")
    }
}
