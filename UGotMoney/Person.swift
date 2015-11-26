//
//  Person.swift
//  UGotMoney
//
//  Created by Laurent Nicolas on 11/14/15.
//  Copyright © 2015 Laurent Nicolas. All rights reserved.
//

import Foundation
import CoreData
import UIKit

@objc(Person)

class Person: NSManagedObject {
    
    @NSManaged var firstName: String
    @NSManaged var lastName: String
    @NSManaged var middleName: String
    @NSManaged var id: Int              // unique id for privacy
    @NSManaged var transactions: [Transaction]
    @NSManaged var active: Bool
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
        
    init?(firstName: String, middleName: String?, lastName: String, id: Int!, context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("Person", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)

        self.firstName = firstName
        self.lastName = lastName
        if middleName == nil {
            self.middleName = ""
        } else {
            self.middleName = middleName!
        }
        if id == nil {
            self.id = Person.getNextId()
        } else {
            return nil
        }
        active = true
    }
    
    func deactivate() {
        active = false
    }

    func activate() {
        active = true
    }
    
    var checksum: Int {
        return id
    }
    
    // return count+1
    static func getNextId()->Int {
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetch error, \(error.localizedDescription)")
            return 0
        }
        
        if let fetchedObjects = fetchedResultsController.fetchedObjects {
            if fetchedObjects.count > 0 {
                let max_id = fetchedObjects[0].valueForKey("id") as! Int
                print(">>> \(max_id)")
                return max_id + 1
            }
        }
        return 0
    }
    
    var name: String {
        
        return [firstName, middleName, lastName].joinWithSeparator(" ")
    }
    
    static func name(firstName: String, middleName: String, lastName: String) -> String {
        
        return [firstName, middleName, lastName].joinWithSeparator(" ")
    }
    
    static func getClientNames() -> [String] {
        
        var clientNames: [String] = []
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetch error, \(error.localizedDescription)")
            return clientNames
        }
        
        if let fetchedObjects = fetchedResultsController.fetchedObjects as? [Person] {
            for person in fetchedObjects {
                clientNames.append(person.name)
            }
        }
        return clientNames
    }
    
    static func getClientNamesLowerCase() -> [String] {
        
        let clientNames = getClientNames()
        return clientNames.map({$0.lowercaseString})
    }
    
    static func getClientNamesDict() -> [String: Person] {
        
        var clientNames: [String: Person] = [:]
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetch error, \(error.localizedDescription)")
            return clientNames
        }
        
        if let fetchedObjects = fetchedResultsController.fetchedObjects as? [Person] {
            for person in fetchedObjects {
                clientNames[person.name] = person
            }
        }
        return clientNames
    }
    
    static func getPerson(name: String) -> Person! {
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetch error, \(error.localizedDescription)")
            return nil
        }
        
        if let fetchedObjects = fetchedResultsController.fetchedObjects as? [Person] {
            for person in fetchedObjects {
                if name == person.name {
                    return person
                }
            }
        }
        return nil
    }
    
    // MARK: coredata

    static var fetchedResultsController: NSFetchedResultsController = {
        
        let request = NSFetchRequest(entityName: "Person")
        
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        request.predicate = NSPredicate(format: "active == true")
        
        let context = CoreDataStackManager.sharedInstance().managedObjectContext
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
    }()
}