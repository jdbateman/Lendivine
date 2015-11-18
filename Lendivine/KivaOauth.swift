//
//  KivaOauth.swift
//  OAuthSwift
//
//  Created by john bateman on 10/28/15.
//  Copyright © 2015 John Bateman. All rights reserved.
//
// This class implements the client portion of the OAuth 1.0a protocol for the Kiva.org service.

import Foundation
import OAuthSwift

class KivaOAuth {
    
    var oAuthAccessToken: String?
    var oAuthSecret: String?
    
    var kivaAPI: KivaAPI?
    
    static let sharedInstance = KivaOAuth()
    
//    init() {
//
//    }
    
    func doOAuthKiva(completionHandler: (success: Bool, error: NSError?, kivaAPI: KivaAPI?) -> Void){
        
        let oauthswift = OAuth1Swift(
            consumerKey:    Kiva["consumerKey"]!,
            consumerSecret: Kiva["consumerSecret"]!,
            requestTokenUrl: "https://api.kivaws.org/oauth/request_token",
            authorizeUrl:    "https://www.kiva.org/oauth/authorize",
            accessTokenUrl:  "https://api.kivaws.org/oauth/access_token" 
        )
        
        // Request an unauthorized oauth Request Token. Upon receipt of the request token from Kiva use it to redirect to Kiva.org for user authentication and user authorization of app. If the user authorizes this app then Kiva.org redirects to the callback url below by appending an oauth_verifier code. The app will exchange the unauthorized oauth request token and oauth_verifier code for a long lived Access Token that can be used to make Kiva API calls to access protected resources.
        oauthswift.authorizeWithCallbackURL( NSURL(string: Constants.OAuthValues.consumerCallbackUrl /*"oauth-swift://oauth-callback/kiva"*/)!,
            success: { credential, response in
            
                print("oauth_token:\(credential.oauth_token)\n\noauth_token_secret:\(credential.oauth_token_secret)")
                //self.showAlertView("Kiva", message: "oauth_token:\(credential.oauth_token)\n\noauth_token_secret:\(credential.oauth_token_secret)")
                
                // TODO: securely store the access credentials

                // get the kivaAPI handle
                self.kivaAPI = KivaAPI.sharedInstance

                // Enable KivaAPI calls requiring an OAuth access token.
                KivaAPI.sharedInstance.setOAuthAccessToken(credential.oauth_token, oAuth1: oauthswift)
                
                completionHandler(success: true, error: nil, kivaAPI: self.kivaAPI)
            },
            failure: {
                
                (error:NSError!) -> Void in
                print(error.localizedDescription)
                completionHandler(success: false, error: error, kivaAPI: nil)
            }
        )
    }
    
    func testKivaAPI() {
        /*
        kivaAPI.kivaOAuthGetUserAccount() { success, error, userAccount in
        if success {
        print("success: userAccount{ name:\(userAccount?.firstName) \(userAccount?.lastName) lenderID:\(userAccount?.lenderID) id:(userAccount?.id) developer:\(userAccount?.isDeveloper) public:\(userAccount?.isPublic)}")
        } else {
        print("failed")
        }
        }
        
        kivaAPI.kivaGetUserBalance() { success, error, balance in
        if success {
        print("success: balance = \(balance)")
        } else {
        print("failed")
        }
        }
        
        kivaAPI.kivaGetUserEmail() { success, error, email in
        if success {
        print("success: email = \(email)")
        } else {
        print("failed")
        }
        }
        
        kivaAPI.kivaGetUserExpectedRepayment() { success, error, expectedRepayment in
        if success {
        print("success: expected repayment = \(expectedRepayment)")
        } else {
        print("failed")
        }
        }
        
        kivaAPI.kivaGetLender() { success, error, lender in
        if success {
        print("lender: \(lender)")
        } else {
        print("failed")
        }
        }
        
        kivaAPI.kivaGetLoans() { success, error, loans in
        if success {
        print("loans: \(loans)")
        
        if let loans = loans {
        let loan = loans.first
        let loanID = loan!.id
        
        // TODO: fix kivaGetLoanBalances
        kivaAPI.kivaGetLoanBalances(loanID) { success, error, balances in
        if success {
        print("loans: \(balances)")
        } else {
        print("failed")
        }
        }
        
        }
        } else {
        print("failed")
        }
        }
        
        kivaAPI.kivaGetMyLenderStatistics() { success, error, statistics in
        if success {
        print("statistics: \(statistics)")
        } else {
        print("failed")
        }
        }
        */
        
        //            kivaAPI.kivaGetLoanBalances() { success, error, balances in
        //                if success {
        //                    print("loans: \(balances)")
        //                } else {
        //                    print("failed")
        //                }
        //            }
        
        /*
        kivaAPI.kivaGetMyTeams() { success, error, teams in
        if success {
        if let teams = teams {
        print("teams: \(teams)")
        }
        } else {
        print("failed")
        }
        }
        
        kivaAPI.kivaGetPartners() { success, error, partners in
        if success {
        print("statistics: \(partners)")
        } else {
        print("failed")
        }
        }
        
        kivaAPI.kivaGetNewestLoans() { success, error, newestLoans in
        if success {
        print("newest loans: \(newestLoans)")
        } else {
        print("failed")
        }
        }
        
        let regions = "ca,sa,af,as,me,ee,we,an,oc"
        let countries = "TD,TG,TH,TJ,TL,TR,TZ"
        kivaAPI.kivaSearchLoans(queryMatch: "family", status: KivaAPI.LoanStatus.fundraising.rawValue, gender: nil, regions: regions, countries: nil, sector: KivaAPI.LoanSector.Agriculture, borrowerType: KivaAPI.LoanBorrowerType.individuals.rawValue, maxPartnerRiskRating: KivaAPI.PartnerRiskRatingMaximum.medLow, maxPartnerDelinquency: KivaAPI.PartnerDelinquencyMaximum.medium, maxPartnerDefaultRate: KivaAPI.PartnerDefaultRateMaximum.medium, includeNonRatedPartners: true, includedPartnersWithCurrencyRisk: true, page: 1, perPage: 20, sortBy: KivaAPI.LoanSortBy.popularity.rawValue) { success, error, loanResults in
        
        if success {
        print("search loans results: \(loanResults)")
        } else {
        print("failed")
        }
        }
        */
        //            self.testCheckout(self.kivaAPI!)
    }
    
