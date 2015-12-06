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
    @NSManaged var icd10: String
    @NSManaged var notes: String
    @NSManaged var serviceDate: NSDate
    
    enum FieldName {
        case paymentDate
        case clientName
        case paymentValue
        case paymentType
        case icd10
        case serviceDate
        case notes
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(transactionDict: [FieldName: AnyObject!], context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("Transaction", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        let person = Person.getPerson(transactionDict[.clientName] as! String, activeOnly: true)
        // print(">>>person: \(person)")
        if person == nil {
            return
        }
        
        self.person = person
        self.amountPaid = transactionDict[.paymentValue] as! Float
        self.paymentType = transactionDict[.paymentType] as! String
        self.icd10 = transactionDict[.icd10] as! String
        self.notes = transactionDict[.notes] as! String
        self.paymentDate = transactionDict[.paymentDate] as? NSDate ?? NSDate()
        self.serviceDate = transactionDict[.serviceDate] as? NSDate ?? self.paymentDate
    }
    
    // return number of elements for pickerChoices
    // DatePickers arbitrirarly set to 1
    static func getFieldLabel(name: Transaction.FieldName) -> String {
        
        var value: String
        switch name {
        case .clientName:
            value = "Client name"
        case .paymentValue:
            value = "Amount paid"
        case .paymentType:
            value = "Payment type"
        case .paymentDate:
            value = "Payment date"
        case .serviceDate:
            value = "Service date"
        case .icd10:
            value = "ICD-10"
        case .notes:
            value = "Notes"
        }
        return value
    }
    
    static var csvTitle: String {
        
        return [
                "Id",
                getFieldLabel(.paymentDate),
                getFieldLabel(.paymentValue),
                getFieldLabel(.paymentType),
                getFieldLabel(.icd10),
                getFieldLabel(.serviceDate),
                getFieldLabel(.notes)
                ].joinWithSeparator(",") + "\n"
    }
    
    var csv: String {
        
        return [
                "\(person.id)",
                "\(Formatting.formattedDateCSV(paymentDate))",
                "\(amountPaid)",
                "\"\(paymentType)\"",
                "\"\(icd10)\"",
                "\(Formatting.formattedDateCSV(serviceDate))",
                "\"\(notes)\""
                ].joinWithSeparator(",")  + "\n"
    }
    
    
    
}