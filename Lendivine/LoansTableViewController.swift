//
//  LoansTableViewController.swift
//  Lendivine
//
//  Created by john bateman on 11/12/15.
//  Copyright © 2015 John Bateman. All rights reserved.
//

import UIKit
import CoreData

class LoansTableViewController: DVNTableViewController, NSFetchedResultsControllerDelegate {
    
    // a collection of Kiva loans
    var loans = [KivaLoan]() // todo - comment out this line. no longer used.
    
//    var kivaAPI: KivaAPI?
    
    /* The main core data managed object context. This context will be persisted. */
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }()
    
    /* A core data managed object context that will not be persisted. */
//todo remove
//    lazy var scratchContext: NSManagedObjectContext = {
//        var context = NSManagedObjectContext()
//        context.persistentStoreCoordinator = CoreDataStackManager.sharedInstance().persistentStoreCoordinator
//        return context
//    }()
    
//    var nextPageOfKivaSearchResults = 1
    
//    static let KIVA_LOAN_SEARCH_RESULTS_PER_PAGE = 20
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // OAuth with Kiva.org. Login happens on Kiva website and is redirected to Lendivine app once an OAuth access token is granted.
        //doOAuth()
 // todo - can remove this it has been moved to the superclass.
//        let kivaOAuth = KivaOAuth.sharedInstance
//        self.kivaAPI = kivaOAuth.kivaAPI
        
        // Initialize the fetchResultsController from the core data store.
        fetchLoans()
        
        // set the NSFetchedResultsControllerDelegate
        fetchedResultsController.delegate = self

        configureBarButtonItems()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidDisappear(animated: Bool) {
        //self.removeAllLoans()
        fetchedResultsController.delegate = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*! Setup the nav bar button items. */
    func configureBarButtonItems() {
    
        // Additional bar button items
        //TODO - enable let refreshButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "onRefreshButtonTap")
        //let oAuthButton = UIBarButtonItem(title: "OAuth", style: .Plain, target: self, action: "onOAuthButton")
        
        let oAuthButton = UIBarButtonItem(barButtonSystemItem: .Play, target: self, action: "onOAuthButtonTap")
        let trashButton = UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: "onTrashButtonTap")
        let mapButton = UIBarButtonItem(image: UIImage(named: "earth-america-7"), style: .Plain, target: self, action: "onMapButton")
        //        let cartButton = UIBarButtonItem(image: UIImage(named: "Checkout-50"), style: .Plain, target: self, action: "onCartButton")
        //        navigationItem.setRightBarButtonItems([oAuthButton, cartButton], animated: true)
        
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "onRefreshButtonTap")
        //navigationItem.setRightBarButtonItems([refreshButton], animated: true)
        navigationItem.setRightBarButtonItems([mapButton, refreshButton, trashButton, oAuthButton], animated: true)
        
        //self.navigationItem.rightBarButtonItems?.first?.enabled = false
        //self.navigationItem.rightBarButtonItems?[1].enabled = false
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
        // return self.fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let sectionInfo = self.fetchedResultsController.sections![section]
        let count = sectionInfo.numberOfObjects
        return count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("LoansTableViewCellID", forIndexPath: indexPath) as! LoansTableViewCell

        // Configure the cell...
        configureCell(cell, indexPath: indexPath)

        cell.parentTableView = tableView
        cell.parentController = self
        
        return cell
    }
    
    // Initialize the contents of the cell.
    func configureCell(cell: LoansTableViewCell, indexPath: NSIndexPath) {
        
        //dispatch_async(dispatch_get_main_queue()) {
            
            // TODO: loan is a CoreData object now. Use fetchedresultsController to initialize an instance.
            let loan = self.fetchedResultsController.objectAtIndexPath(indexPath) as! KivaLoan
            
            //let loan = self.loans[indexPath.row]
            
            if let name = loan.name {
                cell.nameLabel.text = name
            }
            
            if let sector = loan.sector {
                cell.sectorLabel.text = sector
            }
            
            var amountString = "$"
            if let loanAmount = loan.loanAmount {
                amountString.appendContentsOf(loanAmount.stringValue)
            } else {
                amountString.appendContentsOf("0")
            }
            cell.amountLabel.text = amountString
            
            if let country = loan.country {
                cell.countryLabel.text = loan.country
            }
            
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
            
            // TODO: crashing here
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
        //}
    }
    
    // MARK: - Fetched results controller
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        // Create the fetch request
        let fetchRequest = NSFetchRequest(entityName: KivaLoan.entityName)
        
        // Add a sort descriptor to enforce a sort order on the results.
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        
        // Create the Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext:
            CoreDataStackManager.sharedInstance().scratchContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Return the fetched results controller. It will be the value of the lazy variable
        return fetchedResultsController
    } ()

    /* Perform a fetch of Loan objects to update the fetchedResultsController with the current data from the core data store. */
    func fetchLoans() {
        var error: NSError? = nil
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error = error1
        }
        
        if let error = error {
            LDAlert(viewController:self).displayErrorAlertView("Error retrieving loans", message: "Unresolved error in fetchedResultsController.performFetch \(error), \(error.userInfo)")
        }
    }

    
    // MARK: NSFetchedResultsControllerDelegate
    
    // Any change to Core Data causes these delegate methods to be called.
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        // store up changes to the table until endUpdates() is called
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        // Our project does not use sections. So we can ignore these invocations.
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
            
        case .Insert:
            
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            
        case .Delete:
            
            print("deleting row \(indexPath!.row)")
            
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            
        case .Update:
            
            self.configureCell(tableView.cellForRowAtIndexPath(indexPath!) as! LoansTableViewCell, indexPath: indexPath!)
            
        case .Move:
            
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            
        default:
            return
            
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        // Make the stored changes visible.
        self.tableView.endUpdates()
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
    
    // OAuth button was selected.
    func onTrashButtonTap() {
        removeAllLoans()
    }
    
    // OAuth button was selected.
    func onOAuthButtonTap() {
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
        //self.navigationItem.rightBarButtonItems?.first?.enabled = true // todo - can remove: no longer needed. cannot get to this VC if oAuth failed in login screen.
        
/* TODO - reenable
            
        // load loans from core data
        //todo KivaLoan.fetchAllLoans()
        
        // fetch loans from Kiva.org
        // populateLoans(LoansTableViewController.KIVA_LOAN_SEARCH_RESULTS_PER_PAGE) { success, error in
        self.getMostRecentLoans() {
            success, loans, error in
            if success {
                dispatch_async(dispatch_get_main_queue()) {
                    
                    // Add any newly downloaded loans to the shared context if they are not already persisted in the core data store.
                    if let loans = loans {
                        for loan in loans where loan.id != nil {
                            if KivaLoan.fetchLoanByID2(loan.id!) == nil {
                                
                                // The following lines were causing duplicate objects to appear in core data. removing these lines results in owning the existing loan objects being upserted when saveContext is called.
                                
                                // todo duplicate loans 
                                //_ = KivaLoan.init(fromLoan: loan, context: self.sharedContext)
                                
                                //_ = KivaLoan.init(fromLoan: loan, context: CoreDataStackManager.sharedInstance().scratchContext)
                                
                                // todo... CoreDataStackManager.sharedInstance().saveContext()
                                
                                saveScratchContext()
                            }
                        }
                    }
                    
                    // call reloadData to trigger the fetchedResultController to pickup the newly added loans and add them to the table
                    // TODO: have we added this code yet or are we still using the self.loans array?
                    
                    (self.tableView.reloadData()) // self.tableView.setNeedsDisplay()
                    
                    // TODO: enable cart button
                    self.navigationItem.rightBarButtonItems?.first?.enabled = true
                }
            } else {
                // TODO - handle error
            }
        }
*/
    }
    
    func onMapButton() {
    
        // get list of loans displayed in this view controller
//        guard let loans = self.fetchAllLoans() else {
//            return
//        }
        presentMapController()
        
        // present the map view controller
//        let storyboard = UIStoryboard (name: "Main", bundle: nil)
//        let controller: MapViewController = storyboard.instantiateViewControllerWithIdentifier("MapStoryboardID") as! MapViewController
//        controller.loans = loans
//        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func onCartButton() {
        // Display local Cart VC containing only the loans in the cart.
        let storyboard = UIStoryboard (name: "Main", bundle: nil)
        let controller: CartTableViewController = storyboard.instantiateViewControllerWithIdentifier("CartStoryboardID") as! CartTableViewController
        controller.kivaAPI = self.kivaAPI
        self.presentViewController(controller, animated: true, completion: nil)
        
        
        // 2. TODO - modify security keys in info.plist to get kiva.org cart to render correctly. currently <key>NSAllowsArbitraryLoads</key> <true/> is set to get around the security restriction. To fix look at http://stackoverflow.com/questions/30731785/how-do-i-load-an-http-url-with-app-transport-security-enabled-in-ios-9 and enable appropriate options then remove the workaround above.
        
        // For now to demonstration checkout functionality call checkout here directly. TODO - move this to local CartVC.
        //checkout()
    }
    
    // Get the 20 most recent loans from Kiva.org in a Core Data scratch context.
    func getMostRecentLoans(completionHandler: (success: Bool, loans: [KivaLoan]?, error: NSError?) -> Void) {
        if let kivaAPI = self.kivaAPI {
            kivaAPI.kivaGetNewestLoans(CoreDataStackManager.sharedInstance().scratchContext) {
                success, error, loans in
                if success {
                    if let loans = loans {
                        // todo: duplicate loans.  remove permanently?     self.loans = loans
                        completionHandler(success: true, loans: loans, error: nil)
                    } else {
                        // TODO - display "no loans" in view controller
                        let error = VTError(errorString: "No Kiva loans found.", errorCode: VTError.ErrorCodes.KIVA_API_NO_LOANS)
                        completionHandler(success: false, loans: nil, error: error.error)
                    }
                } else {
                    // TODO - display error, then "no loans" in view controller
                    let error = VTError(errorString: "Error searching for newest Kiva loans.", errorCode: VTError.ErrorCodes.KIVA_API_NO_LOANS)
                    completionHandler(success: false, loans: nil, error: error.error)
                }
            }
        }
    }
    