    func testCheckout(kivaAPI: KivaAPI) {
        // search some loans
        //var loans = [KivaLoan]()
        
        findLoans(kivaAPI) { success, error, loanResults in
            if success {
                if let loans = loanResults {
                    // put the first loan into the cart
                    let loanId = loans[0].id
                    let loan = loans[0]
                    kivaAPI.KivaAddItemToCart(loan, loanID: loanId, amount: 25.00 )
                    
                    // call checkout
                    kivaAPI.KivaCheckout()
                }
                print("search loans results: \(loanResults)")
            } else {
                print("failed")
            }
        }
    }
    
    // helper function that searches for loans
    func findLoans(kivaAPI: KivaAPI, completionHandler: (success: Bool, error: NSError?, loans: [KivaLoan]?) -> Void) {
        
        let regions = "ca,sa,af,as,me,ee,we,an,oc"
        let countries = "TD,TG,TH,TJ,TL,TR,TZ"
        kivaAPI.kivaSearchLoans(queryMatch: "family", status: KivaAPI.LoanStatus.fundraising.rawValue, gender: nil, regions: regions, countries: nil, sector: KivaAPI.LoanSector.Agriculture, borrowerType: KivaAPI.LoanBorrowerType.individuals.rawValue, maxPartnerRiskRating: KivaAPI.PartnerRiskRatingMaximum.medLow, maxPartnerDelinquency: KivaAPI.PartnerDelinquencyMaximum.medium, maxPartnerDefaultRate: KivaAPI.PartnerDefaultRateMaximum.medium, includeNonRatedPartners: true, includedPartnersWithCurrencyRisk: true, page: 1, perPage: 20, sortBy: KivaAPI.LoanSortBy.popularity.rawValue) { success, error, loanResults in
            
            if success {
                // print("search loans results: \(loanResults)")
                completionHandler(success: success, error: error, loans: loanResults)
            } else {
                // print("kivaSearchLoans failed")
                completionHandler(success: success, error: error, loans: nil)
            }
        }
    }
    
//    func doOAuthKiva(){
//
//        let oauthswift = OAuth1Swift(
//            consumerKey:    Kiva["consumerKey"]!,
//            consumerSecret: Kiva["consumerSecret"]!,
//            requestTokenUrl: "https://api.kivaws.org/oauth/request_token",
//            authorizeUrl:    "https://www.kiva.org/oauth/authorize",
//            accessTokenUrl:  "https://api.kivaws.org/oauth/access_token"
//        )
//        
//        // Request an unauthorized oauth Request Token. Upon receipt of the request token from Kiva use it to redirect to Kiva.org for user authentication and user authorization of app. If the user authorizes this app then Kiva.org redirects to the callback url below by appending an oauth_verifier code. The app will exchange the unauthorized oauth request token and oauth_verifier code for a long lived Access Token that can be used to make Kiva API calls to access protected resources.
//        oauthswift.authorizeWithCallbackURL( NSURL(string: "oauth-swift://oauth-callback/kiva")!, success: {
//            credential, response in
//            
//            print("bravo. Now make a call to the Kiva api")
//            
//            print("oauth_token:\(credential.oauth_token)\n\noauth_token_secret:\(credential.oauth_token_secret)")
//            //self.showAlertView("Kiva", message: "oauth_token:\(credential.oauth_token)\n\noauth_token_secret:\(credential.oauth_token_secret)")
//            
//            // TODO: securely store the access credentials
//            
//            // TODO: make a call to a Kiva API using the access credentials.
//            
//            print("")
//            print("****************************************************************************")
//            print("Step 4: Make Kiva API request with Access Token")
//            //print("")
//            
//            let url :String = "https://api.kivaws.org/v1/my/account.json"
//            
//            // set the oauth_token parameter. remove any existing URL encoding (% escaped characters)
//            var parameters =  Dictionary<String, AnyObject>()
//            var oauthToken = credential.oauth_token
//            oauthToken = oauthToken.stringByRemovingPercentEncoding!
//            parameters = [
//                "oauth_token"    : oauthToken
//            ]
//            
//            oauthswift.client.get(url, parameters: parameters,
//                success: {
//                    data, response in
//                    print("Kiva API request succeeded.")
//                    let jsonDict: AnyObject! = try? NSJSONSerialization.JSONObjectWithData(data, options: [])
//                    print(jsonDict)
//                }, failure: {(error:NSError!) -> Void in
//                    print("Kiva API request failed.")
//                    print(error)
//            })
//            }, failure: {(error:NSError!) -> Void in
//                print(error.localizedDescription)
//            }
//        )
//    }
}