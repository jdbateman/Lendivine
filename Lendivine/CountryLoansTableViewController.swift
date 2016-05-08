//
//  CountryLoansTableViewController.swift
//  Lendivine
//
//  Created by john bateman on 3/13/16.
//  Copyright © 2016 John Bateman. All rights reserved.
//
// This table view controller displays a list of current loans available in a particular country as returned in a response to a country specific search against the Kiva REST API. The loans are not persisted.

import UIKit
import CoreData

class CountryLoansTableViewController: UITableViewController {
    
    var country: Country?
    
    // var kivaAPI: KivaAPI = KivaAPI.sharedInstance
    
    var nextPageOfKivaSearchResults = 1
    
    // a collection of the Kiva loans the user has made
    var loans = [KivaLoan]()
    
    let activityIndicator = DVNActivityIndicator()
    
    // Set to true if No Results message should be displayed.
    var showNoResults: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.activityIndicator.startActivityIndicator(tableView)
        
        // initialize user's loans
        refreshLoans(nil)
        
        configureView()
        
        // add the map bar button item
        let mapButton = UIBarButtonItem(image: UIImage(named: "earth-america-7"), style: .Plain, target: self, action: "onMapButton")
        navigationItem.setRightBarButtonItem(mapButton, animated: true)
        self.navigationItem.rightBarButtonItems?.first?.enabled = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        configureView()
        
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureView() {
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        navigationItem.title = loans.first?.country
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if self.loans.count > 0 {
            
            if let countryName = self.country?.name {
                navigationItem.title = String(format:"\(self.loans.count) in %@", countryName)
            }
            
            self.tableView.backgroundView = nil
            return 1
            
        } else {
            
            if self.showNoResults {
                
                let noDataLabel: UILabel = UILabel(frame: CGRectMake(0, 0, tableView.bounds.size.width, tableView.bounds.size.height))
                noDataLabel.text = "No loans available"
                if let country = self.country, let name = country.name {
                    noDataLabel.text = "No loans available" + " for " + "\(name)"
                }
                noDataLabel.textColor = UIColor.darkGrayColor()
                noDataLabel.textAlignment = .Center
                tableView.backgroundView = noDataLabel
                tableView.separatorStyle = .None
            }
            
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.loans.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> CountryLoanTableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("CountryLoansTableViewCellID" /*"MyLoansTableViewCellID"*/, forIndexPath: indexPath) as! CountryLoanTableViewCell //MyLoansTableViewCell
        
        // Configure the cell...
        configureCell(cell, row: indexPath.row)
        
        cell.parentTableView = tableView
        cell.parentController = self
        
        return cell
    }
    
    // Initialize the contents of the cell.
    func configureCell(cell: CountryLoanTableViewCell /*MyLoansTableViewCell*/, row: Int) {
        
        let loan = self.loans[row]
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
        
        // Set placeholder image
        cell.loanImageView.image = UIImage(named: "Download-50")
        
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
        
        cell.addToCartButton.layer.cornerRadius = 19.2 // 24
        if let cart = UIImage(named: "Add Shopping Cart-50") {
            let tintedCart = cart.imageWithRenderingMode(.AlwaysTemplate)
            cell.addToCartButton.imageView!.image = tintedCart
            cell.addToCartButton.imageView!.tintColor = UIColor.blueColor()
        }
    }
    
//    /*! 
//        @brief Search the kiva service for loans available in the specified country.
//        @param (in) country - The country in which to search for loans.
//        @return A list of available loans, else nil.
//    */
//    func searchForLoansInCountry(country: Country?, completionHandler: ((success: Bool, countries: [Country]?, error: NSError?) -> Void)?) {
//        
//        self.onRefreshButtonTap()
//        
//    }
    
    
//    /* Refresh button was selected. */
//    func onRefreshButtonTap() {
//        
//        // Search Kiva.org for the next page of Loan results.
//        let countryCode = self.country?.countryCodeTwoLetter
//        CountryLoansKivaApiHelper.populateLoansForCountry(LoansTableViewController.KIVA_LOAN_SEARCH_RESULTS_PER_PAGE, twoLetterCountryCode: countryCode, nextPage: self.nextPageOfKivaSearchResults) { success, error, loans, nextPage in
//            
//            if success {
//                
//                // Append any new loans returned by the Kiva api to our existing collection.
//                if let loans = loans {
//                    self.loans.appendContentsOf(loans)
//                }
//                
//                // paging
//                if nextPage == -1 {
//                    
//                    // disable the refresh button
//                    self.navigationItem.rightBarButtonItems?.first?.enabled = false
//                
//                } else {
//                
//                    // save the nextPage
//                    self.nextPageOfKivaSearchResults = nextPage
//                    self.navigationItem.rightBarButtonItems?.first?.enabled = true
//                }
//
//                dispatch_async(dispatch_get_main_queue()) {
//                    
//                    self.tableView.reloadData()
//                    
//                    if self.loans.count == 0 {
//                        self.showNoResults = true
//                    }
//                }
//                
//            } else {
//                
//                self.showNoResults = true
//                print("failed to populate loans. error: \(error?.localizedDescription)")
//            }
//            
//            self.activityIndicator.stopActivityIndicator()
//        }
//    }
    
//    // Find loans from Kiva.org and update this instance's loan collection property.
//    func populateLoans(numberOfLoansToAdd: Int, completionHandler: (success: Bool, error: NSError?) -> Void) {
//        
//            self.findLoans(self.kivaAPI) { success, error, loanResults in
//                
//            if success {
//                if let loans = loanResults {
//                    
//                    // Append any new loans returned by the Kiva api to our existing collection.
//                    self.loans.appendContentsOf(loans)
//                    
//                    print("new list after appending fetched loans:")
//                    for loan in loans {
//                        print("%@", loan.name)
//                    }
//                    
//                    completionHandler(success: true, error: nil)
//                }
//            } else {
//                print("failed")
//                completionHandler(success: false, error: error)
//            }
//        }
//    }
//    
//    // helper function that searches for loans
//    func findLoans(kivaAPI: KivaAPI, completionHandler: (success: Bool, error: NSError?, loans: [KivaLoan]?) -> Void) {
//        
//        guard let countryCode = self.country?.countryCodeTwoLetter else {
//            
//            let error = NSError(domain: "CountryLoans", code: 994, userInfo: [NSLocalizedDescriptionKey: "missing country code"])
//            completionHandler(success: true, error: error, loans: nil)
//            return
//        }
//        
//        let countries = countryCode
//        
//        
//        
//        // Lenient criteria to maximimze the possibility that any particular country will return matches.
//        kivaAPI.kivaSearchLoans(queryMatch: nil, status: nil, gender: nil, regions: nil, countries: countries, sector: nil, borrowerType: KivaAPI.LoanBorrowerType.individuals.rawValue, maxPartnerRiskRating: nil, maxPartnerDelinquency: nil, maxPartnerDefaultRate: nil, includeNonRatedPartners: true, includedPartnersWithCurrencyRisk: true, page: self.nextPageOfKivaSearchResults, perPage: LoansTableViewController.KIVA_LOAN_SEARCH_RESULTS_PER_PAGE, sortBy: KivaAPI.LoanSortBy.popularity.rawValue) {
//
//            success, error, loanResults, nextPage in
//            
//            // paging
//            if nextPage == -1 {
//                // disable the refresh button
//                self.navigationItem.rightBarButtonItems?.first?.enabled = false
//                //.enabled = false
//            } else {
//                // save the nextPage
//                self.nextPageOfKivaSearchResults = nextPage
//                
//                // enable the refresh button
//                self.navigationItem.rightBarButtonItems?.first?.enabled = true
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

    
    // MARK: Actions
    
    func onMapButton() {
        presentMapController()
    }
    
    @IBAction func onSeeMoreLoansButton(sender: AnyObject) {

        refreshLoans() {
            success, error in
            if success {
                self.tableView.reloadData()
            } else {
                print("refreshLoans returned an error: \(error)")
            }
        }
    }
    
    // MARK: UITableViewDelegate Accessory Views
    
    /*! Disclosure indicator tapped. Present the loan detail view controller for the selected loan. */
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        
        guard indexPath.row < loans.count else {return}
        
        let loan = loans[indexPath.row]
        self.presentLoanDetailViewController(loan)
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
        
        if segue.identifier == "ShowCountryLoanDetail" {
            
            if let indexPath = self.tableView.indexPathForSelectedRow {
                
                let controller = segue.destinationViewController as! LoanDetailViewController
                
                let loan = self.loans[indexPath.row]
                controller.loan = loan
            }
            
        } else if segue.identifier == "CountryLoanToMapSegueId" {
            
            // navigationItem.title = loans.first?.country
            
            let controller = segue.destinationViewController as! MapViewController
            
            controller.sourceViewController = self
            
            controller.navigationItem.title = loans.first?.country
            
            // get list of loans displayed in this view controller
            controller.loans = loans
        }
    }
    