//    // Find loans from Kiva.org and update this instance's loan collection property.
//    func populateLoans(numberOfLoansToAdd: Int, completionHandler: (success: Bool, error: NSError?) -> Void) {
//        if let kivaAPI = self.kivaAPI {
//            self.findLoans(kivaAPI) { success, error, loanResults in
//                if success {
//                    if var loans = loanResults {
//                        
//                        // just keep the first numberOfLoansToAdd loans
//                        //tood - reenable? loans.removeRange(numberOfLoansToAdd..<loans.count)  // Not sure this is doing anything: todo investigate
//                        
//                        // todo - do i need to maintain this collection anymore?  self.loans = loans
//                        
//                        print("fetched loans:")
//                        for loan in loans {
//                            print("%@", loan.name)
//                        }
//                        
//                        
//                        // Add any newly downloaded loans to the shared context if they are not already persisted in the core data store.
//                        //if let loans = loans {
//                            for loan in loans where loan.id != nil {
//                                if KivaLoan.fetchLoanByID2(loan.id!, context: CoreDataStackManager.sharedInstance().scratchContext) == nil {
//                                    
//                                    print("Need to add loan: %@", loan.name)
//                                    
//                                    // The following lines were causing duplicate objects to appear in core data. removing these lines results in owning the existing loan objects being upserted when saveContext is called.
//                                    
//                                    // todo duplicate loans 
//                                    // _ = KivaLoan.init(fromLoan: loan, context: self.sharedContext)
//                                    
//                                    // Instantiate a KivaLoan in the scratchContext so the fetchResultsController will update the table view.
//                                    let newLoan = KivaLoan.init(fromLoan: loan, context: CoreDataStackManager.sharedInstance().scratchContext)
//                                    print("new loan: %@, %d", newLoan.name, newLoan.id)
//                                
//                                    // CoreDataStackManager.sharedInstance().saveContext()
//                                    
//                                    self.saveScratchContext()
//                                }
//                            }
//                        //}
//                        
////                        for loan in loans {
////                            // add the  loan to our collection
////                            self.loans.append(loan)
////                            
////                            print("cart contains loanId: \(loanId) in amount: \(amount)")
////                        }
//                        
//                        completionHandler(success: true, error: nil)
//                    }
//                } else {
//                    print("failed")
//                    completionHandler(success: false, error: error)
//                }
//            }
//        } else {
//            print("no kivaAPI")
//            completionHandler(success: false, error: nil)
//        }
//    }
    
    // MARK: Kiva Test functions
    
