//
//  KivaAPI.swift
//  OAuthSwift
//
//  Created by john bateman on 10/28/15.
//  Copyright © 2015 John Bateman. All rights reserved.
//

// TODO: API calls that support paging. set up mechanism to call to get additional pages of data. Search has been updated. Fix others.

import Foundation
import OAuthSwift
import UIKit
import CoreData

let kKivaPageSize = 20

class KivaAPI {
    
    var oAuthAccessToken: String?
    var oAuth1: OAuth1Swift?
    
    static let sharedInstance = KivaAPI()

    /* The main core data managed object context. This context will be persisted. */
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }()
    
    init() {
        oAuthAccessToken = nil
        oAuth1 = nil
    }
    
    // Enable KivaAPI calls requiring an OAuth access token.
    func setOAuthAccessToken(oAuthAccessToken: String, oAuth1: OAuth1Swift) {
        self.oAuthAccessToken = oAuthAccessToken
        self.oAuth1 = oAuth1
    }
    
    func makeKivaOAuthAPIRequest(urlOfAPI url: String, parametersDict: [String: AnyObject]?, completionHandler: (success: Bool, error: NSError?, jsonData: AnyObject?) -> Void ) {
        
        if oAuthAccessToken == nil || oAuth1 == nil {
            let vtError = VTError(errorString: "No OAuth access token.", errorCode: VTError.ErrorCodes.KIVA_OAUTH_ERROR)
            completionHandler(success: false, error: vtError.error, jsonData: nil)
            return
        }
        
        // set the oauth_token parameter. remove any existing URL encoding (% escaped characters)
        var parameters =  Dictionary<String, AnyObject>()
        parameters = [
            "oauth_token" : self.oAuthAccessToken!.stringByRemovingPercentEncoding!,
            "app_id" : Constants.OAuthValues.consumerKey
        ]
        if let newParameters = parametersDict {
            for (key,value) in newParameters {
                parameters[key] = value
            }
        }
        
        let consoleOutput = String(format: "Kiva API request: %@", url)
        print(consoleOutput)
        
        self.oAuth1!.client.get(url, parameters: parameters,
            
            success: { data, response in
                let jsonDict: AnyObject! = try? NSJSONSerialization.JSONObjectWithData(data, options: [])
                completionHandler(success: true, error: nil, jsonData: jsonDict)
            },
            
            failure: { (error:NSError!) -> Void in
                print("Kiva API request failed.")
                //print(error)
                completionHandler(success: false, error: error, jsonData: nil)
            }
        )
    }
    
    // MARK: Notifications
    
    func setupNotificationObservers() {
        
        // Add a notification observer for logout.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(KivaAPI.onLogout), name: logoutNotificationKey, object: nil)
    }
    
    /* Received a notification that logout was initiated. */
    @objc private func onLogout() {
        oAuthAccessToken = nil
    }
}

// MARK: These Convenience methods must provide an OAuth access token to the underlying KivaAPI.

extension KivaAPI {
    
    var oAuthEnabled: Bool {
        if oAuthAccessToken != nil && oAuth1 != nil {
            return true
        } else {
            return false
        }
    }
    
    func kivaOAuthGetUserAccount(completionHandler: (success: Bool, error: NSError?, userAccount: KivaUserAccount?) -> Void ) {
        if !oAuthEnabled {
            let vtError = VTError(errorString: "No OAuth access token.", errorCode: VTError.ErrorCodes.KIVA_OAUTH_ERROR)
            completionHandler(success: false, error: vtError.error, userAccount: nil)
            return
        }
        makeKivaOAuthAPIRequest(urlOfAPI: "https://api.kivaws.org/v1/my/account.json", parametersDict: nil) { success, error, jsonData in
            if success {
                
                let userAccountDict = jsonData!["user_account"] as? [String: AnyObject]
                
                let firstName = userAccountDict?["first_name"] as? String
                let lastName = userAccountDict?["last_name"] as? String
                let lenderID = userAccountDict?["lender_id"] as? String
                let id = userAccountDict?["id"] as? NSNumber
                let isPublic = userAccountDict?["is_public"] as? Bool
                let isDeveloper = userAccountDict?["is_developer"] as? Bool
                
                var dictionary = [String: AnyObject]()
                dictionary["first_name"] = firstName
                dictionary["last_name"] = lastName
                dictionary["lender_id"] = lenderID
                dictionary["id"] = id
                dictionary["is_public"] = isPublic
                dictionary["is_developer"] = isDeveloper
                
                
                let account = KivaUserAccount(dictionary: dictionary)
                
                completionHandler(success: success, error: error, userAccount: account)
            } else {
                completionHandler(success: success, error: error, userAccount: nil)
            }
        }
    }
    
