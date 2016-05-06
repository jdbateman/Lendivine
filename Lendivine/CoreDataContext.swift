//
//  CoreDataContext.swift
//  Lendivine
//
//  Created by john bateman on 5/4/16.
//  Copyright © 2016 John Bateman. All rights reserved.
//

import Foundation
import CoreData

class CoreDataContext {
    
    /* Get a shared instance of the stack manager. */
    class func sharedInstance() -> CoreDataContext {
        struct Static {
            static let instance = CoreDataContext()
        }
        
        return Static.instance
    }
    
    // MARK: - Scratch context
    
    /* A core data managed object context that will not be persisted. */
    lazy var scratchContext: NSManagedObjectContext = {
        var context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = CoreDataStackManager.sharedInstance().persistentStoreCoordinator
        context.mergePolicy = NSMergePolicy(mergeType: NSMergePolicyType.MergeByPropertyObjectTrumpMergePolicyType)
        return context
    }()
    
    /* Save the data in the Scratch context to the core data store on disk. */
    func saveScratchContext() {
        
        let error: NSErrorPointer = nil
        do {
            _ = try CoreDataContext.sharedInstance().scratchContext.save()
            
        } catch let error1 as NSError {
            error.memory = error1
            print("Error saving cartContext: \(error)")
        }
    }
    
    // MARK: - Loans scratch context
    
    /* A core data managed object context that will not be used to persist objects. The DVNTableViewController uses this context to work with the user's loans retrieved from the Kiva API. */
    lazy var loansScratchContext: NSManagedObjectContext = {
        var context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = CoreDataStackManager.sharedInstance().persistentStoreCoordinator
        context.mergePolicy = NSMergePolicy(mergeType: NSMergePolicyType.MergeByPropertyObjectTrumpMergePolicyType)
        return context
    }()
    
    /* A core data managed object context that will not be used to persist objects. The DVNTableViewController uses this context to work with the user's loans retrieved from the Kiva API. */
    lazy var loansScratchContext2: NSManagedObjectContext = {
        var context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = CoreDataStackManager.sharedInstance().persistentStoreCoordinator
        context.mergePolicy = NSMergePolicy(mergeType: NSMergePolicyType.MergeByPropertyObjectTrumpMergePolicyType)
        return context
    }()
    
    // MARK: - myLoans context
    
    /* A core data managed object context that will not be used to persist objects. The MyLoans view controller uses this context to work with the user's loans retrieved from the Kiva API. */
    lazy var myLoansContext: NSManagedObjectContext = {
        var context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = CoreDataStackManager.sharedInstance().persistentStoreCoordinator
        context.mergePolicy = NSMergePolicy(mergeType: NSMergePolicyType.MergeByPropertyObjectTrumpMergePolicyType)
        return context
    }()
    
    // MARK: - Cart context
    
    /* A core data managed object context that wil be used to persist objects. The Cart view controller uses this context it to create, manage, and save KivaCartItems contstructed from the properties of KivaLoan objects. Other view controllers use this context to save KivaLoan objects to the cart and to persist them to disk. (See LoanDetailViewController for an example.) */
    lazy var cartContext: NSManagedObjectContext = {
        var context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = CoreDataStackManager.sharedInstance().persistentStoreCoordinator
        context.mergePolicy = NSMergePolicy(mergeType: NSMergePolicyType.MergeByPropertyObjectTrumpMergePolicyType)
        return context
    }()
    
    /* Save the data in the Cart context to the core data store on disk. */
    func saveCartContext() {
        
        let error: NSErrorPointer = nil
        do {
            _ = try CoreDataContext.sharedInstance().cartContext.save()
            
        } catch let error1 as NSError {
            error.memory = error1
            print("Error saving cartContext: \(error)")
        }
    }
    
    // MARK: - Cart scratch context
    
    /* A core data managed object context that will not be used to persist objects. The Cart view controller uses this context to create temporary KivaLoan objects. Each temporary KivaLoan object is used to evaluate the payment status of a loan represented by a KivaCartItem object. */
    lazy var cartScratchContext: NSManagedObjectContext = {
        var context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = CoreDataStackManager.sharedInstance().persistentStoreCoordinator
        context.mergePolicy = NSMergePolicy(mergeType: NSMergePolicyType.MergeByPropertyObjectTrumpMergePolicyType)
        return context
    }()
    
    // MARK: - Account context
    
