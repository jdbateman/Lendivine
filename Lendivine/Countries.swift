//
//  Countries.swift
//  Lendivine
//
//  Created by john bateman on 3/12/16.
//  Copyright © 2016 John Bateman. All rights reserved.
//
//  This class implements a higher level interface to initialize core data with countries queried from the RESTCountries api, and to interact with the collection of countries persisted to core data.

import Foundation
import CoreData

/* A custom NSNotification that indicates any updated country data from the web service is now available in core data. */
let countriesUpdateNotificationKey = "com.lendivine.countries.update"


class Countries {
    
    /* The main core data managed object context. This context will be persisted. */
    static var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }()
    
    /*!
        @brief Initialize Core data with all countries from the RESTCountries.eu api. Country objects are persisted in core data. 
        @discussion This is an asynchronous method that interacts with a REST service. Objects are persisted to the shared core data context. No duplicate country objects are persisted.
    */
    class func persistCountriesFromWebService(completionHandler: ((success: Bool, error: NSError?) -> Void)? ) {
        
        // Acquire countries from rest api.
        restCountriesAPI.getCountries() { countries, error in
            
            if let countries = countries {
                
                Countries.persistNewCountries(countries)
                
                Countries.sendUpdatedCountriesNotification()
                
                if completionHandler != nil {
                    completionHandler!(success: true, error: nil)
                }
                
            } else {
                
                if completionHandler != nil {
                    completionHandler!(success: false, error: error)
                }
            }
        }
    }
    
    /*! Provides a count of countries that reside in core data in memory. Note that these objects have not necessarily been persisted to the sqlite store yet. */
    class func countCountries() -> Int {
        
        var error: NSError?
        
        let fetchRequest = NSFetchRequest(entityName: Country.entityName)
        
        let count = sharedContext.countForFetchRequest(fetchRequest, error:&error)
        
        if (count == NSNotFound) {
            print("Error: \(error)")
            return 0
        }
        
        return count
    }
    
    /*! Provides a count of the number of Country objects that match the specified Country that reside in core data in memory. Note that these objects have not necessarily been persisted to the sqlite store yet. */
    class func countCountry(country: Country?) -> Int {
        
        guard let country = country else {
            return 0
        }
        
        var error: NSError?
        
        let fetchRequest = NSFetchRequest(entityName: Country.entityName)
        
        fetchRequest.predicate = NSPredicate(format: "name == %@", country.name!)
        
        let count = sharedContext.countForFetchRequest(fetchRequest, error:&error)
        
        if (count == NSNotFound) {
            print("Error: \(error)")
            return 0
        }
        
        return count
    }
    
    /*! Returns true if a Country object with the same name already exists in core data memory. */
    class func doesCountryExistInCoreData(country: Country?) -> Bool {
        
        guard let country = country else {
            return false
        }
        
        var error: NSError?
        
        let fetchRequest = NSFetchRequest(entityName: Country.entityName)
        
        fetchRequest.predicate = NSPredicate(format: "name == %@", country.name!)
        
        let count = sharedContext.countForFetchRequest(fetchRequest, error:&error)
        
        if (count == NSNotFound) {
            print("Error: \(error)")
            return false
        } else if count == 0 {
            return false
        }
        
        return true
    }
    
    /*! Saves new countries to core data context. Does not persist duplicate Country objects. */
    class func persistNewCountries(countries: [Country]?) {
        
        var duplicateCountries = [Country]()
        
        guard let countries = countries else {
            return
        }
        
        for country in countries {
            
            if Countries.countCountry(country) > 1  {
            //if Countries.doesCountryExistInCoreData(country) {
                
                duplicateCountries.append(country)
                //print("added duplicate country = \(country)")
            }
        }
        
        // When the Country NSManaged objects were created they were saved to the in-memory version of the core data context.
        // Here will save all countries from core data memory to the core data sqlite store on disk.
        print("saveContext: Countries.persistNewCountries()")
        CoreDataStackManager.sharedInstance().saveContext()
        
        // remove all duplicates
        print("removing \(duplicateCountries.count) duplicate countries")
        for dupCountry in duplicateCountries {
            
            // delete the object from core data memory
            sharedContext.deleteObject(dupCountry)
        }
        
        // commit the deletes to the core data sqlite data store on disk
        print("saveContext: Countries.persistNewCountries()")
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    /*! Return a randomized comma separated string of country names. */
    class func getRandomCountries(numberOfCountries:Int = 20) -> String? {
        
        var countries = [String]()
        var randomCountries = [String]()
        
        let fetchRequest = NSFetchRequest(entityName: Country.entityName)
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
        
        _ = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext:
            CoreDataStackManager.sharedInstance().scratchContext, sectionNameKeyPath: nil, cacheName: nil)

        var results: [AnyObject]?
        do {
            results = try sharedContext.executeFetchRequest(fetchRequest)
            if let results = results {
                for result in results {
                    if let result = result as? Country {
                        if let name = result.name {
                            countries.append(name)
                        }
                    }
                }
            }
        } catch let error1 as NSError {
            print("Error in fetchLoanByID(): \(error1)")
            results = nil
        }

        // add the requested number of randomly selected countries
        for var i = 0; i < numberOfCountries; i++ {
            let index = Int(arc4random_uniform(UInt32(countries.count)))
            randomCountries.append(countries[index])
        }
        
        let randomCountriesString = randomCountries.joinWithSeparator(",")
        
        return randomCountriesString
    }
    
    enum RandomCountryResultType {
        case Name, TwoLetterCode
    }
    
    /*! Return a randomized comma separated string of two letter country codes. */
    class func getRandomCountryCodes(numberOfCountries:Int = 20, resultType:RandomCountryResultType = .Name) -> String? {
        
        var countries = [String]()
        var randomCountries = [String]()
        
        let fetchRequest = NSFetchRequest(entityName: Country.entityName)
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
        
        _ = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext:
            CoreDataStackManager.sharedInstance().scratchContext, sectionNameKeyPath: nil, cacheName: nil)
        
        var results: [AnyObject]?
        do {
            results = try sharedContext.executeFetchRequest(fetchRequest)
            if let results = results {
                for result in results {
                    if let result = result as? Country {
                        if resultType == .Name {
                            if let name = result.name {
                                countries.append(name)
                            }
                        } else if resultType == .TwoLetterCode {
                            if let countryCode = result.countryCodeTwoLetter {
                                countries.append(countryCode)
                            }
                        }
                    }
                }
            }
        } catch let error1 as NSError {
            //error!.memory = error1
            print("Error in fetchLoanByID(): \(error1)")
            results = nil
        }
        
        // add the requested number of randomly selected countries
        for var i = 0; i < numberOfCountries; i++ {
            let index = Int(arc4random_uniform(UInt32(countries.count)))
            randomCountries.append(countries[index])
        }
        
        let randomCountriesString = randomCountries.joinWithSeparator(",")
        
        return randomCountriesString
    }
    
    
    
    // MARK: - Fetched results controller
    
    static var fetchedResultsController: NSFetchedResultsController = {
        
        // Create the fetch request
        let fetchRequest = NSFetchRequest(entityName: Country.entityName)
        
        // Add a sort descriptor to enforce a sort order on the results.
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        // Create the Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext:
            CoreDataStackManager.sharedInstance().scratchContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Return the fetched results controller. It will be the value of the lazy variable
        return fetchedResultsController
    } ()
    
    /* Perform a fetch of Country objects to update the fetchedResultsController with the current data from the core data store. */
    class func fetchCountries() {
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            let error = error1
            print("\(error)")
        }
    }
    
    // MARK - notifications
    
    /*! Send a notification indicating that any new country obtained from the rest service is now avaiable in core data. */
    class func sendUpdatedCountriesNotification() {
        NSNotificationCenter.defaultCenter().postNotificationName(countriesUpdateNotificationKey, object: self)
    }
    
}