    func kivaOAuthGetUserBalance(completionHandler: (success: Bool, error: NSError?, balance: String?) -> Void ) {
        if !oAuthEnabled {
            let vtError = VTError(errorString: "No OAuth access token.", errorCode: VTError.ErrorCodes.KIVA_OAUTH_ERROR)
            completionHandler(success: false, error: vtError.error, balance: nil)
            return
        }
        makeKivaOAuthAPIRequest(urlOfAPI: "https://api.kivaws.org/v1/my/balance.json", parametersDict: nil) { success, error, jsonData in
            //parse jsonData to extract user balance
            
            let userBalanceDict = jsonData!["user_balance"] as? [String: AnyObject]
            let balance = userBalanceDict?["balance"] as? String
            
            completionHandler(success: success, error: error, balance: balance)
        }
    }
    
    func kivaOAuthGetUserEmail(completionHandler: (success: Bool, error: NSError?, email: String?) -> Void ) {
        if !oAuthEnabled {
            let vtError = VTError(errorString: "No OAuth access token.", errorCode: VTError.ErrorCodes.KIVA_OAUTH_ERROR)
            completionHandler(success: false, error: vtError.error, email: nil)
            return
        }
        makeKivaOAuthAPIRequest(urlOfAPI: "https://api.kivaws.org/v1/my/email.json", parametersDict: nil) { success, error, jsonData in
            //parse jsonData to extract user email
            
            if success {
                let userEmailDict = jsonData!["user_email"] as? [String: AnyObject]
                let email = userEmailDict?["email"] as? String

                completionHandler(success: success, error: error, email: email)
            } else {
                completionHandler(success: false, error: error, email: nil)
            }
        }
    }
    
    
    func kivaOAuthGetUserExpectedRepayment(completionHandler: (success: Bool, error: NSError?, expectedRepayments: [KivaRepayment]?) -> Void ) {
        if !oAuthEnabled {
            let vtError = VTError(errorString: "No OAuth access token.", errorCode: VTError.ErrorCodes.KIVA_OAUTH_ERROR)
            completionHandler(success: false, error: vtError.error, expectedRepayments: nil)
            return
        }
        makeKivaOAuthAPIRequest(urlOfAPI: "https://api.kivaws.org/v1/my/expected_repayments.json", parametersDict: nil) { success, error, jsonData in
            
            // JSON data format:
            //{ "1685602800000": { "user_repayments": "159.01", "promo_repayments": "7.43", "loans_making_repayments": "98","repayment_date": "2015-02-01 00:00:00" } }
            
            /*
                {
                    1462086000000 =     {
                        "loans_making_repayments" = 1;
                        "promo_repayments" = "0.00";
                        "repayment_date" = "2016-05-01 00:00:00";
                        "user_repayments" = "1.97";
                    };
                    1464764400000 =     {
                        "loans_making_repayments" = 1;
                        "promo_repayments" = "0.00";
                        "repayment_date" = "2016-06-01 00:00:00";
                        "user_repayments" = "2.03";
                    };
            
                    ...
            
                    1480579200000 =     {
                        "loans_making_repayments" = 1;
                        "promo_repayments" = "0.00";
                        "repayment_date" = "2016-12-01 00:00:00";
                        "user_repayments" = "2.46";
                    };
                }
            */
            
            
            if success {
                
                var repayments = [KivaRepayment]()
                
                if let jsonData = jsonData {
                    
                    if jsonData.count > 0 {
                        
                        for (key, value) in jsonData as! [String: AnyObject] {
                            
                            if let repayment:KivaRepayment = KivaRepayment(key: key, dictionary: value as? [String: AnyObject]) {
                                repayments.append(repayment)
                            }
                        }
                    }
                }
                
                completionHandler(success: success, error: error, expectedRepayments: repayments)
            }
            else {
                completionHandler(success: success, error: error, expectedRepayments: nil)
            }
        }
    }
    
    func kivaOAuthGetLender(completionHandler: (success: Bool, error: NSError?, lender: KivaLender?) -> Void ) {
        
        if !oAuthEnabled {
            let vtError = VTError(errorString: "No OAuth access token.", errorCode: VTError.ErrorCodes.KIVA_OAUTH_ERROR)
            completionHandler(success: false, error: vtError.error, lender: nil)
            return
        }
        
        makeKivaOAuthAPIRequest(urlOfAPI: "https://api.kivaws.org/v1/my/lender.json", parametersDict: nil) { success, error, jsonData in
            
            if success {
                var lender: KivaLender? = nil
                if let jsonData = jsonData {
                    if jsonData.count > 0 {
                        // lenders is an array of dictionaries
                        if let lendersArray = jsonData["lenders"] as? [AnyObject] {
                            for lenderDict in lendersArray {
                                lender = KivaLender(dictionary: lenderDict as? [String: AnyObject])
                            }
                        }
                    }
                }
                
                completionHandler(success: success, error: error, lender: lender)
            } else {
                completionHandler(success: success, error: error, lender: nil)
            }
        }
    }
    
