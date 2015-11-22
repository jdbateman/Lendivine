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
    @IBOutlet weak var changeDonationButton: UIButton!
    @IBOutlet weak var countryLabel: UILabel!
    
//    @IBAction func onRemoveFromCartButtonTap(sender: UIButton) {
//            removeFromCart(sender)
//    }

    // User selected the change donation button in the cell. Present donation amount options in an action sheet.
    @IBAction func onChangeDonationButton(sender: AnyObject) {
        presentDonationAmounts(sender)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // TODO - present donation amounts in a picker instead.
    
    // Display a list of user selectable donation amounts in an action sheet.
    func presentDonationAmounts(sender: AnyObject) {
        let alertController = UIAlertController(title: nil, message: "Select an amount to lend.", preferredStyle: .ActionSheet)
        
        let Action25 = UIAlertAction(title: "$25", style: .Default) { (action) in
            // update donation amount on button text
            self.changeDonationButton.imageView!.image = self.imageForButton(25)
            
            // update donation amount in cart item
            self.updateCartItem(sender as! UIView, donationAmount: 25)
        }
        alertController.addAction(Action25)
        
        let Action50 = UIAlertAction(title: "$50", style: .Default) { (action) in
            // update donation amount on button text
            self.changeDonationButton.imageView!.image = self.imageForButton(50)
            
            // update donation amount in cart item
            self.updateCartItem(sender as! UIView, donationAmount: 50)
        }
        alertController.addAction(Action50)
        
        let Action100 = UIAlertAction(title: "$100", style: .Default) { (action) in
            // update donation amount on button text
            self.changeDonationButton.imageView!.image = self.imageForButton(100)
            
            // update donation amount in cart item
            self.updateCartItem(sender as! UIView, donationAmount: 100)
        }
        alertController.addAction(Action100)
        
        // present the controller
        let controller = parentViewController
        if let controller = controller {
            controller.presentViewController(alertController, animated: true) {
                // ...
            }
        }
        
//        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // Update the donation amount of the cart item associated with this cell.
    func updateCartItem(subView: UIView, donationAmount: NSNumber) {
        let indexPath = getIndexPathForCellContainingSubview(subView)
        if let indexPath = indexPath {
            let index = indexPath.row
            let cartViewController = getTableViewControllerForCellContainingSubview(subView)
        
            let cartItem = cartViewController.cart.items[index]
            let donationAmountOriginal = cartItem.donationAmount
            cartItem.donationAmount = donationAmount
            print("cartItem donation amount changed from \(donationAmountOriginal) to \(cartItem.donationAmount)")
        }
    }
    
    // Set button image to donation amount
    func imageForButton(donationAmount: NSNumber) -> UIImage {
        
        var xCoord = 14
        switch donationAmount.intValue {
        case 0...9:
            xCoord = 14
        case 10...99:
            xCoord = 14
        case 100...999:
            xCoord = 10
        default:
            xCoord = 14
        }
        
        let buttonText: String = "$" + donationAmount.stringValue
        
//        let x = donationAmount.characters.count
//        
//        if
//        
//        let xCoord = CGFloat(x)
        //let donationImage: UIImage = textToImage(buttonText, inImage: UIImage(named:"EmptyCart-50")!, atPoint: CGPointMake(CGFloat(xCoord), 7))
        let donationImage: UIImage = ViewUtility.createImageFromText(buttonText, backingImage: UIImage(named:"EmptyCart-50")!, atPoint: CGPointMake(CGFloat(xCoord), 4))
        return donationImage
    }
    
    // TODO - remove
//    func textToImage(drawText: NSString, inImage: UIImage, atPoint:CGPoint)->UIImage{
//        
//        // Setup the font specific variables
//        var textColor: UIColor = UIColor.whiteColor()
//        var textFont: UIFont = UIFont(name: "Helvetica Bold", size: 14)!
//        
//        //Setup the image context using the passed image.
//        UIGraphicsBeginImageContext(inImage.size)
//        
//        //Setups up the font attributes that will be later used to dictate how the text should be drawn
//        let textFontAttributes = [
//            NSFontAttributeName: textFont,
//            NSForegroundColorAttributeName: textColor,
//        ]
//        
//        //Put the image into a rectangle as large as the original image.
//        inImage.drawInRect(CGRectMake(0, 0, inImage.size.width, inImage.size.height))
//        
//        // Creating a point within the space that is as bit as the image.
//        var rect: CGRect = CGRectMake(atPoint.x, atPoint.y, inImage.size.width, inImage.size.height)
//        
//        //Now Draw the text into an image.
//        drawText.drawInRect(rect, withAttributes: textFontAttributes)
//        
//        // Create a new image out of the images we have created
//        var newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
//        
//        // End the context now that we have the image we need
//        UIGraphicsEndImageContext()
//        
//        //And pass it back up to the caller.
//        return newImage
//        
//    }
    
    // Return an index path for the cell containing the specified subview of the cell.
    func getIndexPathForCellContainingSubview(subview: UIView) -> NSIndexPath? {
        
        // Find the cell starting from the subview.
        let contentView = subview.superview!
        let cell = contentView.superview as! CartTableViewCell

        // Find the tableView by walking the view hierarchy until a UITableView class is encountered.
        var view = cell.superview
        while ( (view != nil) && (view?.isKindOfClass(UITableView) == false) ) {
            view = view!.superview
        }
        let tableView: UITableView = view as! UITableView
        
        // Get the indexPath associated with this table cell
        let indexPath = tableView.indexPathForCell(cell)
        
        return indexPath
    }
    
    // Return the CartTableViewController for the cell containing the specified subview of the cell.
    func getTableViewControllerForCellContainingSubview(subview: UIView) -> CartTableViewController {
        
        // Find the cell starting from the subview.
        let contentView = subview.superview!
        let cell = contentView.superview as! CartTableViewCell
        
        // Find the tableView by walking the view hierarchy until a UITableView class is encountered.
        var view = cell.superview
        while ( (view != nil) && (view?.isKindOfClass(UITableView) == false) ) {
            view = view!.superview
        }
        let tableView: UITableView = view as! UITableView
        
        let cartViewController = tableView.dataSource as! CartTableViewController
        
        return cartViewController
    }
    
    // Remove cell containing the selected button from the cart table view controller, and remove the associated loan from the cart.
    func removeFromCart(sender: UIButton) {
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
        //        tableViewController.kivaAPI!.KivaAddItemToCart(loan, loanID: loan.id, donationAmount: amount)
        
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
    
//    func getViewControllerFromCellSubview(subview: UIView?) -> CartTableViewController? {
//        
//        // Find the tableView by walking the view hierarchy until a UITableView class is encountered.
//        var view = subview
//        while ( (view != nil) && (view?.isKindOfClass(UITableView) == false) ) {
//            view = view!.superview
//        }
//        let tableView: UITableView = view as! UITableView
//        let cartViewController: CartTableViewController? = tableView.dataSource // as! CartTableViewController?
//        return cartViewController
//    }

}

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.nextResponder()
            if parentResponder is UIViewController {
                return parentResponder as! UIViewController!
            }
        }
        return nil
    }
}
