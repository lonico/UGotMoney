//
//  Formatting.swift
//  pickerViews
//
//  Created by Laurent Nicolas on 11/6/15.
//  Copyright © 2015 Laurent Nicolas. All rights reserved.
//

import Foundation

struct Formatting {
    
    static let dateFormat = NSDateFormatter.dateFormatFromTemplate("EEE, MMM d, yyyy", options: 0, locale: NSLocale.currentLocale())
    static let dateFormatter = NSDateFormatter()
    
    static func formattedDate(date: NSDate!) -> String! {
        
        if date == nil {
            return nil
        }
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.stringFromDate(date)
    }
    
    static let currencyFormatter = NSNumberFormatter()
    
    static func formattedCurrency(value: Float!) -> String! {
        
        if value == nil {
            return nil
        }
        currencyFormatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        return currencyFormatter.stringFromNumber(value)
    }
    
    static func floatFromCurrency(value: String) -> Float {
        
        currencyFormatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        if let fvalue = currencyFormatter.numberFromString(value) {
            return Float(fvalue)
        }
        let msg = "ERROR: unexpected number: \(value) in \(__FUNCTION__)"
        print(msg)
        return 0
    }

}