    func kivaOAuthGetUserLoans(page: NSNumber?, completionHandler: (success: Bool, error: NSError?, loans: [KivaLoan]?, nextPage: Int) -> Void ) {
        
        // page details
        var nextPage = -1
        var parametersDictionary = [String: AnyObject]()
        if let page = page {
            parametersDictionary["page"] = page
        }
        parametersDictionary["per_page"] = kKivaPageSize * 5 // Note: in future remove multiple on page size an turn paging on in Calling view controller.
        
        if !oAuthEnabled {
            let vtError = VTError(errorString: "No OAuth access token.", errorCode: VTError.ErrorCodes.KIVA_OAUTH_ERROR)
            completionHandler(success: false, error: vtError.error, loans: nil, nextPage: nextPage)
            return
        }
        makeKivaOAuthAPIRequest(urlOfAPI: "https://api.kivaws.org/v1/my/loans.json", parametersDict: nil) { success, error, jsonData in
            
            var loans = [KivaLoan]()  // array of KivaLoans to return
            
            if success {
                if let jsonData = jsonData {
                    if jsonData.count > 0 {
                        
                        // paging
                        if let pagingDictionary = jsonData["paging"] as? [String: AnyObject] {
                            let paging = KivaPaging(dictionary: pagingDictionary)
                            if paging.page < paging.pages {
                                nextPage = paging.page + 1
                            } else {
                                nextPage = -1
                            }
                        }
                        
                        // The jsonData contains an array of loans where each loan is described by a dictionary.
                        if let loansArray = jsonData["loans"] as? [AnyObject] {
                            for loanDict in loansArray {
                                var loan:KivaLoan?
                                if let loanDict = loanDict as? [String: AnyObject] {
                                    loan = KivaLoan(dictionary: loanDict, context:CoreDataContext.sharedInstance().myLoansContext) // self.sharedContext
                                }
                                if let loan = loan {
                                    loans.append(loan)
                                }
                            }
                        }
                    }
                }
                
                completionHandler(success: success, error: error, loans: loans, nextPage: nextPage)
            } else {
                completionHandler(success: success, error: error, loans: nil, nextPage: nextPage)
            }
        }
    }
    
    func kivaOAuthGetMyLenderStatistics(completionHandler: (success: Bool, error: NSError?, statistics: KivaLoanStatistics?) -> Void ) {
        
        if !oAuthEnabled {
            let vtError = VTError(errorString: "No OAuth access token.", errorCode: VTError.ErrorCodes.KIVA_OAUTH_ERROR)
            completionHandler(success: false, error: vtError.error, statistics: nil)
            return
        }
        makeKivaOAuthAPIRequest(urlOfAPI: "https://api.kivaws.org/v1/my/stats.json", parametersDict: nil) { success, error, jsonData in
            
            if success {
                var statistics: KivaLoanStatistics?
                
                if let jsonData = jsonData {
                    if jsonData.count > 0 {
                        
                        // The jsonData contains a dictionary of loan statistics.
                        statistics = KivaLoanStatistics(dictionary: jsonData as? [String: AnyObject])
                    }
                }
                
                completionHandler(success: success, error: error, statistics: statistics)
            } else {
                completionHandler(success: success, error: error, statistics: nil)
            }
        }
    }
    
    /*! Get the balance data for the loan identied by loanID. */
    func kivaOAuthGetLoanBalance(loanID: NSNumber, completionHandler: (success: Bool, error: NSError?, balance: KivaLoanBalance?) -> Void ) {
    
        if !oAuthEnabled {
            let vtError = VTError(errorString: "No OAuth access token.", errorCode: VTError.ErrorCodes.KIVA_OAUTH_ERROR)
            completionHandler(success: false, error: vtError.error, balance: nil)
            return
        }
        
        let requestUrl = String(format: "https://api.kivaws.org/v1/my/loans/%@/balances.json", loanID)
        
        makeKivaOAuthAPIRequest(urlOfAPI: requestUrl, parametersDict: nil) { success, error, jsonData in
            
            if success {
                var balances = [KivaLoanBalance]()
                
                if let jsonData = jsonData {
                    if jsonData.count > 0 {
                        
                        /* example json:
                            {
                                balances =     (
                                    {
                                        "amount_purchased_by_lender" = 25;
                                        "amount_purchased_by_promo" = 0;
                                        "amount_repaid_to_lender" = "9.279999999999999";
                                        "amount_repaid_to_promo" = 0;
                                        "arrears_amount" = 0;
                                        "currency_loss_to_lender" = 0;
                                        "currency_loss_to_promo" = 0;
                                        id = 965946;
                                        "latest_share_purchase_time" = 1446232901;
                                        status = "in_repayment";
                                        "total_amount_purchased" = 25;
                                    }
                                );
                            }
                        */
                        
                        if let balancesArray = jsonData["balances"] as? [AnyObject] { // or as? [[String: AnyObject]]
                            for balanceDict in balancesArray {
                                let balance = KivaLoanBalance(dictionary: balanceDict as? [String: AnyObject])
                                if balance.id == loanID {
                                    balances.append(balance)
                                }
                            }
                        }
                    }
                }
                
                var returnBalance:KivaLoanBalance? = nil
                if balances.count > 0 {
                    returnBalance = balances[0]
                }
                completionHandler(success: success, error: error, balance: returnBalance)
            } else {
                completionHandler(success: success, error: error, balance: nil)
            }
        }
    }
    
