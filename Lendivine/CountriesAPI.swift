//
//  CountriesAPI.swift
//  Lendivine
//
//  Created by john bateman on 3/9/16.
//  Copyright © 2016 John Bateman. All rights reserved.
//
// An extension of RESTCountries providing a wrapper api that acquires data on countries using the RestCountries API: http://restcountries.eu/, 
// JSON data returned by rest queries is converted to core data manage objects on the main thread in this extension.

import Foundation
import CoreData

extension RESTCountries {
    
    /*
        @brief Get a collection of Country objects representing all countries.
        @discussion Parses the data returned from the RESTCountries api into a collection of Country objects. Invokes the https://restcountries.eu/rest/v1/all endpoint.
        @return A collection of Country objects, else nil if an error occurred.
    */
    func getCountries(completionHandler: (countries: [Country]?, error: NSError?) -> Void) {
        
        /* 1. Specify parameters */
        // none
        
        // set up http header parameters
        // none
        
        /* 2. Make the request */
        //let apiEndpoint = "name/canada"
        let apiEndpoint = "all"
        taskForGETMethod(baseUrl: "https://restcountries.eu/rest/v1/", method: apiEndpoint, headerParameters: nil, queryParameters: nil) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                // didn't work. bubble up error.
                completionHandler(countries: nil, error: error)
            } else {
                // parse the json response
                var countries = [Country]()
                
                if let returnData = JSONResult as! [[String:AnyObject]]? {
                    
                    // Ensure cored data operations happen on the main thread.
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        // Convert each dictionary in the response data into a Country object.
                        for dictionary in returnData {
                            let country:Country = Country(dictionary: dictionary, context: self.sharedContext)
                            countries.append(country)
                        }
                        completionHandler(countries: countries, error: nil)
                    }
                }
            else {
                    completionHandler(countries: nil, error: error)
                }
            }
        }
    }
}