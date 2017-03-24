//
//  DVNViewController.swift
//  Lendivine
//
//  Created by john bateman on 4/2/16.
//  Copyright © 2016 John Bateman. All rights reserved.
//
//  This file implements a base class for view controllers. It provides helper functions to do search queries for loans against the kiva REST API.

import UIKit
import CoreData

class DVNViewController: UIViewController {

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
        @brief A helper function that searches for loans by randomizing the countries input to the query.
        @discussion Because the input countries vary on each call, paging does not need to be handled.
        @param (in) completionHandler
        @return 
            success true if query was successful, else false.
            error nil if query was successful and returned a valid result, else contains error information.
            loans A list of loans returned by the query, else nil if an error occurred.
    */
    func findRandomLoans(_ kivaAPI: KivaAPI, completionHandler: @escaping (_ success: Bool, _ error: NSError?, _ loans: [KivaLoan]?) -> Void) {
        
        var countries = "TD,TG,TH,TJ,TL,TR,TZ"
        if let randomCountries = Countries.getRandomCountryCodes(30, resultType:.twoLetterCode) {
            countries = randomCountries
        }
        
        kivaAPI.kivaSearchLoans(queryMatch: nil /*"family"*/, status: KivaLoan.Status.fundraising.rawValue, gender: nil, regions: nil, countries: countries, sector: KivaAPI.LoanSector.Agriculture, borrowerType: KivaAPI.LoanBorrowerType.individuals.rawValue, maxPartnerRiskRating: KivaAPI.PartnerRiskRatingMaximum.medLow, maxPartnerDelinquency: KivaAPI.PartnerDelinquencyMaximum.medium, maxPartnerDefaultRate: KivaAPI.PartnerDefaultRateMaximum.medium, includeNonRatedPartners: true, includedPartnersWithCurrencyRisk: true, page: self.nextPageOfKivaSearchResults as NSNumber?, perPage: LoansTableViewController.KIVA_LOAN_SEARCH_RESULTS_PER_PAGE as NSNumber?, sortBy: KivaAPI.LoanSortBy.popularity.rawValue, context: self.sharedContext) {
            
            success, error, loanResults, nextPage in
            
            if success {
                if let loanResults = loanResults {
                    var loanNames: String = ""
                    for loan in loanResults {
                        if let name = loan.name {
                            loanNames.append(name + ",")
                        }
                    }
                }
                
                completionHandler(success, error, loanResults)
            } else {
                completionHandler(success, error, nil)
            }
        }
    }
    
    /*!
        @brief A helper function that searches for loans across all regions and countries.
        @discussion Because the input countries vary on each call, paging does not need to be handled.
        @param (in) completionHandler
        @return
            success true if query was successful, else false.
            error nil if query was successful and returned a valid result, else contains error information.
            loans A list of loans returned by the query, else nil if an error occurred.
    */
    func findLoans(_ kivaAPI: KivaAPI, completionHandler: @escaping (_ success: Bool, _ error: NSError?, _ loans: [KivaLoan]?) -> Void) {
        
        kivaAPI.kivaSearchLoans(queryMatch: nil /*"family"*/, status: KivaLoan.Status.fundraising.rawValue, gender: nil, regions: nil, countries: nil, sector: KivaAPI.LoanSector.Agriculture, borrowerType: KivaAPI.LoanBorrowerType.individuals.rawValue, maxPartnerRiskRating: KivaAPI.PartnerRiskRatingMaximum.medLow, maxPartnerDelinquency: KivaAPI.PartnerDelinquencyMaximum.medium, maxPartnerDefaultRate: KivaAPI.PartnerDefaultRateMaximum.medium, includeNonRatedPartners: true, includedPartnersWithCurrencyRisk: true, page: self.nextPageOfKivaSearchResults as NSNumber?, perPage: LoansTableViewController.KIVA_LOAN_SEARCH_RESULTS_PER_PAGE as NSNumber?, sortBy: KivaAPI.LoanSortBy.popularity.rawValue, context: self.sharedContext) {
            
            success, error, loanResults, nextPage in
            
            // paging
            if nextPage == -1 {
                self.navigationItem.rightBarButtonItems?[1].isEnabled = false
            } else {
                // save the nextPage
                self.nextPageOfKivaSearchResults = nextPage
                
                // enable the refresh button
                self.navigationItem.rightBarButtonItems?[1].isEnabled = true
            }
            
            if success {
                if let loanResults = loanResults {
                    var loanNames: String = ""
                    for loan in loanResults {
                        if let name = loan.name {
                            loanNames.append(name + ",")
                        }
                    }
                }
                
                completionHandler(success, error, loanResults)
            } else {
                completionHandler(success, error, nil)
            }
        }
    }
    
    // Find loans from Kiva.org and update this instance's loan collection property.
    func populateLoans(_ numberOfLoansToAdd: Int, completionHandler: @escaping (_ success: Bool, _ error: NSError?) -> Void) {
        if let kivaAPI = self.kivaAPI {
            self.findRandomLoans(kivaAPI) { success, error, loanResults in
                if success {
                    if let loans = loanResults {
                        
                        // Add any newly downloaded loans to the shared context if they are not already persisted in the core data store.
                        for loan in loans where (loan.id != nil) && (loan.id != -1) {
                            if KivaLoan.fetchLoanByID2(loan.id!, context: CoreDataContext.sharedInstance().scratchContext) == nil {
                                
                                // Instantiate a KivaLoan in the scratchContext so the fetchResultsController will update the table view.
                                _ = KivaLoan.init(fromLoan: loan, context: CoreDataContext.sharedInstance().scratchContext)
                                
                                 self.saveScratchContext()
                            }
                        }
                        
                        completionHandler(true, nil)
                    }
                } else {
                    completionHandler(false, error)
                }
            }
        } else {
            print("no kivaAPI")
            completionHandler(false, nil)
        }
    }
    
    /* Save the data in the scrach context to the core data store on disk. */
    func saveScratchContext() {
        
        let error: NSErrorPointer? = nil
        do {
            _ = try CoreDataContext.sharedInstance().scratchContext.save()
        } catch let error1 as NSError {
            error??.pointee = error1
            print("Error saving scratchContext: \(error)")
        }
    }

}
