//
//  Country.swift
//  Lendivine
//
//  Created by john bateman on 3/10/16.
//  Copyright © 2016 John Bateman. All rights reserved.
//
/* example country data: 
    https://github.com/fayder/restcountries/wiki/API-1.x.x 
    http://restcountries.eu/
*/

import Foundation
import UIKit
import CoreData

// make Country visible to CoreData
@objc(Country)

class Country: NSManagedObject /*, Equatable  < todo remove*/  {
    
    static let entityName = "Country"
    
    struct InitKeys {
        static let name: String = "name"
        static let capital: String = "capital"
        static let region: String = "region"
        static let subregion: String = "subregion"
        static let population: String = "population"            // 26023100
        static let latlng: String = "latlng"                    // "latlng": [33,65]
        static let area: String = "area"                        // 652230
        static let borders: String = "borders"                  // ["IRN","PAK","TKM","UZB","TJK","CHN"]
        static let currencies: String = "currencies"            // ["AFN"]
        static let languages: String = "languages"              // ["ps","uz","tk"]
        static let timezones: String = "timezones"              // ["UTC+04:30"]
        static let gini: String = "gini"                        // 27.8    (where 0 is total equality, 100 is total inequality)
        static let topLevelDomain: String = "topLevelDomain"    // [".af"]
        static let alpha2Code: String = "alpha2Code"            // "AF"
        static let alpha3Code: String = "alpha3Code"            // "AFG"
    }
    
    @NSManaged var name: String?
    

    /*! Core Data init method */
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    /*! Init instance with a dictionary of values, and a core data context. */
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName(Country.entityName, inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.name = dictionary[InitKeys.name] as? String
    }
}

/*! Support Equatable protocol. Allows KivaCartItem instances to be compared. */
func ==(lhs: Country, rhs: Country) -> Bool {
    return (lhs.name == rhs.name)
}