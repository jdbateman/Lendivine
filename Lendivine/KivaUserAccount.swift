//
//  KivaUserAccount.swift
//  OAuthSwift
//
//  Created by john bateman on 10/29/15.
//  Copyright © 2015 John Bateman. All rights reserved.
//

import Foundation

class KivaUserAccount {
    
    var firstName: String = ""
    var lastName: String = ""
    var lenderID: String = ""
    var id: NSNumber = -1
    var isPublic: Bool = false
    var isDeveloper: Bool = false
    
    // designated initializer
    init(dictionary: [String: AnyObject]?) {
        if let dictionary = dictionary {
            if let fname = dictionary["first_name"] as? String {
                firstName = fname
            }
            if let lname = dictionary["last_name"] as? String {
                lastName = lname
            }
            if let liD = dictionary["lender_id"] as? String {
                lenderID = liD
            }
            if let iD = dictionary["id"] as? NSNumber {
                id = iD
            }
            if let isPub = dictionary["is_public"] as? Bool {
                isPublic = isPub
            }
            if let dev = dictionary["is_developer"] as? Bool {
                isDeveloper = dev
            }
        }
    }
}