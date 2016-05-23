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
import SafariServices


class LoansTableViewController: DVNTableViewController, NSFetchedResultsControllerDelegate, SFSafariViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        CoreDataLoanHelper.cleanup()
        
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
        
        KivaCart.updateCartBadge(self)
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
        let trashButton = UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: #selector(LoansTableViewController.onTrashButtonTap))

        navigationItem.setLeftBarButtonItems([trashButton], animated: true)
        
        // right bar button items
        let mapButton = UIBarButtonItem(image: UIImage(named: "earth-america-7"), style: .Plain, target: self, action: #selector(LoansTableViewController.onMapButton))
        
        let addLoansButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(LoansTableViewController.onAddLoansButtonTap))
        navigationItem.setRightBarButtonItems([mapButton, addLoansButton], animated: true)
    }
    
    func initRefreshControl() {
        
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.whiteColor()
        refreshControl.transform = CGAffineTransformMakeScale(2.0, 2.0)
        refreshControl.addTarget(self, action: #selector(LoansTableViewController.onPullToRefresh(_:)), forControlEvents: .ValueChanged)
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
        
        
        if loan.id == -1 {
            CoreDataContext.sharedInstance().scratchContext.deleteObject(loan)
            return
        }
        
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
        cell.loanImageView.image = UIImage(named: "Download-50")
    
        // put rounded corners on loan image
        cell.loanImageView.layer.cornerRadius = 20
        cell.loanImageView.layer.borderWidth = 0
        cell.loanImageView.layer.borderColor = UIColor.clearColor().CGColor
        cell.loanImageView.clipsToBounds = true
    
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        activityIndicator.center = CGPointMake(cell.loanImageView.center.x - 8, cell.loanImageView.center.y - 20)
        cell.loanImageView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        loan.getImage(200, height:200, square:true) {
            success, error, image in
            
            dispatch_async(dispatch_get_main_queue()) {
                activityIndicator.stopAnimating()
            }
            
            if success {
                dispatch_async(dispatch_get_main_queue()) {
                    cell.loanImageView!.image = image
                }
            } else  {
                print("error retrieving image: \(error)")
            }
        }
        
        let cart = KivaCart.sharedInstance
        if let id = loan.id {
            cell.donatedImageView.hidden = cart.containsLoanId(id) ? false : true
        }
    }
    
    
    // MARK: - Fetched results controller
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        // Create the fetch request
        let fetchRequest = NSFetchRequest(entityName: KivaLoan.entityName)
        
        // Add a sort descriptor to enforce a sort order on the results.
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        
        // Create the Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext:
            CoreDataContext.sharedInstance().scratchContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Return the fetched results controller. It will be the value of the lazy variable
        return fetchedResultsController
    } ()

    /* Perform a fetch of Loan objects to update the fetchedResultsController with the current data from the core data store. */
    func fetchLoans() -> Int {
        var error: NSError? = nil
        
        CoreDataContext.sharedInstance().scratchContext.reset()
        
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
    
    // OAuth with Kiva.org. Login happens on Kiva website and is redirected to Lendivine app once an OAuth access token is granted.
    func doOAuth() {
        let kivaOAuth = KivaOAuth.sharedInstance
        
        // Do the oauth in a background queue.
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
            
            if #available(iOS 9.0, *) {
                kivaOAuth.doOAuthKiva(self) {success, error, kivaAPI in
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
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    func oAuthCompleted(success: Bool) {
        print("OAuth completed with success = \(success)")
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
        refreshLoans(nil)
    }
    
    /*! Refresh button was selected. */
    func onAddLoansButtonTap() {
        
        refreshLoans(nil)
    }
    
    func onPullToRefresh(refreshControl: UIRefreshControl) {
        
        let myAttribute = [ NSFontAttributeName: UIFont(name: "Georgia", size: 10.0)! ]
        
        refreshControl.attributedTitle =  NSAttributedString(string: "Searching for Loans...", attributes: myAttribute)
        
        refreshLoans() {
            success, error in
            refreshControl.endRefreshing()
        }
    }
    
    
    // MARK: Helpfer functions
    
    /*! 
        @brief Get loans from Kiva.org.
        @discussion Loans are persisted to disk and refetched into the sharedContext.
    */
    func refreshLoans(completionHandler: ((success: Bool, error: NSError?) -> Void)? ) {
        
        // Search Kiva.org for the next page of Loan results.
        self.populateLoans(LoansTableViewController.KIVA_LOAN_SEARCH_RESULTS_PER_PAGE) {
            success, error in
            
            // refetch irrespective or result.
            self.fetchLoans()
            self.tableView.reloadData()
            
            if success {
                dispatch_async(dispatch_get_main_queue()) {
                    if let completionHandler = completionHandler {
                        completionHandler(success:true, error: nil)
                    }
                }
            } else {
                if (error != nil) && ((error?.code)! == -1009) && (error?.localizedDescription.containsString("offline"))! {
                    LDAlert(viewController: self).displayErrorAlertView("No Internet Connection", message: (error?.localizedDescription)!)
                }
                print("failed to populate loans. error: \(error?.localizedDescription)")
                if let completionHandler = completionHandler {
                    completionHandler(success:false, error: error)
                }
            }
        }
    }
    
    /*! Reload loans from Core Data. Note: placeholder. In future if we want to say fire a notification when items are removed from the cart we could respond here by refetching the loans and removing them from this scree. Chose not to implement this interaction flow with the data for the first version.
    */
//    func reloadLoansFromCoreData() {
//        //TODO
//    }
    
    /*! Remove all loans from the scratch context. */
    func removeAllLoans() {
        
        if let loans = self.fetchAllLoans() {
            
            let cart = KivaCart.sharedInstance
            var inCartCount = 0
            
            for loan: KivaLoan in loans {
                
                if let id = loan.id where (cart.containsLoanId(id) == false) {
                    CoreDataContext.sharedInstance().scratchContext.deleteObject(loan)
                } else {
                    inCartCount += 1
                }
            }
            CoreDataContext.sharedInstance().saveScratchContext()
            CoreDataLoanHelper.cleanup()
            
            if inCartCount > 0 {
                LDAlert(viewController:self).displayErrorAlertView("Loans in Cart", message: "Loans in the cart were not deleted.\n\n Once a loan is removed from the cart it can be removed from the Loans screen.")
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
            results = try CoreDataContext.sharedInstance().scratchContext.executeFetchRequest(fetchRequest) as? [KivaLoan]
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
            
            let controller = segue.destinationViewController as! LoansMapViewController
        
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