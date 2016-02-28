//
//  LoansTableViewCell.swift
//  Lendivine
//
//  Created by john bateman on 11/12/15.
//  Copyright © 2015 John Bateman. All rights reserved.
//
// This custom table view cell is used in the LoansTableViewController to display summary information about a loan. The cell contains an AddToCart button. When selected the loan associated with the cell must be added to the cart. That is handled in this class.

import UIKit
import CoreData

class LoansTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sectorLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel! // loan amount
    @IBOutlet weak var loanImageView: UIImageView!
    @IBOutlet weak var countryLabel: UILabel!
    
    /* The main core data managed object context. This context will be persisted. */
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }()
    
    @IBAction func onAddToCartButtonTap(sender: UIButton) {
        
        // Find the cell starting from the button.
        let button = sender 
        let contentView = button.superview!
        let cell = contentView.superview as! LoansTableViewCell
        
        // Find the tableView by walking the view hierarchy until a UITableView class is encountered.
        var view = cell.superview
        while ( (view != nil) && (view?.isKindOfClass(UITableView) == false) ) {
            view = view!.superview
        }
        let tableView: UITableView = view as! UITableView
        
        // Get the indexPath associated with this table cell
        let indexPath = tableView.indexPathForCell(cell)

        // Alternatively use the version specific code:
        //let tableView = cell.superview as! UITableView
        
        // Place the loan in the cart.
        let tableViewController = tableView.dataSource as! LoansTableViewController
        let loan = tableViewController.loans[indexPath!.row]
        let amount = 25  // TODO: set default donation amount to user preference.
        let persistedLoan = KivaLoan(fromLoan: loan, context: self.sharedContext)
        let cart = KivaCart.sharedInstance
        cart.KivaAddItemToCart(persistedLoan, loanID: persistedLoan.id, donationAmount: amount, context: self.sharedContext)
        
//todo - cleanup        tableViewController.kivaAPI!.KivaAddItemToCart(persistedLoan, loanID: persistedLoan.id, donationAmount: amount, context: self.sharedContext)
//        tableViewController.kivaAPI!.KivaAddItemToCart(loan, loanID: loan.id, donationAmount: amount, context: sharedContext /*self.sharedContext*/)
        
        // Persist the KivaCartItem object we added to the Core Data shared context
        dispatch_async(dispatch_get_main_queue()) {
            CoreDataStackManager.sharedInstance().saveContext()
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
