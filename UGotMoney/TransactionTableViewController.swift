//
//  TransactionTableViewController.swift
//  UGotMoney
//
//  Created by Laurent Nicolas on 11/19/15.
//  Copyright © 2015 Laurent Nicolas. All rights reserved.
//

import UIKit
import CoreData

// Show a list of transactions in a table, for all clients or one client.
// Selecting a transaction shows the details for this transaction.
class TransactionTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var transactions: [Transaction]!
    var person: Person! = nil
    
    override func viewWillAppear(animated: Bool) {
    
        super.viewWillAppear(animated)
        transactions = getTransactions()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return transactions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cellWithSub", forIndexPath: indexPath) as UITableViewCell
        let transaction = transactions[indexPath.row]
        cell.textLabel?.text = transaction.person.name + "    " + Formatting.formattedCurrency(transaction.amountPaid)
        cell.textLabel?.textColor = UIColor.blueColor()
        cell.detailTextLabel?.text = [Formatting.formattedDate(transaction.paymentDate),
                                      Formatting.formattedDate(transaction.serviceDate),
                                      transaction.paymentType,
                                      transaction.icd10].joinWithSeparator(" - ")
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let transaction = transactions[indexPath.row]
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("transactionDetailsVC") as! TransactionDetailsViewController
        vc.transaction = transaction
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: actions
    
    @IBAction func actionButtonTouchUp(sender: UIBarButtonItem) {
        
        let alert = AlertController.Alert(msg: "Do you want to export these transactions", title: AlertController.AlertTitle.Generic, style: .ActionSheet, actionTitle: AlertController.AlertActionTitle.Export) { action in
            
            if action.title == AlertController.AlertActionTitle.Export {
                self.exportTransactions()
            }
        }
        alert.showAlert(self)
    }
    
    func exportTransactions() {
    
        var filename = "transactions"
        
        if person != nil {
            
            filename += "_\(person.id)"
        }
        filename += ".csv"
        
        if let dir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
            let path = NSURL(fileURLWithPath: dir).URLByAppendingPathComponent(filename)
            //print("writing to \(path)")
            if FileAndiCloudServices.writeToFile(path, transactions: transactions, vc: self) {
                //print("copying to iCLoud")
                FileAndiCloudServices.saveFileToiCloud(path, filename: filename, vc: self)
            }
        } else {
            AlertController.Alert(msg: "Failed to create local file", title: AlertController.AlertTitle.InternalError).showAlert(self)
        }
    }
    
    
        
    // MARK: coredata

    func getTransactions() -> [Transaction] {
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetch error, \(error.localizedDescription)")
            return []
        }
        if let fetchedObjects = fetchedResultsController.fetchedObjects as? [Transaction] {
            return fetchedObjects
        }
        return []
    }

    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let request = NSFetchRequest(entityName: "Transaction")
        
        request.sortDescriptors = [NSSortDescriptor(key: "paymentDate", ascending: false)]
        if self.person != nil {
            request.predicate = NSPredicate(format: "person == %@", self.person)
        }
        let context = CoreDataStackManager.sharedInstance().managedObjectContext
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
    }()
}
