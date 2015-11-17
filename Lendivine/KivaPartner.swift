//
//  KivaPartner.swift
//  OAuthSwift
//
//  Created by john bateman on 11/7/15.
//  Copyright © 2015 John Bateman. All rights reserved.
//

import Foundation

class KivaPartner {
    
    var average_loan_size_percent_per_capita_income: NSNumber = 0
    var charges_fees_and_interest: Bool = true
    
    // countries
    var countries = [KivaCountry]()
    
    var currency_exchange_loss_rate: NSNumber = 0
    var default_rate: NSNumber = 0
    var default_rate_note: String = ""
    var delinquency_rate: NSNumber = 0
    var delinquency_rate_note: String = ""
    var id: NSNumber = 0
    
    // image
    var imageID: NSNumber = -1
    var imageTemplateID: NSNumber = -1
    
    var loans_at_risk_rate: NSNumber = 0
    var loans_posted: NSNumber = 0
    var name: String = ""
    var portfolio_yield_note: String = ""
    var profitability: NSNumber = 0
    var rating: String = ""
    var start_date: String = ""
    var status: String = ""
    var total_amount_raised: NSNumber = 0
    var url: String = ""
    
    // designated initializer
    init(dictionary: [String: AnyObject]?) {
        if let dictionary = dictionary {
            
            if let pci = dictionary["average_loan_size_percent_per_capita_income"] as? NSNumber {
                average_loan_size_percent_per_capita_income = pci
            }
            if let cfi = dictionary["charges_fees_and_interest"] as? Bool {
                charges_fees_and_interest = cfi
            }
            
            // countries
            if let countriesArray = dictionary["countries"] as? [[String: AnyObject]] {
                for countryDict in countriesArray {
                    let country = KivaCountry(dictionary:countryDict)
                    countries.append(country)
                }
            }
            
            if let celr = dictionary["currency_exchange_loss_rate"] as? NSNumber {
                currency_exchange_loss_rate = celr
            }
            if let dr = dictionary["default_rate"] as? NSNumber {
                default_rate = dr
            }
            if let drn = dictionary["default_rate_note"] as? String {
                default_rate_note = drn
            }
            if let delr = dictionary["delinquency_rate"] as? NSNumber {
                delinquency_rate = delr
            }
            if let dlrn = dictionary["delinquency_rate_note"] as? String {
                delinquency_rate_note = dlrn
            }
            if let ID = dictionary["id"] as? NSNumber {
                id = ID
            }
            
            // image
            if let imageDict = dictionary["image"] as? [String: AnyObject] {
                if let templateId = imageDict["template_id"] as? NSNumber {
                    imageTemplateID = templateId
                }
                if let imgId = imageDict["id"] as? NSNumber {
                    imageID = imgId
                }
            }
            
            if let atRisk = dictionary["loans_at_risk_rate"] as? NSNumber {
                loans_at_risk_rate = atRisk
            }
            if let posted = dictionary["loans_posted"] as? NSNumber {
                loans_posted = posted
            }
            if let n = dictionary["name"] as? String {
                name = n
            }
            if let pyn = dictionary["portfolio_yield_note"] as? String {
                portfolio_yield_note = pyn
            }
            if let profitN = dictionary["profitability"] as? NSNumber {
                profitability = profitN
            }
            if let r = dictionary["rating"] as? String {
                rating = r
            }
            if let date = dictionary["start_date"] as? String {
                start_date = date
            }
            if let s = dictionary["status"] as? String {
                status = s
            }
            if let totalAmount = dictionary["total_amount_raised"] as? NSNumber {
                total_amount_raised = totalAmount
            }
            if let link = dictionary["url"] as? String {
                url = link
            }
        }
    }
}

/* Kiva JSON for partner
    "average_loan_size_percent_per_capita_income" = 0;
    "charges_fees_and_interest" = 1;
    countries =             (
        {
            "iso_code" = PS;
            location =                     {
                geo =                         {
                    level = country;
                    pairs = "31.92157 35.203285";
                    type = point;
                };
            };
            name = Palestine;
            region = "Middle East";
        }
    );
    "currency_exchange_loss_rate" = 0;
    "default_rate" = 0;
    "default_rate_note" = "";
    "delinquency_rate" = 0;
    "delinquency_rate_note" = "";
    id = 462;
    image =             {
        id = 1969935;
        "template_id" = 1;
    };
    "loans_at_risk_rate" = 0;
    "loans_posted" = 31;
    name = "Alibdaa Microfinance";
    "portfolio_yield_note" = "";
    profitability = "-7.3";
    rating = "Not Rated";
    "start_date" = "2015-09-17T22:00:04Z";
    status = active;
    "total_amount_raised" = 38000;
    url = "http://www.alibdaa.ps";
*/