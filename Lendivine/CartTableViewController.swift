//
//  CartTableViewController.swift
//  Lendivine
//
//  Created by john bateman on 11/15/15.
//  Copyright © 2015 John Bateman. All rights reserved.
//
// This table view controller displays a set of loans the user has added to the cart.

import UIKit
import CoreData

let cartDonationImageName:String = String("EmptyCart-50")

class CartTableViewController: UITableViewController {

    var cart:KivaCart? // = KivaCart.sharedInstance
    var kivaAPI: KivaAPI?
    
    /* The main core data managed object context. This context will be persisted. */
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.kivaAPI = KivaAPI.sharedInstance
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        cart = KivaCart.sharedInstance
        
        configureBarButtonItems()
        
        navigationItem.title = "Cart"
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        updateCart()
    }
    
    func updateCart() {
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cart!.items.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("CartTableCellID", forIndexPath: indexPath) as! CartTableViewCell

        // Configure the cell...
        configureCell(cell, row: indexPath.row)
        
        return cell
    }
    
    func configureCell(cell: CartTableViewCell, row: Int) {
        
        dispatch_async(dispatch_get_main_queue()) {
            
            // make donation button corners rounded
            cell.changeDonationButton.layer.cornerRadius = 7
            cell.changeDonationButton.layer.masksToBounds = true
            
            let cartItem = self.cart!.items[row]
            
                cell.nameLabel.text = cartItem.name
            
                if let country = cartItem.country {
                    // flag
                    if let uiImage = UIImage(named: country) {
                        cell.flagImageView.image = uiImage
                    } else {
                        cell.flagImageView.image = UIImage(named: "United Nations")
                    }
                }
            
                cell.countryLabel.text = cartItem.country
                
                // donation amount
                var donationAmount = "$"
                if let itemDonationAmount = cartItem.donationAmount {
                    donationAmount.appendContentsOf(itemDonationAmount.stringValue)
                }
                // Set button image to donation amount
                let donationImage: UIImage = ViewUtility.createImageFromText(donationAmount, backingImage: UIImage(named:cartDonationImageName)!, atPoint: CGPointMake(CGFloat(14), 4))
                cell.changeDonationButton.imageView!.image = donationImage
                
                // Set main image placeholder image
                cell.loanImageView.image = UIImage(named: "Add Shopping Cart-50") // TODO: update placeholder image in .xcassets
                
                // getKivaImage can retrieve the image from the server in a background thread. Make sure to update UI from main thread.
                cartItem.getImage() {success, error, image in
                    if success {
                        dispatch_async(dispatch_get_main_queue()) {
                            cell.loanImageView!.image = image
                            
                            // draw border around image
                            cell.loanImageView!.layer.borderColor = UIColor.blueColor().CGColor;
                            cell.loanImageView!.layer.borderWidth = 2.5
                            cell.loanImageView!.layer.cornerRadius = 3.0
                            cell.loanImageView!.clipsToBounds = true
                        }
                    } else  {
                        print("error retrieving image: \(error)")
                    }
                }
                
                print("cart = \(self.cart!.items.count) [configureCell]")
        }
    }
    
    // Conditional editing of the table view. (Return true to allow edit of the item, false if item is not editable.)
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            
            // remove the item from the KivaCart object
            cart!.removeItemByIndex(indexPath.row)
            
            // remove the item from the table view
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    /*! Setup the nav bar button items. */
    func configureBarButtonItems() {
        
        // left bar button items
        let trashButton = UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: "onTrashButtonTap")
        navigationItem.setLeftBarButtonItem(trashButton, animated: true)
        
        // right bar button items
        let checkoutButton = UIBarButtonItem(image: UIImage(named: "Checkout-50"), style: .Plain, target: self, action: "onCheckoutButtonTapped")
        //self.navigationItem.rightBarButtonItem = checkoutButton
        let mapButton = UIBarButtonItem(image: UIImage(named: "earth-america-7"), style: .Plain, target: self, action: "onMapButton")
        navigationItem.setRightBarButtonItems([mapButton, checkoutButton], animated: true)
    }

    
    // MARK: Actions
    
    func onMapButton() {
        presentMapController()
    }

    /*! Remove all items from the cart and referesh the view. */
    func onTrashButtonTap() {

        // Confirm the delete-all operation with the user via an alert controller.
        let alertController = UIAlertController(title: "Clear Cart", message: "Select OK to remove all loans from the cart." , preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            if let cart = self.cart {
                cart.empty()
            }
            self.updateCart()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
            UIAlertAction in
            // do nothing
        }

        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // The user selected the checkout button.
    @IBAction func onCheckoutButtonInViewTapped(sender: AnyObject) {
        onCheckoutButtonTapped()
    }
    
    // The user selected the checkout bar button item.
    func onCheckoutButtonTapped() {
        print("call KivaAPI.checkout")
        
        let activityIndicator = DVNActivityIndicator()
        activityIndicator.startActivityIndicator(tableView)
        
        let loans = cart!.getLoans2()
        print("cart count before stripping out non-fundraising loans = \(self.cart!.items.count)")
        print("loans: %@", loans)
        self.getCurrentFundraisingStatus(loans) {
            success, error, fundraising, notFundraising in
            if success {
                // remove notFundraising loans from the cart
                if let notFundraising = notFundraising {
                    if notFundraising.count > 0 {
                        if var loans = loans {
                            for notFRLoan in notFundraising {
                                if let index = loans.indexOf(notFRLoan) {
                                    loans.removeAtIndex(index)
                                }
                                
                                //  UIAlertController
                                var userMessage = "The following loans are no longer raising funds and have been removed from the cart:\n\n"
                                var allRemovedLoansString = ""
                                for nfLoan in notFundraising {
                                    if let country = nfLoan.country, name = nfLoan.name, sector = nfLoan.sector {
                                        let removedLoanString = String(format: "%@, %@, %@\n", name, sector, country)
                                        allRemovedLoansString.appendContentsOf(removedLoanString)
                                    }
                                }
                                userMessage.appendContentsOf(allRemovedLoansString)
                                let alertController = UIAlertController(title: "Cart Modified", message: userMessage, preferredStyle: .Alert)
                                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                                    UIAlertAction in
                                    print("OK Tapped")
                                    self.displayKivaWebCartInBrowser()
                                }
                                alertController.addAction(okAction)
                                self.presentViewController(alertController, animated: true, completion: nil)
                            }
                        }
                    } else {
                        // There are no loans to remove from the cart
                        self.displayKivaWebCartInBrowser()
                    }
                }
            } else {
                // Even though an error occured just continue on to the cart on Kiva.org and they will handle any invalid loans in the cart.
                print("Non-fatal error confirming fundraising status of loans.")
                self.displayKivaWebCartInBrowser()
            }
            activityIndicator.stopActivityIndicator()
        }
    }
    
    /*! Clear local cart of all items and present the Kiva web cart in the browser. */
    func displayKivaWebCartInBrowser() {
        
        // Display web cart.
        self.showEmbeddedBrowser()
    }
    
    /*! 
        @brief Get loans from Kiva.org and confirm the status of each is "fundraising".
        @return List of loans with fundraising status, and list of loans no longer with fundraining status.
    */
    func getCurrentFundraisingStatus(loans: [KivaLoan]?, completionHandler: (success: Bool, error: NSError?, fundraising: [KivaLoan]?, notFundraising: [KivaLoan]?) -> Void) {
        
        // validate loans not nil or empty
        if loans == nil || loans!.count == 0 {
            let error = VTError(errorString: "Kiva loan not specified.", errorCode: VTError.ErrorCodes.KIVA_API_NO_LOANS)
            completionHandler(success: true, error: error.error, fundraising: nil, notFundraising: nil)
        }
        
        var fundraising = [KivaLoan]()
        var notFundraising = [KivaLoan]()
        
        // accumulate loan IDs
        var loanIDs = [NSNumber?]()
        for loan in loans! {
            if let id = loan.id {
                loanIDs.append(id)
            }
        }
        
        // Find loans on Kiva.org
        KivaAPI.sharedInstance.kivaGetLoans(loanIDs) {
            success, error, loans in
            if success {
                if let loans = loans {
                    for loan in loans {
                        if loan.status == KivaLoan.Status.fundraising.rawValue {
                            fundraising.append(loan)
                        } else {
                            notFundraising.append(loan)
                        }
                    }
                    completionHandler(success: true, error: nil, fundraising: fundraising, notFundraising: notFundraising)
                }
            } else {
                let error = VTError(errorString: "Kiva loan not found.", errorCode: VTError.ErrorCodes.KIVA_API_LOAN_NOT_FOUND)
                completionHandler(success: true, error: error.error, fundraising: nil, notFundraising: nil)
            }
        }
    }
    
    /*! 
        @brief Check the Kiva.org service to verify that the specified loan is still available to be funded.
        @param (in) loan - the loan whose status the caller wishes to verify
        @param (out) completionHandler:  - callback is invoked when function completes and has a result to return.
            (out) result - true if loan status was able to be confirmed, else false if an error occurred.
            (out) error - NSError describing the error, else nil if no error occurred. If an error occured the result is not valid.
    */
    func confirmLoanIsAvailable(loan: KivaLoan?, completionHandler: (result: Bool, error: NSError?) -> Void) {
        
        if let loan = loan {
            loan.confirmLoanStatus(KivaLoan.Status.fundraising) {
                result, error in
                if error == nil {
                    // successfully determined status of loan
                    completionHandler(result: result, error: nil)
                } else {
                    // error determining the status of the loan
                    completionHandler(result: false, error: error)
                }
            }
        }
    }
    
    /* Display url in an embeded webkit browser. */
    func showEmbeddedBrowser() {
        
        let controller = KivaCartViewController()
        if let kivaAPI = self.kivaAPI {
            controller.request = kivaAPI.getKivaCartRequest()  // KivaCheckout()
        }
        
        // add the view controller to the navigation controller stack
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: UITableViewDelegate Accessory Views
    
    /*! Disclosure indicator tapped. Present the loan detail view controller for the selected loan. */
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        
        let cartItem = self.cart!.items[indexPath.row]
        
        if let loanID = cartItem.loanID {

            if let loan:KivaLoan = KivaLoan.createKivaLoanFromLoanID(loanID, context: CoreDataStackManager.sharedInstance().scratchContext) {
                self.presentLoanDetailViewController(loan)
            }
        }
    }
    
    
    // MARK: Navigation
    
    /* Modally present the LoanDetail view controller. */
    func presentLoanDetailViewController(loan: KivaLoan?) {
        guard let loan = loan else {
            return
        }
        let storyboard = UIStoryboard (name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("LoanDetailStoryboardID") as! LoanDetailViewController
        controller.loan = loan
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowCartDetail" {
            
            if let indexPath = self.tableView.indexPathForSelectedRow {
                
                let controller = segue.destinationViewController as! LoanDetailViewController
                
                let cartItem = self.cart!.items[indexPath.row]
                
                if let loanID = cartItem.loanID {
                    
                    if let loan:KivaLoan = KivaLoan.createKivaLoanFromLoanID(loanID, context: CoreDataStackManager.sharedInstance().scratchContext) {
                        controller.loan = loan
                    }
                }
            }
            
        } else if segue.identifier == "CartToMapSegueId" {
            
            //navigationItem.title = "Cart"
            
            let controller = segue.destinationViewController as! MapViewController
            
            controller.sourceViewController = self
            controller.navigationItem.title = "Cart"
            
            // get list of loans displayed in this view controller
            if let loans = self.cart!.getLoans2() {
                controller.loans = loans
            }
        }
    }
    
    /* Modally present the MapViewController on the main thread. */
    func presentMapController() {
        dispatch_async(dispatch_get_main_queue()) {
            self.performSegueWithIdentifier("CartToMapSegueId", sender: self)
        }
    }
}