    // Note: enable paging in future
    func kivaOAuthGetMyTeams(completionHandler: (success: Bool, error: NSError?, teams: [KivaTeam]?) -> Void) {
        
        if !oAuthEnabled {
            let vtError = VTError(errorString: "No OAuth access token.", errorCode: VTError.ErrorCodes.KIVA_OAUTH_ERROR)
            completionHandler(success: false, error: vtError.error, teams: nil)
            return
        }
 
        makeKivaOAuthAPIRequest(urlOfAPI: "https://api.kivaws.org/v1/my/teams.json", parametersDict: nil /*parametersDict*/) { success, error, jsonData in
            
            if success {
                var teams = [KivaTeam]()
                
                if let jsonData = jsonData {
                    if jsonData.count > 0 {
                        
                        // teams
                        if let arrayOfTeamsDictionaries = jsonData["teams"] as? [[String: AnyObject]] {
                            
                            for team in arrayOfTeamsDictionaries {
                                let kivaTeam = KivaTeam(dictionary: team as [String: AnyObject])
                                teams.append(kivaTeam)
                            }
                        }
                    }
                }
                completionHandler(success: success, error: error, teams: teams)
            } else {
                completionHandler(success: success, error: error, teams: nil)
            }
        }
    }

/* Kiva teams JSON:
    {
        paging =     {
            page = 1;
            "page_size" = 20;
            pages = 1;
            total = 1;
        };
        teams =     (
            {
                category = "Common Interest";
                description = "We're Nerdfighters! We fight against suck; we fight for awesome! We fight using our brains, our hearts, our calculators, and our trombones.
                    \n
                    \nHappy lending!
                    \n
                    \nFollow us on twitter: https://twitter.com/KivaNerds";
                id = 394;
                image =             {
                id = 1364412;
                    "template_id" = 1;
                };
                "loan_because" = "We aim to decrease world suck.
                    \n
                    \nAnd this is how:
                    \nwww.eludehcs.no/kiva/nerdfighters/nerdfighters20120916.png by Nerdfighter Ole Bendik";
                "loan_count" = 212225;
                "loaned_amount" = 6214250;
                "member_count" = 49255;
                "membership_type" = open;
                name = Nerdfighters;
                shortname = nerdfighters;
                "team_since" = "2008-09-02T16:26:24Z";
                "website_url" = "youtube.com/vlogbrothers";
                whereabouts = Nerdfighteria;
            }
        );
    }
*/
}


// MARK: these public methods do not require the caller to provide an OAuth access token.

extension KivaAPI {

    // Note: enable paging in future
    func kivaGetPartners(completionHandler: (success: Bool, error: NSError?, partners: [KivaPartner]?) -> Void) {
        
        makeKivaOAuthAPIRequest(urlOfAPI: "http://api.kivaws.org/v1/partners.json", parametersDict: nil /*parametersDict*/) { success, error, jsonData in
            
            if success {
                var partners = [KivaPartner]()
                
                if let jsonData = jsonData {
                    if jsonData.count > 0 {
            
                        // partners
                        if let arrayOfPartnersDictionaries = jsonData["partners"] as? [[String: AnyObject]] {
                            
                            for partner in arrayOfPartnersDictionaries {
                                let kivaPartner = KivaPartner(dictionary: partner as [String: AnyObject])
                                partners.append(kivaPartner)
                            }
                        }
                    }
                }
                completionHandler(success: success, error: error, partners: partners)
            } else {
                completionHandler(success: success, error: error, partners: nil)
            }
        }
    }

/* Kiva partners JSON:
    partners =     (
        {
        "average_loan_size_percent_per_capita_income" = 0;
        "charges_fees_and_interest" = 1;
        countries = (
            {
                "iso_code" = TZ;
                location =                     {
                    geo =                         {
                        level = country;
                        pairs = "-6 35";
                        type = point;
                    };
                };
                name = Tanzania;
                region = Africa;
            },
            {
                "iso_code" = UG;
                location =                     {
                    geo =                         {
                        level = country;
                        pairs = "2 33";
                        type = point;
                    };
                };
                name = Uganda;
                region = Africa;
            },
            {
                "iso_code" = KE;
                location =                     {
                    geo =                         {
                        level = country;
                        pairs = "1 38";
                        type = point;
                    };
                };
                name = Kenya;
                region = Africa;
            }
        );
        "currency_exchange_loss_rate" = 0;
        "default_rate" = "9.1917293233083";
        "default_rate_note" = "";
        "delinquency_rate" = 0;
        "delinquency_rate_note" = "";
        id = 1;
        image =             {
            id = 58088;
            "template_id" = 1;
        };
        "loans_at_risk_rate" = 0;
        "loans_posted" = 62;
        name = "East Africa Beta";
        "portfolio_yield_note" = "";
        rating = "0.0";
        "start_date" = "2005-04-15T17:00:00Z";
        status = closed;
        "total_amount_raised" = 26600;
        }
    );
*/
    
}


