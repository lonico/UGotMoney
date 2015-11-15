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
    static let formatter = NSDateFormatter()
    
    static func formattedDate(date: NSDate) -> String {
        
        formatter.dateFormat = dateFormat
        return formatter.stringFromDate(date)
    }
}