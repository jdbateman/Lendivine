//
//  KivaCartItem.swift
//  OAuthSwift
//
//  Created by john bateman on 11/8/15.
//  Copyright © 2015 Dongri Jin. All rights reserved.
//

import Foundation

class KivaCartItem {
    
    var loanID: NSNumber
    var amount: NSNumber
    
    init(loanID: NSNumber, amount: NSNumber) {
        self.loanID = loanID
        self.amount = amount
    }
    
    func getDictionaryRespresentation() -> [String: AnyObject] {
        var dictionary = [String: AnyObject]()
        dictionary["id"] = loanID
        dictionary["amount"] = amount
        return dictionary
    }
}