//
//  KivaLoan.swift
//  OAuthSwift
//
//  Created by john bateman on 10/29/15.
//  Copyright © 2015 John Bateman. All rights reserved.
//
//  This model class describes and allows manipulation of properties of a loan on the Kiva service. Instances of this class are cored data objects.

/* example loan data: http://build.kiva.org/docs/data/loans */


import Foundation
import UIKit
import CoreData
import MapKit

let kDefaultImageWidth:Int = 200
let kDefaultImageHeight:Int = 200

// make KivaLoan visible to CoreData
@objc(KivaLoan)

class KivaLoan: NSManagedObject  {
    
    static let entityName = "KivaLoan"
    
    enum Status:String {
        case fundraising = "fundraising"
        case funded = "funded"
        case in_repayment = "in_repayment"
        case paid = "paid"
        case defaulted = "defaulted"
        case refunded = "refunded"
    }
    
    struct InitKeys {
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
    
    /*! Core Data init method */
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    /*! Init instance with a dictionary of values, and a core data context. */
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entity(forEntityName: "KivaLoan", in: context)!
        super.init(entity: entity, insertInto: context)
        
        self.name = dictionary[InitKeys.name] as? String
        self.country = dictionary["location"]?.object(forKey: InitKeys.country) as? String
        self.geo = (dictionary["location"]?.object(forKey: InitKeys.geo) as AnyObject).object(forKey: "pairs") as? String
        self.town = dictionary["location"]?.object(forKey: InitKeys.town) as? String
        self.postedDate = dictionary[InitKeys.postedDate] as? String
        self.activity = dictionary[InitKeys.activity] as? String
        self.id = dictionary[InitKeys.id] as? NSNumber
        self.use = dictionary[InitKeys.use] as? String
        self.fundedAmount = dictionary[InitKeys.fundedAmount] as? NSNumber
        self.partnerID = dictionary[InitKeys.partnerID] as? NSNumber
        self.imageID = (dictionary[InitKeys.image])?.object(forKey: InitKeys.imageId) as? NSNumber
        self.imageTemplateID = (dictionary[InitKeys.image])?.object(forKey: InitKeys.imageTemplateID) as? NSNumber
        self.borrowerCount = dictionary[InitKeys.borrowerCount] as? NSNumber
        self.lenderCount = dictionary[InitKeys.lenderCount] as? NSNumber
        self.loanAmount = dictionary[InitKeys.loanAmount] as? NSNumber
        self.status = dictionary[InitKeys.status] as? String
        self.sector = dictionary[InitKeys.sector] as? String
        self.language = (dictionary["description"]?.object(forKey: InitKeys.languages) as AnyObject).firstObject as? String
    }

    /*! 
        @brief Initialize a KivaLoan object from another KivaLoan object.  
        @discussion Useful for creating a new loan in the specified context from a loan in another context.
        @param (in) fromLoan - the KivaLoan object from which to generate the new KivaLoan instance.
        @param (in) context - the NSManagedObjectContext of the new KivaLoan object.
        @return the new KivaLoan instance.
    */
    init(fromLoan: KivaLoan, context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entity(forEntityName: "KivaLoan", in: context)!
        super.init(entity: entity, insertInto: context)

        self.name = fromLoan.name
        self.country = fromLoan.country
        self.geo = fromLoan.geo
        self.town = fromLoan.town
        self.postedDate = fromLoan.postedDate
        self.activity = fromLoan.activity
        self.id = fromLoan.id
        self.use = fromLoan.use
        self.fundedAmount = fromLoan.fundedAmount
        self.partnerID = fromLoan.partnerID
        self.imageID = fromLoan.imageID
        self.imageTemplateID = fromLoan.imageTemplateID
        self.borrowerCount = fromLoan.borrowerCount
        self.lenderCount = fromLoan.lenderCount
        self.loanAmount = fromLoan.loanAmount
        self.status = fromLoan.status
        self.sector = fromLoan.sector
        self.language = fromLoan.language
    }
    
    init(fromCartItem: KivaCartItem, context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entity(forEntityName: "KivaLoan", in: context)!
        super.init(entity: entity, insertInto: context)
        
        self.name = fromCartItem.name
        self.country = fromCartItem.country
        self.geo = fromCartItem.geo
        self.town = fromCartItem.town
        self.postedDate = fromCartItem.postedDate
        self.activity = fromCartItem.activity
        self.id = fromCartItem.id
        self.use = fromCartItem.use
        self.fundedAmount = fromCartItem.fundedAmount
        self.partnerID = fromCartItem.partnerID
        self.imageID = fromCartItem.imageID
        self.imageTemplateID = fromCartItem.imageTemplateID
        self.borrowerCount = fromCartItem.borrowerCount
        self.lenderCount = fromCartItem.lenderCount
        self.loanAmount = fromCartItem.loanAmount
        self.status = fromCartItem.status
        self.sector = fromCartItem.sector
        self.language = fromCartItem.language
    }
    
