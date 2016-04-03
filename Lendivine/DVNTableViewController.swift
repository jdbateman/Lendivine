//
//  DVNTableViewController.swift
//  Lendivine
//
//  Created by john bateman on 4/2/16.
//  Copyright © 2016 John Bateman. All rights reserved.
//

import UIKit
import CoreData

class DVNTableViewController: UITableViewController {

    var kivaAPI: KivaAPI?
    
    var nextPageOfKivaSearchResults = 1
    
    static let KIVA_LOAN_SEARCH_RESULTS_PER_PAGE = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // OAuth with Kiva.org. Login happens on Kiva website and is redirected to Lendivine app once an OAuth access token is granted.
        //doOAuth()
        
        let kivaOAuth = KivaOAuth.sharedInstance
        self.kivaAPI = kivaOAuth.kivaAPI
    }
    
    // helper function that searches for loans
    func findLoans(kivaAPI: KivaAPI, completionHandler: (success: Bool, error: NSError?, loans: [KivaLoan]?) -> Void) {
        
        let regions = "ca,sa,af,as,me,ee,we,an,oc"
        let countries = "TD,TG,TH,TJ,TL,TR,TZ" // TODO: expand list of ocuntries or use user preferences
        kivaAPI.kivaSearchLoans(queryMatch: "family", status: KivaLoan.Status.fundraising.rawValue, gender: nil, regions: regions, countries: nil, sector: KivaAPI.LoanSector.Agriculture, borrowerType: KivaAPI.LoanBorrowerType.individuals.rawValue, maxPartnerRiskRating: KivaAPI.PartnerRiskRatingMaximum.medLow, maxPartnerDelinquency: KivaAPI.PartnerDelinquencyMaximum.medium, maxPartnerDefaultRate: KivaAPI.PartnerDefaultRateMaximum.medium, includeNonRatedPartners: true, includedPartnersWithCurrencyRisk: true, page: self.nextPageOfKivaSearchResults, perPage: LoansTableViewController.KIVA_LOAN_SEARCH_RESULTS_PER_PAGE, sortBy: KivaAPI.LoanSortBy.popularity.rawValue) {
            
            success, error, loanResults, nextPage in
            
            // paging
            if nextPage == -1 {
                // disable the refresh button
                //self.navigationItem.rightBarButtonItems?.first?.enabled = false
                self.navigationItem.rightBarButtonItems?[1].enabled = false
                //.enabled = false
            } else {
                // save the nextPage
                self.nextPageOfKivaSearchResults = nextPage
                
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
                    if var loans = loanResults {
                        
                        // just keep the first numberOfLoansToAdd loans
                        //tood - reenable? loans.removeRange(numberOfLoansToAdd..<loans.count)  // Not sure this is doing anything: todo investigate
                        
                        // todo - do i need to maintain this collection anymore?  self.loans = loans
                        
                        print("fetched loans:")
                        for loan in loans {
                            print("%@", loan.name)
                        }
                        
                        
                        // Add any newly downloaded loans to the shared context if they are not already persisted in the core data store.
                        //if let loans = loans {
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
                        //}
                        
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
    
    /* Save the data in the scrach context to the core data store on disk. */
    func saveScratchContext() {
        
        let error: NSErrorPointer = nil
        //var results: [AnyObject]?
        do {
            _ = try CoreDataStackManager.sharedInstance().scratchContext.save()
        } catch let error1 as NSError {
            error.memory = error1
            print("Error saving scratchContext: \(error)")
        }
    }
}
