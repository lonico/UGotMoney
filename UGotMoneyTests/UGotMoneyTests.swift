//
//  UGotMoneyTests.swift
//  UGotMoneyTests
//
//  Created by Laurent Nicolas on 11/1/15.
//  Copyright © 2015 Laurent Nicolas. All rights reserved.
//

import XCTest
@testable import UGotMoney

class UGotMoneyTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testDateFormattingRef() {
        let secondsFromGMT = NSTimeZone.defaultTimeZone().secondsFromGMT
        let date = NSDate(timeIntervalSinceReferenceDate: Double(-secondsFromGMT)) // adjust from UTC to local time
        let formatted_date = Formatting.formattedDate(date)
        XCTAssertEqual(formatted_date, "Mon, Jan 1, 2001")
    }
    
    func testDateFormattingFromString() {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        let date = formatter.dateFromString("11/10/15")
        let formatted_date = Formatting.formattedDate(date!)
        XCTAssertEqual(formatted_date, "Tue, Nov 10, 2015")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testFloatoString() {
        let str = Formatting.formattedCurrency(12.34)
        XCTAssertEqual(str, "$12.34")
    }
    
    func testStringToFloat() {
        let fvalue = Formatting.floatFromCurrency("$1456.45")
        XCTAssertEqual(fvalue, 1456.45)
    }
    
    
    
    func testPerson() {
        let context = CoreDataStackManager.sharedInstance().managedObjectContext
        let person = Person(firstName: "First", middleName: "Middle", lastName: "Last", id: nil, context: context)
        XCTAssertNotNil(person, "Failed to create Person object")
        XCTAssertEqual(person?.name, "First Middle Last")
    }
    
    func testTransaction() {
        let context = CoreDataStackManager.sharedInstance().managedObjectContext
        let person = Person(firstName: "First", middleName: "Middle", lastName: "Last", id: nil, context: context)
        XCTAssertNotNil(person, "Failed to create Person object")
        if person == nil {
            return
        }
        XCTAssertEqual(person!.name, "First Middle Last")
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        let date = formatter.dateFromString("11/10/15")
        let expectedCSVDate = "11/10/2015"
        let transactionDict: [Transaction.FieldName: AnyObject!] = [
            Transaction.FieldName.clientName: person!.name,
            Transaction.FieldName.paymentDate: date,
            Transaction.FieldName.paymentValue: 130.0,
            Transaction.FieldName.paymentType: "cash",
            Transaction.FieldName.icd10: "",
            Transaction.FieldName.notes: ""
            ]
        let transaction = Transaction(transactionDict: transactionDict, context: context)
        XCTAssertEqual(transaction.csv, "\(person!.id),\(expectedCSVDate),130.0,\"cash\",\"\",\(expectedCSVDate),\"\"\n")
    }
}
