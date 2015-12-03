//
//  ClientTableViewController.swift
//  UGotMoney
//
//  Created by Laurent Nicolas on 11/24/15.
//  Copyright © 2015 Laurent Nicolas. All rights reserved.
//

import UIKit
import CoreData

class ClientTableViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    var clients: [Person]!
    
    override func viewWillAppear(animated: Bool) {
        print(">>> \(__FUNCTION__)")
        
        super.viewWillAppear(animated)
        clients = getPersons()
    }

    func getPersons() -> [Person]! {
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetch error, \(error.localizedDescription)")
            return nil
        }
        
        if let fetchedObjects = fetchedResultsController.fetchedObjects as? [Person] {
            return fetchedObjects
        }
        return nil
    }
    
    @IBAction func addButtonTouchUp(sender: UIBarButtonItem) {
        
        let vc = storyboard?.instantiateViewControllerWithIdentifier("addNewClientVC") as! AddNewClientViewController
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: coredata
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let request = NSFetchRequest(entityName: "Person")
        
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        
        let context = CoreDataStackManager.sharedInstance().managedObjectContext
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
    }()
}

extension ClientTableViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return clients.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("clientCell")!
        let person = clients[indexPath.row]
        cell.textLabel?.text = person.name
        if person.transactions.count > 0 {
            cell.accessoryType = .DisclosureIndicator
        }
        if person.active {
            cell.textLabel?.textColor = UIColor.blueColor()
        } else {
            cell.textLabel?.textColor = UIColor.lightGrayColor()
        }
        return cell
    }
}

extension ClientTableViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        
        let person = clients[indexPath.row]
        if person.transactions.count > 0 {
            return indexPath
        }
        return nil
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let person = clients[indexPath.row]
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("transactionTable") as! TransactionTableViewController
        vc.person = person
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ClientTableViewController: AddNewClientViewControllerDelegate {
    
    func didFinishAddingClient(value: Person!) {
        
        navigationController?.popViewControllerAnimated(true)
        if value != nil {
            clients = getPersons()
            tableView.reloadData()
        }
    }
}