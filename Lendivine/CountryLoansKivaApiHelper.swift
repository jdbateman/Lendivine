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
    class func populateLoansForCountry(numberOfLoansToAdd: Int,
        twoLetterCountryCode: String?,
        nextPage: Int,
        completionHandler: (success: Bool, error: NSError?, loans: [KivaLoan]?, nextPage: Int) -> Void) {
        
            CountryLoansKivaApiHelper.findLoansForCountry(twoLetterCountryCode, nextPage: nextPage) { success, error, loanResults, nextPage in
            
            if success {
                if let loans = loanResults {
                    completionHandler(success: true, error: nil, loans: loans, nextPage: nextPage)
                }
                else {
                    completionHandler(success: true, error: nil, loans: nil, nextPage: nextPage)
                }
            } else {
                completionHandler(success: false, error: error, loans: nil, nextPage: nextPage)
            }
        }
    }
    
    // helper function that searches for loans
    class func findLoansForCountry(twoLetterCountryCode: String?, nextPage: Int, completionHandler: (success: Bool, error: NSError?, loans: [KivaLoan]?, nextPage: Int) -> Void) {
        
        let kivaAPI: KivaAPI = KivaAPI.sharedInstance
        
        guard let countryCode = twoLetterCountryCode else {
            
            let error = NSError(domain: "CountryLoans", code: 994, userInfo: [NSLocalizedDescriptionKey: "missing country code"])
            completionHandler(success: true, error: error, loans: nil, nextPage: -1)
            return
        }
        
        let countries = countryCode
        
        // Lenient criteria to maximimze the possibility that any particular country will return matches.
        kivaAPI.kivaSearchLoans(queryMatch: nil, status: nil, gender: nil, regions: nil, countries: countries, sector: nil, borrowerType: KivaAPI.LoanBorrowerType.individuals.rawValue, maxPartnerRiskRating: nil, maxPartnerDelinquency: nil, maxPartnerDefaultRate: nil, includeNonRatedPartners: true, includedPartnersWithCurrencyRisk: true, page: nextPage, perPage: LoansTableViewController.KIVA_LOAN_SEARCH_RESULTS_PER_PAGE, sortBy: KivaAPI.LoanSortBy.popularity.rawValue, context:CoreDataContext.sharedInstance().countryLoanContext) {
            
            success, error, loanResults, nextPage in
            
            if success {
                completionHandler(success: success, error: error, loans: loanResults, nextPage: nextPage)
            } else {
                completionHandler(success: success, error: error, loans: nil, nextPage: nextPage)
            }
        }
    }
}