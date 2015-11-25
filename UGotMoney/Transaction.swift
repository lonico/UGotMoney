//
//  Transaction.swift
//  UGotMoney
//
//  Created by Laurent Nicolas on 11/14/15.
//  Copyright © 2015 Laurent Nicolas. All rights reserved.
//

import Foundation
import CoreData

@objc(Transaction)

class Transaction: NSManagedObject {
    
    @NSManaged var paymentDate: NSDate
    @NSManaged var person: Person
    @NSManaged var amountPaid: Float
    @NSManaged var paymentType: String
    @NSManaged var notes: String
    @NSManaged var serviceDate: NSDate
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(paymentDate: NSDate, person: Person, amountPaid: Float, paymentType: String, notes: String, serviceDate: NSDate, context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("Transaction", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.paymentDate = paymentDate
        self.person = person
        self.amountPaid = amountPaid
        self.paymentType = paymentType
        self.notes = notes
        self.serviceDate = serviceDate
    }
    
}