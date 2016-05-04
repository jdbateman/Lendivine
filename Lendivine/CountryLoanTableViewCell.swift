//
//  CountryLoanTableViewCell.swift
//  Lendivine
//
//  Created by john bateman on 3/14/16.
//  Copyright © 2016 John Bateman. All rights reserved.
//
//  This class implements the custom table view cell for a loan displayed in the CountryLoansTableViewController.

import UIKit
import CoreData

class CountryLoanTableViewCell:DVNTableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sectorLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var loanImageView: UIImageView!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var addToCartButton: UIButton!
    
    @IBAction func onAddCountryLoanToCartButtonTap(sender: AnyObject) {
        
        // Find the cell starting from the button.
        let button = sender
        let contentView = button.superview!
        let cell = contentView!.superview as! CountryLoanTableViewCell
        
        // Find the tableView by walking the view hierarchy until a UITableView class is encountered.
        var view = cell.superview
        while ( (view != nil) && (view?.isKindOfClass(UITableView) == false) ) {
            view = view!.superview
        }
        let tableView: UITableView = view as! UITableView
        
        // Get the indexPath associated with this table cell
        let indexPath = tableView.indexPathForCell(cell)
        
        // Place the loan in the cart.
        let tableViewController = tableView.dataSource as! CountryLoansTableViewController
        
        // NOTE - In the future if we want to change CountryLoanTableViewController to use fetchedResultsController then enable the following line:
        //let loan = tableViewController.fetchedResultsController.objectAtIndexPath(indexPath!) as! KivaLoan
        let loan = tableViewController.loans[indexPath!.row]
        
        // set default donation amount to user preference.
        var amount = 25
        let appSettings = NSUserDefaults.standardUserDefaults()
        amount = appSettings.integerForKey("AccountDefaultDonation")
        if amount == 0 {
            amount = 25
        }
        
        let cart = KivaCart.sharedInstance
        
        if cart.KivaAddItemToCart(loan, donationAmount: amount, context: CoreDataContext.sharedInstance().cartContext) {
            
            // Persist the KivaCartItem object we added to the Core Data shared context
//TODO            self.saveCartItem(loan)
            
            // Persist the loan to the sharedContext.
//            self.persistLoan(loan)
            
//            dispatch_async(dispatch_get_main_queue()) {
//                print("saveContext: CountryLoanTableViewCell.onAddCountryLoanToCartButtonTap()")
//                CoreDataStackManager.sharedInstance().saveContext()
//            }
        } else {
            
            if let controller = self.parentController {
                self.showLoanAlreadyInCartAlert(loan, controller: controller)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
//    /*! Save a single loan to the shared context. */
//    func persistLoan(loan:KivaLoan?) {
//        
//        guard let loan = loan else { return }
//        
//                let fetchRequest = NSFetchRequest(entityName: KivaLoan.entityName)
//                fetchRequest.predicate = NSPredicate(format: "id == %@", loan.id!)
//        
//                var results: [AnyObject]?
//                do {
//                    results = try self.sharedContext.executeFetchRequest(fetchRequest)
//                    if let results = results {
//                        for result in results {
//                            if let matchedLoan = result as? KivaLoan {
//                                self.sharedContext.deleteObject(matchedLoan)
//                            }
//                        }
//                    }
//                } catch let error1 as NSError {
//                    print("Error in fetchLoanByID(): \(error1)")
//                    results = nil
//                }
//        
//        _ = KivaLoan(fromLoan: loan, context: self.sharedContext)
//        
//        // save the loan to disk
//        CoreDataStackManager.sharedInstance().saveContext()
//    }

    /*!
    @brief Save cart item to persistent data store using core data shared context.
    @discussion Update any loans already in the database to avoid adding duplicates.
    */
//    func saveCartItem(selectedLoan:KivaLoan?) {
//        
//        dispatch_async(dispatch_get_main_queue()) {
//            
//            // fetch all core data objects from persistent store to memory
//            guard let controller = self.parentController as? CountryLoansTableViewController else { return }
//            
//            if let loans = controller.fetchAllLoans() {
//                
//                print("fetched loans in saveCartItem:")
//                for loan in loans {
//                    print ("\(loan.name!) \(loan.country!)")
//                }
//                
//                var existingPersistedLoans = [KivaLoan]()
//                var newLoans = [KivaLoan]()
//                
//                // find the loans that already exist on disk
//                for loan in loans {
//                    
//                    let fetchRequest = NSFetchRequest(entityName: KivaLoan.entityName)
//                    fetchRequest.predicate = NSPredicate(format: "id == %@", loan.id!)
//                    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
//                    
//                    var results: [AnyObject]?
//                    do {
//                        results = try self.sharedContext.executeFetchRequest(fetchRequest)
//                        if let results = results {
//                            for result in results {
//                                if let matchedLoan = result as? KivaLoan {
//                                    // keep track of the loans that already exist
//                                    existingPersistedLoans.append(matchedLoan)
//                                }
//                            }
//                        } else {
//                            newLoans.append(loan)  // doesn't get here
//                        }
//                    } catch let error1 as NSError {
//                        print("Error in fetchLoanByID(): \(error1)")
//                        results = nil
//                    }
//                }
//                
//                // delete the loan whether it exists on disk or not
//                //self.sharedContext.deleteObject(loan)
//                for existingLoan in existingPersistedLoans {
//                    print("deleting existing loan: \(existingLoan.name!) \(existingLoan.country!)")
//                    self.sharedContext.deleteObject(existingLoan)
//                }
//                for newLoan in newLoans {
//                    print("deleting new loan: \(newLoan.name!) \(newLoan.country!)")
//                    self.sharedContext.deleteObject(newLoan)
//                    //todo CoreDataStackManager.sharedInstance().scratchContext
//                }
//                
//                // commit the deletes to the core data sqlite data store on disk
//                CoreDataStackManager.sharedInstance().saveContext()
//
//                // Add back in the existing persisted loans
//                for loan in existingPersistedLoans {
//                    _ = KivaLoan(fromLoan: loan, context: self.sharedContext)
//                }
//                
//                // add the selected country loan
//                if let selectedLoan = selectedLoan {
//                    _ = KivaLoan(fromLoan: selectedLoan, context: self.sharedContext)
//                }
//                
//                // save all loans to disk
//                CoreDataStackManager.sharedInstance().saveContext()
//            }
//        }
//    }
}
