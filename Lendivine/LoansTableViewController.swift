//
//  LoansTableViewController.swift
//  Lendivine
//
//  Created by john bateman on 11/12/15.
//  Copyright © 2015 John Bateman. All rights reserved.
//

import UIKit

class LoansTableViewController: UITableViewController {

    // a collection of Kiva loans
    var loans = [KivaLoan]()
    
    var kivaAPI: KivaAPI?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // OAuth with Kiva.org. Login happens on Kiva website and is redirected to Lendivine app once an OAuth access token is granted.
        doOAuth()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // Additional bar button items
        //TODO - enable let refreshButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "onRefreshButtonTap")
        let oAuthButton = UIBarButtonItem(title: "OAuth", style: .Plain, target: self, action: "onOAuthButton")
        let cartButton = UIBarButtonItem(image: UIImage(named: "Checkout-50"), style: .Plain, target: self, action: "onCartButton")
        navigationItem.setRightBarButtonItems([oAuthButton, cartButton], animated: true)
        
        self.navigationItem.rightBarButtonItems?.first?.enabled = false
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
        return self.loans.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LoansTableViewCellID", forIndexPath: indexPath) as! LoansTableViewCell

        // Configure the cell...
        configureCell(cell, indexPath: indexPath)

        return cell
    }
    
    func configureCell(cell: LoansTableViewCell, indexPath: NSIndexPath) {
        let loan = self.loans[indexPath.row]
        cell.nameLabel.text = loan.name
        cell.sectorLabel.text = loan.sector
        cell.amountLabel.text = "$" + loan.loanAmount.stringValue
        
        // Set placeholder image
        cell.loanImageView.image = UIImage(named: "Add Shopping Cart-50") // TODO: update placeholder image in .xcassets
        
//        if let kivaAPI = self.kivaAPI {
//            // getKivaImage can retrieve the image from the server in a background thread. Make sure to update UI from main thread.
//            kivaAPI.getKivaImage(loan.imageID) {success, error, image in
//                if success {
//                    dispatch_async(dispatch_get_main_queue()) {
//                        cell.loanImageView!.image = image
//                    }
//                } else  {
//                    print("error retrieving image: \(error)")
//                }
//            }
//        }
        
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
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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
    
    // OAuth button was selected.
    func onOAuthButton() {
        doOAuth()
    }
    
    // OAuth with Kiva.org. Login happens on Kiva website and is redirected to Lendivine app once an OAuth access token is granted.
    func doOAuth() {
        let kivaOAuth = KivaOAuth.sharedInstance // = KivaOAuth()
        
        // Do the oauth in a background queue.
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
            
            kivaOAuth.doOAuthKiva() {success, error, kivaAPI in
                if success {
                    self.kivaAPI = kivaOAuth.kivaAPI
                } else {
                    print("kivaOAuth failed. Unable to acquire kivaAPI handle.")
                }
                
                // Call oAuthCompleted on main queue.
                dispatch_async(dispatch_get_main_queue()) {
                    self.oAuthCompleted(success)
                }
            }
        }
    }
    
    func oAuthCompleted(success: Bool) {
        print("OAuth completed with success = \(success)")
        
        // fetch loans from Kiva.org
        populateLoans(20) { success, error in
            dispatch_async(dispatch_get_main_queue()) {
                (self.tableView.reloadData()) // self.tableView.setNeedsDisplay()
                
                // TODO: enable cart button
                self.navigationItem.rightBarButtonItems?.first?.enabled = true
            }
        }
    }
    
    func onCartButton() {
        // Display local Cart VC containing only the loans in the cart.
        let storyboard = UIStoryboard (name: "Main", bundle: nil)
        let controller: CartTableViewController = storyboard.instantiateViewControllerWithIdentifier("CartStoryboardID") as! CartTableViewController
        controller.kivaAPI = self.kivaAPI
        self.presentViewController(controller, animated: true, completion: nil);
        
        
        // 2. TODO - modify security keys in info.plist to get kiva.org cart to render correctly. currently <key>NSAllowsArbitraryLoads</key> <true/> is set to get around the security restriction. To fix look at http://stackoverflow.com/questions/30731785/how-do-i-load-an-http-url-with-app-transport-security-enabled-in-ios-9 and enable appropriate options then remove the workaround above.
        
        // For now to demonstration checkout functionality call checkout here directly. TODO - move this to local CartVC.
        //checkout()
    }
    
    // Find loans from Kiva.org and update the loan collection.
    func populateLoans(numberOfLoansToAdd: Int, completionHandler: (success: Bool, error: NSError?) -> Void) {
        if let kivaAPI = self.kivaAPI {
            self.findLoans(kivaAPI) { success, error, loanResults in
                if success {
                    if var loans = loanResults {
                        
                        // just keep the first numberOfLoansToAdd loans
                        loans.removeRange(numberOfLoansToAdd..<loans.count)
                        
                        self.loans = loans
                        
//                        for loan in loans {
//                            // add the  loan to our collection
//                            self.loans.append(loan)
//                            
//                            print("cart contains loanId: \(loanId) in amount: \(amount)")
//                        }
                        
                        completionHandler(success: true, error: nil)
                    }
                } else {
                    print("failed")
                    completionHandler(success: false, error: error)
                }
            }
        } else {
            print("no kivaAPI")
            completionHandler(success: false, error: nil)
        }
    }
    
    // MARK: Kiva Test functions
    
    func checkout() {
        print("checkout called")
        
        let numberOfLoans = self.loans.count
        putLoansInCart(numberOfLoans) {success, error in
            if success {
                self.showEmbeddedBrowser()
            } else {
                print("failed to put any loans in the cart")
            }
        }
        
        //    TODO - this is a data class. Need to move this logic to a view class and create a view controller for the web view. Look at code in OnTheMap.
        //
        //    /* Create a UIWebView the size of the screen and set it's delegate to this view controller. */
        //    func showWebView(request: NSURLRequest?) {
        //        let webView:UIWebView = UIWebView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height))
        //        webView.delegate = self
        //        if let url = url {
        //            webView.loadRequest(request)
        //            self.view.addSubview(webView)
        //        }
        //    }
        
    }
    
    // Add some randomly selected loans to the cart.
    func putLoansInCart(numberOfLoansToAdd: Int, completionHandler: (success: Bool, error: NSError?) -> Void) {
        if let kivaAPI = self.kivaAPI {
            self.findLoans(kivaAPI) { success, error, loanResults in
                if success {
                    if var loans = loanResults {
                        
                        // just keep the first numberOfLoansToAdd loans
                        loans.removeRange(numberOfLoansToAdd..<loans.count)
                        
                        print("looping through loans...")
                        for loan in loans {
                            // put the  loan into the cart
                            let loanId = loan.id
                            let amount = ( ( Int(arc4random() % 100) / 5 ) * 5) + 5
                            print("amount of loan = \(amount)")
                            kivaAPI.KivaAddItemToCart(loan, loanID: loan.id, amount: amount)
                            
                            print("cart contains loanId: \(loanId) in amount: \(amount)")
                        }
                        
                        completionHandler(success: true, error: nil)
                    }
                } else {
                    print("failed")
                    completionHandler(success: false, error: error)
                }
            }
        } else {
            print("no kivaAPI")
            completionHandler(success: false, error: nil)
        }
    }
    
    // helper function that searches for loans
    func findLoans(kivaAPI: KivaAPI, completionHandler: (success: Bool, error: NSError?, loans: [KivaLoan]?) -> Void) {
        
        let regions = "ca,sa,af,as,me,ee,we,an,oc"
        let countries = "TD,TG,TH,TJ,TL,TR,TZ"
        kivaAPI.kivaSearchLoans(queryMatch: "family", status: KivaAPI.LoanStatus.fundraising.rawValue, gender: nil, regions: regions, countries: nil, sector: KivaAPI.LoanSector.Agriculture, borrowerType: KivaAPI.LoanBorrowerType.individuals.rawValue, maxPartnerRiskRating: KivaAPI.PartnerRiskRatingMaximum.medLow, maxPartnerDelinquency: KivaAPI.PartnerDelinquencyMaximum.medium, maxPartnerDefaultRate: KivaAPI.PartnerDefaultRateMaximum.medium, includeNonRatedPartners: true, includedPartnersWithCurrencyRisk: true, page: 1, perPage: 20, sortBy: KivaAPI.LoanSortBy.popularity.rawValue) { success, error, loanResults in
            
            if success {
                // print("search loans results: \(loanResults)")
                completionHandler(success: success, error: error, loans: loanResults)
            } else {
                // print("kivaSearchLoans failed")
                completionHandler(success: success, error: error, loans: nil)
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
            controller.request = self.kivaAPI!.getKivaCartRequest()  // KivaCheckout()
        }
        //controller.webViewDelegate = self
        self.presentViewController(controller, animated: true, completion: nil);
    }

}
