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
    @IBOutlet weak var loanImageView: UIImageView!
    @IBOutlet weak var changeDonationButton: UIButton!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var flagImageView: UIImageView!

    // User selected the change donation button in the cell. Present donation amount options in an action sheet.
    @IBAction func onChangeDonationButton(_ sender: AnyObject) {
        presentDonationAmounts(sender)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // Display a list of user selectable donation amounts in an action sheet.
    func presentDonationAmounts(_ sender: AnyObject) {
        let alertController = UIAlertController(title: nil, message: "Select an amount to lend.", preferredStyle: .actionSheet)
        
        let Action25 = UIAlertAction(title: "$25", style: .default) { (action) in
            // update donation amount on button text
            self.changeDonationButton.imageView!.image = self.imageForButton(25)
            
            // update donation amount in cart item
            self.updateCartItem(sender as! UIView, donationAmount: 25)
        }
        alertController.addAction(Action25)
        
        let Action50 = UIAlertAction(title: "$50", style: .default) { (action) in
            // update donation amount on button text
            self.changeDonationButton.imageView!.image = self.imageForButton(50)
            
            // update donation amount in cart item
            self.updateCartItem(sender as! UIView, donationAmount: 50)
        }
        alertController.addAction(Action50)
        
        let Action100 = UIAlertAction(title: "$100", style: .default) { (action) in
            // update donation amount on button text
            self.changeDonationButton.imageView!.image = self.imageForButton(100)
            
            // update donation amount in cart item
            self.updateCartItem(sender as! UIView, donationAmount: 100)
        }
        alertController.addAction(Action100)
        
        // present the controller
        let controller = parentViewController
        if let controller = controller {
            controller.present(alertController, animated: true) {
                // ...
            }
        }
    }
    
    // Update the donation amount of the cart item associated with this cell.
    func updateCartItem(_ subView: UIView, donationAmount: NSNumber) {
        
        let indexPath = getIndexPathForCellContainingSubview(subView)
        if let indexPath = indexPath {
            let index = indexPath.row
            let cartViewController = getTableViewControllerForCellContainingSubview(subView)
        
            let cartItem = cartViewController.cart!.items[index]
            cartItem.donationAmount = donationAmount
            
            // save the context to persist the updated cart property to core data
            CoreDataContext.sharedInstance().saveCartContext()
        }
    }
    
    // Set button image to donation amount
    func imageForButton(_ donationAmount: NSNumber) -> UIImage {
        
        var xCoord = 15
        switch donationAmount.int32Value {
        case 0...9:
            xCoord = 14
        case 10...99:
            xCoord = 18
        case 100...999:
            xCoord = 10
        default:
            xCoord = 15
        }
        
        let buttonText: String = "$" + donationAmount.stringValue
        
        let donationImage: UIImage = ViewUtility.createImageFromText(buttonText as NSString, backingImage: UIImage(named:cartDonationImageName)!, atPoint: CGPoint(x: CGFloat(xCoord), y: 4))
        return donationImage
    }
    
    // Return an index path for the cell containing the specified subview of the cell.
    func getIndexPathForCellContainingSubview(_ subview: UIView) -> IndexPath? {
        
        // Find the cell starting from the subview.
        let contentView = subview.superview!
        let cell = contentView.superview as! CartTableViewCell

        // Find the tableView by walking the view hierarchy until a UITableView class is encountered.
        var view = cell.superview
        while ( (view != nil) && (view?.isKind(of: UITableView.self) == false) ) {
            view = view!.superview
        }
        let tableView: UITableView = view as! UITableView
        
        // Get the indexPath associated with this table cell
        let indexPath = tableView.indexPath(for: cell)
        
        return indexPath
    }
    
    // Return the CartTableViewController for the cell containing the specified subview of the cell.
    func getTableViewControllerForCellContainingSubview(_ subview: UIView) -> CartTableViewController {
        
        // Find the cell starting from the subview.
        let contentView = subview.superview!
        let cell = contentView.superview as! CartTableViewCell
        
        // Find the tableView by walking the view hierarchy until a UITableView class is encountered.
        var view = cell.superview
        while ( (view != nil) && (view?.isKind(of: UITableView.self) == false) ) {
            view = view!.superview
        }
        let tableView: UITableView = view as! UITableView
        
        let cartViewController = tableView.dataSource as! CartTableViewController
        
        return cartViewController
    }
    
    // Remove cell containing the selected button from the cart table view controller, and remove the associated loan from the cart.
    func removeFromCart(_ sender: UIButton) {
        // Find the cell starting from the button.
        let button = sender
        let contentView = button.superview!
        let cell = contentView.superview as! CartTableViewCell
        
        // Find the tableView by walking the view hierarchy until a UITableView class is encountered.
        var view = cell.superview
        while ( (view != nil) && (view?.isKind(of: UITableView.self) == false) ) {
            view = view!.superview
        }
        let tableView: UITableView = view as! UITableView
        
        // Get the indexPath associated with this table cell
        let indexPath = tableView.indexPath(for: cell)
        
        // Remove the loan from the cart.
        let cartViewController = tableView.dataSource as! CartTableViewController
        let index = indexPath!.row
        cartViewController.cart?.removeItemByIndex(index)
        
        // refresh the table view
        DispatchQueue.main.async {
            tableView.reloadData()
        }
    }
}

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if parentResponder is UIViewController {
                return parentResponder as! UIViewController!
            }
        }
        return nil
    }
}
