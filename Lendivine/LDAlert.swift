//
//  LDAlert.swift
//  Lendivine
//
//  Created by john bateman on 2/16/16.
//  Copyright © 2016 John Bateman. All rights reserved.
//

import UIKit
import Foundation

class LDAlert {
    
    var controller: UIViewController?
    
    /* designated initializer */
    init(viewController: UIViewController) {
        controller = viewController
    }
    
    /*
    @brief display an UIAlertView presenting the error to the end user
    usage:
    LDAlert(viewController:self).displayErrorAlertView("error_title", message: "error_message \(some_var)")
    */
    func displayErrorAlertView(title: String, message: String) {
        // Make the alert controller
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        // Create and add the actions
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { UIAlertAction in
            // do nothing on OK
        }
        alertController.addAction(okAction)
        
        // Present the Alert controller
        dispatch_async(dispatch_get_main_queue()) {
            if let controller = self.controller {
                controller.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
}