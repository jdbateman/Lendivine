//
//  KivaCartItem.swift
//  OAuthSwift
//
//  Created by john bateman on 11/8/15.
//  Copyright © 2015 John Bateman. All rights reserved.
//

import Foundation

class KivaCartItem: Equatable {
    
    var loanID: NSNumber = -1
    var amount: NSNumber = 0
    var loan = KivaLoan()
    
    init(loan: KivaLoan, loanID: NSNumber, amount: NSNumber) {
        self.loanID = loanID
        self.amount = amount
        self.loan = loan
    }
    
    func getDictionaryRespresentation() -> [String: AnyObject] {
        var dictionary = [String: AnyObject]()
        dictionary["id"] = loanID
        dictionary["amount"] = amount
        return dictionary
    }
}

// Support Equatable protocol.
func ==(lhs: KivaCartItem, rhs: KivaCartItem) -> Bool {
    return lhs.loan.id == rhs.loan.id
}