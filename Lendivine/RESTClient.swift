//
//  RESTClient.swift
//  OnTheMap
//
//  Created by john bateman on 7/24/15.
//  Copyright (c) 2015 John Bateman. All rights reserved.
//
//  This class provides HTTP Get and POST requests to a specified REST service. Networking is implemented using NSURLSession. This class abstracts the lower level networking and can be used by way of the Delegation pattern to handle the low level networking. KivaAPI and RESTCountries are two classes that use RESTClient in this way in this app, each implementing a distinct REST api.
//  Acknowledgement:  This class is patterned after methods from The Movie Manager app in the Udacity iOS Nanodegree course, Lesson 3.

import Foundation

class RESTClient {
    
    /* Shared session */
    var session: NSURLSession
    
    // MARK: - Shared Instance
    
    /* Instantiate a single instance of the RESTClient. */
    class func sharedInstance() -> RESTClient {
        
        struct Singleton {
            static var sharedInstance = RESTClient()
        }
        
        return Singleton.sharedInstance
    }
    
    /* default initializer */
    init() {
        session = NSURLSession.sharedSession()
    }
    
    /* Create a task to send an HTTP Get request */    
//    func taskForGETMethod(#baseUrl: String, method: String, headerParameters: [String : AnyObject], queryParameters: [String : AnyObject]?, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
//        
//        /* 1. Set the parameters */
//        var mutableParameters = [String : AnyObject]()
//        if let params = queryParameters {
//            mutableParameters = params
//        }
//        
//        /* 2/3. Build the URL and configure the request */
//        var urlString = baseUrl + method
//        if mutableParameters.count > 0 {
//            urlString += RESTClient.escapedParameters(mutableParameters)
//        }
//        let url = NSURL(string: urlString)!
//        let request = NSMutableURLRequest(URL: url)
//        
//        // configure http header
//        var jsonifyError: NSError? = nil
//        for (key,value) in headerParameters {
//            request.addValue(key, forHTTPHeaderField: value as! String)
//        }
//        
//        /* 4. Make the request */
//        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
//            /* 5/6. Parse the data and use the data (happens in completion handler) */
//            if let error = downloadError {
//                let newError = RESTClient.errorForData(data, response: response, error: error)
//                completionHandler(result: nil, error: newError)
//            } else {
//                // success
//                var returnData = data
//                
//                // ignore first 5 characters for Udacity responses
//                if baseUrl == Constants.udacityBaseURL {
//                    returnData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
//                }
//                
//                RESTClient.parseJSONWithCompletionHandler(returnData, completionHandler: completionHandler)
//            }
//        }
//        
//        /* 7. Start the request */
//        task.resume()
//        
//        return task
//    }
    
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
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let headerParameters = headerParameters {
            for (key,value) in headerParameters {
                request.addValue(key, forHTTPHeaderField: value as! String)
            }
        }
//        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonBody, options: nil, error: &jsonifyError)
        
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(jsonBody, options: NSJSONWritingOptions.PrettyPrinted)
        } catch let error as NSError {
            print(error)
        }
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            if let error = downloadError {
                let newError = RESTClient.errorForData(data, response: response, error: error)
                print("error in post request: \(newError)")
                completionHandler(result: nil, error: downloadError)
            } else {
                // success
                if let returnData = data {
                    RESTClient.parseJSONWithCompletionHandler(returnData, completionHandler: completionHandler)
                }
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    /* Return an NSMutalbeURLRequest for an HTTP Post */
    func getPostRequest(baseUrl: String, method: String, headerParameters: [String : AnyObject]?, queryParameters: [String : AnyObject]?, /*jsonBody: [String:AnyObject],*/ httpBody: NSData?) -> NSMutableURLRequest? {
        
        /* 1. Set the parameters */
        var mutableParameters = [String : AnyObject]()
        if let params = queryParameters {
            mutableParameters = params
        }
//        if apiKey != "" {
//            mutableParameters["api_key"/*ParameterKeys.ApiKey*/] = apiKey
//        }
        
        /* 2/3. Build the URL and configure the request */
        var urlString = baseUrl + method
        if mutableParameters.count > 0 {
            urlString += RESTClient.escapedParameters(mutableParameters)
        }
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        
        // configure http header
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
//TODO        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let headerParameters = headerParameters {
            for (key,value) in headerParameters {
                request.addValue(key, forHTTPHeaderField: value as! String)
            }
        }
        
        // configure the HTTPBody
        request.HTTPBody = httpBody
        
        return request
    }
    
    /* Helper: Given a response with error, see if a status_message is returned, otherwise return the previous error */
    class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {
        
        guard let data = data else {
            return NSError(domain: "REST service Error", code: 1, userInfo: [NSLocalizedDescriptionKey : "no json data in response"])
        }
            
        do {
            if let parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as? [String : AnyObject] {

                if let errorMessage = parsedResult["status_message"] as? String {
                    
                    let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                    
                    return NSError(domain: "REST service Error", code: 1, userInfo: userInfo)
                }
            }
        } catch let error as NSError? {
            return error!
        }
        
        return error
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData?, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        guard let data = data
            else {
                print("no data found")
                return
            }
        
        let dataAsUTF8String = String(data: data, encoding: NSUTF8StringEncoding)
        print("raw json data: \(dataAsUTF8String)")
        
        do {
            let parsedResult: AnyObject? = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
            // here "parsedResult" is the dictionary decoded from JSON data
            completionHandler(result: parsedResult!, error: nil)
        } catch let error as NSError {
            print(error)
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
        
        return (!urlVars.isEmpty ? "?" : "") +  urlVars.joinWithSeparator("&")
    }
}