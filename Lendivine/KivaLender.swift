//
//  KivaLender.swift
//  OAuthSwift
//
//  Created by john bateman on 10/29/15.
//  Copyright © 2015 John Bateman. All rights reserved.
//
//  This model class describes a lender on the kiva service.

import Foundation

class KivaLender {
    
    var countryCode: String = ""
    var inviteeCount: NSNumber = 0
    var lenderID: String = ""
    var loanBecause: String = ""
    var loanCount: NSNumber = 0
    var memberSince: String = ""
    var name: String = ""
    var occupation: String = ""
    var occupationalInfo: String = ""
    var personalUrl: String = ""
    var uid: String = ""
    var whereabouts: String = ""
    var imageID: NSNumber = -1
    var imageTemplateID: NSNumber = -1
    
    // designated initializer
    init(dictionary: [String: AnyObject]?) {
        if let dictionary = dictionary {
            if let country = dictionary["country_code"] as? String {
                countryCode = country
            }
            if let count = dictionary["invitee_count"] as? NSNumber {
                inviteeCount = count
            }
            if let liD = dictionary["lender_id"] as? String {
                lenderID = liD
            }
            if let because = dictionary["loan_because"] as? String {
                loanBecause = because
            }
            if let lcount = dictionary["loan_count"] as? NSNumber {
                loanCount = lcount
            }
            if let since = dictionary["member_since"] as? String {
                memberSince = since
            }
            if let n = dictionary["name"] as? String {
                name = n
            }
            if let oc = dictionary["occupation"] as? String {
                occupation = oc
            }
            if let occupational = dictionary["occupational_info"] as? String {
                occupationalInfo = occupational
            }
            if let personal = dictionary["personal_url"] as? String {
                personalUrl = personal
            }
            if let iD = dictionary["uid"] as? String {
                uid = iD
            }
            if let location = dictionary["whereabouts"] as? String {
                whereabouts = location
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
        }
    }
}