//
//  LDAlert.swift
//  Lendivine
//
//  Created by john bateman on 2/16/16.
//  Copyright © 2016 John Bateman. All rights reserved.
//
//  This view class can be used to display an error alert controller.

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
    func displayErrorAlertView(_ title: String, message: String) {
        // Make the alert controller
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Create and add the actions
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { UIAlertAction in
            // do nothing on OK
        }
        alertController.addAction(okAction)
        
        // Present the Alert controller
        DispatchQueue.main.async {
            if let controller = self.controller {
                controller.present(alertController, animated: true, completion: nil)
            }
        }
    }
}
