//
//  PersistentData.swift
//  UGotMoney
//
//  Created by Laurent Nicolas on 11/14/15.
//  Copyright © 2015 Laurent Nicolas. All rights reserved.
//

import Foundation

struct PersistentData {
    
    struct Keys {
        static let paymentTypes = "paymentTypes"
        static let fees = "fees"
        static let ICDs = "ICDs"
    }
    
    static func getPaymentTypes() -> [String] {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let paymentTypes = defaults.arrayForKey(Keys.paymentTypes) as! [String]? {
            return paymentTypes
        }
        return []
    }
    
    static func storePaymentTypes(paymentTypes: [String]) {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(paymentTypes, forKey: Keys.paymentTypes)
    }
    
    static func getFees() -> [Float] {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let fees = defaults.arrayForKey(Keys.fees) as! [Float]? {
            return fees
        }
        return []
    }
    
    static func storeFees(fees: [Float]) {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(fees, forKey: Keys.fees)
    }
    
    static func getICDs() -> [String] {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let ICDs = defaults.arrayForKey(Keys.ICDs) as! [String]? {
            return ICDs
        }
        return []
    }
    
    static func storeICDs(ICDs: [String]) {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(ICDs, forKey: Keys.ICDs)
    }
    

}