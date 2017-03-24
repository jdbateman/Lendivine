//
//  CountryLoansKivaApiHelper.swift
//  Lendivine
//
//  Created by john bateman on 5/3/16.
//  Copyright © 2016 John Bateman. All rights reserved.
//
//  This class contains helpfer functions used by the CountryLoansViewController to interface with the KivaApi class.

import Foundation

class CountryLoansKivaApiHelper {
    
    // Find loans from Kiva.org and update this instance's loan collection property.
    class func populateLoansForCountry(_ numberOfLoansToAdd: Int,
        twoLetterCountryCode: String?,
        nextPage: Int,
        completionHandler: @escaping (_ success: Bool, _ error: NSError?, _ loans: [KivaLoan]?, _ nextPage: Int) -> Void) {
        
            CountryLoansKivaApiHelper.findLoansForCountry(twoLetterCountryCode, nextPage: nextPage) { success, error, loanResults, nextPage in
            
            if success {
                if let loans = loanResults {
                    completionHandler(true, nil, loans, nextPage)
                }
                else {
                    completionHandler(true, nil, nil, nextPage)
                }
            } else {
                completionHandler(false, error, nil, nextPage)
            }
        }
    }
    
    // helper function that searches for loans
    class func findLoansForCountry(_ twoLetterCountryCode: String?, nextPage: Int, completionHandler: @escaping (_ success: Bool, _ error: NSError?, _ loans: [KivaLoan]?, _ nextPage: Int) -> Void) {
        
        let kivaAPI: KivaAPI = KivaAPI.sharedInstance
        
        guard let countryCode = twoLetterCountryCode else {
            
            let error = NSError(domain: "CountryLoans", code: 994, userInfo: [NSLocalizedDescriptionKey: "missing country code"])
            completionHandler(true, error, nil, -1)
            return
        }
        
        let countries = countryCode
        
        // Lenient criteria to maximimze the possibility that any particular country will return matches.
        kivaAPI.kivaSearchLoans(queryMatch: nil, status: nil, gender: nil, regions: nil, countries: countries, sector: nil, borrowerType: KivaAPI.LoanBorrowerType.individuals.rawValue, maxPartnerRiskRating: nil, maxPartnerDelinquency: nil, maxPartnerDefaultRate: nil, includeNonRatedPartners: true, includedPartnersWithCurrencyRisk: true, page: nextPage as NSNumber?, perPage: LoansTableViewController.KIVA_LOAN_SEARCH_RESULTS_PER_PAGE as NSNumber?, sortBy: KivaAPI.LoanSortBy.popularity.rawValue, context:CoreDataContext.sharedInstance().countryLoanContext) {
            
            success, error, loanResults, nextPage in
            
            if success {
                completionHandler(success, error, loanResults, nextPage)
            } else {
                completionHandler(success, error, nil, nextPage)
            }
        }
    }
}
