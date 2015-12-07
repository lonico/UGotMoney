//
//  PersistentData.swift
//  UGotMoney
//
//  Created by Laurent Nicolas on 11/14/15.
//  Copyright © 2015 Laurent Nicolas. All rights reserved.
//

import Foundation

// Fields with a limited set of values are kept using NSUserDefaults.
// These support functions are used to store and retrieve data
struct PersistentData {
    
    struct Keys {
        static let paymentTypes = "paymentTypes"
        static let fees = "fees"
        static let ICDs = "ICDs"
        static let ICDDescriptions = "ICDDescriptions"
    }
    
    static func getPaymentTypes() -> [String] {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let paymentTypes = defaults.arrayForKey(Keys.paymentTypes) as? [String] {
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
        if let fees = defaults.arrayForKey(Keys.fees) as? [Float] {
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
        if var ICDs = defaults.arrayForKey(Keys.ICDs) as? [String] {
            if !ICDs.contains("") {
                ICDs.append("")
            }
            return ICDs
        }
        return [""]
    }
    
    static func storeICDs(ICDs: [String]) {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(ICDs, forKey: Keys.ICDs)
    }
    
    static func getICDDescriptions() -> [String: String] {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if var ICDescs = defaults.dictionaryForKey(Keys.ICDDescriptions) as? [String: String] {
            if ICDescs[""] == nil {
                ICDescs[""] = "<empty>"
            }
            return ICDescs
        }
        return ["":"<empty>"]
    }
    
    static func storeICDDescriptions(ICDs: [String: String]) {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(ICDs, forKey: Keys.ICDDescriptions)
    }

    
}