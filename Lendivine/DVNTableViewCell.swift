//
//  DVNTableViewCell.swift
//  Lendivine
//
//  Created by john bateman on 4/2/16.
//  Copyright © 2016 John Bateman. All rights reserved.
//
//  This base class provides common methods for a table view cell containing a loan.\

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
    
    /*!
    @brief Save cart item to persistent data store using core data shared context.
    @discussion Update any loans already in the database to avoid adding duplicates.
    */
    func saveCartItem() {
        
        dispatch_async(dispatch_get_main_queue()) {
            
            // fetch all core data objects from persistent store to memory
            guard let controller = self.parentController as? LoansTableViewController else { return }
            
            if let loans = controller.fetchAllLoans() {
                
                for loan in loans {
                    
                    // If any of the loans already exist in core data memory then delete them before saving the context
                    
                    //let error: NSError?
                    let fetchRequest = NSFetchRequest(entityName: KivaLoan.entityName)
                    fetchRequest.predicate = NSPredicate(format: "id == %@", loan.id!)
                    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
                    
                    var results: [AnyObject]?
                    do {
                        results = try controller.sharedContext.executeFetchRequest(fetchRequest)
                        if let results = results {
                            for result in results {
                                if let matchedLoan = result as? KivaLoan {
                                    controller.sharedContext.deleteObject(matchedLoan)
                                }
                            }
                        }
                    } catch let error1 as NSError {
                        print("Error in fetchLoanByID(): \(error1)")
                        results = nil
                    }
                    
                }
                
                // commit the deletes to the core data sqlite data store on disk
                CoreDataStackManager.sharedInstance().saveContext()
                
                for loan in loans {
                    _ = KivaLoan(fromLoan: loan, context: controller.sharedContext)
                }
                // save all loans to disk
                CoreDataStackManager.sharedInstance().saveContext()
            }
        }
    }
}
