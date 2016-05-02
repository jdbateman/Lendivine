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
    func findRandomLoans(kivaAPI: KivaAPI, completionHandler: (success: Bool, error: NSError?, loans: [KivaLoan]?) -> Void) {
        
        print("findLoans called with nextPage = \(self.nextPageOfKivaSearchResults)")
        
        // TODO - in query below pass in nil for sector
        //_ = "na,ca,sa,af,as,me,ee,we,an,oc" // TODO: remove
        
        var countries = "TD,TG,TH,TJ,TL,TR,TZ"
        if let randomCountries = Countries.getRandomCountryCodes(30, resultType:.TwoLetterCode) {
            countries = randomCountries
        }
        
        print("calling kivaSearchLoans with countries = \(countries)")
        
        kivaAPI.kivaSearchLoans(queryMatch: nil /*"family"*/, status: KivaLoan.Status.fundraising.rawValue, gender: nil, regions: nil, countries: countries, sector: KivaAPI.LoanSector.Agriculture, borrowerType: KivaAPI.LoanBorrowerType.individuals.rawValue, maxPartnerRiskRating: KivaAPI.PartnerRiskRatingMaximum.medLow, maxPartnerDelinquency: KivaAPI.PartnerDelinquencyMaximum.medium, maxPartnerDefaultRate: KivaAPI.PartnerDefaultRateMaximum.medium, includeNonRatedPartners: true, includedPartnersWithCurrencyRisk: true, page: self.nextPageOfKivaSearchResults, perPage: LoansTableViewController.KIVA_LOAN_SEARCH_RESULTS_PER_PAGE, sortBy: KivaAPI.LoanSortBy.popularity.rawValue) {
            
            success, error, loanResults, nextPage in
            
            print("findLoans returned nextPage = \(nextPage)")
            
            if success {
                // todo: debug
                if let loanResults = loanResults {
                    var loanNames: String = ""
                    for loan in loanResults {
                        if let name = loan.name {
                            loanNames.appendContentsOf(name + ",")
                        }
                    }
                    print("loans: \(loanNames)")
                }
                
                completionHandler(success: success, error: error, loans: loanResults)
            } else {
                completionHandler(success: success, error: error, loans: nil)
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
    func findLoans(kivaAPI: KivaAPI, completionHandler: (success: Bool, error: NSError?, loans: [KivaLoan]?) -> Void) {
        
        kivaAPI.kivaSearchLoans(queryMatch: nil /*"family"*/, status: KivaLoan.Status.fundraising.rawValue, gender: nil, regions: nil, countries: nil, sector: KivaAPI.LoanSector.Agriculture, borrowerType: KivaAPI.LoanBorrowerType.individuals.rawValue, maxPartnerRiskRating: KivaAPI.PartnerRiskRatingMaximum.medLow, maxPartnerDelinquency: KivaAPI.PartnerDelinquencyMaximum.medium, maxPartnerDefaultRate: KivaAPI.PartnerDefaultRateMaximum.medium, includeNonRatedPartners: true, includedPartnersWithCurrencyRisk: true, page: self.nextPageOfKivaSearchResults, perPage: LoansTableViewController.KIVA_LOAN_SEARCH_RESULTS_PER_PAGE, sortBy: KivaAPI.LoanSortBy.popularity.rawValue) {
            
            success, error, loanResults, nextPage in
            
            print("findLoans returned nextPage = \(nextPage)")
            
            // paging
            if nextPage == -1 {
                self.navigationItem.rightBarButtonItems?[1].enabled = false
            } else {
                // save the nextPage
                self.nextPageOfKivaSearchResults = nextPage
                
                // enable the refresh button
                self.navigationItem.rightBarButtonItems?[1].enabled = true
            }
            
            if success {
                // todo: debug
                if let loanResults = loanResults {
                    var loanNames: String = ""
                    for loan in loanResults {
                        if let name = loan.name {
                            loanNames.appendContentsOf(name + ",")
                        }
                    }
                    print("loans: \(loanNames)")
                }
                
                completionHandler(success: success, error: error, loans: loanResults)
            } else {
                completionHandler(success: success, error: error, loans: nil)
            }
        }
    }
    
    // Find loans from Kiva.org and update this instance's loan collection property.
    func populateLoans(numberOfLoansToAdd: Int, completionHandler: (success: Bool, error: NSError?) -> Void) {
        if let kivaAPI = self.kivaAPI {
            self.findRandomLoans(kivaAPI) { success, error, loanResults in
                if success {
                    if let loans = loanResults {
                        
                        // just keep the first numberOfLoansToAdd loans
                        //tood - reenable? loans.removeRange(numberOfLoansToAdd..<loans.count)  // Not sure this is doing anything: todo investigate
                        
                        // todo - do i need to maintain this collection anymore?  self.loans = loans
                        
                        print("fetched loans:")
                        for loan in loans {
                            print("%@", loan.name)
                        }
                        
                        
                        // Add any newly downloaded loans to the shared context if they are not already persisted in the core data store.
                        for loan in loans where loan.id != nil {
                            if KivaLoan.fetchLoanByID2(loan.id!, context: CoreDataStackManager.sharedInstance().scratchContext) == nil {
                                
                                print("Need to add loan: %@", loan.name)
                                
                                // The following lines were causing duplicate objects to appear in core data. removing these lines results in owning the existing loan objects being upserted when saveContext is called.
                                
                                // todo duplicate loans
                                // _ = KivaLoan.init(fromLoan: loan, context: self.sharedContext)
                                
                                // Instantiate a KivaLoan in the scratchContext so the fetchResultsController will update the table view.
                                let newLoan = KivaLoan.init(fromLoan: loan, context: CoreDataStackManager.sharedInstance().scratchContext)
                                print("new loan: %@, %d", newLoan.name, newLoan.id)
                                
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
        do {
            print("saveContext: DVNViewController.saveScratchContext()")
            _ = try CoreDataStackManager.sharedInstance().scratchContext.save()
        } catch let error1 as NSError {
            error.memory = error1
            print("Error saving scratchContext: \(error)")
        }
    }

}
