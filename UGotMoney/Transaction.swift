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
    @NSManaged var paymentMethod: String
    @NSManaged var notes: String
    @NSManaged var serviceDate: NSDate
    
}