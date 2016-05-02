//
//  KivaAccount.swift
//  Lendivine
//
//  Created by john bateman on 4/24/16.
//  Copyright © 2016 John Bateman. All rights reserved.
//
//  This class implements the model for a Kiva user account.

import Foundation
import UIKit
import CoreData

// make KivaAccount visible to CoreData
@objc(KivaAccount)

class KivaAccount: NSManagedObject {
    
    static let entityName = "KivaAccount"
    
    struct InitKeys {
        static let name: String = "name"
        static let email: String = "email"
        static let balance: String = "balance"
        static let lenderId: String = "lenderId"
    }
    
    @NSManaged var name: String?
    @NSManaged var email: String?
    @NSManaged var balance: String?
    @NSManaged var lenderId: String?
    
    /*! Core Data init method */
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    /*! Init instance with a dictionary of values, and a core data context. */
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName(KivaAccount.entityName, inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.name = dictionary[InitKeys.name] as? String
        
        self.email = dictionary[InitKeys.email] as? String
        
        self.balance = dictionary[InitKeys.balance] as? String
        
        self.lenderId = dictionary[InitKeys.lenderId] as? String
    }

    
    // MARK: Image
    
    /*! Get image from filesystem. Name of image is based off of this object's lenderId property. */
    func getImage() -> UIImage? {
        // Try loading the data from the file system.
        if let id = self.lenderId {
            if let image = getImageFromFileSystem(id) {
                //print("image loaded from file system")
                return image
            }
        }
        return nil
    }
    
    func saveImage(newImage:UIImage) {
        deleteFileFromFileSystem()
        if let id = self.lenderId {
            saveImageToFileSystem(id, image: newImage)
        }
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
    
    
    /*
    @brief Delete the file in the Documents directory associated with this photo.
    @discussion Uses the accountId property as the base of the filename.
    */
    func deleteFileFromFileSystem() {
        if let id = self.lenderId {
            let path = pathForImageFileWith(id)
            if let path = path {
                if NSFileManager.defaultManager().fileExistsAtPath(path) {
                    let error:NSErrorPointer = NSErrorPointer()
                    do {
                        try NSFileManager.defaultManager().removeItemAtPath(path)
                    } catch let error1 as NSError {
                        error.memory = error1
                    }
                    print("deleted file at \(path)")
                    if error != nil {
                        print(error.debugDescription)
                    }
                }
            }
        }
    }
}

/*! Support Equatable protocol. Allows KivaCartItem instances to be compared. */
//func ==(lhs: KivaAccount, rhs: KivaAccount) -> Bool {
//    return (lhs.name == rhs.name)
//}