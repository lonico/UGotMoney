//
//  Person.swift
//  UGotMoney
//
//  Created by Laurent Nicolas on 11/14/15.
//  Copyright © 2015 Laurent Nicolas. All rights reserved.
//

import Foundation
import CoreData

@objc(Person)

class Person: NSManagedObject {
    
    @NSManaged var firstName: String
    @NSManaged var lastName: String
    @NSManaged var middleName: String
    @NSManaged var id: Int              // unique id for privacy
    @NSManaged var transactions: [Transaction]
    
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
            self.id = get_next_id()
        } else {
            return nil
        }
    }
    
    var checksum: Int {
        return id
    }
    
    // return count+1
    func get_next_id()->Int {
        let fetchedObjects = fetchedResultsController.fetchedObjects as! [Person]
        if let max_id = fetchedObjects[0].valueForKey("id") as! Int? {
            print(">>> \(max_id)")
            return max_id + 1
        } else {
            return 0
        }
    }
    
    
    // MARK: coredata
    
    var sharedContext: NSManagedObjectContext {
        return AppDelegate().managedObjectContext
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let request = NSFetchRequest(entityName: "Person")
        
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: AppDelegate().managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
    }()

}