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
}


// MARK: Account Image

extension KivaAccount {
    
    func saveAccountImage(newImage:UIImage) {
        
        if let id = self.lenderId {  // here we save the image using the lenderId to construct the filename on disk
            
            if let idNum = Int(id) {
                let accountImage = KivaImage(imageId: idNum)
                accountImage.saveImageToFileSystem(id, image: newImage)
            }
        }
    }
    
    /*
        @brief Delete the file in the Documents directory associated with this photo.
        @discussion Uses the accountId property as the base of the filename.
    */
    func deleteAccountImageFileFromFileSystem() {
        if let id = self.lenderId {
            if let idNum = Int(id) {
                let accountImage = KivaImage(imageId: idNum)
                let path = accountImage.pathForImageFileWith(id)
                if let path = path {
                    if NSFileManager.defaultManager().fileExistsAtPath(path) {
                        let error:NSErrorPointer = NSErrorPointer()
                        do {
                            try NSFileManager.defaultManager().removeItemAtPath(path)
                        } catch let error1 as NSError {
                            error.memory = error1
                        }
                        if error != nil {
                            print(error.debugDescription)
                        }
                    }
                }
            }
        }
    }
}