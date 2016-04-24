//
//  KivaTeam.swift
//  OAuthSwift
//
//  Created by john bateman on 11/7/15.
//  Copyright © 2015 John Bateman. All rights reserved.
//
//  This moel object describes a group of lenders that make loans in the Kiva network focussed on a specific topic.

import Foundation

class KivaTeam {
    
    var category: String = ""
    var description: String = ""
    var imageID: NSNumber = -1
    var imageTemplateID: NSNumber = -1
    var teamID: NSNumber = -1
    var loanBecause: String = ""
    var loanCount: NSNumber = 0
    var loanedAmount: NSNumber = 0
    var memberCount: NSNumber = 0
    var membershipType: String = ""
    var name: String = ""
    var shortname: String = ""
    var teamSince: String = ""
    var websiteUrl: String = ""
    var whereabouts: String = ""
    
    // designated initializer
    init(dictionary: [String: AnyObject]?) {
        if let dictionary = dictionary {
            if let cat = dictionary["category"] as? String {
                category = cat
            }
            if let desc = dictionary["description"] as? String {
                description = desc
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
            
            if let tID = dictionary["id"] as? NSNumber {
                teamID = tID
            }
            if let because = dictionary["loan_because"] as? String {
                loanBecause = because
            }
            if let lcount = dictionary["loan_count"] as? NSNumber {
                loanCount = lcount
            }
            if let amount = dictionary["loaned_amount"] as? NSNumber {
                loanedAmount = amount
            }
            if let mCount = dictionary["member_count"] as? NSNumber {
                memberCount = mCount
            }
            if let membership = dictionary["membership_type"] as? String {
                membershipType = membership
            }
            if let n = dictionary["name"] as? String {
                name = n
            }
            if let sn = dictionary["shortname"] as? String {
                shortname = sn
            }
            if let datestring = dictionary["team_since"] as? String {
                teamSince = datestring
            }
            if let url = dictionary["website_url"] as? String {
                websiteUrl = url
            }
            if let location = dictionary["whereabouts"] as? String {
                whereabouts = location
            }
        }
    }
}