    /* Modally present the MapViewController on the main thread. */
    func presentMapController() {
        dispatch_async(dispatch_get_main_queue()) {
            self.performSegueWithIdentifier("CountryLoanToMapSegueId", sender: self)
        }
    }

    
    // MARK: Kiva API

    func refreshLoans(completionHandler: ((success: Bool, error: NSError?) -> Void)? ) {
        
        // Search Kiva.org for the next page of Loan results.
        CountryLoansKivaApiHelper.populateLoansForCountry(LoansTableViewController.KIVA_LOAN_SEARCH_RESULTS_PER_PAGE, twoLetterCountryCode: self.country?.countryCodeTwoLetter, nextPage: self.nextPageOfKivaSearchResults) {
            success, error, loans, nextPage in
            
            if success {
                
                // enable/disable earth bar button item
                if let loans = loans where loans.count > 0 {
                    self.navigationItem.rightBarButtonItems?.first?.enabled = true
                } else {
                    self.navigationItem.rightBarButtonItems?.first?.enabled = false
                }
                
                // Append any new loans returned by the Kiva api to our existing collection.
                if let loans = loans {
                    self.loans.appendContentsOf(loans)
                }
                
                // paging
                if nextPage != -1 {
                    // save the nextPage
                    self.nextPageOfKivaSearchResults = nextPage
                }
                
                dispatch_async(dispatch_get_main_queue()) {

                    self.tableView.reloadData()
                    
                    if self.loans.count == 0 {
                        self.showNoResults = true
                    }
                    
                    if let completionHandler = completionHandler {
                        completionHandler(success:true, error: nil)
                    }
                }
                
            } else {
                
                self.showNoResults = true
                
                print("failed to populate loans. error: \(error?.localizedDescription)")
                
                if let completionHandler = completionHandler {
                    completionHandler(success:false, error: error)
                }
            }
            
            self.activityIndicator.stopActivityIndicator()
        }
    }
    
    
    // MARK: Core Data
    
    /*
    @brief Perform a fetch of all the loan objects in the countryLoan context. Return array of KivaLoan instances, or an empty array if no results or query failed.
    @discussion Updates the fetchedResultsController with the matching data from the core data store.
    */
    func fetchAllLoans() -> [KivaLoan]? {
        
        let error: NSErrorPointer = nil
        let fetchRequest = NSFetchRequest(entityName: KivaLoan.entityName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        var results: [AnyObject]?
        do {
            results = try CoreDataContext.sharedInstance().countryLoanContext.executeFetchRequest(fetchRequest) as? [KivaLoan]
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
}