// MARK: loan API convenience methods

extension KivaAPI {
    
    enum LoanStatus: String {
        case fundraising = "fundraising"
        case funded = "funded"
        case in_repayment = "in_repayment"
        case paid = "paid"
        case defaulted = "defaulted"
        case ended_with_loss = "ended_with_loss"
        case expired = "expired"
    }
    
    enum LoanGender: String {
        case male = "male"
        case female = "female"
        case all = ""
    }
    
    enum LoanRegion: String {
        case na = "na"
        case ca = "ca"
        case sa = "sa"
        case af = "af"
        case _as = "as"
        case me = "me"
        case ee = "ee"
        case we = "we"
        case an = "an"
        case oc = "oc"
    }
    
    enum LoanCountry: String {
        case AF = "AF"
        case AL = "AL"
        case AM = "AM"
        case AZ = "AZ"
        case BA = "BA"
        case BF = "BF"
        case BG = "BG"
        case BI = "BI"
        case BJ = "BJ"
        case BO = "BO"
        case BR = "BR"
        case BZ = "BZ"
        case CD = "CD"
        case CG = "CG"
        case CI = "CI"
        case CL = "CL"
        case CM = "CM"
        case CN = "CN"
        case CO = "CO"
        case CR = "CR"
        case DO = "DO"
        case EC = "EC"
        case EG = "EG"
        case GE = "GE"
        case GH = "GH"
        case GT = "GT"
        case GZ = "GZ"
        case HN = "HN"
        case HT = "HT"
        case ID = "ID"
        case IL = "IL"
        case IN = "IN"
        case IQ = "IQ"
        case JO = "JO"
        case KE = "KI"
        case KG = "KG"
        case KH = "KH"
        case LA = "LA"
        case LB = "LB"
        case LK = "LK"
        case LR = "LR"
        case LS = "LS"
        case MD = "MD"
        case MG = "MG"
        case ML = "ML"
        case MM = "MM"
        case MN = "MN"
        case MR = "MR"
        case MW = "MW"
        case MX = "MX"
        case MZ = "MZ"
        case NA = "NA"
        case NG = "NG"
        case NI = "NI"
        case NP = "NP"
        case PA = "PA"
        case PE = "PE"
        case PG = "PG"
        case PH = "PH"
        case PK = "PK"
        case PS = "PS"
        case PY = "PY"
        case QS = "QS"
        case RW = "RW"
        case SB = "SB"
        case SL = "SL"
        case SN = "SN"
        case SO = "SO"
        case SR = "SR"
        case SV = "SV"
        case TD = "TD"
        case TG = "TB"
        case TH = "TH"
        case TJ = "TJ"
        case TL = "TL"
        case TR = "TR"
        case TZ = "TZ"
        case UA = "UA"
        case UG = "UG"
        case US = "US"
        case VC = "VC"
        case VN = "VN"
        case VU = "VU"
        case WS = "WS"
        case XK = "XK"
        case YE = "YE"
        case ZA = "ZA"
        case ZM = "ZM"
        case ZW = "ZW"
    }
    
    enum LoanSector: String {
        case Agriculture = "Agriculture"
        case Arts = "Arts"
        case Clothing = "Clothing"
        case Construction = "Construction"
        case Education = "Education"
        case Entertainment = "Entertainment"
        case Food = "Food"
        case Health = "Health"
        case Housing = "Housing"
        case Manufacturing = "Manufacturing"
        case PersonalUse = "Personal Use"
        case Retail = "Retail"
        case Services = "Services"
        case Transportation = "Transportation"
        case Wholesale = "Wholesale"
    }
    
