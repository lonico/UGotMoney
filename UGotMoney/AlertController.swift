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
        let style: UIAlertControllerStyle
        let handler: ((UIAlertAction) -> Void)?
        let actionTitle: String?
        
        init(msg: String?, title: String?, handler: ((UIAlertAction) -> Void)? = nil) {
            self.msg = msg
            self.title = title
            self.style = .Alert
            self.handler = handler
            self.actionTitle = nil
        }

        init(msg: String?, title: String?, style: UIAlertControllerStyle, actionTitle: String, handler: ((UIAlertAction) -> Void)? = nil) {
            self.msg = msg
            self.title = title
            self.style = style
            self.handler = handler
            self.actionTitle = actionTitle
        }
        
        func showAlert(vc: UIViewController) -> Void {
            
            var valid_title = title
            if valid_title == nil {
                valid_title = AlertTitle.Generic
            }
            let alertController = UIAlertController(title: valid_title, message: msg, preferredStyle: style)
            var cancelAction: UIAlertAction
            var confirmAction: UIAlertAction
            var cancelActionTitle = AlertActionTitle.Dismiss
            if (style == .ActionSheet) {
                cancelActionTitle = AlertActionTitle.Cancel
            }
            if handler == nil {
                cancelAction = UIAlertAction(title: cancelActionTitle, style: UIAlertActionStyle.Cancel, handler: nil)
            } else {
                cancelAction = UIAlertAction(title: cancelActionTitle, style: UIAlertActionStyle.Cancel) { action in
                    self.handler!(action)
                }
            }
            if (style == .ActionSheet) {
                if handler == nil {
                    confirmAction = UIAlertAction(title: actionTitle, style: UIAlertActionStyle.Default) { action in
                        self.handler!(action)
                    }
                }else {
                    confirmAction = UIAlertAction(title: actionTitle, style: UIAlertActionStyle.Default) { action in
                        self.handler!(action)
                    }
                }
                alertController.addAction(confirmAction)
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
        static let Error = "Error"
        static let Details = "Details"
        static let Success = "Success"
        
        static let ConnectionError = "ConnectioError"
        
        static let AuthenticationError = "Failed to connect or authenticate with server"
        static let QueryError = "Failed to query data from server"
        static let EmptyName = "Empty name"
        
        static let DuplicateEntry = "Duplicate Name"
        static let EmptyList = "Empty list"

    }
    
    struct AlertActionTitle {
        
        static let Cancel = "Cancel"
        static let Dismiss = "Dismiss"
        static let Enable = "Enable"
        static let Export = "Export"
    }
}