    /*! Update this instance's properties with that from the specified object. */
    func update(fromLoan: KivaLoan?) {
        
        guard let fromLoan = fromLoan else {return}
        
        if let name = fromLoan.name {
            self.setValue(name, forKey: KivaLoan.InitKeys.name)
        }
        if let geo = fromLoan.geo {
            self.setValue(geo, forKey: KivaLoan.InitKeys.geo)
        }
        if let country = fromLoan.country {
            self.setValue(country, forKey: KivaLoan.InitKeys.country)
        }
        if let town = fromLoan.town {
            self.setValue(town, forKey: KivaLoan.InitKeys.town)
        }
        if let activity = fromLoan.activity {
            self.setValue(activity, forKey: KivaLoan.InitKeys.activity)
        }
        if let id = fromLoan.id {
            self.id = id
        }
        if let use = fromLoan.use {
            self.setValue(use, forKey: KivaLoan.InitKeys.use)
        }
        if let imageID = fromLoan.imageID {
            self.imageID = imageID
            //self.setValue(imageID, forKey: KivaLoan.InitKeys.imageId)  // This line sets both self.id and self.imageID to fromLoan.imageID
        }
        if let status = fromLoan.status {
            self.setValue(status, forKey: KivaLoan.InitKeys.status)
        }
        if let sector = fromLoan.sector {
            self.setValue(sector, forKey: KivaLoan.InitKeys.sector)
        }
        if let postedDate = fromLoan.postedDate {
            self.postedDate = postedDate
        }
        if let fundedAmount = fromLoan.fundedAmount {
            self.fundedAmount = fundedAmount
        }
        if let partnerID = fromLoan.partnerID {
            self.partnerID = partnerID
        }
        if let imageTemplateID = fromLoan.imageTemplateID {
            self.imageTemplateID = imageTemplateID
        }
        if let borrowerCount = fromLoan.borrowerCount {
            self.borrowerCount = borrowerCount
        }
        if let lenderCount = fromLoan.lenderCount {
            self.lenderCount = lenderCount
        }
        if let loanAmount = fromLoan.loanAmount {
            self.loanAmount = loanAmount
        }
        if let languages = fromLoan.language {
            self.language = languages
        }
    }
    
    // MARK: - Fetched results controller
    
    /* The main core data managed object context. This context will be persisted. */
    static var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }()

    /* Perform a fetch of the loan object. Updates the fetchedResultsController with the matching data from the core data store. */
    class func fetchLoanByID2(_ loanID: NSNumber, context: NSManagedObjectContext) -> KivaLoan? {
        
        let error: NSErrorPointer? = nil
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: KivaLoan.entityName)
        fetchRequest.predicate = NSPredicate(format: "id == %@", loanID)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        var results: [AnyObject]?
        do {
            results = try context.fetch(fetchRequest) as! [KivaLoan]
        } catch let error1 as NSError {
            error??.pointee = error1
            print("Error in fetchLoanByID2(): \(error)")
            return nil
        }
        
        // Check for Errors
        if error != nil {
            print("Error in fetchLoanByID2(): \(error)")
        }
        
        // Return the first result, or nil
        if let results = results, results.count > 0 {
            for loan in results {
                if let loan = loan as? KivaLoan {
                    if loan.id == loanID {
                        return loan as KivaLoan
                    }
                }
            }
        } else {
            return nil
        }
        return nil
    }
    
    /* Return mappable coordinates for a KivaLoan object */
    class func getCoordinatesForLoan(_ loan: KivaLoan) -> CLLocationCoordinate2D? {
        
        // get latitude and longitude from loan and save as CCLocationDegree type (a Double type)
        guard let geo = loan.geo else {
            print("loan \(loan.name) has invalid geo coordinates. Here is the entire loan object: \(loan)")
            return nil
        }
        
        let geoCoordsArray = geo.characters.split{$0 == " "}.map(String.init)
        
        guard let latitude = Double(geoCoordsArray[0]) else {return nil}
        guard let longitude = Double(geoCoordsArray[1]) else {return nil}
        let lat = CLLocationDegrees(latitude)
        let long = CLLocationDegrees(longitude)
        
        // The lat and long are used to create a CLLocationCoordinates2D instance.
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        return coordinate
    }
}

extension KivaLoan {
    
