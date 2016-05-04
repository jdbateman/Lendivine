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
    class func add(loan: KivaLoan?, toContext context: NSManagedObjectContext) -> KivaLoan? {

        var persistedLoan: KivaLoan?
        
        guard let loan = loan else {return nil}
        guard let id = loan.id else {return nil}
        
        // fetch request with predicate on loan id
        let fetchRequest = NSFetchRequest(entityName: "KivaLoan")
        fetchRequest.predicate = NSPredicate(format: "id = %@", id)
        
        // if not found instantiate object in context and save context
        do {
            let fetchResults = try context.executeFetchRequest(fetchRequest)
            
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
    
    /*! Create the loan in the context and save it if it doesn't exist, else update it if it does, then save the context. */
    class func upsert(loan: KivaLoan?, toContext context: NSManagedObjectContext) -> KivaLoan? {
        
        var persistedLoan: KivaLoan?
        
        guard let loan = loan else {return nil}
        guard let id = loan.id else {return nil}
        
        // fetch request with predicate on loan id
        let fetchRequest = NSFetchRequest(entityName: "KivaLoan")
        fetchRequest.predicate = NSPredicate(format: "id = %@", id)
        
        // if not found instantiate object in context and save context
        do {
            let fetchResults = try context.executeFetchRequest(fetchRequest)
            
            // a match was found
            if fetchResults.count != 0 {
                
                // update existing object
                
                if let fetchedLoan = fetchResults[0] as? KivaLoan {
                    
                    if let name = loan.name {
                        fetchedLoan.setValue(name, forKey: KivaLoan.InitKeys.name)
                    }
                    
                    // TODO .... finish copying properties from loan to fetchedLoan
                    
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
    class func saveContext (context: NSManagedObjectContext) {
        
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
}
