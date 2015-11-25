//
//  TransactionTableViewController.swift
//  UGotMoney
//
//  Created by Laurent Nicolas on 11/19/15.
//  Copyright © 2015 Laurent Nicolas. All rights reserved.
//

import UIKit
import CoreData

class TransactionTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var transactions: [Transaction]!
    var person: Person! = nil
    
    override func viewWillAppear(animated: Bool) {
    
        super.viewWillAppear(animated)
        transactions = getTransactions()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return transactions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cellWithSub", forIndexPath: indexPath) as UITableViewCell
        let transaction = transactions[indexPath.row]
        cell.textLabel?.text = transaction.person.name + " " + Formatting.formattedCurrency(transaction.amountPaid)
        cell.detailTextLabel?.text = Formatting.formattedDate(transaction.paymentDate) + " - " + Formatting.formattedDate(transaction.serviceDate) + " - " + transaction.paymentType
        
        return cell
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
