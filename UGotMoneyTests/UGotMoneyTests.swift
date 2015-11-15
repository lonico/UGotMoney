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
    
}