//    func checkout() {
//        print("checkout called")
//        
//        let numberOfLoans = self.loans.count
//        putLoansInCart(numberOfLoans) {success, error in
//            if success {
//                self.showEmbeddedBrowser()
//            } else {
//                print("failed to put any loans in the cart")
//            }
//        }
//        
//        //    TODO - this is a data class. Need to move this logic to a view class and create a view controller for the web view. Look at code in OnTheMap.
//        //
//        //    /* Create a UIWebView the size of the screen and set it's delegate to this view controller. */
//        //    func showWebView(request: NSURLRequest?) {
//        //        let webView:UIWebView = UIWebView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height))
//        //        webView.delegate = self
//        //        if let url = url {
//        //            webView.loadRequest(request)
//        //            self.view.addSubview(webView)
//        //        }
//        //    }
//        
//    }
    
    // Add some randomly selected loans to the cart.
//    func putLoansInCart(numberOfLoansToAdd: Int, completionHandler: (success: Bool, error: NSError?) -> Void) {
//        if let kivaAPI = self.kivaAPI {
//            self.findLoans(kivaAPI) { success, error, loanResults in
//                if success {
//                    if var loans = loanResults {
//                        
//                        // just keep the first numberOfLoansToAdd loans
//                        loans.removeRange(numberOfLoansToAdd..<loans.count)
//                        
//                        print("looping through loans...")
//                        for loan in loans {
//                            // put the  loan into the cart
//                            let loanId = loan.id
//                            let amount = ( ( Int(arc4random() % 100) / 5 ) * 5) + 5
//                            print("amount of loan = \(amount)")
//                            kivaAPI.KivaAddItemToCart(loan, loanID: loan.id, donationAmount: amount, context: CoreDataStackManager.sharedInstance().scratchContext)
//                            
//                            print("cart contains loanId: \(loanId) in amount: \(amount)")
//                        }
//                        
//                        completionHandler(success: true, error: nil)
//                    }
//                } else {
//                    print("failed")
//                    completionHandler(success: false, error: error)
//                }
//            }
//        } else {
//            print("no kivaAPI")
//            completionHandler(success: false, error: nil)
//        }
//    }
    
    // helper function that searches for loans
