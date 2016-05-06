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
    
//    struct InitKeys {
//        static let kivaLoan: String = "kivaLoan"
//        static let donationAmount: String = "donationAmount"
//        static let loanId: String = "id"
//        static let name: String = "name"
//        static let sector: String = "sector"
//        static let country: String = "country"
//        static let loanAmount: String = "loan_amount"
//        static let image: String = "image"
//        static let imageID: String = "id"
//    }
    
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
        static let imageId: String = "id"  // todo: is this somehow causing imageId to be saved to id?
        static let imageTemplateID: String = "template_id"
        static let borrowerCount: String = "borrower_count"
        static let lenderCount: String = "lender_count"
        
        static let loanAmount: String = "loan_amount"
        static let status: String = "status"
        static let sector: String = "sector"
        static let languages: String = "languages"
    }
    
//    @NSManaged var loanID: NSNumber? // default: -1
    @NSManaged var donationAmount: NSNumber? // default: 0
//    @NSManaged var name: String?
//    @NSManaged var sector: String?
//    @NSManaged var country: String?
//    @NSManaged var loanAmount: NSNumber?
//    @NSManaged var imageID: NSNumber? // default: -1
    
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

//        self.loanID = loan.id
//        self.name = loan.name
//        self.country = loan.country
//        self.loanAmount = loan.loanAmount
//        self.sector = loan.sector
//        self.imageID = loan.imageID
        
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
        
        debugValidateTODORemove()
    }
    
    /*! Core Data init method */
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        debugValidateTODORemove()
    }
    
    /*! Return a dictionary representation of a portion of the data in this KivaCartItem instance. 
    @discussion Will be serialized to json and sent to Kiva backend cart.
    */
    func getDictionaryRespresentation() -> [String: AnyObject] {
        var dictionary = [String: AnyObject]()
        dictionary[InitKeys.id] = id
        dictionary[InitKeys.donationAmount] = donationAmount
        
        debugValidateTODORemove()
        return dictionary
    }
    
    /*! Init instance with a dictionary of values, and a core data context. */
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("KivaCartItem", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
//        self.loanID = dictionary[InitKeys.loanId] as? NSNumber
//        self.donationAmount = dictionary[InitKeys.donationAmount] as? NSNumber
//        
//        self.name = dictionary[InitKeys.name] as? String
//        self.country = dictionary[InitKeys.country] as? String
//        self.loanAmount = dictionary[InitKeys.loanAmount] as? NSNumber
//        self.sector = dictionary[InitKeys.sector] as? String
//        self.imageID = dictionary[InitKeys.imageID] as? NSNumber
        
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
        
        debugValidateTODORemove()
    }
    
    func debugValidateTODORemove() {
        assert(self.id != self.imageID, "KivaCartItem id == imageID. \(self.id) == \(self.imageID)")
    }
}

/*! Support Equatable protocol. Allows KivaCartItem instances to be compared. */
func ==(lhs: KivaCartItem, rhs: KivaCartItem) -> Bool {
    return (lhs.id == rhs.id)
}

// MARK: image management functions

extension KivaCartItem {
    
    /*
    @brief Acquire the UIImage for this Loan object.
    @discussion The image is retrieved using the following sequence:
    1. cache
    2. filesystem
    3. download the image from self.imageUrl.
    @param completion (in)
    @param success (out) - true if image successfully acquired, else false.
    @param error (out) - NSError object if an error occurred, else nil.
    @param image (out) - the retrieved UIImage. May be nil if no image was found, or if an error occurred.
    */
    func getImage(completion: (success: Bool, error: NSError?, image: UIImage?) -> Void ) {
        
        let imageUrl = getImageUrl(self.imageID)
        
        // Try loading the image from the image cache.
        if let url = imageUrl {
            if let theImage: UIImage = NSCache.sharedInstance.objectForKey(url) as? UIImage {
                //print("image loaded from cache")
                completion(success: true, error: nil, image: theImage)
                return
            }
        }
        
        // Try loading the data from the file system.
        if let imageID = self.imageID {
            if let image = getImageFromFileSystem(imageID.stringValue) {
                //print("image loaded from file system")
                
                // Cache the image in memory.
                self.cacheImage(image)
                
                completion(success: true, error: nil, image: image)
                return
            }
        }
        
        // Load the image from the server asynchronously on a background queue.
        if let url = imageUrl {
            self.dowloadImageFrom(url) { success, error, theImage in
                if success {
                    if let theImage = theImage {
                        self.cacheImageAndWriteToFile(theImage)
                    }
                    //print("image downloaded from server")
                    completion(success: true, error: nil, image: theImage)
                    return
                } else {
                    // The download failed. Retry the download once.
                    self.dowloadImageFrom(url) { success, error, theImage in
                        if success {
                            if let theImage = theImage {
                                self.cacheImageAndWriteToFile(theImage)
                            }
                            //print("image downloaded from server")
                            completion(success: true, error: nil, image: theImage)
                            return
                        } else {
                            let vtError = VTError(errorString: "Image download from Kiva service failed.", errorCode: VTError.ErrorCodes.S3_FILE_DOWNLOAD_ERROR)
                            completion(success: false, error: vtError.error, image: nil)
                        }
                    }
                }
            }
        }
    }
    