    enum LoanBorrowerType: String {
        case individuals = "individuals"
        case groups = "groups"
        case both = "both"
    }
    
    enum LoanSortBy: String {
        case popularity = "popularity"
        case loan_amount = "loan_amount"
        case expiration = "expiration"
        case newest = "newest"
        case oldest = "oldest"
        case amount_remaining = "amount_remaining"
        case repayment_term = "repayment_term"
        case random = "random"
    }
    
    enum PartnerRiskRatingMaximum: Int {
        case low = 0, medLow, medium, medHigh, High, Highest = 5
    }
    
    enum PartnerDelinquencyMaximum: Int {
        case low = 0
        case medLow = 8
        case medium = 16
        case medHigh = 24
        case High = 32
        case Highest = 41
    }
    
    enum PartnerDefaultRateMaximum: Int {
        case low = 0
        case medLow = 5
        case medium = 10
        case medHigh = 15
        case High = 20
        case Highest = 26
    }
    
    /*!
    @brief Search Kiva for loans using the specified query string parameters.
    @param (in) queryMatch - A string to match against the query results.
    @param (in) status - A comma seperated list of KivaLoan.Status enum values as a String.
    @param (in) gender - Filter results by gender. Defaults to all.
    @param (in) regions - A comma seperated list of LoanRegion values as a String.
    @param (in) countries - A comma seperated list of LoanCountries values as a String.
    @param (in) sectors - A LoanSector.
    @param (in) borrowerType - A LoanBorrowerType. Defaults to both individuals and groups.
    @param (in) maxPartnerRiskRating - A PartnerRiskRatingMaximum.
    @param (in) maxPartnerDelinquency - A PartnerDelinquencyMaximum.
    @param (in) maxPartnerDefaultRate - A PartnerDefaultRateMaximum.
    @param (in) includeNonRatedPartners - true to include, false to exclude. default = true.
    @param (in) includedPartnersWithCurrencyRisk -  true to include, false to exclude. default = true.
    @param (in) page - The page position of results to return.
    @param (in) perPage - The number of results to return for a single page.
    @param (in) sortBy - A LoanSortBy. Defaults to newest.
    @param (in) completionHandler
        success (out) true if call succeeded and image data was retrieved, else false if an error occurred.
        error (out) An NSError if an error occurred, else nil.
        loans (out) An Array of KivaLoan objects. Nil if an error occurred or no loans were found.
        nextPage (out) -1 if there is no next page, else the number of the next page of results to request.
    */
    func kivaSearchLoans(queryMatch queryMatch: String?, status: String?, gender: LoanGender?, regions: String?, countries: String?, sector: LoanSector?, borrowerType: String?, maxPartnerRiskRating: PartnerRiskRatingMaximum?, maxPartnerDelinquency: PartnerDelinquencyMaximum?, maxPartnerDefaultRate: PartnerDefaultRateMaximum?, includeNonRatedPartners: Bool?, includedPartnersWithCurrencyRisk: Bool?, page: NSNumber?, perPage: NSNumber?, sortBy: String?, context: NSManagedObjectContext, completionHandler: (success: Bool, error: NSError?, loans: [KivaLoan]?, nextPage: Int) -> Void) {
        
        var nextPage = -1
        var parametersDictionary = [String: AnyObject]()
                    
        // Validate input parameters
        if let q = queryMatch {
            parametersDictionary["query"] = q
        }
    
        if let s = status {
            parametersDictionary["status"] = s
        }
        
        if let g = gender {
            parametersDictionary["gender"] = g.rawValue
        }
        
        if let r = regions {
            parametersDictionary["region"] = r
        }
        
        if let c = countries {
            parametersDictionary["country_code"] = c
        }
                    
        if let s = sector {
            parametersDictionary["sector"] = s.rawValue
        }
        
        if let b = borrowerType {
            parametersDictionary["borrower_type"] = b
        }
                    
        if let risk = maxPartnerRiskRating {
            parametersDictionary["partner_risk_rating_max"] = risk.rawValue
        }
                    
        if let delinquency = maxPartnerDelinquency {
            parametersDictionary["partner_arrears_max"] = delinquency.rawValue
        }
                    
        if let defaultRate = maxPartnerDefaultRate {
            parametersDictionary["partner_default_max"] = defaultRate.rawValue
        }
                
        if let nonRatedPartners = includeNonRatedPartners {
            if nonRatedPartners == true {
                parametersDictionary["partner_risk_include_nonrated"] = "false"
            } else {
                parametersDictionary["partner_risk_include_nonrated"] = "true"
            }
        }
                    
        if let currencyRisk = includedPartnersWithCurrencyRisk {
            if currencyRisk == true {
                parametersDictionary["include_curr_risk"] = "false"
            } else {
                parametersDictionary["include_curr_risk"] = "true"
            }
        }
                    
        if let page = page {
            parametersDictionary["page"] = page
        }
                    
        if let perPage = perPage {
            parametersDictionary["per_page"] = perPage
        }
                    
        if let sortBy = sortBy {
            parametersDictionary["sort_by"] = sortBy
        }
                    
        makeKivaOAuthAPIRequest(urlOfAPI: "http://api.kivaws.org/v1/loans/search.json", parametersDict: parametersDictionary) { success, error, jsonData in
        
            if success {
                var loans = [KivaLoan]()
                if let jsonData = jsonData {
                    if jsonData.count > 0 {
                        
                        // loans
                        if let arrayOfPartnersDictionaries = jsonData["loans"] as? [[String: AnyObject]] {
                    
                            for loan in arrayOfPartnersDictionaries {
                                let kivaLoan = KivaLoan(dictionary: loan as [String: AnyObject], context: context)
                                
                                if kivaLoan.id != -1 {
                                    loans.append(kivaLoan)
                                } else {
                                    print("Error: http://api.kivaws.org/v1/loans/search.json returned an invalid loan")
                                }
                            }
                        }
                        
                        // paging
                        if let pagingDictionary = jsonData["paging"] as? [String: AnyObject] {
                            let paging = KivaPaging(dictionary: pagingDictionary)
                            if paging.page < paging.pages {
                                nextPage = paging.page + 1
                            } else {
                                nextPage = -1
                            }
                        }
                    }
                }
                completionHandler(success: success, error: error, loans: loans, nextPage: nextPage)
            } else {
                completionHandler(success: success, error: error, loans: nil, nextPage: nextPage)
            }
        }
    }
    
