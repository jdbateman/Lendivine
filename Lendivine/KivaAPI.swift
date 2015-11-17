//
//  KivaAPI.swift
//  OAuthSwift
//
//  Created by john bateman on 10/28/15.
//  Copyright © 2015 John Bateman. All rights reserved.
//

// TODO: API calls that support paging. set up mechanism to call to get additional pages of data

import Foundation
import OAuthSwift
import UIKit

class KivaAPI {
    
    var oAuthAccessToken: String?
    var oAuth1: OAuth1Swift?
    
    static let sharedInstance = KivaAPI()
    
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
        }
        
        // set the oauth_token parameter. remove any existing URL encoding (% escaped characters)
        var parameters =  Dictionary<String, AnyObject>()
        parameters = [
            "oauth_token" : self.oAuthAccessToken!.stringByRemovingPercentEncoding!,
            "app_id" : "com.johnbateman.awesomeapp"
        ]
        if let newParameters = parametersDict {
            for (key,value) in newParameters {
                parameters[key] = value
            }
        }
        
        let consoleOutput = String(format: "\n***** Kiva API request: %@ *****\n", url)
        print(consoleOutput)
        
        self.oAuth1!.client.get(url,
            parameters: parameters,
            success: { data, response in
                print("Kiva API request succeeded.")
                let jsonDict: AnyObject! = try? NSJSONSerialization.JSONObjectWithData(data, options: [])
                if let jsonDict = jsonDict {
                    print(jsonDict)
                }
                completionHandler(success: true, error: nil, jsonData: jsonDict)
            },
            failure: { (error:NSError!) -> Void in
                print("Kiva API request failed.")
                print(error)
                completionHandler(success: false, error: error, jsonData: nil)
            }
        )
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
        }
        makeKivaOAuthAPIRequest(urlOfAPI: "https://api.kivaws.org/v1/my/account.json", parametersDict: nil) { success, error, jsonData in
            if success {
                
                //TODO - instead of rebuilding a separate dictionary, pass the userAccountDict directly to the KivaUserAccount initializer.
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
        }
        makeKivaOAuthAPIRequest(urlOfAPI: "https://api.kivaws.org/v1/my/balance.json", parametersDict: nil) { success, error, jsonData in
            //parse jsonData to extract user balance
//            let userBalance = jsonData?.valueForKey("user_balance") as? NSDictionary
//            let balance = userBalance?.valueForKey("balance") as? String
            
            let userBalanceDict = jsonData!["user_balance"] as? [String: AnyObject]
            let balance = userBalanceDict?["balance"] as? String
            
            completionHandler(success: success, error: error, balance: balance)
        }
    }
    
    func kivaOAuthGetUserEmail(completionHandler: (success: Bool, error: NSError?, email: String?) -> Void ) {
        if !oAuthEnabled {
            let vtError = VTError(errorString: "No OAuth access token.", errorCode: VTError.ErrorCodes.KIVA_OAUTH_ERROR)
            completionHandler(success: false, error: vtError.error, email: nil)
        }
        makeKivaOAuthAPIRequest(urlOfAPI: "https://api.kivaws.org/v1/my/email.json", parametersDict: nil) { success, error, jsonData in
            //parse jsonData to extract user email
//            let userEmail = jsonData?.valueForKey("user_email") as? NSDictionary
//            let email = userEmail?.valueForKey("email") as? String
            
            let userEmailDict = jsonData!["user_email"] as? [String: AnyObject]
            let email = userEmailDict?["email"] as? String

            completionHandler(success: success, error: error, email: email)
        }
    }
    
    
    func kivaOAuthGetUserExpectedRepayment(completionHandler: (success: Bool, error: NSError?, expectedRepayment: String?) -> Void ) {
        if !oAuthEnabled {
            let vtError = VTError(errorString: "No OAuth access token.", errorCode: VTError.ErrorCodes.KIVA_OAUTH_ERROR)
            completionHandler(success: false, error: vtError.error, expectedRepayment: nil)
        }
        makeKivaOAuthAPIRequest(urlOfAPI: "https://api.kivaws.org/v1/my/expected_repayments.json", parametersDict: nil) { success, error, jsonData in
            //parse jsonData to extract repayment information
            
            // JSON data format:
            //{ "1685602800000": { "user_repayments": "159.01", "promo_repayments": "7.43", "loans_making_repayments": "98","repayment_date": "2015-02-01 00:00:00" } }
            
            //TODO: update parsing code when I get some real repayment data in my account
            if let jsonData = jsonData {
                if jsonData.count > 0 {
                    print("\(jsonData)")
                    for (key, value) in jsonData as! [String: AnyObject] {
                        if let dict = value as? [String: AnyObject] {
                            let userRepayments = dict["user_repayments"] as? String
                            let promoRepayments = dict["promo_repayments"] as? String
                            let loansMakingRepayments = dict["loans_making_repayments"] as? String
                            let repaymentDate = dict["repayment_date"] as? String
                            
                            print("loan: \(userRepayments) \(promoRepayments) \(loansMakingRepayments) \(repaymentDate)")
                        }
                    }
    //            let paymentsDict = jsonData!["user_email"] as? [String: AnyObject]
    //            let expectedRepayment = paymentsDict?["email"] as? String
                }
            }
            
            completionHandler(success: success, error: error, expectedRepayment: "") //TODO - return string
        }
    }
    
    func kivaOAuthGetLender(completionHandler: (success: Bool, error: NSError?, lender: KivaLender?) -> Void ) {
        if !oAuthEnabled {
            let vtError = VTError(errorString: "No OAuth access token.", errorCode: VTError.ErrorCodes.KIVA_OAUTH_ERROR)
            completionHandler(success: false, error: vtError.error, lender: nil)
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
    
    func kivaOAuthGetLoans(completionHandler: (success: Bool, error: NSError?, loans: [KivaLoan]?) -> Void ) {
        
        // page details
        var page = 0
        var page_size = 20
        var pages = 0
        var total = 0
        
        // TODO: add ability to pass paging parameters into the API request to enable iteration through multiple pages of data.
        
        if !oAuthEnabled {
            let vtError = VTError(errorString: "No OAuth access token.", errorCode: VTError.ErrorCodes.KIVA_OAUTH_ERROR)
            completionHandler(success: false, error: vtError.error, loans: nil)
        }
        makeKivaOAuthAPIRequest(urlOfAPI: "https://api.kivaws.org/v1/my/loans.json", parametersDict: nil) { success, error, jsonData in
            
            var loans = [KivaLoan]()  // array of KivaLoans to return
            
            if success {
                if let jsonData = jsonData {
                    if jsonData.count > 0 {
                        
                        print("\(jsonData)")
                        
                        // paging
                        if let pagingDict = jsonData["paging"] as? [String: AnyObject] {
                            if let pg = pagingDict["page"] as? Int {
                                page = pg
                            }
                            if let size = pagingDict["page_size"] as? Int {
                                page_size = size
                            }
                            if let pgs = pagingDict["pages"] as? Int {
                                pages = pgs
                            }
                            if let t = pagingDict["total"] as? Int {
                                total = t
                            }
                        }
                        
                        // The jsonData contains an array of loans where each loan is described by a dictionary.
                        if let loansArray = jsonData["loans"] as? [AnyObject] {
                            for loanDict in loansArray {
                                let loan = KivaLoan(dictionary: loanDict as? [String: AnyObject])
                                loans.append(loan)
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
    
    func kivaOAuthGetMyLenderStatistics(completionHandler: (success: Bool, error: NSError?, statistics: KivaLoanStatistics?) -> Void ) {
        
        if !oAuthEnabled {
            let vtError = VTError(errorString: "No OAuth access token.", errorCode: VTError.ErrorCodes.KIVA_OAUTH_ERROR)
            completionHandler(success: false, error: vtError.error, statistics: nil)
        }
        makeKivaOAuthAPIRequest(urlOfAPI: "https://api.kivaws.org/v1/my/stats.json", parametersDict: nil) { success, error, jsonData in
            
            if success {
                var statistics: KivaLoanStatistics?
                
                if let jsonData = jsonData {
                    if jsonData.count > 0 {
                        
                        print("\(jsonData)")
                        
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
    
    // TODO: Post to Kiva support. getting 404 no matter what parameters are.
    func kivaOAuthGetLoanBalances(loanID: NSNumber, completionHandler: (success: Bool, error: NSError?, balances: [String]? /*TODO: change type*/) -> Void ) {
    
        var parametersDict = [/*"ids": 965946, "app_id": "com.johnbateman.awesomeapp"*/] //TODO: ["ids": loanID]
        
        if !oAuthEnabled {
            let vtError = VTError(errorString: "No OAuth access token.", errorCode: VTError.ErrorCodes.KIVA_OAUTH_ERROR)
            completionHandler(success: false, error: vtError.error, balances: nil)
        }
        makeKivaOAuthAPIRequest(urlOfAPI: "https://api.kivaws.org/v1/my/loans/:ids/balances.json", parametersDict: nil /*parametersDict*/) { success, error, jsonData in
            
            if success {
                var balances = [String]() //TODO: change type of array
                
                if let jsonData = jsonData {
                    if jsonData.count > 0 {
                        
                        print("\(jsonData)")
                        
                        // The jsonData contains a dictionary of loan statistics.
//                        statistics = KivaLoanBalance(dictionary: jsonData as? [String: AnyObject])
                    }
                }
                
                completionHandler(success: success, error: error, balances: balances)
            } else {
                completionHandler(success: success, error: error, balances: nil)
            }
        }
    }
    
    func kivaOAuthGetMyTeams(completionHandler: (success: Bool, error: NSError?, teams: [KivaTeam]?) -> Void) {

        // page details
        var page = 0
        var page_size = 20
        var pages = 0
        var total = 0
        
        if !oAuthEnabled {
            let vtError = VTError(errorString: "No OAuth access token.", errorCode: VTError.ErrorCodes.KIVA_OAUTH_ERROR)
            completionHandler(success: false, error: vtError.error, teams: nil)
        }
 
        makeKivaOAuthAPIRequest(urlOfAPI: "https://api.kivaws.org/v1/my/teams.json", parametersDict: nil /*parametersDict*/) { success, error, jsonData in
            
            if success {
                var teams = [KivaTeam]()
                
                if let jsonData = jsonData {
                    if jsonData.count > 0 {
                        
                        print("teams: \(jsonData)")
                        
                        // paging
                        if let pagingDict = jsonData["paging"] as? [String: AnyObject] {
                            if let pg = pagingDict["page"] as? Int {
                                page = pg
                            }
                            if let size = pagingDict["page_size"] as? Int {
                                page_size = size
                            }
                            if let pgs = pagingDict["pages"] as? Int {
                                pages = pgs
                            }
                            if let t = pagingDict["total"] as? Int {
                                total = t
                            }
                        }
                        
                        // teams
                        if let arrayOfTeamsDictionaries = jsonData["teams"] as? [[String: AnyObject]] {
                            print("teams: \(arrayOfTeamsDictionaries)")
                            
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
    
    func kivaGetPartners(completionHandler: (success: Bool, error: NSError?, partners: [KivaPartner]?) -> Void) {
        
        // page details
        var page = 0
        var page_size = 20
        var pages = 0
        var total = 0
        
        makeKivaOAuthAPIRequest(urlOfAPI: "http://api.kivaws.org/v1/partners.json", parametersDict: nil /*parametersDict*/) { success, error, jsonData in
            
            if success {
                var partners = [KivaPartner]()
                
                if let jsonData = jsonData {
                    if jsonData.count > 0 {
                        print("partners: \(jsonData)")
            
                        // paging
                        if let pagingDict = jsonData["paging"] as? [String: AnyObject] {
                                if let pg = pagingDict["page"] as? Int {
                                page = pg
                                }
                                if let size = pagingDict["page_size"] as? Int {
                                        page_size = size
                                }
                                if let pgs = pagingDict["pages"] as? Int {
                            pages = pgs
                                }
                                if let t = pagingDict["total"] as? Int {
                                    total = t
                                }
                        }
            
                        // partners
                        if let arrayOfPartnersDictionaries = jsonData["partners"] as? [[String: AnyObject]] {
                            print("partners: \(arrayOfPartnersDictionaries)")
                            
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
    
    func kivaGetNewestLoans(completionHandler: (success: Bool, error: NSError?, loans: [KivaLoan]?) -> Void) {
    
        makeKivaOAuthAPIRequest(urlOfAPI: "http://api.kivaws.org/v1/loans/newest.json", parametersDict: nil /*parametersDict*/) { success, error, jsonData in
            
            if success {
            var loans = [KivaLoan]()
            
            if let jsonData = jsonData {
                if jsonData.count > 0 {
                    print("newest loans: \(jsonData)")
                    
                    // loans
                    if let arrayOfPartnersDictionaries = jsonData["loans"] as? [[String: AnyObject]] {
                        print("partners: \(arrayOfPartnersDictionaries)")
                        
                        for loan in arrayOfPartnersDictionaries {
                        let kivaLoan = KivaLoan(dictionary: loan as [String: AnyObject])
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
    @param (in) status - A comma seperated list of LoanStatus values as a String.
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
    */
    func kivaSearchLoans(queryMatch queryMatch: String?, status: String?, gender: LoanGender?, regions: String?, countries: String?, sector: LoanSector?, borrowerType: String?, maxPartnerRiskRating: PartnerRiskRatingMaximum?, maxPartnerDelinquency: PartnerDelinquencyMaximum?, maxPartnerDefaultRate: PartnerDefaultRateMaximum?, includeNonRatedPartners: Bool?, includedPartnersWithCurrencyRisk: Bool?, page: NSNumber?, perPage: NSNumber?, sortBy: String?, completionHandler: (success: Bool, error: NSError?, loans: [KivaLoan]?) -> Void) {
        
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
                    
        print("\n***** http://api.kivaws.org/v1/loans/search.json *****\n")
                
        makeKivaOAuthAPIRequest(urlOfAPI: "http://api.kivaws.org/v1/loans/search.json", parametersDict: parametersDictionary) { success, error, jsonData in
        
            if success {
                var loans = [KivaLoan]()
                if let jsonData = jsonData {
                    if jsonData.count > 0 {
                        print("search loans results: \(jsonData)")
                            
                        // loans
                        if let arrayOfPartnersDictionaries = jsonData["loans"] as? [[String: AnyObject]] {
                            print("partners: \(arrayOfPartnersDictionaries)")
                    
                            for loan in arrayOfPartnersDictionaries {
                                let kivaLoan = KivaLoan(dictionary: loan as [String: AnyObject])
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
    
    // Add an item to the cart.
    func KivaAddItemToCart(loan: KivaLoan?, loanID: NSNumber?, amount: NSNumber?) {
        if let loan = loan {
            if let loanID = loanID {
                if let amount = amount {
                    let cart = KivaCart.sharedInstance
                    let item = KivaCartItem(loan: loan, loanID: loanID, amount: amount)
                    if !cart.items.contains(item) {
                        cart.add(item)
                        print("Added item to cart with loan Id: \(loanID) in amount: \(amount)")
                    } else {
                        print("Item not added to cart. The cart already contains loanId: \(loanID)")
                    }
                    print("cart = \(cart.count) [KivaAddItemToCart]")
                }
            }
        }
    }
    
    // Assemble an HTTP POST request containing the cart in the request body.
    func getKivaCartRequest() -> NSMutableURLRequest? {
        let cart = KivaCart.sharedInstance

        print("cart = \(cart.count) [getKivaCartRequest begin]")
        
        if cart.count > 0 {
            /* 1. Specify parameters, method (if has {key}) */
            // none
            
            // specify base URL
            let baseURL = "http://www.kiva.org" // TODO: make a constant in RESTClient.Constants.kivaBaseURL
            
            // specify method
            var mutableMethod : String = "/basket/set" // TODO: make a constant in RESTClient.Constants.parseGetStudentLocations
            
            // set up http header parameters
            let headerParms = [String:AnyObject]() /*[
            Constants.ParseAppID : "X-Parse-Application-Id",
            Constants.ParseApiKey : "X-Parse-REST-API-Key"
            ]*/
            
            // HTTP body
            
            // using directly UTF8 encoded string
            
            var httpBody: NSData?
            var loanIDs = [NSNumber]()
            //let loanIDs = [974236, 961687, 961683, 974236, 973680] // [961687, 961683, 974236, 973680, 974236]
            for item in cart.items {
                loanIDs.append(item.loanID)
            }
            if let body = createHTTPBody(loanIDs, appID: "com.johnbateman.awesomeapp", donation: 10.00, callbackURL: nil /*"oauth-swift://oauth-callback/kiva"*/) {
                httpBody = body
            }
            
            // using JSON approach
//            var jsonBody = [String: AnyObject]()
//
//            if cart.count > 0 {
//                let serializableItems: [[String : AnyObject]] = cart.convertCartItemsToSerializableItems()
//                jsonBody["loans"] = serializableItems
//            }
//            jsonBody["app_id"] = "com.johnbateman.awesomeapp"
//            jsonBody["donation"] = "10.00"
////            jsonBody["callback_url"] = "oauth-swift://oauth-callback/kiva" // TODO - differentiate this url from oauth callback url
//            
//            // TODO: test hardcode of loans
////            jsonBody["loans"] =  String(format: "[{%@:958201,%@:25}]","id", "amount") // "[{\"id\":958201,\"amount\":25}]"
            
            /* 2. Make the request */
            let restClient = RESTClient()
            if let postRequest: NSMutableURLRequest = restClient.getPostRequest(baseURL, method: mutableMethod, headerParameters: headerParms, queryParameters: nil, /*jsonBody: jsonBody,*/ httpBody: httpBody) {
                
                print("cart = \(cart.count) [getKivaCartRequest end]")

                return postRequest
            } else {
                print("cart = \(cart.count) [getKivaCartRequest end]")

                return nil
            }
        } else  {
            print("cart = \(cart.count) [getKivaCartRequest end]")

            return nil
        }
    }
    
    // Helper function to create http body for cart POST request given a collection of loan IDs and additional information.
    func createHTTPBody(loanIDs:[NSNumber], appID: String, donation: NSNumber?, callbackURL: String?) -> NSData? {
        
        let cart = KivaCart.sharedInstance
        var loanString = "loans=["
        
        //        var loanString = String(format:"loans=[{\"id\":%ld,\"amount\":25}]&app_id=com.johnbateman.awesomeapp&donation=%0.2f&callback_url=oauth-swift://oauth-callback/kiva",958718,10.00)
        
        // loans
        for item in cart.items {
            if item.loanID.intValue > 0 {
                let loanToAdd = String(format:"{\"id\":%ld,\"amount\":%0.2f},", item.loanID.intValue, item.amount.floatValue)
                loanString.appendContentsOf(loanToAdd)
            }
        }
//        for id in loanIDs {
//            if id.intValue > 0 {
//                let loanToAdd = String(format:"{\"id\":%ld,\"amount\":25},", id.intValue) // TODO: need to pass in amount for each loan individually
//                loanString.appendContentsOf(loanToAdd)
//            }
//        }
        loanString.removeAtIndex(loanString.endIndex.predecessor())
        loanString.appendContentsOf("]")
        
        // app_id
        loanString.appendContentsOf("&app_id=com.johnbateman.awesomeapp")
        
        // donation
        if let donation = donation {
            loanString.appendContentsOf(String(format:"&donation=%0.2f",donation.floatValue))
        }/* else {
        loanString.append("&donation=0.00")
        }*/
        
        // callback_url
        if let callbackUrl = callbackURL {
            loanString.appendContentsOf(String(format:"&callback_url=%@",callbackUrl))
        }
        
        print("\(loanString)")
        
        print("cart = \(cart.count) [createHTTPBody]")

        return loanString.dataUsingEncoding(NSUTF8StringEncoding)
        
    }
    
    // TODO - Check out cart via Kiva.org -> returns an NSURLMutableRequest for the kiva.org basket
    func KivaCheckout() -> NSMutableURLRequest? {
        let cart = KivaCart.sharedInstance
    
        if cart.count > 0 {
//            let jsonCart: NSData? = cart.getJSONData()
            print("\n***** http://www.kiva.org/basket/set *****\n")
            let request: NSMutableURLRequest? = postCartToKiva(cart)
            return request
            
//            { success, error in
//                if success {
//                    print("cart successfully posted to kiva.org")
//                } else {
//                    print("error post cart to kiva.org: \(error)")
//                }
//            }
            
//            makeKivaAPIRequest(urlOfAPI: "http://www.kiva.org/basket/set", parametersDict: parametersDictionary) { success, error, jsonData in
//                if success {
//                    var loans = [KivaLoan]()
//                    if let jsonData = jsonData {
//                        if jsonData.count > 0 {
//                            print("search loans results: \(jsonData)")
//                            
//                            // loans
//                            if let arrayOfPartnersDictionaries = jsonData["loans"] as? [[String: AnyObject]] {
//                                print("partners: \(arrayOfPartnersDictionaries)")
//                        
//                                for loan in arrayOfPartnersDictionaries {
//                                    let kivaLoan = KivaLoan(dictionary: loan as [String: AnyObject])
//                                    loans.append(kivaLoan)
//                                }
//                            }
//                        }
//                    }
//                    completionHandler(success: success, error: error, loans: loans)
//                } else {
//                    completionHandler(success: success, error: error, loans: nil)
//                }
//            }
        } else  {
            return nil
        }
    }

            
    // MARK: POST Convenience Methods
    
    /*
    @brief Post cart to Kiva.org.
    @return void
    completion handler:
        result Contains true if post was successful, else it contains false if an error occurred.
        error  An error if something went wrong, else nil.
    */
    func postCartToKiva(cart: KivaCart /*, completionHandler: (result: Bool, error: NSError?) -> NSMutableURLRequest?*/) -> NSMutableURLRequest? {
        
        /* 1. Specify parameters, method (if has {key}) */
        // none
        
        // specify base URL
        let baseURL = "http://www.kiva.org" // TODO: make a constant in RESTClient.Constants.kivaBaseURL
        
        // specify method
        var mutableMethod : String = "/basket/set" // TODO: make a constant in RESTClient.Constants.parseGetStudentLocations
        
        // set up http header parameters
        let headerParms = [String:AnyObject]() /*[
            Constants.ParseAppID : "X-Parse-Application-Id",
            Constants.ParseApiKey : "X-Parse-REST-API-Key"
        ]*/
        
        // HTTP body
        var jsonBody = [String: AnyObject]()
        if cart.count > 0 {
            let serializableItems: [[String : AnyObject]] = cart.convertCartItemsToSerializableItems()
            jsonBody["loans"] = serializableItems

//            if let cartJsonData: NSData? = cart.getJSONData() {
//                jsonBody["loans"] = cartJsonData
//            }
        }
        print("cart = \(cart.items.count) [postCartToKiva]")
        return nil
        
        
        /* 2. Make the request */
        
        // TODO - if you want to use this function need to add NSData parameter to the end of the estClient.getPostRequest because we are not sending json mime type anymore.
//        let restClient = RESTClient()
//        if let postRequest: NSMutableURLRequest = restClient.getPostRequest(baseURL, method: mutableMethod, headerParameters: headerParms, queryParameters: nil, jsonBody: jsonBody) {
//            
//            return postRequest
//            
//            
////            /* 3. Send the desired value(s) to completion handler */
////            if let error = error {
////                completionHandler(result: false, error: error)
////            } else {
////                // parse the json response which looks like the following:
////                /*
////                {
////                "createdAt":"2015-03-11T02:48:18.321Z",
////                "objectId":"CDHfAy8sdp"
////                }
////                */
////                if let errorString = JSONResult.valueForKey("error") as? String {
////                    // a valid response was received from the service, but the response contains an error code like the following:
////                    /*
////                    {
////                    code = 142
////                    error = "uniqueKey is required for a Student Location"
////                    }
////                    */
////                    let error = NSError(domain: "Parse POST response", code: 0, userInfo: [NSLocalizedDescriptionKey: errorString])
////                    completionHandler(result: false, error: error)
////                } else {
////                    if let dictionary = JSONResult.valueForKey("objectId") as? String {
////                        completionHandler(result: true, error: nil)
////                    } else {
////                        completionHandler(result: false, error: NSError(domain: "parsing Parse POST response", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse postToFavoritesList"]))
////                    }
////                }
////            }
//        }
//        else {
//            return nil
//        }
    }

    /* Display url in an embeded webkit browser. */
/*
    
    func showEmbeddedBrowser(request: NSMutableURLRequest) {
        var controller = CartViewController()
//        var storyboard = UIStoryboard (name: "Main", bundle: nil)
//        var controller = storyboard.instantiateViewControllerWithIdentifier("WebSearchStoryboardID") as! WebSearchViewController
        controller.initialURL = url
        controller.webViewDelegate = self
        self.presentViewController(controller, animated: true, completion: nil);
    }
    func createCartViewController() {
        let controller = WebViewController()
        controller.view = UIView(frame: CGRect(x:0, y:0, width: 450, height: 500)) // needed if no nib or not loaded from storyboard
        controller.viewDidLoad()
        self.addChildViewController(controller)
    }
*/    
    
//    TODO - this is a data class. Need to move this logic to a view class and create a view controller for the web view. Look at code in OnTheMap.
//    
//    /* Create a UIWebView the size of the screen and set it's delegate to this view controller. */
//    func showWebView(request: NSURLRequest?) {
//        let webView:UIWebView = UIWebView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height))
//        webView.delegate = self
//        if let url = url {
//            webView.loadRequest(request)
//            self.view.addSubview(webView)
//        }
//    }
    

    
//    func get_url_handler() -> OAuthSwiftURLHandlerType {
//        // Create a WebViewController with default behaviour from OAuthWebViewController
//        let controller = createWebViewController()
//        self.addChildViewController(controller) // allow WebViewController to use this ViewController as parent to be presented
//        return controller
//    }
}

