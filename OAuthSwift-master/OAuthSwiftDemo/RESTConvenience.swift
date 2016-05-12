//
//  RESTConvenience.swift
//  OnTheMap
//
//  Created by john bateman on 7/24/15.
//  Copyright (c) 2015 John Bateman. All rights reserved.
//
// Udacity API for On The Map Instructions:  https://docs.google.com/document/d/1MECZgeASBDYrbBg7RlRu9zBBLGd3_kfzsN-0FtURqn0/pub?embedded=true
//
// This file provides an extension to RESTClient that provides a high level abstraction of the REST API calls to Udacity and Parse.
/*
import Foundation

extension RESTClient {
    
    // MARK: GET Convenience Methods
    
    /*
    @brief Makes a rest query to the Parse service to retrieve an array of student location dictionaries.
    @param (in) skip - Indicates the number of results to skip when returning the list of query results. (cannot be nil).
    @param (in) limit - The maximum number of records to return for a single query. (cannot be nil)
    @return An array of location dictionaries in the completionHandler. success Is true if the array contains valid data, else success is false. If success is false then errorString describes the error.
    */
    func getStudentLocations(skip: Int, limit: Int, completionHandler: (success: Bool, arrayOfLocationDictionaries: [AnyObject]?, errorString: String?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}) */
        var parameters = [
            "limit" : String(limit),
            "skip" : String(skip)
        ]
        
        // set up http header parameters
        let headerParms = [
            Constants.ParseAppID : "X-Parse-Application-Id",
            Constants.ParseApiKey : "X-Parse-REST-API-Key"
        ]
            
        /* 2. Make the request */
        taskForGETMethod(baseUrl: RESTClient.Constants.parseBaseURL, method: RESTClient.Constants.parseGetStudentLocations, headerParameters: headerParms, queryParameters: parameters) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                // Set error string to localizedDescription in error
                completionHandler(success: false, arrayOfLocationDictionaries: nil, errorString: error.localizedDescription)
            } else {
                // parse the json response which looks like the following:
                /*
                    {
                        "results":[
                            {
                                "createdAt": "2015-02-25T01:10:38.103Z",
                                "firstName": "Jarrod",
                                "lastName": "Parkes",
                                "latitude": 34.7303688,
                                "longitude": -86.5861037,
                                "mapString": "Huntsville, Alabama ",
                                "mediaURL": "https://www.linkedin.com/in/jarrodparkes",
                                "objectId": "JhOtcRkxsh",
                                "uniqueKey": "996618664",
                                "updatedAt": "2015-03-09T22:04:50.315Z"
                            },
                            ...
                        ]
                    }
                */
                if let arrayOfLocationDicts = JSONResult.valueForKey("results") as? [AnyObject] {
                    completionHandler(success: true, arrayOfLocationDictionaries: arrayOfLocationDicts, errorString: nil)
                } else {
                    completionHandler(success: false, arrayOfLocationDictionaries: nil, errorString: "No results from server.")
                }
            }
        }
    }
    
    /*
    @brief Get Udacity user information for the specified userID.
    @discussion Parses the user information returned from the Udacity REST api into a StudentLocation object.
    @param (in) userID - The Udacity user account ID. (cannot be nil)
    @return StudentLocation object containing user information returned from the Udacity service, else nil if an error occurred.
    */
    func getUdacityUser(#userID: String, completionHandler: (result: Bool, studentLocation: StudentLocation?, error: NSError?) -> Void) {
        
        /* 1. Specify parameters */
        // none
        
        // set up http header parameters
        let headerParms = [
            Constants.ParseAppID : "X-Parse-Application-Id",
            Constants.ParseApiKey : "X-Parse-REST-API-Key"
        ]
        
        /* 2. Make the request */
        taskForGETMethod(baseUrl: RESTClient.Constants.udacityBaseURL, method: RESTClient.Constants.udacityGetUserMethod + userID, headerParameters: headerParms, queryParameters: nil) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                // didn't work. bubble up error.
                completionHandler(result: false, studentLocation: nil, error: error)
            } else {
                // parse the json response which looks like the following:
                /*
                {
                "user":{
                "last_name":"Doe",
                "social_accounts":[
                ],
                "mailing_address":null,
                ...,
                "_facebook_id":null,
                ...,
                "first_name":"John",
                ...,
                "location":null,
                ...,
                "email":{
                ...,
                "_verified":true,
                "address":"john.doe.udacity.user@gmail.com"
                },
                "website_url":null,
                ...,
                "key":"3903878747",
                ...,
                "_image_url":"//robohash.org/udacity-3903878747.png"
                }
                }
                */
                var userLocation = StudentLocation()
                userLocation.uniqueKey = userID
                if let userDictionary = JSONResult.valueForKey("user") as? [String: AnyObject] {
                    if let lastName = userDictionary["last_name"] as? String {
                        userLocation.lastName = lastName
                    }
                    if let firstName = userDictionary["first_name"] as? String {
                        userLocation.firstName = firstName
                    }
                    if let url = userDictionary["website_url"] as? String{
                        userLocation.mediaURL = url
                    }
                    if let key = userDictionary["key"] as? String {
                        userLocation.uniqueKey = key
                    }
                    completionHandler(result: true, studentLocation: userLocation, error: nil)
                } else {
                    completionHandler(result: false, studentLocation: nil, error: error)
                }
            }
        }
    }
    
    
    // MARK: POST Convenience Methods

    /*
        @brief Post user's location to Parse.
        @return void
        completion handler:
            result Contains true if post was successful, else it contains false if an error occurred.
            error  An error if something went wrong, else nil.
    */
    func postStudentLocationToParse(studentLocation: StudentLocation, completionHandler: (result: Bool, error: NSError?) -> Void) {
       
        /* 1. Specify parameters, method (if has {key}) */
        // none
        
        // specify base URL
        let baseURL = RESTClient.Constants.parseBaseURL
        
        // specify method
        var mutableMethod : String = RESTClient.Constants.parseGetStudentLocations
        
        // set up http header parameters
        let headerParms = [
            Constants.ParseAppID : "X-Parse-Application-Id",
            Constants.ParseApiKey : "X-Parse-REST-API-Key"
        ]
        
        /* HTTP body
            {
                "uniqueKey" : "1234", 
                "firstName" : "Johnny",
                "lastName" : "Appleseed",
                "mapString" : "San Carlos, CA",
                "mediaURL" : "https://udacity.com",
                "latitude" : 37.4955,
                "longitude" : -122.2668
            }
        */

        // create the HTTP body
        // enable parameterized values.
        let jsonBody : [String: AnyObject] = [
            "uniqueKey" : studentLocation.uniqueKey,
            "firstName" : studentLocation.firstName,
            "lastName" : studentLocation.lastName,
            "mapString" : studentLocation.mapString,
            "mediaURL" : studentLocation.mediaURL,
            "latitude" : studentLocation.latitude,
            "longitude" : studentLocation.longitude
        ]
        
        /* 2. Make the request */
        let task = taskForPOSTMethod(apiKey: "", baseUrl: baseURL, method: mutableMethod, headerParameters: headerParms, queryParameters: nil, jsonBody: jsonBody) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandler(result: false, error: error)
            } else {
                // parse the json response which looks like the following:
                /*
                    {
                        "createdAt":"2015-03-11T02:48:18.321Z",
                        "objectId":"CDHfAy8sdp"
                    }
                */
                if let errorString = JSONResult.valueForKey("error") as? String {
                    // a valid response was received from the service, but the response contains an error code like the following:
                    /*
                        {
                            code = 142
                            error = "uniqueKey is required for a Student Location"
                        }
                    */
                    let error = NSError(domain: "Parse POST response", code: 0, userInfo: [NSLocalizedDescriptionKey: errorString])
                    completionHandler(result: false, error: error)
                } else {
                    if let dictionary = JSONResult.valueForKey("objectId") as? String {
                        completionHandler(result: true, error: nil)
                    } else {
                        completionHandler(result: false, error: NSError(domain: "parsing Parse POST response", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse postToFavoritesList"]))
                    }
                }
            }
        }
    }

    
    /*
        @brief Login to Udacity.
        @return void
            completion handler:
                result Contains true if login was successful, else it contains false if an error occurred.
                accountKey A string identifying the user's Id if login was successful (example: "3903878747"), else the empty string.                error  An error if something went wrong, else nil.
    */
    func loginUdacity(#username: String, password: String, completionHandler: (result: Bool, accountKey: String, error: NSError?) -> Void) {
        
        /* 1. Specify parameters */
        let parameters: String? = nil
        
        // specify base URL
        let baseURL = Constants.udacityBaseURL
        
        // specify method
        var mutableMethod : String = RESTClient.Constants.udacitySessionMethod
        
        // specify HTTP body (for POST method)
            /* The Udacity http body for creating a session:
                {
                    "udacity" : {
                    "username" : "account@domain.com"
                    "password" : "********"
                }
            */
        let credentials: Dictionary = ["username" : username, "password" : password]
        let jsonBody : [String:AnyObject] = [
            "udacity" : credentials
        ]
        
        /* 2. Make the request */
        let task = taskForPOSTMethod(apiKey: "", baseUrl: baseURL, method: mutableMethod, headerParameters: nil, queryParameters: nil, jsonBody: jsonBody) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                /* Note: If the internet connection is offline, the system generates an NSError and the function returns here. */
                completionHandler(result: false, accountKey:"", error: error)
            } else {
                // parse the json response which looks like the following:
                /*
                    {
                        "account":{
                            "registered":true,
                            "key":"3903878747"
                        },
                        "session":{
                            "id":"1457628510Sc18f2ad4cd3fb317fb8e028488694088",
                            "expiration":"2015-05-10T16:48:30.760460Z"
                        }
                    }
                */
                if let account = JSONResult.valueForKey("account") as? [String : AnyObject] {
                    var registered = false
                    var key = ""
                    if let _registered = account["registered"] as? Bool {
                        registered = _registered
                        if let _key = account["key"] as? String {
                            key = _key
                        }
                    }
                    completionHandler(result: registered, accountKey:key, error: nil)
                } else {
                    /* The Login request received a valid response, but the Login failed. The following are error responses from the Udacity service for typical failures:
                    
                        // On nonexistant account, or invalid credentials
                        {"status": 403, "error": "Account not found or invalid credentials."}
                        
                        // On missing username
                        {"status": 400, "parameter": "udacity.username", "error": "trails.Error 400: Missing parameter 'username'"}
                        
                        // On missing password
                        {"status": 400, "parameter": "udacity.password", "error": "trails.Error 400: Missing parameter 'password'"}
                    */
                    
                    var description = "Login error."
                    var code = 0
                    if let error = JSONResult.valueForKey("error") as? String {
                        description = error
                    }
                    if let resultCode = JSONResult.valueForKey("status") as? Int {
                        code = resultCode
                    }
                    completionHandler(result: false, accountKey:"", error: NSError(domain: "Udacity Login", code: code, userInfo: [NSLocalizedDescriptionKey: description]))
                }
            }
        }
    }
    
    /* 
        @brief logout of a Udacity session.
    */
    func logoutUdacity(completionHandler: (result: Bool, error: NSError?) -> Void) {

        let sessionUrl = RESTClient.Constants.udacityBaseURL + RESTClient.Constants.udacitySessionMethod
        let request = NSMutableURLRequest(URL: NSURL(string: sessionUrl)!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies as! [NSHTTPCookie] {
            if cookie.name == "XSRF-TOKEN" {
                xsrfCookie = cookie
            }
        }
        if let xsrfCookie = xsrfCookie {
            request.addValue(xsrfCookie.value!, forHTTPHeaderField: "X-XSRF-Token")
        }
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                completionHandler(result: false, error: error)
            } else {
                // the json response looks like the following:
                /*
                {
                    "session": {
                        "id": "1463940997_7b474542a32efb8096ab58ced0b748fe",
                        "expiration": "2015-07-22T18:16:37.881210Z"
                    }
                }
                */

                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
                //println(NSString(data: newData, encoding: NSUTF8StringEncoding))
                
                completionHandler(result: true, error: nil)
            }
        }
        task.resume()
    }
    
}
*/