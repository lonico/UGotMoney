//
//  FileAndiCoudServices.swift
//  UGotMoney
//
//  Created by Laurent Nicolas on 12/4/15.
//  Copyright © 2015 Laurent Nicolas. All rights reserved.
//

import UIKit

struct FileAndiCloudServices {
    
    static func writeToFile(path: NSURL, transactions: [Transaction], vc: UIViewController) -> Bool {
        
        let fileManager = NSFileManager.defaultManager()
        
        if !fileManager.fileExistsAtPath(path.path!) {
            fileManager.createFileAtPath(path.path!, contents: nil, attributes: nil)
        }
        
        var fileHandle: NSFileHandle
        
        do {
            fileHandle = try NSFileHandle(forWritingToURL: path)
        }
        catch let error as NSError {
            print("error opening \(path)")
            print(error.localizedDescription)
            AlertController.Alert(msg: "error opening \(path): \(error.localizedDescription)", title: AlertController.AlertTitle.InternalError).showAlert(vc)
            return false
        }
        
        for transaction in transactions {
            let text = transaction.csv + "\n"
            fileHandle.writeData(text.dataUsingEncoding(NSUTF8StringEncoding)!)
            
        }
        fileHandle.closeFile()
        return true
    }
    
    static func saveFileToiCloud(path: NSURL, filename: String, vc: UIViewController) {
    
        let fileManager = NSFileManager.defaultManager()
        let iCloudURL = fileManager.URLForUbiquityContainerIdentifier(nil)
        if iCloudURL == nil {
            AlertController.Alert(msg: "iCloud is not available - check that you have enabled iCloud on this device", title: AlertController.AlertTitle.OpenURLError).showAlert(vc)
            return
        }
        let iCloudDocURL = iCloudURL!.URLByAppendingPathComponent("Documents")
        if !fileManager.fileExistsAtPath((iCloudDocURL.path)!) {
            do {
                try fileManager.createDirectoryAtURL(iCloudDocURL, withIntermediateDirectories: false, attributes: nil)
            }
            catch let error as NSError {
                print("error creating iCloud directory \(iCloudDocURL)")
                print(error.localizedDescription)
                AlertController.Alert(msg: "error creating iCloud directory \(iCloudDocURL): \(error.localizedDescription)", title: AlertController.AlertTitle.InternalError).showAlert(vc)
                return
            }
        }
        let iCloudPath = iCloudDocURL.URLByAppendingPathComponent(filename)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            if fileManager.fileExistsAtPath(iCloudPath.path!) {
                do {
                    try fileManager.removeItemAtURL(iCloudPath)
                }
                catch let error as NSError {
                    print("error deleting file in iCLoud \(iCloudPath)")
                    print(error.localizedDescription)
                    AlertController.Alert(msg: "error deleting file in iCLoud \(iCloudPath): \(error.localizedDescription)", title: AlertController.AlertTitle.InternalError).dispatchAlert(vc)
                    return
                }
            }
            
            do {
                try fileManager.setUbiquitous(true, itemAtURL: path, destinationURL: iCloudPath)
            }
            catch let error as NSError {
                print("error copying file to iCLoud \(iCloudPath)")
                print(error.localizedDescription)
                AlertController.Alert(msg: "error copying file to iCLoud \(iCloudPath): \(error.localizedDescription)", title: AlertController.AlertTitle.InternalError).dispatchAlert(vc)
                return
            }
            
            var value: AnyObject?
            do {
                try iCloudPath.getResourceValue(&value, forKey: NSURLIsUbiquitousItemKey)
                print ("key: NSURLIsUbiquitousItemKey, value: \(value)")
                var success = false
                if let value = value as? NSNumber {
                    if value == 1 {
                        success = true
                    }
                }
                if success {
                    AlertController.Alert(msg: "Transactions exported to iCloud drive)", title: AlertController.AlertTitle.Success).dispatchAlert(vc)
                } else {
                    AlertController.Alert(msg: "Transactions could not be exported)", title: AlertController.AlertTitle.Generic).dispatchAlert(vc)
                }
            } catch let error as NSError {
                print("error getting key value for: \(iCloudPath)")
                print(error.localizedDescription)
                AlertController.Alert(msg: "error getting key value for: \(iCloudPath): \(error.localizedDescription)", title: AlertController.AlertTitle.InternalError).dispatchAlert(vc)
                return
            }
        }
    }
}