//
//  DVNTableViewCell.swift
//  Lendivine
//
//  Created by john bateman on 4/2/16.
//  Copyright © 2016 John Bateman. All rights reserved.
//
//  This base class provides common methods for a table view cell containing a loan.

import UIKit
import CoreData

class DVNTableViewCell: UITableViewCell {

    weak var parentTableView: UITableView?              // The parent UITableView
    weak var parentController: UITableViewController?   // The parent UITableViewController

    /*! 
        @brief Display an alert controller indicating the specified loan has already been added to the cart.
        @discussion This is a convenience view function used by multiple table view cell classes in the Lendivine app.
        @param (in) loan - An attempt was made to add this loan to the cart.
        @param (in) controller - The parent view controller to host the alert.
    */
    func showLoanAlreadyInCartAlert(loan: KivaLoan, controller: UIViewController) {
        
        var message = "The selected loan has already been added to your cart."
        if let name = loan.name {
            message = "The loan requested by \(name) has already been added to your cart."
        }
        let alertController = UIAlertController(title: "Already in Cart", message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            // handle OK pressed in alert controller
        }
        alertController.addAction(okAction)
        controller.presentViewController(alertController, animated: true, completion: nil)
    }
    
}
