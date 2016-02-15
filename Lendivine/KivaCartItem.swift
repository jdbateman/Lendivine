//
//  KivaCartItem.swift
//  OAuthSwift
//
//  Created by john bateman on 11/8/15.
//  Copyright © 2015 John Bateman. All rights reserved.
//

import Foundation
import CoreData

// make KivaCartItem visible to CoreData
@objc(KivaCartItem)

class KivaCartItem: NSManagedObject /*, Equatable  < todo remove*/ {
    
    struct InitKeys {
        static let kivaLoan: String = "kivaLoan"
        static let donationAmount: String = "donationAmount"
        static let loanId: String = "id"
    }
    
    @NSManaged var loanID: NSNumber? // default: -1
    @NSManaged var donationAmount: NSNumber? // default: 0
    var loan = KivaLoan() // todo: make an optional NSManaged object
    
    convenience init(loan: KivaLoan, loanID: NSNumber, donationAmount: NSNumber, context: NSManagedObjectContext) {

// todo: remove
//        self.loanID = loanID
//        self.donationAmount = donationAmount
//        self.loan = loan
        
        var dictionary = [String: AnyObject]()
        dictionary[InitKeys.loanId] = loanID
        dictionary[InitKeys.donationAmount] = donationAmount
        dictionary[InitKeys.kivaLoan] = loan
        
        self.init(dictionary: dictionary, context: context)
    }
    
    /*! Return a dictionary representation of the data in this KivaCartItem instance. */
    func getDictionaryRespresentation() -> [String: AnyObject] {
        var dictionary = [String: AnyObject]()
        dictionary["id"] = loanID
        dictionary["donationAmount"] = donationAmount
        return dictionary
    }
    
    /*! Core Data init method */
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    /*! Init instance with a dictionary of values, and a core data context. */
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("CartItem", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.loanID = dictionary[InitKeys.loanId] as? NSNumber
        self.donationAmount = dictionary[InitKeys.donationAmount] as? NSNumber
        
        // todo: when made into an NSmanaged object then get rid of the if let construct:
        if let loan = dictionary[InitKeys.kivaLoan] as? KivaLoan {
            self.loan = loan
        }
    }
}

/*! Support Equatable protocol. Allows KivaCartItem instances to be compared. */
func ==(lhs: KivaCartItem, rhs: KivaCartItem) -> Bool {
    return (lhs.loan.id == rhs.loan.id)
}
