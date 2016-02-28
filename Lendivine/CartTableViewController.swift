//
//  CartTableViewController.swift
//  Lendivine
//
//  Created by john bateman on 11/15/15.
//  Copyright © 2015 John Bateman. All rights reserved.
//
// This table view controller displays a set of loans the user has added to the cart.
// TODO - support selecting a loan to display detailed information on the loan

import UIKit

class CartTableViewController: UITableViewController {

    var cart:KivaCart? // = KivaCart.sharedInstance
    var kivaAPI: KivaAPI?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.kivaAPI = KivaAPI.sharedInstance
        
        let checkoutButton = UIBarButtonItem(image: UIImage(named: "Checkout-50"), style: .Plain, target: self, action: "onCheckoutButtonTapped")
        self.navigationItem.rightBarButtonItem = checkoutButton
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        cart = KivaCart.sharedInstance
        
        print("cart = \(cart!.items.count) [viewDidLoad]")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
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
            
            // make delete button corners rounded
            cell.changeDonationButton.layer.cornerRadius = 7
            cell.changeDonationButton.layer.masksToBounds = true

            let cartItem = self.cart!.items[row]
            
            if let loan = cartItem.kivaloan as KivaLoan? {
            
                cell.nameLabel.text = loan.name
                
                cell.sectorLabel.text = loan.sector
                
                var amountString = "$"
                if let loanAmount = loan.loanAmount {
                    amountString.appendContentsOf(loanAmount.stringValue)
                } else {
                    amountString.appendContentsOf("0")
                }
                cell.amountLabel.text = amountString
                
                cell.countryLabel.text = loan.country
                
                // donation amount
                var donationAmount = "$"
                if let itemDonationAmount = cartItem.donationAmount {
                    donationAmount.appendContentsOf(itemDonationAmount.stringValue)
                }
                // Set button image to donation amount
        //        let donationImage: UIImage = textToImage("$25", inImage: UIImage(named:"EmptyCart-50")!, atPoint: CGPointMake(14, 8))
                let donationImage: UIImage = ViewUtility.createImageFromText(donationAmount, backingImage: UIImage(named:"EmptyCart-50")!, atPoint: CGPointMake(CGFloat(14), 4))
                cell.changeDonationButton.imageView!.image = donationImage
                
                // Set main image placeholder image
                cell.loanImageView.image = UIImage(named: "Add Shopping Cart-50") // TODO: update placeholder image in .xcassets
                
                // getKivaImage can retrieve the image from the server in a background thread. Make sure to update UI from main thread.
                loan.getImage() {success, error, image in
                    if success {
                        dispatch_async(dispatch_get_main_queue()) {
                            cell.loanImageView!.image = image
                        }
                    } else  {
                        print("error retrieving image: \(error)")
                    }
                }
                
                print("cart = \(self.cart!.items.count) [configureCell]")
            }
        }
    }
    
    // Conditional editing of the table view. (Return true to allow edit of the item, false if item is not editable.)
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
/*
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            // Remove the data from collection and update the tableview.
            cart.removeItemByIndex(indexPath.row)
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
        }
    }
*/
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


    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // The user selected the checkout button.
    func onCheckoutButtonTapped() {
        print("call KivaAPI.checkout")
        
        let loans = cart!.getLoans()
        print("cart count before stripping out non-fundraising loans = \(cart!.items.count)")
        
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
                
// todo: remove debugging code:
//                var loanCount = 0
//                if let loans = loans {
//                    loanCount = loans.count
//                }
//                print("cart count after stripping out non-fundraising loans = \(self.cart!.items.count). loans count should be the same: \(loanCount)")
            } else {
                // Even though an error occured just continue on to the cart on Kiva.org and they will handle any invalid loans in the cart.
                print("Non-fatal error confirming fundraising status of loans.")
                self.displayKivaWebCartInBrowser()
            }
        }
    }
    
    /*! Clear local cart of all items and present the Kiva web cart in the browser. */
    func displayKivaWebCartInBrowser() {
        
        // Remove all items from local cart view.
        cart?.empty()
        
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
//        var loanIDs: NSMutableArray // = [NSNumber]()
//        for loan in loans! {
//            if let id = loan.id {
//                loanIDs.addObject(id) // loanIDs.append(id)
//            }
//        }
        
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
        //        var storyboard = UIStoryboard (name: "Main", bundle: nil)
        //        var controller = storyboard.instantiateViewControllerWithIdentifier("WebSearchStoryboardID") as! WebSearchViewController
        //controller.initialURL = url
        if let kivaAPI = self.kivaAPI {
            controller.request = kivaAPI.getKivaCartRequest()  // KivaCheckout()
        }
        //controller.webViewDelegate = self
        
        // push the webView controller onto the stack modally
//        self.presentViewController(controller, animated: true, completion: nil);
        
        // add the view controller to the navigation controller stack
        self.navigationController?.pushViewController(controller, animated: true)
    }

}
