//
//  CoreDataLoanHelper.swift
//  Lendivine
//
//  Created by john bateman on 5/3/16.
//  Copyright © 2016 John Bateman. All rights reserved.
//
// This class contains methods to help do CRUD operations involving KivaLoans in a core data context.

import Foundation
import CoreData

class CoreDataLoanHelper {
    
    /*! Add the loan to the context and save it if it doesn't exist, else NOOP. */
    class func add(_ loan: KivaLoan?, toContext context: NSManagedObjectContext) -> KivaLoan? {

        var persistedLoan: KivaLoan?
        
        guard let loan = loan else {return nil}
        guard let id = loan.id else {return nil}
        
        // fetch request with predicate on loan id
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "KivaLoan")
        fetchRequest.predicate = NSPredicate(format: "id = %@", id)
        
        // if not found instantiate object in context and save context
        do {
            let fetchResults = try context.fetch(fetchRequest)
            
            // a match was found
            if fetchResults.count == 0 {

                // no matches to exiting core data objects on disk. save the new object in core data.
                
                // instantiate a new copy of the loan in the desired context
                persistedLoan = KivaLoan(fromLoan: loan, context: context)
            
                // save the context to the persistent store
                CoreDataLoanHelper.saveContext(context)
            }
            
        } catch let error as NSError {
            
            // failure...don't save the new object
            print("Fetch failed: \(error.localizedDescription). Aborting save of account object to core data.")
        }
        
        return persistedLoan
    }
    
    /*! Create the loan in the context and save it to the persistent store on disk if it doesn't exist, else update it if it does, then save the context. */
    class func upsert(_ loan: KivaLoan?, toContext context: NSManagedObjectContext) -> KivaLoan? {
        
        var persistedLoan: KivaLoan?
        
        guard let loan = loan else {return nil}
        guard let id = loan.id else {return nil}
        
        // fetch request with predicate on loan id
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "KivaLoan")
        fetchRequest.predicate = NSPredicate(format: "id = %@", id)
        
        // if not found instantiate object in context and save context
        do {
            let fetchResults = try context.fetch(fetchRequest)
            
            // a match was found
            if fetchResults.count > 0 {
                
                // update existing object
                
                if let fetchedLoan = fetchResults[0] as? KivaLoan {
                    
                    if let name = loan.name {
                        fetchedLoan.setValue(name, forKey: KivaLoan.InitKeys.name)
                    }
                    
                    fetchedLoan.update(fromLoan:loan)
                    
                    persistedLoan = fetchedLoan
                }
                
            }  else {
                
                // no matches to exiting core data objects on disk. save the new object in core data.
                
                // instantiate a new copy of the loan in the desired context
                persistedLoan = KivaLoan(fromLoan: loan, context: context)
            }
            
            // save the context to the persistent store
            CoreDataLoanHelper.saveContext(context)
            
        } catch let error as NSError {
            
            // failure...don't save the new object
            print("Fetch failed: \(error.localizedDescription). Aborting save of account object to core data.")
        }
        
        return persistedLoan
    }
 
    /*! Save the managed object context to the persistent store. */
    class func saveContext (_ context: NSManagedObjectContext) {
        
        var error: NSError? = nil
        
        if context.hasChanges {
            
            do {
                try context.save()

            } catch let error1 as NSError {
                
                error = error1
                
                print("Unresolved error \(error), \(error!.userInfo)")
            }
        }
    }
    
    /*! 
        @brief Scrub for duplicate loans and remove any duplicate objects from the persistant store.
        @discussion This function is not responsible for cleaning up duplicates in a context. It uses it's own internal context in order to clean up duplicates in the core data persistent store. It is the perogative of the caller to do a new fetch after this function finishes.
    */
    class func cleanup() {
        
        let context = CoreDataContext.sharedInstance().coreDataLoanHelperScratchContext
        
        // fetch request for all KivaLoan objects
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "KivaLoan")
        
        do {
            let fetchResults = try context.fetch(fetchRequest)
            
            let results = fetchResults
            for result in results {
                if let loan = result as? KivaLoan {
                    CoreDataLoanHelper.removeDuplicatesForLoan(loan)
                }
            }
        } catch let error as NSError {
            
            // failure
            print("Fetch failed during a clean: \(error.localizedDescription).")
        }
    }
    
    /*! 
        @brief Delete duplicates of the loan object in the context and persistant store.
        @discussion Duplicates are determined by a match of the Kiva loan entities' id property. This call uses it's own context.
    */
    class func removeDuplicatesForLoan(_ loan: KivaLoan?) {
    
        let context = CoreDataContext.sharedInstance().coreDataLoanHelperCleanupContext
        context.reset()
        
        guard let loan = loan else {return}
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "KivaLoan")
        
        if let id = loan.id {
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", id)
            
            do {
                if let count = try? context.count(for: fetchRequest) {
                    if (count != NSNotFound && count > 1) {
                        
                        // Found duplicates. Remove them.
                        
                        // Fetch loan with duplicates by id and elete all after first item.
                        
                        let dupFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "KivaLoan")
                        dupFetchRequest.predicate = NSPredicate(format: "id = %@", id)
                        let dupFetchResults = try context.fetch(dupFetchRequest)
                        let dupResults = dupFetchResults
                        let count = dupResults.count
                        for i in 1..<count {
                            if let loan = dupResults[i] as? KivaLoan {
                                //assert(false,"Should not have duplicate loans! Found duplicate: \(loan)")
                                print("cleaning up duplicate loan \(loan)")
                                context.delete(loan)
                            }
                        }
                        
                        // Save the context in order to update the persistent store.
                        CoreDataContext.sharedInstance().saveCoreDataLoanHelperCleanupContext()
                        
                    } else {
                        // no duplicates.
                    }
                }
                
            } catch let error as NSError {
                
                // failure
                print("Fetch failed: \(error.localizedDescription). Aborting save of account object to core data.")
            }
        }
    }
    
}
