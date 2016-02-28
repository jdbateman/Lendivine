//
//  CoreDataStackManager.swift
//  Lendivine
//
//  Created by john bateman on 2/14/16.
//  Copyright © 2016 John Bateman. All rights reserved.
//
// The CoreDataStackManager class provides access to the Core Data stack, abstracting interaction with the sqlite store.
// Use it to access the Core Data context and to persist the context.


import Foundation
import CoreData

// MARK: - Core Data stack

private let SQLITE_FILE_NAME = "VirtualTourist.sqlite"

class CoreDataStackManager {
    
    /* Get a shared instance of the stack manager. */
    class func sharedInstance() -> CoreDataStackManager {
        struct Static {
            static let instance = CoreDataStackManager()
        }
        
        return Static.instance
    }
    
    /* true indicates a serious error occurred. Get error status info from  . false indicates no serious error has occurred. */
    var bCoreDataSeriousError = false
    
    struct ErrorInfo {
        var code: Int = 0
        var message: String = ""
    }
    var seriousErrorInfo: ErrorInfo = ErrorInfo()
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "self.JohnBateman.VirtualTourist" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Model", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent(SQLITE_FILE_NAME)
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: VTError.Constants.ERROR_DOMAIN, code: VTError.ErrorCodes.CORE_DATA_INIT_ERROR.rawValue, userInfo: dict)
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            
            // flag fatal Core Data error
            self.seriousErrorInfo = ErrorInfo(code: VTError.ErrorCodes.CORE_DATA_INIT_ERROR.rawValue, message: "Failed to initialize the application's saved data")
            self.bCoreDataSeriousError = true
        } catch {
            fatalError()
        }
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        
        // Suggested to make 1 line change the boilerplate code generated by Xcode: https://discussions.udacity.com/t/not-able-to-pass-specification-with-code-taught-in-the-lessons/31961/6
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error1 as NSError {
                    error = error1
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog("Unresolved error \(error), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }
    
    // MARK: - Scratch context
    
    /* A core data managed object context that will not be persisted. */
    lazy var scratchContext: NSManagedObjectContext = {
        var context = NSManagedObjectContext()
        context.persistentStoreCoordinator = CoreDataStackManager.sharedInstance().persistentStoreCoordinator
        return context
    }()
}