    /* A core data managed object context that will be used to persist objects. The Account view controller uses this context to create KivaAccount objects that are persisted to the core data store on disk.*/
    lazy var accountContext: NSManagedObjectContext = {
        var context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = CoreDataStackManager.sharedInstance().persistentStoreCoordinator
        context.mergePolicy = NSMergePolicy(mergeType: NSMergePolicyType.MergeByPropertyObjectTrumpMergePolicyType)
        return context
    }()
    
    /* Save the data in the Account context to the core data store on disk. */
    func saveAccountContext() {
        
        let error: NSErrorPointer = nil
        do {
            _ = try CoreDataContext.sharedInstance().accountContext.save()
            
        } catch let error1 as NSError {
            error.memory = error1
            print("Error saving cartContext: \(error)")
        }
    }
    
    // MARK: - Countries context
    
    /* A core data managed object context that will be used to persist objects. The Countries table view controller uses this context to persist Country objects. */
    lazy var countriesContext: NSManagedObjectContext = {
        var context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = CoreDataStackManager.sharedInstance().persistentStoreCoordinator
        context.mergePolicy = NSMergePolicy(mergeType: NSMergePolicyType.MergeByPropertyObjectTrumpMergePolicyType)
        return context
    }()
    
    /* Save the data in the Countries context to the core data store on disk. */
    func saveCountriesContext() {
        
        let error: NSErrorPointer = nil
        do {
            _ = try CoreDataContext.sharedInstance().countriesContext.save()
            
        } catch let error1 as NSError {
            error.memory = error1
            print("Error saving cartContext: \(error)")
        }
    }
    
    // MARK: - countries scratch context
    
    /* A core data managed object context that will not be used to persist objects. The Countries table view controller uses this context to fetch  temporary Country objects. */
    lazy var countriesScratchContext: NSManagedObjectContext = {
        var context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = CoreDataStackManager.sharedInstance().persistentStoreCoordinator
        context.mergePolicy = NSMergePolicy(mergeType: NSMergePolicyType.MergeByPropertyObjectTrumpMergePolicyType)
        return context
    }()
    
    
    // MARK: - CountryLoan context
    
    /* A core data managed object context that will be used to persist objects. The CountryLoans table view controller uses this context to persist Country objects. */
    lazy var countryLoanContext: NSManagedObjectContext = {
        var context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = CoreDataStackManager.sharedInstance().persistentStoreCoordinator
        context.mergePolicy = NSMergePolicy(mergeType: NSMergePolicyType.MergeByPropertyObjectTrumpMergePolicyType)
        return context
    }()
    
    // MARK: - countryLoan scratch context
    
    /* A core data managed object context that will not be used to persist objects. The CountryLoans table view controller uses this context to fetch  temporary Country objects. */
    lazy var countryLoanScratchContext: NSManagedObjectContext = {
        var context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = CoreDataStackManager.sharedInstance().persistentStoreCoordinator
        context.mergePolicy = NSMergePolicy(mergeType: NSMergePolicyType.MergeByPropertyObjectTrumpMergePolicyType)
        return context
    }()
    
    // MARK: - CoreDataLoanHelper contexts
    
    /* A core data managed object context that will not be used to persist objects. The CoreDataLoanHelper uses this context to fetch  temporary Loan objects. */
    lazy var coreDataLoanHelperCleanupContext: NSManagedObjectContext = {
        var context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = CoreDataStackManager.sharedInstance().persistentStoreCoordinator
        context.mergePolicy = NSMergePolicy(mergeType: NSMergePolicyType.MergeByPropertyObjectTrumpMergePolicyType)
        return context
    }()
    
    /* Save the data in the coreDataLoanHelperCleanupContext context to the core data store on disk. */
    func saveCoreDataLoanHelperCleanupContext() {
        
        let error: NSErrorPointer = nil
        do {
            _ = try CoreDataContext.sharedInstance().coreDataLoanHelperCleanupContext.save()
            
        } catch let error1 as NSError {
            error.memory = error1
            print("Error saving coreDataLoanHelperCleanupContext: \(error)")
        }
    }
    
    lazy var coreDataLoanHelperScratchContext: NSManagedObjectContext = {
        var context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = CoreDataStackManager.sharedInstance().persistentStoreCoordinator
        context.mergePolicy = NSMergePolicy(mergeType: NSMergePolicyType.MergeByPropertyObjectTrumpMergePolicyType)
        return context
    }()
}