//
//  AlertController.swift
//  UGotMoney
//
//  Created by Laurent Nicolas on 11/14/15.
//  Copyright © 2015 Laurent Nicolas. All rights reserved.
//

import UIKit

struct AlertController {
    
    struct Alert {
        let msg: String?
        let title: String?
        let handler: ((UIAlertAction) -> Void)?
        
        init(msg: String?, title: String?, handler: ((UIAlertAction) -> Void)? = nil) {
            self.msg = msg
            self.title = title
            self.handler = handler
        }
        
        func showAlert(vc: UIViewController) -> Void {
            
            var valid_title = title
            if valid_title == nil {
                valid_title = AlertTitle.Generic
            }
            let alertController = UIAlertController(title: valid_title, message: msg, preferredStyle: .Alert)
            var cancelAction: UIAlertAction
            if handler == nil {
                cancelAction = UIAlertAction(title: AlertActionTitle.Dismiss, style: UIAlertActionStyle.Cancel, handler: nil)
            } else {
                cancelAction = UIAlertAction(title: AlertActionTitle.Dismiss, style: UIAlertActionStyle.Cancel) { action in
                    self.handler!(action)
                }
            }
            alertController.addAction(cancelAction)
            vc.presentViewController(alertController, animated: true, completion: nil)
        }
        
        func dispatchAlert(vc: UIViewController) -> Void {
            
            // Only show the alert if the VC is still active, and not presenting another VC
            if vc.isViewLoaded() && vc.presentedViewController == nil {
                dispatch_async(dispatch_get_main_queue()) {
                    self.showAlert(vc)
                }
            } else {
                print("\(__FUNCTION__): \(vc.isViewLoaded()), \(vc.view.window), \(vc.presentedViewController),")
            }
        }
    }
    
    struct AlertTitle {
        
        static let Generic = "Alert"
        static let InternalError = "Internal error"
        
        static let AuthenticationError = "Failed to connect or authenticate with server"
        static let QueryError = "Failed to query data from server"
        static let EmptyName = "Empty name"
        static let EmptyList = "Empty list"
        static let DuplicateEntry = "Duplicate Name"
        static let RefreshError = "Refresh error"
        static let OpenURLError = "Failed to open URL"
        static let MissingURLError = "Empty URL string"
        static let MissingLocationError = "Empty location"
        static let Details = "Details"
        static let Success = "Success"
        
    }
    
    struct AlertActionTitle {
        
        static let Dismiss = "Dismiss"
    }
}