    func kivaGetNewestLoans(scratchContext: NSManagedObjectContext, completionHandler: (success: Bool, error: NSError?, loans: [KivaLoan]?) -> Void) {
        
        makeKivaOAuthAPIRequest(urlOfAPI: "http://api.kivaws.org/v1/loans/newest.json", parametersDict: nil) { success, error, jsonData in
            
            if success {
                var loans = [KivaLoan]()
                
                if let jsonData = jsonData {
                    if jsonData.count > 0 {
                        
                        // loans
                        if let arrayOfPartnersDictionaries = jsonData["loans"] as? [[String: AnyObject]] {
                            
                            for loan in arrayOfPartnersDictionaries {
                                let kivaLoan = KivaLoan(dictionary: loan as [String: AnyObject], context: scratchContext)
                                loans.append(kivaLoan)
                            }
                        }
                    }
                }
                
                completionHandler(success: success, error: error, loans: loans)
            } else {
                completionHandler(success: success, error: error, loans: nil)
            }
        }
    }
    
    func kivaGetLoans(loanIDs: [NSNumber?]?, context: NSManagedObjectContext, completionHandler: (success: Bool, error: NSError?, loans: [KivaLoan]?) -> Void) {
        
        // ensure at least one loan ID was passed in
        if loanIDs == nil || loanIDs!.count == 0 {
            let error = VTError(errorString: "No loan IDs.", errorCode: VTError.ErrorCodes.KIVA_API_NO_LOANS)
            completionHandler(success: false, error: error.error, loans: nil)
            return
        }
        
        // make a string containing the loan ids and save it in a dictionary
        var loanIDsString = ""
        if let loanIDs = loanIDs {
            for id in loanIDs{
                if let id = id {
                    let nextLoanString = id.stringValue
                    loanIDsString.appendContentsOf(String(format:"%@,",nextLoanString))
                }
            }
        }
        loanIDsString.removeAtIndex(loanIDsString.endIndex.predecessor())

        let requestUrl = String(format: "http://api.kivaws.org/v1/loans/%@.json", loanIDsString /*loanIDs![0]*/) // TODO - append all loan IDs not just the first.
        
        makeKivaOAuthAPIRequest(urlOfAPI: requestUrl, parametersDict: nil) { success, error, jsonData in
            
            if success {
                var loans = [KivaLoan]()
                
                if let jsonData = jsonData {
                    if jsonData.count > 0 {
                        
                        if let jsonLoans = jsonData["loans"] as? [[String: AnyObject]] {
                            
                            for loan in jsonLoans {
                                let kivaLoan = KivaLoan(dictionary: loan as [String: AnyObject], context: context /*self.sharedContext*/ )
                                loans.append(kivaLoan)
                            }
                        }
                    }
                }
                
                completionHandler(success: success, error: error, loans: loans)
            } else {
                completionHandler(success: success, error: error, loans: nil)
            }
        }
    }
}


// MARK: basket / cart functions

extension KivaAPI {
    
