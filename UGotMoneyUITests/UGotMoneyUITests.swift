//
//  UGotMoneyUITests.swift
//  UGotMoneyUITests
//
//  Created by Laurent Nicolas on 11/1/15.
//  Copyright © 2015 Laurent Nicolas. All rights reserved.
//

import XCTest

class UGotMoneyUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let app = XCUIApplication()
        let tablesQuery = app.tables
        
        tablesQuery.cells.containingType(.StaticText, identifier: "Client name").element.tap()
        tablesQuery.pickerWheels["Antonio Banderas"].adjustToPickerWheelValue("Lucy Ball")  // BUG?  It adjusts to the previous value
        
        tablesQuery.cells.containingType(.StaticText, identifier: "Amount Paid").childrenMatchingType(.TextField).element.tap()
        tablesQuery.pickerWheels["100.00"].adjustToPickerWheelValue("130.00")
        
        tablesQuery.cells.containingType(.StaticText, identifier: "Payment type").childrenMatchingType(.TextField).element.tap()
        tablesQuery.pickerWheels["Square"].adjustToPickerWheelValue("cash (physical)")
        
        var textField = tablesQuery.cells.containingType(.StaticText, identifier: "Client name").childrenMatchingType(.TextField).element
        XCTAssertEqual(textField.value as! String?, "Lucky Luke")
        
        textField = tablesQuery.cells.containingType(.StaticText, identifier: "Amount Paid").childrenMatchingType(.TextField).element
        XCTAssertEqual(textField.value as! String?, "130.00")
        
        textField = tablesQuery.cells.containingType(.StaticText, identifier: "Payment type").childrenMatchingType(.TextField).element
        XCTAssertEqual(textField.value as! String?, "Cash (app)")
        
        tablesQuery.cells.containingType(.StaticText, identifier:"Notes").childrenMatchingType(.TextField).element.tap()
        app.otherElements["The"].tap()
        app.buttons["Return"].tap()
        tablesQuery.childrenMatchingType(.Cell).elementBoundByIndex(11).childrenMatchingType(.TextView).element.typeText("\n")
        // Failed to find matching element please file bug (bugreport.apple.com) and provide output from Console.app
        
    }
    
    
    
}
