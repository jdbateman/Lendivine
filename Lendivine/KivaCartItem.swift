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
    var donationAmount: NSNumber = 0
    var loan = KivaLoan()
    
    init(loan: KivaLoan, loanID: NSNumber, donationAmount: NSNumber) {
        self.loanID = loanID
        self.donationAmount = donationAmount
        self.loan = loan
    }
    
    func getDictionaryRespresentation() -> [String: AnyObject] {
        var dictionary = [String: AnyObject]()
        dictionary["id"] = loanID
        dictionary["donationAmount"] = donationAmount
        return dictionary
    }
}

// Support Equatable protocol.
func ==(lhs: KivaCartItem, rhs: KivaCartItem) -> Bool {
    return lhs.loan.id == rhs.loan.id
}