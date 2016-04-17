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
    //    let headerParms = [
    //        Constants.ParseAppID : "X-Parse-Application-Id",
    //        Constants.ParseApiKey : "X-Parse-REST-API-Key"
    //    ]
        
        /* 2. Make the request */
        //let apiEndpoint = "name/canada"
        let apiEndpoint = "all"
        taskForGETMethod(baseUrl: "https://restcountries.eu/rest/v1/", method: apiEndpoint, headerParameters: nil, queryParameters: nil) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                // didn't work. bubble up error.
                completionHandler(countries: nil, error: error)
            } else {
                // parse the json response which looks like the following:
                /*
                {

                }
                */
                var countries = [Country]()
                
                
                if let returnData = JSONResult as! [[String:AnyObject]]? {
                    //print("\(returnData)")
                    
                    // Ensure cored data operations happen on the main thread.
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        // Convert each dictionary in the response data into a Country object.
                        for dictionary in returnData {
                            let country:Country = Country(dictionary: dictionary, context: self.sharedContext)
                            //print("country: \(country)")
                            countries.append(country)
                            
                            //CoreDataStackManager.sharedInstance().saveContext() // todo remove debug
                        }
                        
                        // TODO remove this test code
                        //CoreDataStackManager.sharedInstance().saveContext()
                        
                        print("countries in core data = \(Countries.countCountries())")
                        
                        completionHandler(countries: countries, error: nil)
                    }
                }
                
//                if let returnData = JSONResult {
//                    RESTCountries.parseJSONWithCompletionHandler(returnData as? NSData, completionHandler: completionHandler)
//                }
                
                //NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
//                
//                let thedata:NSString = String(NSData:JSONResult, encoding:NSUTF8StringEncoding);
//                    
//                let jsonDict: AnyObject! = try? NSJSONSerialization.JSONObjectWithData(thedata, options: [.NSJSONReadingMutableContainers])
//                if let jsonDict = jsonDict {
//                    print(jsonDict)
//                }
                
                //NSString *data=[[NSString alloc]initWithData:JSONResult encoding:NSUTF8StringEncoding];
                
                //NSDictionary *search = [NSJSONSerialization JSONObjectWithData:[data dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                
//                if let userDictionary = JSONResult.valueForKey("user") as? [String: AnyObject] {
//                    
//// TODO - parse JSON here and save each country in array for return.
//                    
////                    if let lastName = userDictionary["last_name"] as? String {
////                        userLocation.lastName = lastName
////                    }
////                    if let firstName = userDictionary["first_name"] as? String {
////                        userLocation.firstName = firstName
////                    }
////                    if let url = userDictionary["website_url"] as? String{
////                        userLocation.mediaURL = url
////                    }
////                    if let key = userDictionary["key"] as? String {
////                        userLocation.uniqueKey = key
////                    }
//                    
//                    completionHandler(countries: countries, error: nil)
//                }
            else {
                    completionHandler(countries: nil, error: error)
                }
            }
        }
    }
}