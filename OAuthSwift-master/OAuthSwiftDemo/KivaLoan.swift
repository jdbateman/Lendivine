//
//  KivaLoan.swift
//  OAuthSwift
//
//  Created by john bateman on 10/29/15.
//  Copyright © 2015 Dongri Jin. All rights reserved.
//
/* example loan data: http://build.kiva.org/docs/data/loans */

import Foundation

class KivaLoan {
    
    var name: String = ""
    
    // Location
    var country: String = ""
    var geo: String = ""
    var town: String = ""
    
    var postedDate: String = ""
    var activity: String = ""
    var id: NSNumber = -1
    var use: String = ""
    var languages = [String]()
    var fundedAmount: NSNumber = 0
    var partnerID: NSNumber = -1
    
    // image
    var imageID: NSNumber = -1
    var imageTemplateID: NSNumber = -1
    
    var borrowerCount: NSNumber = 0
    var loanAmount: NSNumber = 0
    var status: String = ""
    var sector: String = ""
    
    // designated initializer
    init(dictionary: [String: AnyObject]?) {
        
        if let dictionary = dictionary {

            if let n = dictionary["name"] as? String {
                name = n
            }
            
            // location
            if let locationDict = dictionary["location"] as? [String: AnyObject] {
                if let countryName = locationDict["country"] as? String {
                    country = countryName
                }
                if let geoDict = locationDict["geo"] as? [String: AnyObject] {
                    if let coordinateString = geoDict["pairs"] as? String {
                        geo = coordinateString
                    }
                    // geoDict["level"] example value = "town"
                    // geoDict["type"] example value = "point"
                }
                if let t = locationDict["town"] as? String {
                    town = t
                }
            }
            
            if let date = dictionary["posted_date"] as? String {
                postedDate = date
            }
            if let act = dictionary["activity"] as? String {
                activity = act
            }
            if let ID = dictionary["id"] as? NSNumber {
                id = ID
            }
            if let u = dictionary["use"] as? String {
                use = u
            }
            
            // description
            if let descriptionDict = dictionary["description"] as? [String: AnyObject] {
                if let languagesArray = descriptionDict["languages"] as? [String] {
                    for language in languagesArray {
                        languages.append(language)
                    }
                }
            }
            
            if let funded = dictionary["funded_amount"] as? NSNumber {
                fundedAmount = funded
            }
            if let partnerId = dictionary["partner_id"] as? NSNumber {
                partnerID = partnerId
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

            if let count = dictionary["borrower_count"] as? NSNumber {
                borrowerCount = count
            }
            if let l = dictionary["loan_amount"] as? NSNumber {
                loanAmount = l
            }
            
            if let s = dictionary["status"] as? String {
                status = s
            }
            if let s = dictionary["sector"] as? String {
                sector = s
            }
        }
    }
    
    
}
