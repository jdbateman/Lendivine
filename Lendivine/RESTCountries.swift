//
//  RESTCountries.swift
//  Lendivine
//
//  Created by john bateman on 3/9/16.
//  Copyright © 2016 John Bateman. All rights reserved.
//
//  This class provides HTTP Get and POST requests to the Countries REST service.
//  Contains methods from The Movie Manager app in the Udacity iOS Nanodegree course, Lesson 3.

import Foundation
import CoreData

class RESTCountries {
    
    /* Shared session */
    var session: NSURLSession
    
    // MARK: - Shared Instance
    
    /* Instantiate a single instance of RESTCountries. */
    class func sharedInstance() -> RESTCountries {
        
        struct Singleton {
            static var sharedInstance = RESTCountries()
        }
        
        return Singleton.sharedInstance
    }
    
    /* The main core data managed object context. This context will be persisted. */
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }()
    
    /* default initializer */
    init() {
        session = NSURLSession.sharedSession()
    }
    
    /* Create a task to send an HTTP Get request */
    func taskForGETMethod(baseUrl baseUrl: String, method: String, headerParameters: [String : AnyObject]?, queryParameters: [String : AnyObject]?, completionHandler: (result: AnyObject?, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        var mutableParameters = [String : AnyObject]()
        if let params = queryParameters {
            mutableParameters = params
        }
        
        /* 2/3. Build the URL and configure the request */
        var urlString = baseUrl + method
        if mutableParameters.count > 0 {
            urlString += RESTClient.escapedParameters(mutableParameters)
        }
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        
        // configure http header
        if let headerParameters = headerParameters {
            for (key,value) in headerParameters {
                request.addValue(key, forHTTPHeaderField: value as! String)
            }
        }
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            if let error = downloadError {
                let newError = RESTClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: newError)
            } else {
                // success
                RESTCountries.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    /* Create a task to send an HTTP Post request */
    func taskForPOSTMethod(apiKey apiKey: String, baseUrl: String, method: String, headerParameters: [String : AnyObject]?, queryParameters: [String : AnyObject]?, jsonBody: [String:AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        var mutableParameters = [String : AnyObject]()
        if let params = queryParameters {
            mutableParameters = params
        }
        if apiKey != "" {
            mutableParameters["api_key"/*ParameterKeys.ApiKey*/] = apiKey
        }
        
        /* 2/3. Build the URL and configure the request */
        var urlString = baseUrl + method
        if mutableParameters.count > 0 {
            urlString += RESTClient.escapedParameters(mutableParameters)
        }
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        
        // configure http header
        //var jsonifyError: NSError? = nil
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let headerParameters = headerParameters {
            for (key,value) in headerParameters {
                request.addValue(key, forHTTPHeaderField: value as! String)
            }
        }
        //request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonBody, options: nil, error: &jsonifyError)
        
        request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(jsonBody, options: [])
        
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            guard let data = data
                else {
                    print("no data found: \(downloadError)")
                    completionHandler(result: nil, error: downloadError)
                    return
                }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            if let error = downloadError {
                // error
                _ = RESTClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: downloadError)
            } else {
                // success
                RESTClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    /* Helper: Given a response with error, see if a status_message is returned, otherwise return the previous error */
    class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {
        
        do {
            if let parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as? NSDictionary {
                print(parsedResult)
                
                if let errorMessage = parsedResult["status_message"] as? String {
                    
                    let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                    
                    return NSError(domain: "REST service Error", code: 1, userInfo: userInfo)
                }
                
                return error
            }
        } catch let error as NSError {
            print(error.localizedDescription)
            return error
        }
        
        return error
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData?, completionHandler: (result: AnyObject?, error: NSError?) -> Void) {
        
        guard var data = data
            else {
                print("no data found")
                return
        }

//        let str = "[
//            {
//                "name": "Canada",
//                "capital": "Ottawa",
//                "altSpellings": [
//                "CA"
//                ],
//                "relevance": "2",
//                "region": "Americas",
//                "subregion": "Northern America",
//                "translations": {
//                    "de": "Kanada",
//                    "es": "Canadá",
//                    "fr": "Canada",
//                    "ja": "カナダ",
//                    "it": "Canada"
//                },
//                "population": 35749600,
//                "latlng": [
//                60,
//                -95
//                ],
//                "demonym": "Canadian",
//                "area": 9984670,
//                "gini": 32.6,
//                "timezones": [
//                "UTC−08:00",
//                "UTC−07:00",
//                "UTC−06:00",
//                "UTC−05:00",
//                "UTC−04:00",
//                "UTC−03:30"
//                ],
//                "borders": [
//                "USA"
//                ],
//                "nativeName": "Canada",
//                "callingCodes": [
//                "1"
//                ],
//                "topLevelDomain": [
//                ".ca"
//                ],
//                "alpha2Code": "CA",
//                "alpha3Code": "CAN",
//                "currencies": [
//                "CAD"
//                ],
//                "languages": [
//                "en",
//                "fr"
//                ]
//        }
//        ]"

        do {
            let parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as! [[String:AnyObject]]
                    print(parsedResult)
                    completionHandler(result: parsedResult, error: nil)
        } catch let error as NSError {
            print(error.localizedDescription)
            completionHandler(result: nil, error: error)
        }
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
}