//    func findLoans(kivaAPI: KivaAPI, completionHandler: (success: Bool, error: NSError?, loans: [KivaLoan]?) -> Void) {
//
//        let regions = "ca,sa,af,as,me,ee,we,an,oc"
//        let countries = "TD,TG,TH,TJ,TL,TR,TZ" // TODO: expand list of ocuntries or use user preferences
//        kivaAPI.kivaSearchLoans(queryMatch: "family", status: KivaLoan.Status.fundraising.rawValue, gender: nil, regions: regions, countries: nil, sector: KivaAPI.LoanSector.Agriculture, borrowerType: KivaAPI.LoanBorrowerType.individuals.rawValue, maxPartnerRiskRating: KivaAPI.PartnerRiskRatingMaximum.medLow, maxPartnerDelinquency: KivaAPI.PartnerDelinquencyMaximum.medium, maxPartnerDefaultRate: KivaAPI.PartnerDefaultRateMaximum.medium, includeNonRatedPartners: true, includedPartnersWithCurrencyRisk: true, page: self.nextPageOfKivaSearchResults, perPage: LoansTableViewController.KIVA_LOAN_SEARCH_RESULTS_PER_PAGE, sortBy: KivaAPI.LoanSortBy.popularity.rawValue) {
//            
//            success, error, loanResults, nextPage in
//            
//            // paging
//            if nextPage == -1 {
//                // disable the refresh button
//                //self.navigationItem.rightBarButtonItems?.first?.enabled = false
//                self.navigationItem.rightBarButtonItems?[1].enabled = false
//                //.enabled = false
//            } else {
//                // save the nextPage
//                self.nextPageOfKivaSearchResults = nextPage
//                    
//                // enable the refresh button
//                //self.navigationItem.rightBarButtonItems?.first?.enabled = true
//                self.navigationItem.rightBarButtonItems?[1].enabled = true
//                //.enabled = true
//            }
//            
//            if success {
//                // print("search loans results: \(loanResults)")
//                completionHandler(success: success, error: error, loans: loanResults)
//            } else {
//                // print("kivaSearchLoans failed")
//                completionHandler(success: success, error: error, loans: nil)
//            }
//        }
//    }
    
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
        self.presentViewController(controller, animated: true, completion: nil)
    }

    /* Refresh button was selected. */
    func onRefreshButtonTap() {
        
        // Search Kiva.org for the next page of Loan results.
        self.populateLoans(LoansTableViewController.KIVA_LOAN_SEARCH_RESULTS_PER_PAGE) { success, error in
            if success {
                dispatch_async(dispatch_get_main_queue()) {
                    //self.fetchLoans()
                    self.tableView.reloadData() // self.tableView.setNeedsDisplay()
                }
            } else {
                print("failed to populate loans. error: \(error?.localizedDescription)")
            }

        }
    }
    
    /*! Remove all loans from the scratch context. */
    func removeAllLoans() {
        
        if let loans = self.fetchAllLoans() {
            for loan: KivaLoan in loans {
                CoreDataStackManager.sharedInstance().scratchContext.deleteObject(loan)
                saveScratchContext()
            }
        }
    }
    
