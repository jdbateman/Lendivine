//
//  DVNTableViewController.swift
//  Lendivine
//
//  Created by john bateman on 4/2/16.
//  Copyright © 2016 John Bateman. All rights reserved.
//
//  This view controller is a base class for table view controllers. It provides helper functions that perform search queries against the kiva REST API for loans.

import UIKit
import CoreData

class DVNTableViewController: UITableViewController {

    var kivaAPI: KivaAPI?
    
    var nextPageOfKivaSearchResults = 1
    
    static let KIVA_LOAN_SEARCH_RESULTS_PER_PAGE = 20
    
    /* The main core data managed object context. This context will be persisted. */
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let kivaOAuth = KivaOAuth.sharedInstance
        self.kivaAPI = kivaOAuth.kivaAPI
    }
    
    // helper function that searches for loans
    func findLoans(kivaAPI: KivaAPI, completionHandler: (success: Bool, error: NSError?, loans: [KivaLoan]?) -> Void) {
        
        // TODO: expand loan types beyond agriculture
        
        var nextPage = self.readNextKivaPage()
        if nextPage < 1 {
            nextPage = 1 /*self.nextPageOfKivaSearchResults*/
        }

        
        kivaAPI.kivaSearchLoans(queryMatch: nil /*"family"*/, status: KivaLoan.Status.fundraising.rawValue, gender: nil, regions: nil, countries: nil, sector: nil /*KivaAPI.LoanSector.Agriculture*/, borrowerType: KivaAPI.LoanBorrowerType.individuals.rawValue, maxPartnerRiskRating: KivaAPI.PartnerRiskRatingMaximum.medLow, maxPartnerDelinquency: KivaAPI.PartnerDelinquencyMaximum.medium, maxPartnerDefaultRate: KivaAPI.PartnerDefaultRateMaximum.medium, includeNonRatedPartners: true, includedPartnersWithCurrencyRisk: true, page: nextPage, perPage: LoansTableViewController.KIVA_LOAN_SEARCH_RESULTS_PER_PAGE, sortBy: KivaAPI.LoanSortBy.popularity.rawValue, context: self.sharedContext ) {
            
            success, error, loanResults, nextPage in
            
            print("findLoans returned nextPage = \(nextPage)")
            
            // paging
            if nextPage == -1 {
                // disable the refresh button
                //self.navigationItem.rightBarButtonItems?.first?.enabled = false
                self.navigationItem.rightBarButtonItems?[1].enabled = false
                //.enabled = false
            } else {
                // save the nextPage
                //self.nextPageOfKivaSearchResults = nextPage
                self.saveNextKivaPage(nextPage)
                
                // enable the refresh button
                //self.navigationItem.rightBarButtonItems?.first?.enabled = true
                self.navigationItem.rightBarButtonItems?[1].enabled = true
                //.enabled = true
            }
            
            if success {
                // print("search loans results: \(loanResults)")
                completionHandler(success: success, error: error, loans: loanResults)
            } else {
                // print("kivaSearchLoans failed")
                completionHandler(success: success, error: error, loans: nil)
            }
        }
    }
    
    // Find loans from Kiva.org and update this instance's loan collection property.
    func populateLoans(numberOfLoansToAdd: Int, completionHandler: (success: Bool, error: NSError?) -> Void) {
        if let kivaAPI = self.kivaAPI {
            self.findLoans(kivaAPI) { success, error, loanResults in
                if success {
                    if let loans = loanResults {
                        
                        // just keep the first numberOfLoansToAdd loans
                        //todo - reenable? loans.removeRange(numberOfLoansToAdd..<loans.count)  // Not sure this is doing anything: todo investigate
                        
                        // todo - do i need to maintain this collection anymore?  self.loans = loans
                        
                        print("fetched loans:")
                        for loan in loans {
                            print("%@", loan.name)
                        }
                                                
                        // Add any newly downloaded loans to the shared context if they are not already persisted in the core data store.
                        for loan in loans where (loan.id != nil) && (loan.id != -1) {
                            
                            if KivaLoan.fetchLoanByID2(loan.id!, context: CoreDataContext.sharedInstance().scratchContext) == nil {
                                
                                print("Need to add loan: %@", loan.name)
                                
                                // The following lines were causing duplicate objects to appear in core data. removing these lines results in owning the existing loan objects being upserted when saveContext is called.
                                
                                // todo duplicate loans
                                // _ = KivaLoan.init(fromLoan: loan, context: self.sharedContext)
                                
                                // Instantiate a KivaLoan in the scratchContext so the fetchResultsController will update the table view.
                                let newLoan = KivaLoan.init(fromLoan: loan, context: CoreDataContext.sharedInstance().scratchContext)
                                print("initializing new loan in scratchContext: %@, %d", newLoan.name, newLoan.id)
                                
                                // CoreDataStackManager.sharedInstance().saveContext()
                                
                                self.saveScratchContext()
                            }
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
    
    /* Save the data in the scrach context to the core data store on disk. */
    func saveScratchContext() {
        
        let error: NSErrorPointer = nil
        //var results: [AnyObject]?
        do {
            print("saveContext: DVNTableViewController.saveScratchContext()")
            _ = try CoreDataContext.sharedInstance().scratchContext.save()
        } catch let error1 as NSError {
            error.memory = error1
            print("Error saving scratchContext: \(error)")
        }
    }
    
    
    // MARK: Manage next page
    
    func saveNextKivaPage(page:Int) {
        
        self.nextPageOfKivaSearchResults = page
        let appSettings = NSUserDefaults.standardUserDefaults()
        appSettings.setValue(page, forKey: "NextPageOfKivaSearchResults")
    }
    
    func readNextKivaPage() -> Int {
        
        let appSettings = NSUserDefaults.standardUserDefaults()
        let nextPage = appSettings.integerForKey("NextPageOfKivaSearchResults")
        return nextPage
    }
    
    func resetNextKivaPage() {
        saveNextKivaPage(1)
    }
}
