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
    
    /* The main core data managed object context. This context will be persisted. */
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }()
    
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
        if cart.KivaAddItemToCart(loan, /*loanID: loan.id,*/ donationAmount: amount, context: self.sharedContext) {

            // Persist the KivaCartItem object we added to the Core Data shared context
            dispatch_async(dispatch_get_main_queue()) {
                print("saveContext: CountryLoanTableViewCell.onAddCountryLoanToCartButtonTap()")
                CoreDataStackManager.sharedInstance().saveContext()
            }
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

}
