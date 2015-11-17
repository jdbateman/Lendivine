//
//  KivaLoanStatistics.swift
//  OAuthSwift
//
//  Created by john bateman on 10/30/15.
//  Copyright © 2015 John Bateman. All rights reserved.
//

import Foundation

class KivaLoanStatistics {
    
    var amount_donated: NSNumber = 0
    var amount_in_arrears: NSNumber = 0
    var amount_of_loans: NSNumber = 0
    var amount_of_loans_by_invitees: NSNumber = 0
    var amount_outstanding: NSNumber = 0
    var amount_outstanding_promo: NSNumber = 0
    var amount_refunded: NSNumber = 0
    var amount_repaid: NSNumber = 0
    var arrears_rate: NSNumber = 0
    var currency_loss: NSNumber = 0
    var currency_loss_rate: NSNumber = 0
    var default_rate: NSNumber = 0
    var num_defaulted: NSNumber = 0
    var num_ended: NSNumber = 0
    var num_expired: NSNumber = 0
    var num_fund_raising: NSNumber = 0
    var num_inactive: NSNumber = 0
    var num_inactive_expired: NSNumber = 0
    var num_paying_back: NSNumber = 0
    var num_raised: NSNumber = 0
    var num_refunded: NSNumber = 0
    var number_delinquent: NSNumber = 0
    var number_of_gift_certificates: NSNumber = 0
    var number_of_invites: NSNumber = 0
    var number_of_loans: NSNumber = 0
    var number_of_loans_by_invitees: NSNumber = 0
    var total_defaulted: NSNumber = 0
    var total_ended: NSNumber = 0
    var total_expired: NSNumber = 0
    var total_fund_raising: NSNumber = 0
    var total_inactive: NSNumber = 0
    var total_inactive_expired: NSNumber = 0
    var total_paying_back: NSNumber = 0
    var total_refunded: NSNumber = 0
    
