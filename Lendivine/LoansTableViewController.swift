//
//  LoansTableViewController.swift
//  Lendivine
//
//  Created by john bateman on 11/12/15.
//  Copyright © 2015 John Bateman. All rights reserved.
//
//  This table view controller displays a list of loans queried from the kiva REST API.

import UIKit
import CoreData


class LoansTableViewController: DVNTableViewController, NSFetchedResultsControllerDelegate {
    
    // a collection of Kiva loans
    //var loans = [KivaLoan]() // todo - comment out this line. no longer used.
    
    /* The main core data managed object context. This context will be persisted. */
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize the fetchResultsController from the core data store.
        let loanCount = fetchLoans()
        if loanCount == 0 {
            // There are no persisted loans. Let's request some new ones from Kiva.
            onAddLoansButtonTap()
        }
        
        // set the NSFetchedResultsControllerDelegate
        fetchedResultsController.delegate = self

        configureBarButtonItems()
        
        navigationItem.title = "Loans"
        
        navigationController?.navigationBar.barTintColor = UIColor(rgb:0xFFE8A1)
        navigationController?.navigationBar.translucent = false
        
        initRefreshControl()
    }
    
    /*! hide the status bar */
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        //self.removeAllLoans()
        fetchedResultsController.delegate = nil
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: view setup
    
    /*! Setup the nav bar button items. */
    func configureBarButtonItems() {
    
        // left bar button items
        let trashButton = UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: "onTrashButtonTap")
//        let oAuthButton = UIBarButtonItem(barButtonSystemItem: .Play, target: self, action: "onOAuthButtonTap")
        navigationItem.setLeftBarButtonItems([trashButton/*, oAuthButton*/], animated: true)
        
        // right bar button items
        let mapButton = UIBarButtonItem(image: UIImage(named: "earth-america-7"), style: .Plain, target: self, action: "onMapButton")
        
        let addLoansButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "onAddLoansButtonTap")
        navigationItem.setRightBarButtonItems([mapButton, addLoansButton], animated: true)
    }
    
    func initRefreshControl() {
        
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.whiteColor()
        refreshControl.transform = CGAffineTransformMakeScale(2.0, 2.0)
        refreshControl.addTarget(self, action: "onPullToRefresh:", forControlEvents: .ValueChanged)
        self.tableView.addSubview(refreshControl)
        self.tableView.alwaysBounceVertical = true
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
        // return self.fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let sectionInfo = self.fetchedResultsController.sections![section]
        let count = sectionInfo.numberOfObjects
        navigationItem.title = "\(count) Loans"
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
        
        let loan = self.fetchedResultsController.objectAtIndexPath(indexPath) as! KivaLoan
        
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
        
        if let _ = loan.country {
            cell.countryLabel.text = loan.country
        }

        // Set placeholder image
        cell.loanImageView.image = UIImage(named: "Add Shopping Cart-50") // TODO: update placeholder image in .xcassets
    
        // put rounded corners on loan image
        cell.loanImageView.layer.cornerRadius = 20
        cell.loanImageView.layer.borderWidth = 0
        cell.loanImageView.layer.borderColor = UIColor.clearColor().CGColor
        cell.loanImageView.clipsToBounds = true
    
        loan.getImage() {success, error, image in
            if success {
                dispatch_async(dispatch_get_main_queue()) {
                    cell.loanImageView!.image = image
                }
            } else  {
                print("error retrieving image: \(error)")
            }
        }
// TODO - find another way to determine if the loan is in the cart and update the donatedImageView.
//        // TODO: cart context - This is the only place where a cart item is accessed using a scratchContext
//        let cart = KivaCart.sharedInstance
//        let item = KivaCartItem(loan: loan, donationAmount: 25, context: CoreDataStackManager.sharedInstance().scratchContext /*self.sharedContext*/) // TODO: cart context
//        if cart.itemInCart(item) {
//            cell.donatedImageView.hidden = false
//        } else {
//            cell.donatedImageView.hidden = true
//        }
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
    func fetchLoans() -> Int {
        var error: NSError? = nil
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error = error1
        }
        
        if let error = error {
            LDAlert(viewController:self).displayErrorAlertView("Error retrieving loans", message: "Unresolved error in fetchedResultsController.performFetch \(error), \(error.userInfo)")
        } else {
            let sectionInfo = self.fetchedResultsController.sections![0]
            let count = sectionInfo.numberOfObjects
            print("Fetched \(count) loans.")
            
            navigationItem.title = "\(count) Loans"
            return count
        }
        return 0
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
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        // Make the stored changes visible.
        self.tableView.endUpdates()
    }
    
    
    // MARK: Actions
    
    // OAuth button was selected.
    func onTrashButtonTap() {
        removeAllLoans()
        self.resetNextKivaPage()
        self.fetchLoans()
        self.tableView.reloadData()
    }
    
    // OAuth button was selected.