    /* Download the image identified by imageUrlString in a background thread, convert it to a UIImage object, and return the object. */
    func getKivaImage(kivaImageID: NSNumber?, completion: (success: Bool, error: NSError?, image: UIImage?) -> Void) {
        if let kivaImageID = kivaImageID {
            let imageUrlString = String(format:"http://www.kiva.org/img/w200h200/%@.jpg", kivaImageID.stringValue)
            //            func dowloadImageFrom(imageUrlString: String?, completion: (success: Bool, error: NSError?, image: UIImage?) -> Void) {
            
            let backgroundQueue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
            dispatch_async(backgroundQueue, {
                // get the binary image data
                let imageURL = NSURL(string: imageUrlString)
                if let imageData = NSData(contentsOfURL: imageURL!) {
                    
                    // Convert the image data to a UIImage object and append to the array to be returned.
                    if let picture = UIImage(data: imageData) {
                        completion(success: true, error: nil, image: picture)
                    }
                    else {
                        let vtError = VTError(errorString: "Cannot convert image data.", errorCode: VTError.ErrorCodes.IMAGE_CONVERSION_ERROR)
                        completion(success: false, error: vtError.error, image: nil)
                    }
                    
                } else {
                    let vtError = VTError(errorString: "Image does not exist at \(imageURL)", errorCode: VTError.ErrorCodes.FILE_NOT_FOUND_ERROR)
                    completion(success: false, error: vtError.error, image: nil)
                }
            })
            //            }
        }
    }
    
    /*!
    @brief Return a String representing the url of the image identified by kivaImageID
    @param kivaImageID The Kiva image identifier.
    @return A String representing the url where the image can be downloaded, or nil in case of an error or invalide identifier.
    */
    func getImageUrl(kivaImageID: NSNumber?) -> String? {
        if let kivaImageID = kivaImageID {
            let imageUrlString = String(format:"http://www.kiva.org/img/w200h200/%@.jpg", kivaImageID.stringValue)
            return imageUrlString
        }
        return nil
    }
    
    /* Save image to a file with the name filename on the filesystem in the Documents directory. */
    func saveImageToFileSystem(filename: String, image: UIImage?) {
        if let image = image {
            let imageData = UIImageJPEGRepresentation(image, 1)
            let path = pathForImageFileWith(filename)
            if let path = path {
                if let imageData = imageData {
                    imageData.writeToFile(path, atomically: true)
                }
            }
        }
    }
    
    /* Load the data from filename and return as a UIImage object. */
    func getImageFromFileSystem(filename: String) -> UIImage? {
        let path = pathForImageFileWith(filename)
        if let path = path {
            if NSFileManager.defaultManager().fileExistsAtPath(path) {
                let imageData = NSFileManager.defaultManager().contentsAtPath(path)
                if let imageData = imageData {
                    let image = UIImage(data: imageData)
                    return image
                }
            }
        }
        return nil
    }
    
    /* Return the path to filename in the app’s Documents directory */
    func pathForImageFileWith(filename: String) -> String? {
        // the Documents directory's path is returned as a one-element array.
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let pathArray = [dirPath, filename]
        let fileURL =  NSURL.fileURLWithPathComponents(pathArray)!
        return fileURL.path
    }
    
    /* Save the image data to the image cache in memory. */
    func cacheImage(theImage: UIImage) {
        
        // Ensure access of the managed object happpens on the main queue
        dispatch_async(dispatch_get_main_queue()) {
            let imageUrl = self.getImageUrl(self.imageID)
            if let url = imageUrl {
                let backgroundQueue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
                dispatch_async(backgroundQueue, {
                    NSCache.sharedInstance.setObject(theImage, forKey: url)
                })
            }
        }
    }
    
    /* Download the image identified by imageUrlString in a background thread, convert it to a UIImage object, and return the object. */
    func dowloadImageFrom(imageUrlString: String?, completion: (success: Bool, error: NSError?, image: UIImage?) -> Void) {
        
        let backgroundQueue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
        dispatch_async(backgroundQueue, {
            // get the binary image data
            let imageURL:NSURL? = NSURL(string: imageUrlString!)
            if let imageData = NSData(contentsOfURL: imageURL!) {
                
                // Convert the image data to a UIImage object and append to the array to be returned.
                if let picture = UIImage(data: imageData) {
                    completion(success: true, error: nil, image: picture)
                }
                else {
                    let vtError = VTError(errorString: "Cannot convert image data.", errorCode: VTError.ErrorCodes.IMAGE_CONVERSION_ERROR)
                    completion(success: false, error: vtError.error, image: nil)
                }
                
            } else {
                let vtError = VTError(errorString: "Image does not exist at \(imageURL)", errorCode: VTError.ErrorCodes.FILE_NOT_FOUND_ERROR)
                completion(success: false, error: vtError.error, image: nil)
            }
        })
    }
    
    /* Save the image to the local cache and file system. */
    func cacheImageAndWriteToFile(theImage: UIImage) {
        
        // Ensure access of the managed object happpens on the main queue
        dispatch_async(dispatch_get_main_queue()) {
            if let imageID = self.imageID {
                // save the image data to the file system
                let backgroundQueue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
                dispatch_async(backgroundQueue, {
                    //if let imageID = self.imageID {
                    self.saveImageToFileSystem(imageID.stringValue, image: theImage)
                    //}
                })
            }
        }
        
        // save the image to the image cache in memory
        self.cacheImage(theImage)
    }
}