    // designated initializer
    init(dictionary: [String: AnyObject]?) {
        
        if let dictionary = dictionary {
            
            if let amount_donated = dictionary["amount_donated"] as? NSNumber {
                self.amount_donated = amount_donated
            }
            
            if let amount_in_arrears = dictionary["amount_in_arrears"] as? NSNumber {
                self.amount_in_arrears = amount_in_arrears
            }
            if let amount_of_loans = dictionary["amount_of_loans"] as? NSNumber {
                self.amount_of_loans = amount_of_loans
            }
            if let amount_of_loans_by_invitees = dictionary["amount_of_loans_by_invitees"] as? NSNumber {
                self.amount_of_loans_by_invitees = amount_of_loans_by_invitees
            }
            if let amount_outstanding = dictionary["amount_outstanding"] as? NSNumber {
                self.amount_outstanding = amount_outstanding
            }
            if let amount_outstanding_promo = dictionary["amount_outstanding_promo"] as? NSNumber {
                self.amount_outstanding_promo = amount_outstanding_promo
            }
            if let amount_refunded = dictionary["amount_refunded"] as? NSNumber {
                self.amount_refunded = amount_refunded
            }
            if let amount_repaid = dictionary["amount_repaid"] as? NSNumber {
                self.amount_repaid = amount_repaid
            }
            if let arrears_rate = dictionary["arrears_rate"] as? NSNumber {
                self.arrears_rate = arrears_rate
            }
            if let currency_loss = dictionary["currency_loss"] as? NSNumber {
                self.currency_loss = currency_loss
            }
            if let currency_loss_rate = dictionary["currency_loss_rate"] as? NSNumber {
                self.currency_loss_rate = currency_loss_rate
            }
            
            if let default_rate = dictionary["default_rate"] as? NSNumber {
                self.default_rate = default_rate
            }
            if let num_defaulted = dictionary["num_defaulted"] as? NSNumber {
                self.num_defaulted = num_defaulted
            }
            if let num_ended = dictionary["num_ended"] as? NSNumber {
                self.num_ended = num_ended
            }
            if let num_expired = dictionary["num_expired"] as? NSNumber {
                self.num_expired = num_expired
            }
            if let num_fund_raising = dictionary["num_fund_raising"] as? NSNumber {
                self.num_fund_raising = num_fund_raising
            }
            if let num_inactive = dictionary["num_inactive"] as? NSNumber {
                self.num_inactive = num_inactive
            }
            if let num_inactive_expired = dictionary["num_inactive_expired"] as? NSNumber {
                self.num_inactive_expired = num_inactive_expired
            }
            if let num_paying_back = dictionary["num_paying_back"] as? NSNumber {
                self.num_paying_back = num_paying_back
            }
            if let num_raised = dictionary["num_raised"] as? NSNumber {
                self.num_raised = num_raised
            }
            if let num_refunded = dictionary["num_refunded"] as? NSNumber {
                self.num_refunded = num_refunded
            }
            if let number_delinquent = dictionary["number_delinquent"] as? NSNumber {
                self.number_delinquent = number_delinquent
            }
            if let number_of_gift_certificates = dictionary["number_of_gift_certificates"] as? NSNumber {
                self.number_of_gift_certificates = number_of_gift_certificates
            }
            
            if let number_of_invites = dictionary["number_of_invites"] as? NSNumber {
                self.number_of_invites = number_of_invites
            }
            if let number_of_loans = dictionary["number_of_loans"] as? NSNumber {
                self.number_of_loans = number_of_loans
            }
            if let number_of_loans_by_invitees = dictionary["number_of_loans_by_invitees"] as? NSNumber {
                self.number_of_loans_by_invitees = number_of_loans_by_invitees
            }
            if let total_defaulted = dictionary["total_defaulted"] as? NSNumber {
                self.total_defaulted = total_defaulted
            }
            if let total_ended = dictionary["total_ended"] as? NSNumber {
                self.total_ended = total_ended
            }
            if let total_expired = dictionary["total_expired"] as? NSNumber {
                self.total_expired = total_expired
            }
            if let total_fund_raising = dictionary["total_fund_raising"] as? NSNumber {
                self.total_fund_raising = total_fund_raising
            }
            if let total_inactive = dictionary["total_inactive"] as? NSNumber {
                self.total_inactive = total_inactive
            }
            if let total_inactive_expired = dictionary["total_inactive_expired"] as? NSNumber {
                self.total_inactive_expired = total_inactive_expired
            }
            if let total_paying_back = dictionary["total_paying_back"] as? NSNumber {
                self.total_paying_back = total_paying_back
            }
            if let total_refunded = dictionary["total_refunded"] as? NSNumber {
                self.total_refunded = total_refunded
            }
        }
    }
}

/* Format of JSON data returned by the Kiva https://api.kivaws.org/v1/my/stats.json API
{
    "amount_donated" = 0;
    "amount_in_arrears" = 0;
    "amount_of_loans" = 0;
    "amount_of_loans_by_invitees" = 0;
    "amount_outstanding" = 0;
    "amount_outstanding_promo" = 0;
    "amount_refunded" = 0;
    "amount_repaid" = 0;
    "arrears_rate" = 0;
    "currency_loss" = 0;
    "currency_loss_rate" = 0;
    "default_rate" = 0;
    "num_defaulted" = 0;
    "num_ended" = 0;
    "num_expired" = 0;
    "num_fund_raising" = 0;
    "num_inactive" = 0;
    "num_inactive_expired" = 0;
    "num_paying_back" = 0;
    "num_raised" = 0;
    "num_refunded" = 0;
    "number_delinquent" = 0;
    "number_of_gift_certificates" = 0;
    "number_of_invites" = 0;
    "number_of_loans" = 0;
    "number_of_loans_by_invitees" = 0;
    "total_defaulted" = 0;
    "total_ended" = 0;
    "total_expired" = 0;
    "total_fund_raising" = 0;
    "total_inactive" = 0;
    "total_inactive_expired" = 0;
    "total_paying_back" = 0;
    "total_refunded" = 0;
}
*/