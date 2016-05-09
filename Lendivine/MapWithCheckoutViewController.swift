//
//  MapWithCheckoutViewController.swift
//  Lendivine
//
//  Created by john bateman on 4/3/16.
//  Copyright © 2016 John Bateman. All rights reserved.
//
// This is the Cart Map View Controller which presents an MKMapView containing pins for each loan in the cart.

import UIKit
import MapKit

class MapWithCheckoutViewController: MapViewController {

    var cart:KivaCart?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.kivaAPI = KivaAPI.sharedInstance
        
        cart = KivaCart.sharedInstance
        
        modifyBarButtonItems()
    }
    
    func modifyBarButtonItems() {

        let loansByListButton = UIBarButtonItem(image: UIImage(named: "Donate-32"), style: .Plain, target: self, action: "onLoansByListButtonTap")
        navigationItem.setRightBarButtonItems([loansByListButton], animated: true)
        
        // remove back button
        navigationItem.hidesBackButton = true
    }
    
    @IBAction func onCheckoutButtonTapped(sender: AnyObject) {

        let loans = cart!.getLoans2()

        KivaLoan.getCurrentFundraisingStatus(loans, context: CoreDataContext.sharedInstance().cartScratchContext) {
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
        }
    }
    
    /*! Clear local cart of all items and present the Kiva web cart in the browser. */
    func displayKivaWebCartInBrowser() {
        
        // Display web cart.
        self.showEmbeddedBrowser()
        
        // Note: Enable this line if you want to remove all items from local cart view.
        // cart?.empty()
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
}
