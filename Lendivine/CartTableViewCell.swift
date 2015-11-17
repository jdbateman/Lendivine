//
//  CartTableViewCell.swift
//  Lendivine
//
//  Created by john bateman on 11/16/15.
//  Copyright © 2015 John Bateman. All rights reserved.
//
//  This custom table view cell is used in the CartTableViewController to display summary information about a loan. The RemoveFromCart button is a subview of the cell. When it is selected the data associated with the cell must be deleted. That is handled here.

import UIKit

class CartTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sectorLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel! // loan amount
    @IBOutlet weak var loanImageView: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBAction func onRemoveFromCartButtonTap(sender: UIButton) {
        
        // Find the cell starting from the button.
        let button = sender
        let contentView = button.superview!
        let cell = contentView.superview as! CartTableViewCell
        
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
        
//        // Place the loan in the cart.
//        let tableViewController = tableView.dataSource as! LoansTableViewController
//        let loan = tableViewController.loans[indexPath!.row]
//        let amount = ( ( Int(arc4random() % 100) / 5 ) * 5) + 5  // TODO: calculate default amount: ($25 or user set preference)
//        tableViewController.kivaAPI!.KivaAddItemToCart(loan, loanID: loan.id, amount: amount)
        
        // Remove the loan from the cart.
        let cartViewController = tableView.dataSource as! CartTableViewController
        let index = indexPath!.row
        cartViewController.cart.removeItemByIndex(index)
        print("cart = \(cartViewController.cart.items.count) [onRemoveFromCartButtonTap]")
        
        //cartViewController.cart.items.removeAtIndex(indexPath!.row)
        
        // refresh the table view
        dispatch_async(dispatch_get_main_queue()) {
            tableView.reloadData()
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