//    func onOAuthButtonTap() {
//        doOAuth()
//    }
    
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
        presentMapController()
    }
    
    func onCartButton() {
        // Display local Cart VC containing only the loans in the cart.
        let storyboard = UIStoryboard (name: "Main", bundle: nil)
        let controller: CartTableViewController = storyboard.instantiateViewControllerWithIdentifier("CartStoryboardID") as! CartTableViewController
        controller.kivaAPI = self.kivaAPI
        self.presentViewController(controller, animated: true, completion: nil)
        
        // 2. TODO - modify security keys in info.plist to get kiva.org cart to render correctly. currently <key>NSAllowsArbitraryLoads</key> <true/> is set to get around the security restriction. To fix look at http://stackoverflow.com/questions/30731785/how-do-i-load-an-http-url-with-app-transport-security-enabled-in-ios-9 and enable appropriate options then remove the workaround above.
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
    
    /*! Display url in an embeded webkit browser. */
    func showEmbeddedBrowser() {
        
        let controller = KivaCartViewController()
        if let _ = self.kivaAPI {
            controller.request = self.kivaAPI!.getKivaCartRequest()
        }

        self.presentViewController(controller, animated: true, completion: nil)
    }

    /*! See More Loans..." button was selected. */
    @IBAction func seeMoreLoans(sender: AnyObject) {
        refreshLoans() {
            success, error in
            if success {
                self.fetchLoans()
                self.tableView.reloadData()
            } else {
                print("refreshLoans returned an error: \(error)")
            }
        }
    }
    
    /*! Refresh button was selected. */
    func onAddLoansButtonTap() {
        
        refreshLoans() {
            success, error in
            if success {
                self.fetchLoans()
                self.tableView.reloadData()
            }
        }
    }
    
    func onPullToRefresh(refreshControl: UIRefreshControl) {
        
        let myAttribute = [ NSFontAttributeName: UIFont(name: "Georgia", size: 10.0)! ]
        
        refreshControl.attributedTitle =  NSAttributedString(string: "Searching for Loans...", attributes: myAttribute)
        
        refreshLoans() {
            success, error in
            
            refreshControl.endRefreshing()
            
            if success {
                self.fetchLoans()
                self.tableView.reloadData()
            }
        }
    }
    
    
    // MARK: Helpfer functions
    
    func refreshLoans(completionHandler: ((success: Bool, error: NSError?) -> Void)? ) {
        
        // Search Kiva.org for the next page of Loan results.
        self.populateLoans(LoansTableViewController.KIVA_LOAN_SEARCH_RESULTS_PER_PAGE) { success, error in
            if success {
                dispatch_async(dispatch_get_main_queue()) {
                    //self.fetchLoans()
                    //self.tableView.reloadData()
                    if let completionHandler = completionHandler {
                        completionHandler(success:true, error: nil)
                    }
                }
            } else {
                print("failed to populate loans. error: \(error?.localizedDescription)")
                if let completionHandler = completionHandler {
                    completionHandler(success:false, error: error)
                }
            }
        }
    }
    // TODO - why are we using a scratch context? 
    /*! Remove all loans from the scratch context. */
    func removeAllLoans() {
        
        if let loans = self.fetchAllLoans() {
            for loan: KivaLoan in loans {
                CoreDataStackManager.sharedInstance().scratchContext.deleteObject(loan)
                saveScratchContext()
            }
        }
    }
    
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
}