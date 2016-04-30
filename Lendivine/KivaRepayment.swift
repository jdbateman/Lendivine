//
//  KivaRepayment.swift
//  Lendivine
//
//  Created by john bateman on 4/28/16.
//  Copyright © 2016 John Bateman. All rights reserved.
//
//  This model class describes information about the future repayment schedule for all Kiva Loans associated with a Kiva account.

import Foundation

class KivaRepayment {
    
    var userRepayments: String = ""
    var promoRepayments: String = ""
    var loansMakingRepayments: String = ""
    var repaymentDate: String = ""
    var repaymentId: String = ""
    
    // designated initializer
    init(key:String, dictionary: [String: AnyObject]?) {
        
        if let dictionary = dictionary {
            
            if let k = key as? String {
                repaymentId = k
            }
            
            if let repayments = dictionary["user_repayments"] as? String {
                userRepayments = repayments
            }
            if let promo = dictionary["promo_repayments"] as? String {
                promoRepayments = promo
            }
            if let numloans = dictionary["loans_making_repayments"] as? String {
                loansMakingRepayments = numloans
            }
            if let date = dictionary["repayment_date"] as? String {
                repaymentDate = date
            }
        }
    }
}