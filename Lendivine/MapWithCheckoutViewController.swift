//
//  MapWithCheckoutViewController.swift
//  Lendivine
//
//  Created by john bateman on 4/3/16.
//  Copyright © 2016 John Bateman. All rights reserved.
//
// This is the Cart Map View Controller.

import UIKit
import MapKit

class MapWithCheckoutViewController: MapViewController {

    var cart:KivaCart? // = KivaCart.sharedInstance
//    var kivaAPI: KivaAPI?
    
//    /* The main core data managed object context. This context will be persisted. */
//    lazy var sharedContext: NSManagedObjectContext = {
//        return CoreDataStackManager.sharedInstance().managedObjectContext!
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.kivaAPI = KivaAPI.sharedInstance
        
        cart = KivaCart.sharedInstance
        
        modifyBarButtonItems()
    }
    
    func modifyBarButtonItems() {
        // disable the refresh button
//        self.navigationItem.rightBarButtonItems?[1].enabled = false
//        self.navigationItem.rightBarButtonItems?[1].width = 0.1
//        navigationItem.rightBarButtonItems = []
        let loansByListButton = UIBarButtonItem(image: UIImage(named: "Donate-32"), style: .Plain, target: self, action: "onLoansByListButtonTap")
        navigationItem.setRightBarButtonItems([loansByListButton], animated: true)
        
        // remove back button
        //self.navigationItem.leftBarButtonItems?.first?.enabled = false
        navigationItem.hidesBackButton = true
    }
    
    @IBAction func onCheckoutButtonTapped(sender: AnyObject) {

        print("call KivaAPI.checkout")
        
        //cart!.getLoans() { loans, error in
        
        let loans = cart!.getLoans2()
        print("cart count before stripping out non-fundraising loans = \(self.cart!.items.count)")
        print("loans: %@", loans)
        KivaLoan.getCurrentFundraisingStatus(loans) {
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
        //}
    }
    
    /*! Clear local cart of all items and present the Kiva web cart in the browser. */
    func displayKivaWebCartInBrowser() {
        
        // Display web cart.
        self.showEmbeddedBrowser()
        
        // Remove all items from local cart view.
        //todo cart?.empty()
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
        //        self.presentViewController(controller, animated: true, completion: nil)
        
        // add the view controller to the navigation controller stack
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
