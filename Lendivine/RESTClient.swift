//
//  RESTClient.swift
//  OnTheMap
//
//  Created by john bateman on 7/24/15.
//  Copyright (c) 2015 John Bateman. All rights reserved.
//
//  This class provides HTTP Get and POST requests to a specified REST service.
//  Contains methods from The Movie Manager app in the Udacity iOS Nanodegree course, Lesson 3.

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
        var jsonifyError: NSError? = nil
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
        var jsonifyError: NSError? = nil
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
        
        //        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonBody, options: nil, error: &jsonifyError)
        
//        // TODO: try application/x-www-form-urlencoded instead of application/json for "Content-Type"
//        let loanIDs = [974236, 961687, 961683, 974236, 973680] // [961687, 961683, 974236, 973680, 974236]
//        if let body = createHTTPBody(loanIDs, appID: Constants.OAuthValues.consumerKey, donation: 10.00, callbackURL: nil /*"oauth-swift://oauth-callback/kiva"*/) {
//            request.HTTPBody = body
//        }
        
//        if let body = createHTTPBody() {
//            request.HTTPBody = body
//        }
        
        return request

//        do {
//            if NSJSONSerialization.isValidJSONObject(jsonBody) {
//                request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(jsonBody, options: NSJSONWritingOptions(rawValue: 0)/*TODO: NSJSONWritingOptions.PrettyPrinted*/)
//                return request
//            } else {
//                return nil
//            }
//        } catch let error as NSError {
//            print(error)
//            return nil
//        }
    }
    
    //TODO - test this function. may need to move it
    func createHTTPBody(loanIDs:[NSNumber], appID: String, donation: NSNumber?, callbackURL: String?) -> NSData? {
    
        var loanString = "loans=["

//        var loanString = String(format:"loans=[{\"id\":%ld,\"amount\":25}]&app_id=com.johnbateman.awesomeapp&donation=%0.2f&callback_url=oauth-swift://oauth-callback/kiva",958718,10.00)
        
        // loans
        for id in loanIDs {
            if id.intValue > 0 {
                let loanToAdd = String(format:"{\"id\":%ld,\"amount\":25},", id.intValue) // TODO: need to pass in amount for each loan individually
                loanString.appendContentsOf(loanToAdd)
            }
        }
        loanString.removeAtIndex(loanString.endIndex.predecessor())
        loanString.appendContentsOf("]")
        
        // app_id
        loanString.appendContentsOf("&app_id=" + Constants.OAuthValues.consumerKey) //("&app_id=com.johnbateman.awesomeapp")
        
        // donation
        if let donation = donation {
            loanString.appendContentsOf(String(format:"&donation=%0.2f",donation.floatValue))
        }/* else {
            loanString.append("&donation=0.00")
        }*/
            
        // callback_url
        if let callbackUrl = callbackURL {
            loanString.appendContentsOf(String(format:"&callback_url=%@",callbackUrl))
        }
        
        return loanString.dataUsingEncoding(NSUTF8StringEncoding)
    
    }

    // TODO - test function. OK to comment out.
    func createHTTPBody() -> NSData? {
        var loanString = String(format:"loans=[{\"id\":%ld,\"amount\":25}]&app_id=%@&donation=%0.2f&callback_url=oauth-swift://oauth-callback/kiva/Lendivine",974236, Constants.OAuthValues.consumerKey, 10.00)

//        var loanString = String(format:"loans=[{\"id\":%ld,\"amount\":25}]&app_id=%@&donation=%0.2f&callback_url=oauth-swift://oauth-callback/kiva",974236, Constants.OAuthValues.consumerKey, 10.00)
        
        return loanString.dataUsingEncoding(NSUTF8StringEncoding)

        // jsonBody["callback_url"] = "oauth-swift://oauth-callback/kiva"
        
        ///////////////////////
//        NSMutableString *loanString = [NSMutableString stringWithString:@"loans=["];
//        float donationAmount = 3.75 * self.loadIdsSet.count;
//        
//        for (NSNumber *loadId in self.loadIdsSet) {
//            NSString *stringToappend = [NSString stringWithFormat:@"{\"id\":%ld,\"amount\":25},", [loadId integerValue]];
//            [loanString appendString:stringToappend];
//            
//        }
//        [loanString deleteCharactersInRange:NSMakeRange([loanString length]-1, 1)];
//        [loanString appendString:[NSString stringWithFormat:@"]&app_id=com.drrajan.cp-kiva-app&donation=%0.2f", donationAmount]];
//        
//        NSData* data = [loanString dataUsingEncoding:NSUTF8StringEncoding];
//        
//        NSMutableURLRequest * request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.kiva.org/basket/set"]];
//        [request setHTTPMethod:@"POST"];
//        [request setHTTPBody:data];
    }
    
    
    /* Helper: Given a response with error, see if a status_message is returned, otherwise return the previous error */
    class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {

// TODO: remove legacy code
//        if let parsedResult = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil) as? [String : AnyObject] {
        
            
        do {
            if let parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as? [String : AnyObject] {

                if let errorMessage = parsedResult["status_message"] as? String {
                    
                    let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                    
                    return NSError(domain: "REST service Error", code: 1, userInfo: userInfo)
                }
            }
        } catch let error as NSError? {
            return error!
        }
            
            
// TODO: remove legacy code
//        }
        
        return error  // TODO - should re-throw the error
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        let dataAsUTF8String = String(data: data, encoding: NSUTF8StringEncoding)
        print("raw json data: \(dataAsUTF8String)")
        
// TODO: remove legacy code
//        var parsingError: NSError? = nil
//        let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
        
        do {
            let parsedResult: AnyObject? = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
            // here "parsedResult" is the dictionary decoded from JSON data
            completionHandler(result: parsedResult!, error: nil)
        } catch let error as NSError {
            print(error)
            completionHandler(result: nil, error: error)
        }
        
// TODO: legacy code - remove it
//        if let error = parsingError {
//            completionHandler(result: nil, error: error)
//        } else {
//            completionHandler(result: parsedResult, error: nil)
//        }
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
        
        return (!urlVars.isEmpty ? "?" : "") +  urlVars.joinWithSeparator("&") // join("&", urlVars)
    }
}