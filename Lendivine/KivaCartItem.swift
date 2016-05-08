//
//  KivaCartItem.swift
//  OAuthSwift
//
//  Created by john bateman on 11/8/15.
//  Copyright © 2015 John Bateman. All rights reserved.
//
//  This model class describes an item in the cart. Instances of this class are core data objects. The object contains data from a loan that are useful for the Cart view to render. The object contains the loan Id, which can be used to fetch the actual loan from core data if necessary.

import Foundation
import CoreData
import UIKit

// make KivaCartItem visible to CoreData
@objc(KivaCartItem)

class KivaCartItem: NSManagedObject {
    
    static let entityName = "KivaCartItem"
    
    struct InitKeys {
        static let donationAmount: String = "donationAmount"

        static let name: String = "name"
        static let country: String = "country"
        static let geo: String = "geo"
        static let town: String = "town"
        static let postedDate: String = "posted_date"
        static let activity: String = "activity"
        static let id: String = "id"
        
        static let use: String = "use"
        static let fundedAmount: String = "funded_amount"
        static let partnerID: String = "partner_id"
        static let image: String = "image"
        static let imageId: String = "id"
        static let imageTemplateID: String = "template_id"
        static let borrowerCount: String = "borrower_count"
        static let lenderCount: String = "lender_count"
        
        static let loanAmount: String = "loan_amount"
        static let status: String = "status"
        static let sector: String = "sector"
        static let languages: String = "languages"
    }
    
    @NSManaged var donationAmount: NSNumber? // default: 0
    
    @NSManaged var name: String?
    
    // Location
    @NSManaged var country: String?
    @NSManaged var geo: String?
    @NSManaged var town: String?
    
    @NSManaged var postedDate: String?
    @NSManaged var activity: String?
    @NSManaged var id: NSNumber? // = -1
    @NSManaged var use: String?
    @NSManaged var language: String?
    @NSManaged var fundedAmount: NSNumber? // = 0
    @NSManaged var partnerID: NSNumber? // = -1
    
    // image
    @NSManaged var imageID: NSNumber? // = -1
    @NSManaged var imageTemplateID: NSNumber? // = -1
    
    @NSManaged var borrowerCount: NSNumber? // = 0
    @NSManaged var lenderCount: NSNumber? // = 0
    @NSManaged var loanAmount: NSNumber? // = 0
    @NSManaged var status: String?
    @NSManaged var sector: String?
    
    
    init(loan: KivaLoan, donationAmount: NSNumber, context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("KivaCartItem", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)

        self.donationAmount = donationAmount
        
        self.name = loan.name
        self.country = loan.country
        self.geo = loan.geo
        self.town = loan.town
        self.postedDate = loan.postedDate
        self.activity = loan.activity
        self.id = loan.id
        self.use = loan.use
        self.fundedAmount = loan.fundedAmount
        self.partnerID = loan.partnerID
        self.imageID = loan.imageID
        self.imageTemplateID = loan.imageTemplateID
        self.borrowerCount = loan.borrowerCount
        self.lenderCount = loan.lenderCount
        self.loanAmount = loan.loanAmount
        self.status = loan.status
        self.sector = loan.sector
        self.language = loan.language
    }
    
    /*! Core Data init method */
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    /*! Return a dictionary representation of a portion of the data in this KivaCartItem instance. 
    @discussion Will be serialized to json and sent to Kiva backend cart.
    */
    func getDictionaryRespresentation() -> [String: AnyObject] {
        var dictionary = [String: AnyObject]()
        dictionary[InitKeys.id] = id
        dictionary[InitKeys.donationAmount] = donationAmount
        return dictionary
    }
    
    /*! Init instance with a dictionary of values, and a core data context. */
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("KivaCartItem", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.donationAmount = dictionary[InitKeys.donationAmount] as? NSNumber
        self.name = dictionary[InitKeys.name] as? String
        self.country = dictionary["location"]?.objectForKey(InitKeys.country) as? String
        self.geo = dictionary["location"]?.objectForKey(InitKeys.geo)?.objectForKey("pairs") as? String
        self.town = dictionary["location"]?.objectForKey(InitKeys.town) as? String
        self.postedDate = dictionary[InitKeys.postedDate] as? String
        self.activity = dictionary[InitKeys.activity] as? String
        self.id = dictionary[InitKeys.id] as? NSNumber
        self.use = dictionary[InitKeys.use] as? String
        self.fundedAmount = dictionary[InitKeys.fundedAmount] as? NSNumber
        self.partnerID = dictionary[InitKeys.partnerID] as? NSNumber
        self.imageID = (dictionary[InitKeys.image])?.objectForKey(InitKeys.imageId) as? NSNumber
        self.imageTemplateID = (dictionary[InitKeys.image])?.objectForKey(InitKeys.imageTemplateID) as? NSNumber
        self.borrowerCount = dictionary[InitKeys.borrowerCount] as? NSNumber
        self.lenderCount = dictionary[InitKeys.lenderCount] as? NSNumber
        self.loanAmount = dictionary[InitKeys.loanAmount] as? NSNumber
        self.status = dictionary[InitKeys.status] as? String
        self.sector = dictionary[InitKeys.sector] as? String
        self.language = dictionary["description"]?.objectForKey(InitKeys.languages)?[0] as? String
    }
}

/*! Support Equatable protocol. Allows KivaCartItem instances to be compared. */
func ==(lhs: KivaCartItem, rhs: KivaCartItem) -> Bool {
    return (lhs.id == rhs.id)
}

