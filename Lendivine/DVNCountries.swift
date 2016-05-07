//
//  DVNCountries.swift
//  Lendivine
//
//  Created by john bateman on 5/7/16.
//  Copyright © 2016 John Bateman. All rights reserved.
//

import Foundation
import CoreData

class DVNCountries {

// MARK: - Fetched results controller

    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        // Create the fetch request
        let fetchRequest = NSFetchRequest(entityName: Country.entityName)
        
        // Add a sort descriptor to enforce a sort order on the results.
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
        
        // Create the Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext:
            CoreDataContext.sharedInstance().countriesScratchContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Return the fetched results controller. It will be the value of the lazy variable
        return fetchedResultsController
    } ()


    /*! Perform a fetch of Country objects from the countriesScratchContext filtered for those that contain the specified userInput string. */
    class func fetchCountriesFilteredByNameOn(userInput: String?) -> [AnyObject]? {
        
        guard let userInput = userInput else {
            return nil
        }
        
        let fetchRequest = NSFetchRequest(entityName: Country.entityName)
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
        
        fetchRequest.predicate = NSPredicate(format: "name CONTAINS[cd] %@", userInput)
        //let searchPredicate = NSPredicate(format: "SELF.name CONTAINS[c] %@", searchController.searchBar.text!)
        
        _ = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext:
            CoreDataContext.sharedInstance().countriesScratchContext, sectionNameKeyPath: nil, cacheName: nil)
        
        var results: [AnyObject]?
        do {
            results = try CoreDataContext.sharedInstance().countriesContext.executeFetchRequest(fetchRequest)
        } catch let error1 as NSError {
            print("Error in fetchCountriesFilteredByNameOn(): \(error1)")
            results = nil
        }
        
        return results
    }
}