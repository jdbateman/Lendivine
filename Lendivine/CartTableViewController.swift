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

    var noDataLabel: UILabel?
    
    var cart:KivaCart?
    var kivaAPI: KivaAPI?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.kivaAPI = KivaAPI.sharedInstance
        
        cart = KivaCart.sharedInstance
        
        configureBarButtonItems()
        
        navigationItem.title = "Cart"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateCart()
    }
    
    func updateCart() {
        if let cart = cart {
            cart.update() {
                self.tableView.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        if cart!.items.count > 0 {
        
            noDataLabel?.text = ""
            noDataLabel?.isHidden = true
            
            return 1
            
        } else {
            
            noDataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            
            if let noDataLabel = noDataLabel {
                noDataLabel.isHidden = false
                noDataLabel.text = "The cart is empty."
                noDataLabel.textColor = UIColor.darkGray
                noDataLabel.textAlignment = .center
                tableView.backgroundView = noDataLabel
                tableView.separatorStyle = .none
            }
            
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cart!.items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CartTableCellID", for: indexPath) as! CartTableViewCell

        // Configure the cell...
        configureCell(cell, row: indexPath.row)
        
        return cell
    }
    
    func configureCell(_ cell: CartTableViewCell, row: Int) {
        
        DispatchQueue.main.async {
            
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
                donationAmount.append(itemDonationAmount.stringValue)
            }
            // Set button image to donation amount
            let donationImage: UIImage = ViewUtility.createImageFromText(donationAmount as NSString, backingImage: UIImage(named:cartDonationImageName)!, atPoint: CGPoint(x: CGFloat(14), y: 4))
            cell.changeDonationButton.imageView!.image = donationImage
            
            // Set main image placeholder image
            cell.loanImageView.image = UIImage(named: "Download-50")
            
            // getImage can retrieve the image from the server in a background thread. Make sure to update UI from main thread.
            
            if let itemImageId = cartItem.imageID {
                let itemImage = KivaImage(imageId: itemImageId)
                itemImage.getImage(200, height:200, square:true) {
                    success, error, image in
                    if success {
                        DispatchQueue.main.async {
                            cell.loanImageView!.image = image
                            
                            // draw border around image
                            cell.loanImageView!.layer.borderColor = UIColor.blue.cgColor;
                            cell.loanImageView!.layer.borderWidth = 2.5
                            cell.loanImageView!.layer.cornerRadius = 3.0
                            cell.loanImageView!.clipsToBounds = true
                        }
                    } else  {
                        print("error retrieving image: \(error)")
                    }
                }
            }
         }
    }
    
    // Conditional editing of the table view. (Return true to allow edit of the item, false if item is not editable.)
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            
            // remove the item from the KivaCart object
            cart!.removeItemByIndex(indexPath.row)
            
            KivaCart.updateCartBadge(self)
            
            // remove the item from the table view
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    /*! Setup the nav bar button items. */
    func configureBarButtonItems() {
        
        // left bar button items
        let trashButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(CartTableViewController.onTrashButtonTap))
        navigationItem.setLeftBarButton(trashButton, animated: true)
        
        // right bar button items
        let checkoutButton = UIBarButtonItem(image: UIImage(named: "Checkout-50"), style: .plain, target: self, action: #selector(CartTableViewController.onCheckoutButtonTapped))
        //self.navigationItem.rightBarButtonItem = checkoutButton
        let mapButton = UIBarButtonItem(image: UIImage(named: "earth-america-7"), style: .plain, target: self, action: #selector(CartTableViewController.onMapButton))
        navigationItem.setRightBarButtonItems([mapButton, checkoutButton], animated: true)
    }

    
    // MARK: Actions
    
    func onMapButton() {
        presentMapController()
    }

    /*! Remove all items from the cart and referesh the view. */
    func onTrashButtonTap() {

        // Confirm the delete-all operation with the user via an alert controller.
        let alertController = UIAlertController(title: "Clear Cart", message: "Select OK to remove all loans from the cart." , preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
            if let cart = self.cart {
                cart.empty()
                KivaCart.updateCartBadge(self)
            }
            self.updateCart()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
            // do nothing
        }

        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // The user selected the checkout button.
    @IBAction func onCheckoutButtonInViewTapped(_ sender: AnyObject) {
        onCheckoutButtonTapped()
    }
    
    // The user selected the checkout bar button item.
    func onCheckoutButtonTapped() {
        
        let activityIndicator = DVNActivityIndicator()
        activityIndicator.startActivityIndicator(tableView)
        
        let loans = cart!.getLoans2()

        self.getCurrentFundraisingStatus(loans) {
            success, error, fundraising, notFundraising in
            if success {
                // remove notFundraising loans from the cart
                if let notFundraising = notFundraising {
                    if notFundraising.count > 0 {
                        if var loans = loans {
                            for notFRLoan in notFundraising {
                                if let index = loans.index(of: notFRLoan) {
                                    loans.remove(at: index)
                                }
                                
                                //  UIAlertController
                                var userMessage = "The following loans are no longer raising funds and have been removed from the cart:\n\n"
                                var allRemovedLoansString = ""
                                for nfLoan in notFundraising {
                                    if let country = nfLoan.country, let name = nfLoan.name, let sector = nfLoan.sector {
                                        let removedLoanString = String(format: "%@, %@, %@\n", name, sector, country)
                                        allRemovedLoansString.append(removedLoanString)
                                    }
                                }
                                userMessage.append(allRemovedLoansString)
                                let alertController = UIAlertController(title: "Cart Modified", message: userMessage, preferredStyle: .alert)
                                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                                    UIAlertAction in
                                    self.displayKivaWebCartInBrowser()
                                }
                                alertController.addAction(okAction)
                                self.present(alertController, animated: true, completion: nil)
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
    func getCurrentFundraisingStatus(_ loans: [KivaLoan]?, completionHandler: @escaping (_ success: Bool, _ error: NSError?, _ fundraising: [KivaLoan]?, _ notFundraising: [KivaLoan]?) -> Void) {
        
        // validate loans not nil or empty
        if loans == nil || loans!.count == 0 {
            let error = VTError(errorString: "Kiva loan not specified.", errorCode: VTError.ErrorCodes.kiva_API_NO_LOANS)
            completionHandler(true, error.error, nil, nil)
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
        
        // Find loans on Kiva.org. Create temporary loan objects in order to extract funraising status.
        KivaAPI.sharedInstance.kivaGetLoans(loanIDs, context: CoreDataContext.sharedInstance().cartScratchContext) {
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
                    completionHandler(true, nil, fundraising, notFundraising)
                }
            } else {
                if (error != nil) && ((error?.code)! == -1009) && (error?.localizedDescription.contains("offline"))! {
                    LDAlert(viewController: self).displayErrorAlertView("No Internet Connection", message: (error?.localizedDescription)!)
                }
                let error = VTError(errorString: "Kiva loan not found.", errorCode: VTError.ErrorCodes.kiva_API_LOAN_NOT_FOUND)
                completionHandler(true, error.error, nil, nil)
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
    func confirmLoanIsAvailable(_ loan: KivaLoan?, completionHandler: @escaping (_ result: Bool, _ error: NSError?) -> Void) {
        
        if let loan = loan {
            loan.confirmLoanStatus(KivaLoan.Status.fundraising, context: CoreDataContext.sharedInstance().cartContext) {
                result, error in
                if error == nil {
                    // successfully determined status of loan
                    completionHandler(result, nil)
                } else {
                    if (error != nil) && ((error?.code)! == -1009) && (error?.localizedDescription.contains("offline"))! {
                        LDAlert(viewController: self).displayErrorAlertView("No Internet Connection", message: (error?.localizedDescription)!)
                    }
                    // error determining the status of the loan
                    completionHandler(false, error)
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
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        let cartItem = self.cart!.items[indexPath.row]
        
            let loan:KivaLoan = KivaLoan(fromCartItem: cartItem, context: CoreDataContext.sharedInstance().cartContext)
            self.presentLoanDetailViewController(loan)
    }
    
    
    // MARK: Navigation
    
    /* Modally present the LoanDetail view controller. */
    func presentLoanDetailViewController(_ loan: KivaLoan?) {
        guard let loan = loan else {
            return
        }
        let storyboard = UIStoryboard (name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "LoanDetailStoryboardID") as! LoanDetailViewController
        controller.loan = loan
        self.present(controller, animated: true, completion: nil)
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowCartDetail" {
            
            if let indexPath = self.tableView.indexPathForSelectedRow {
                
                let controller = segue.destination as! LoanDetailViewController
                
                controller.showAddToCart = false
                
                let cartItem = self.cart!.items[indexPath.row]
                
                let loan:KivaLoan = KivaLoan(fromCartItem: cartItem, context: CoreDataContext.sharedInstance().cartContext)
                controller.loan = loan
            }
            
        } else if segue.identifier == "CartToMapSegueId" {
            
            //navigationItem.title = "Cart"
            
            let controller = segue.destination as! MapViewController
            
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
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "CartToMapSegueId", sender: self)
        }
    }
}
