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
    
    /*!
        @brief Find loans from Kiva.org and save to the Core data persistant store on disk.
        @discussion The caller should refetch after calling this function. Loans found on Kiva are insantiated in the sharedContext. Updates of the persistent store are done using an internal scratch context that is reset upon completion of processing.
    */
    func populateLoans(numberOfLoansToAdd: Int, completionHandler: (success: Bool, error: NSError?) -> Void) {
        
        guard let kivaAPI = self.kivaAPI else {
            completionHandler(success: false, error: NSError(domain: "kivaAPI is nil.", code: 2019, userInfo: [NSLocalizedDescriptionKey: "kivaAPI is nil in populateLoans in DVNTableViewController."]))
            return
        }
        
        // Get a collection of loans from Kiva into the loansScratchContext, but not yet saved to disk.
        self.findLoans(kivaAPI, context: CoreDataContext.sharedInstance().loansScratchContext) {
            
            success, error, loanResults in
            
            if success {
                if let loans = loanResults {
                    for loan in loans where (loan.id != nil) && (loan.id != -1) {
                        // persist the loan
                        CoreDataLoanHelper.upsert(loan, toContext: CoreDataContext.sharedInstance().loansScratchContext2)
                    }
                    CoreDataContext.sharedInstance().loansScratchContext2.reset()
                    CoreDataContext.sharedInstance().loansScratchContext.reset()
                    completionHandler(success: true, error: nil)
                    return
                }
            }
            
            CoreDataContext.sharedInstance().loansScratchContext.reset()
            completionHandler(success: false, error: error)
        }
    }
    
    /*!
        @brief This helper function searches for loans on Kiva.org.
        @discussion KivaLoan objects are instantiated in the specified context but not saved to the persistent store.
        @return A collection of KivaLoan objects.
    */
    func findLoans(kivaAPI: KivaAPI, context: NSManagedObjectContext, completionHandler: (success: Bool, error: NSError?, loans: [KivaLoan]?) -> Void) {
        
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
                self.navigationItem.rightBarButtonItems?[1].enabled = false
            } else {
                // save the nextPage
                self.saveNextKivaPage(nextPage)
                
                // enable the refresh button
                self.navigationItem.rightBarButtonItems?[1].enabled = true
            }
            
            if success {
                completionHandler(success: success, error: error, loans: loanResults)
            } else {
                completionHandler(success: success, error: error, loans: nil)
            }
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