//    /* Query context for all MapRegion objects. Return array of MapRegion instances, or an empty array if no results or query failed. */
//    func fetchAllLoans() -> [MapRegion] {
//        let errorPointer: NSErrorPointer = nil
//        let fetchRequest = NSFetchRequest(entityName: MapRegion.entityName)
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: false), NSSortDescriptor(key: "longitude", ascending: false)]
//        let results: [AnyObject]?
//        do {
//            results = try sharedContext.executeFetchRequest(fetchRequest)
//        } catch let error as NSError {
//            errorPointer.memory = error
//            results = nil
//        }
//        if errorPointer != nil {
//            print("Error in fetchAllMapRegions(): \(errorPointer)")
//        }
//        return results as? [MapRegion] ?? [MapRegion]()
//    }
    
    /* 
        @brief Perform a fetch of all the loan objects in the scratch context. Return array of KivaLoan instances, or an empty array if no results or query failed.
        @discussion Updates the fetchedResultsController with the matching data from the core data store.
    */
    func fetchAllLoans() -> [KivaLoan]? {

        let error: NSErrorPointer = nil
        let fetchRequest = NSFetchRequest(entityName: KivaLoan.entityName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        var results: [AnyObject]?
        do {
            results = try CoreDataStackManager.sharedInstance().scratchContext.executeFetchRequest(fetchRequest) as? [KivaLoan]
        } catch let error1 as NSError {
            error.memory = error1
            print("Error in fetchAllLoans(): \(error)")
            return nil
        }

        // Check for Errors
        if error != nil {
            print("Error in fetchAllLoans(): \(error)")
        }
        
        return results as? [KivaLoan] ?? [KivaLoan]()
    }
    
//    /* Save the data in the scrach context to the core data store on disk. */
//    func saveScratchContext() {
//        
//        let error: NSErrorPointer = nil
//        //var results: [AnyObject]?
//        do {
//            _ = try CoreDataStackManager.sharedInstance().scratchContext.save()
//        } catch let error1 as NSError {
//            error.memory = error1
//            print("Error saving scratchContext: \(error)")
//        }
//    }
    
//    @IBAction func unwindToVC(segue:UIStoryboardSegue) {
////        if(segue.sourceViewController .isKindOfClass(ViewController2))
////        {
////            let alert = UIAlertView()
////            alert.title = "UnwindSegue"
////            alert.message = "Unwind from view 2"
////            alert.addButtonWithTitle("Ok")
////            alert.show()
////        }
////        if(segue.sourceViewController .isKindOfClass(ViewController3))
////        {
////            let alert = UIAlertView()
////            alert.title = "UnwindSegue"
////            alert.message = "Unwind from view 3"
////            alert.addButtonWithTitle("Ok")
////            alert.show()
////        }
//    }

    // MARK: UITableViewDelegate Accessory Views
    
    /*! Disclosure indicator tapped. Present the loan detail view controller for the selected loan. */
//    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
//        
//        if let loan = self.fetchedResultsController.objectAtIndexPath(indexPath) as? KivaLoan {
//            
//            self.presentLoanDetailViewController(loan)
//        }
//    }
    
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowDetail" {
            
            if let indexPath = self.tableView.indexPathForSelectedRow {
                
                let controller = segue.destinationViewController as! LoanDetailViewController
                
                if let loan = self.fetchedResultsController.objectAtIndexPath(indexPath) as? KivaLoan {
                    controller.loan = loan
                }
            }
        
        } else if segue.identifier == "LoansToMapSegueId" {
     
            navigationItem.title = "Loans"
            
            let controller = segue.destinationViewController as! MapViewController
        
            controller.sourceViewController = self
        
            // get list of loans displayed in this view controller
            if let loans = self.fetchAllLoans() {
                controller.loans = loans
            }
        }
    }
    
    /* Modally present the MapViewController on the main thread. */
    func presentMapController() {
        dispatch_async(dispatch_get_main_queue()) {
            self.performSegueWithIdentifier("LoansToMapSegueId", sender: self)
        }
    }
    
//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        
//    }
    
// TODO - remove? I don't think this is being used now.
/* Modally present the LoanDetail view controller. */
//    func presentLoanDetailViewController(loan: KivaLoan?) {
//        guard let loan = loan else {
//            return
//        }
//        let storyboard = UIStoryboard (name: "Main", bundle: nil)
//        //let controller = storyboard.instantiateViewControllerWithIdentifier("TestStoryboardID") as! UIViewController
//        let controller = storyboard.instantiateViewControllerWithIdentifier("LoanDetailStoryboardID") as! LoanDetailViewController
//        controller.loan = loan
//        //self.presentViewController(controller, animated: true, completion: nil)
//        self.navigationController!.presentViewController(controller, animated: true, completion: nil)
//    }

// TODO
//    override func canPerformUnwindSegueAction(action: Selector, fromViewController: UIViewController, withSender sender: AnyObject) -> Bool {
//        return true
//    }
    
}