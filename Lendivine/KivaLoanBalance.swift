//
//  KivaLoanBalance.swift
//  Lendivine
//
//  Created by john bateman on 4/27/16.
//  Copyright © 2016 John Bateman. All rights reserved.
//
//  This model class describes information about the balance on a Kiva Loan.

import Foundation

class KivaLoanBalance {
    
    var amountPurchasedByLender: NSNumber = -1
    var amountRepaidToLender: NSNumber = -1
    var arrearsAmount: NSNumber = -1
    var status: String = ""
    var id: NSNumber = -1
    
    // designated initializer
    init(dictionary: [String: AnyObject]?) {
        if let dictionary = dictionary {
            if let identifier = dictionary["id"] as? NSNumber {
                id = identifier
            }
            if let purchased = dictionary["amount_purchased_by_lender"] as? NSNumber {
                amountPurchasedByLender = purchased
            }
            if let repaid = dictionary["amount_repaid_to_lender"] as? NSNumber {
                amountRepaidToLender = repaid
            }
            if let arrears = dictionary["arrears_amount"] as? NSNumber {
                arrearsAmount = arrears
            }
            if let s = dictionary["status"] as? String {
                status = s
            }
        }
    }
}