    /*
    @brief Acquire the UIImage for this Loan object.
    @discussion The image is retrieved using the following sequence:
    1. cache
    2. filesystem
    3. download the image from self.imageUrl.
    Image sizes are maximums
    @param width (in) - desired width of image
    @param height (in) - desired height of image
    @param square (in) - If true then a square image will be requested from Kiva using the width parameter for the dimension of a side.
    @param completion (in)
    @param success (out) - true if image successfully acquired, else false.
    @param error (out) - NSError object if an error occurred, else nil.
    @param image (out) - the retrieved UIImage. May be nil if no image was found, or if an error occurred.
    */
    func getImage(_ width:Int = kDefaultImageWidth, height:Int = kDefaultImageHeight, square:Bool = false, completion: @escaping (_ success: Bool, _ error: NSError?, _ image: UIImage?) -> Void ) {
        
        let image = KivaImage(imageId: self.imageID)
        image.getImage(width, height:height, square:square) {
            success, error, image in
            completion(success, error, image)
        }
    }
    
    /*! Return an image of the flag where this loan resides. */
    func getFlagImage() -> UIImage? {
        
        var flagImage: UIImage?
        
        if let country = self.country {
            
            if let uiImage = UIImage(named: country) {
                flagImage = uiImage
            } else {
                flagImage = UIImage(named: "United Nations")
            }
        }
        
        return flagImage
    }
    
    /*! Return the name of this loan's flag image. */
    func getNameOfFlagImage() -> String {
        
        var name: String = "United Nations"
        
        if let country = self.country {
            if let _ = UIImage(named: country) {
                name = country
            }
        }
        
        return name
    }
}


// MARK: helper functions

extension KivaLoan {

    /*! 
    @brief Check with Kiva.org to see if the current loan status matches the specified KivaLoan.Status enum value.
    @param (in) statusToMatch
    @param (in) completionHandler called when function has completed
        (out) result - true if loan status matches the specified input, else false.
        (out) error - nil if loan status successfully determined, else contains an NSError.
    */
    func confirmLoanStatus(_ statusToMatch: KivaLoan.Status, context: NSManagedObjectContext, completionHandler: @escaping (_ result: Bool, _ error: NSError?) -> Void ) {
        // get loan from server and check it's status
        let loanIDs = [self.id]
        KivaAPI.sharedInstance.kivaGetLoans(loanIDs, context: context) {
            success, error, loans in
            if success {
                if let loans = loans {
                    for loan in loans {
                        if loan.id == self.id {
                            // Found the loan in the results, now determine if the loan status matches the desired status.
                            if loan.status == statusToMatch.rawValue {
                                completionHandler(true, nil)
                            } else {
                                completionHandler(false, nil)
                            }
                            return
                        }
                    }
                }
            } else {
                
            }
            
            let error = VTError(errorString: "Unable to find loan id.", errorCode: VTError.ErrorCodes.kiva_API_LOAN_NOT_FOUND)
            completionHandler(false, error.error)
        }
    }

    /*!
    @brief Get loans from Kiva.org and confirm the status of each is "fundraising".
    @return List of loans with fundraising status, and list of loans no longer with fundraining status.
    */
    class func getCurrentFundraisingStatus(_ loans: [KivaLoan]?, context: NSManagedObjectContext, completionHandler: @escaping (_ success: Bool, _ error: NSError?, _ fundraising: [KivaLoan]?, _ notFundraising: [KivaLoan]?) -> Void) {
        
        // validate loans not nil or empty
        if loans == nil || loans!.count == 0 {
            let error = VTError(errorString: "Kiva loan not specified.", errorCode: VTError.ErrorCodes.kiva_API_NO_LOANS)
            completionHandler(true, error.error, nil, nil)
        }
        
        var fundraising = [KivaLoan]()
        var notFundraising = [KivaLoan]()
        
        // accumulate loan IDs
        var loanIDs = [NSNumber?]()
        for loan in loans! {
            if let id = loan.id {
                loanIDs.append(id)
            }
        }
        
        // Find loans on Kiva.org
        KivaAPI.sharedInstance.kivaGetLoans(loanIDs, context:context) {
            success, error, loans in
            if success {
                if let loans = loans {
                    for loan in loans {
                        if loan.status == KivaLoan.Status.fundraising.rawValue {
                            fundraising.append(loan)
                        } else {
                            notFundraising.append(loan)
                        }
                    }
                    completionHandler(true, nil, fundraising, notFundraising)
                }
            } else {
                let error = VTError(errorString: "Kiva loan not found.", errorCode: VTError.ErrorCodes.kiva_API_LOAN_NOT_FOUND)
                completionHandler(true, error.error, nil, nil)
            }
        }
    }
}

func ==(lhs: KivaLoan, rhs: KivaLoan) -> Bool {
    return lhs.id == rhs.id
}