    // Assemble an HTTP POST request containing the cart in the request body.
    func getKivaCartRequest() -> NSMutableURLRequest? {
        let cart = KivaCart.sharedInstance

        if cart.count > 0 {
            /* 1. Specify parameters, method (if has {key}) */
            // none
            
            // specify base URL
            let baseURL = "http://www.kiva.org"
            
            // specify method
            let mutableMethod : String = "/basket/set"
            
            // set up http header parameters
            let headerParms = [String:AnyObject]()

            // HTTP body
            
            // using directly UTF8 encoded string
            
            var httpBody: NSData?
            var loanIDs = [NSNumber]()
            for item in cart.items {
                if let loanID = item.id {
                    loanIDs.append(loanID)
                }
            }
            if let body = createHTTPBody(loanIDs, appID: Constants.OAuthValues.consumerKey /*"com.johnbateman.awesomeapp"*/, donation: 10.00, callbackURL: nil /*"oauth-swift://oauth-callback/kiva"*/) {
                httpBody = body
            }
            
            /* 2. Make the request */
            let restClient = RESTClient()
            if let postRequest: NSMutableURLRequest = restClient.getPostRequest(baseURL, method: mutableMethod, headerParameters: headerParms, queryParameters: nil, /*jsonBody: jsonBody,*/ httpBody: httpBody) {
                
                return postRequest
            } else {
                return nil
            }
        } else  {
            return nil
        }
    }
    
    // Helper function to create http body for cart POST request given a collection of loan IDs and additional information.
    func createHTTPBody(loanIDs:[NSNumber], appID: String, donation: NSNumber?, callbackURL: String?) -> NSData? {
        
        let cart = KivaCart.sharedInstance
        var loanString = "loans=["
        
        // loans
        for item in cart.items {
            if let loanID = item.id, donationAmount = item.donationAmount where loanID.intValue > 0 {
                let loanToAdd = String(format:"{\"id\":%ld,\"amount\":%0.2f},", loanID.intValue, donationAmount.floatValue)
                loanString.appendContentsOf(loanToAdd)
            }
        }

        loanString.removeAtIndex(loanString.endIndex.predecessor())
        loanString.appendContentsOf("]")
        
        // app_id
        loanString.appendContentsOf("&app_id=" + Constants.OAuthValues.consumerKey) // ("&app_id=com.johnbateman.awesomeapp")
        
        // donation
        if let donation = donation {
            loanString.appendContentsOf(String(format:"&donation=%0.2f",donation.floatValue))
        }
        
        // callback_url
        if let callbackUrl = callbackURL {
            loanString.appendContentsOf(String(format:"&callback_url=%@",callbackUrl))
        }
        
        return loanString.dataUsingEncoding(NSUTF8StringEncoding)
    }
    
    // Check out cart via Kiva.org -> returns an NSURLMutableRequest for the kiva.org basket
    func KivaCheckout() -> NSMutableURLRequest? {
        let cart = KivaCart.sharedInstance
    
        if cart.count > 0 {
            let request: NSMutableURLRequest? = postCartToKiva(cart)
            return request
        } else  {
            return nil
        }
    }

            
    // MARK: POST Convenience Methods
    
    /*!
    @brief Post cart to Kiva.org.
    @return void
    completion handler:
        result Contains true if post was successful, else it contains false if an error occurred.
        error  An NSError object if something went wrong, else nil.
    */
    func postCartToKiva(cart: KivaCart /*, completionHandler: (result: Bool, error: NSError?) -> NSMutableURLRequest?*/) -> NSMutableURLRequest? {
        
        /* 1. Specify parameters, method (if has {key}) */
        
        // HTTP body
        var jsonBody = [String: AnyObject]()
        if cart.count > 0 {
            let serializableItems: [[String : AnyObject]] = cart.convertCartItemsToSerializableItems()
            jsonBody["loans"] = serializableItems
        }
        return nil
    }
}

// MARK: KivaAPI helper functions.

extension KivaAPI {
    
// TODO: in future use this helper to support paging for multiple calls.
//    func getPaging(jsonData: AnyObject?) -> KivaPaging? {
//        
//        if let jsonData = jsonData {
//            if jsonData.count > 0 {
//                
//                print("\(jsonData)")
//                
//                // paging
//                if let pagingDict = jsonData["paging"] as? [String: AnyObject] {
//                    
//                    let paging = KivaPaging(dictionary: pagingDict)
//                    return paging
//                    
////                    if let pg = pagingDict["page"] as? Int {
////                        page = pg
////                    }
////                    if let size = pagingDict["page_size"] as? Int {
////                        page_size = size
////                    }
////                    if let pgs = pagingDict["pages"] as? Int {
////                        pages = pgs
////                    }
////                    if let t = pagingDict["total"] as? Int {
////                        total = t
////                    }
//                }
//            }
//        }
//        
//        return nil
//    }
}

