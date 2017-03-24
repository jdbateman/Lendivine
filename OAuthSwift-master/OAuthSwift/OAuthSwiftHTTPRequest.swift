//
//  OAuthSwiftHTTPRequest.swift
//  OAuthSwift
//
//  Created by Dongri Jin on 6/21/14.
//  Copyright (c) 2014 Dongri Jin. All rights reserved.
//

import Foundation

open class OAuthSwiftHTTPRequest: NSObject, URLSessionDelegate {

    public typealias SuccessHandler = (_ data: Data, _ response: HTTPURLResponse) -> Void
    public typealias FailureHandler = (_ error: NSError) -> Void

    var URL: Foundation.URL
    var HTTPMethod: String
    var HTTPBodyMultipart: Data?
    var contentTypeMultipart: String?

    var request: NSMutableURLRequest?
    var session: URLSession!

    var headers: Dictionary<String, String>
    var parameters: Dictionary<String, AnyObject>
    var encodeParameters: Bool

    var dataEncoding: String.Encoding

    var timeoutInterval: TimeInterval

    var HTTPShouldHandleCookies: Bool

    var response: HTTPURLResponse!
    var responseData: NSMutableData

    var successHandler: SuccessHandler?
    var failureHandler: FailureHandler?

    convenience init(URL: Foundation.URL) {
        self.init(URL: URL, method: "GET", parameters: [:])
    }

    init(URL: Foundation.URL, method: String, parameters: Dictionary<String, AnyObject>) {
        self.URL = URL
        self.HTTPMethod = method
        self.headers = [:]
        self.parameters = parameters
        self.encodeParameters = false
        self.dataEncoding = String.Encoding.utf8
        self.timeoutInterval = 60
        self.HTTPShouldHandleCookies = false
        self.responseData = NSMutableData()
    }

    init(request: URLRequest) {
        
        // request as? NSMutableURLRequest
        self.request = ((request as NSURLRequest).mutableCopy() as? NSMutableURLRequest)! //todo:swift3
        
        self.URL = request.url!
        self.HTTPMethod = request.httpMethod!
        self.headers = [:]
        self.parameters = [:]
        self.encodeParameters = false
        self.dataEncoding = String.Encoding.utf8
        self.timeoutInterval = 60
        self.HTTPShouldHandleCookies = false
        self.responseData = NSMutableData()
    }

    func start() {
        if (request == nil) {
            var error: NSError?

            do {
                self.request = try self.makeRequest()
            } catch let error1 as NSError {
                error = error1
                self.request = nil
            }

            if ((error) != nil) {
                print(error!.localizedDescription)
            }
        }

        DispatchQueue.main.async(execute: {
            
            /* Dump the NSURLRequest type (POST or GET), all the headers fields, and body.
            print("url = \(self.request!.URL?.absoluteString)")
            print("method = \(self.request!.HTTPMethod)")
            //TODO: self.request!.setValue("", forHTTPHeaderField: "oauth_timestamp")
            print("headers = \(self.request!.allHTTPHeaderFields)")
            print("request body = \(self.request!.HTTPBody)")
            */
            
            self.session = URLSession(configuration: URLSessionConfiguration.default,
                delegate: self,
                delegateQueue: OperationQueue.main)
            
            let task: URLSessionDataTask = self.session.dataTask(with: self.request! as URLRequest, completionHandler: { data, response, error -> Void in
                #if os(iOS)
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                #endif
                
                self.response = response as? HTTPURLResponse
                self.responseData.length = 0
                if let data = data {
                    self.responseData.append(data)
                }
                
                if let response = self.response {
                    if response.statusCode >= 400 {
                        let responseString = NSString(data: self.responseData as Data, encoding: self.dataEncoding.rawValue) //todo:swift3
                        var localizedDescription = ""
                        if let responseString = responseString {
                            localizedDescription = OAuthSwiftHTTPRequest.descriptionForHTTPStatus(self.response.statusCode, responseString: responseString as String)
                        }
                        let userInfo : [AnyHashable: Any] = [NSLocalizedDescriptionKey: localizedDescription, "Response-Headers": self.response.allHeaderFields]
                        let error = NSError(domain: NSURLErrorDomain, code: self.response.statusCode, userInfo: userInfo)
                        self.failureHandler?(error)
                        return
                    }
                    
                    self.successHandler?(self.responseData as Data, self.response)
                } else {
                    // response is invalid - the else block added by John B on 11/7/2015
                    print("invalid response")
                    if let error = error {
                        self.failureHandler?(error as NSError)
                    }
//                    if let data = data {
//                        self.successHandler?(data: data, response: )
//                    }
                }
            }) 
            task.resume()

            #if os(iOS)
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            #endif
        })
    }

    open func makeRequest() throws -> NSMutableURLRequest {
        return try OAuthSwiftHTTPRequest.makeRequest(self.URL, method: self.HTTPMethod, headers: self.headers, parameters: self.parameters, dataEncoding: self.dataEncoding, encodeParameters: self.encodeParameters, body: self.HTTPBodyMultipart, contentType: self.contentTypeMultipart)
    }
    
    open class func makeRequest(
        _ URL: Foundation.URL,
        method: String,
        headers: [String : String],
        parameters: Dictionary<String, AnyObject>,
        dataEncoding: String.Encoding,
        encodeParameters: Bool,
        body: Data? = nil,
        contentType: String? = nil) throws -> NSMutableURLRequest {
            var error: NSError! = NSError(domain: "Migrator", code: 0, userInfo: nil)
            let request = NSMutableURLRequest(url: URL)
            request.httpMethod = method

            // NOTE: This is where the "Authorization" field in the header is set.
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }

            let charset = CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(dataEncoding.rawValue))

            let nonOAuthParameters = parameters.filter { key, _ in !key.hasPrefix("oauth_") }

            if (body != nil && contentType != nil) {
                request.setValue(contentType!, forHTTPHeaderField: "Content-Type")
                //request!.setValue(self.HTTPBodyMultipart!.length.description, forHTTPHeaderField: "Content-Length")
                request.httpBody = body!
            } else {
                if nonOAuthParameters.count > 0 {
                    if request.httpMethod == "GET" || request.httpMethod == "HEAD" || request.httpMethod == "DELETE" {
                        let queryString = nonOAuthParameters.urlEncodedQueryStringWithEncoding(dataEncoding)
                        request.url = URL.URLByAppendingQueryString(queryString)
                        request.setValue("application/x-www-form-urlencoded; charset=\(charset)", forHTTPHeaderField: "Content-Type")
                    }
                    else {
                        if (encodeParameters) {
                            let queryString = nonOAuthParameters.urlEncodedQueryStringWithEncoding(dataEncoding)
                            //self.request!.URL = self.URL.URLByAppendingQueryString(queryString)
                            request.setValue("application/x-www-form-urlencoded; charset=\(charset)", forHTTPHeaderField: "Content-Type")
                            request.httpBody = queryString.data(using: String.Encoding.utf8, allowLossyConversion: true)
                        }
                        else {
                            var jsonError: NSError?
                            do {
                                //TODO - calling NSJSONSerialization.dataWithJSONObject twice!!!
                                let jsonData: Data = try JSONSerialization.data(withJSONObject: nonOAuthParameters, options: [])
                                request.setValue("application/json; charset=\(charset)", forHTTPHeaderField: "Content-Type")
                                request.httpBody = jsonData
                            } catch let error1 as NSError {
                                jsonError = error1
                                if (true) {
                                    //println(jsonError!.localizedDescription)
                                    error = jsonError
                                }
                                throw error
                            }
                        }
                    }
                }
            }
            return request
    }

    class func stringWithData(_ data: Data, encodingName: String?) -> String {
        var encoding: UInt = String.Encoding.utf8.rawValue

        if (encodingName != nil) {
            let encodingNameString = encodingName! as NSString
            encoding = CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding(encodingNameString))

            if encoding == UInt(kCFStringEncodingInvalidId) {
                encoding = String.Encoding.utf8.rawValue // by default
            }
        }

        return NSString(data: data, encoding: encoding)! as String
    }

    class func descriptionForHTTPStatus(_ status: Int, responseString: String) -> String {
        var s = "HTTP Status \(status)"

        var description: String?
        // http://www.iana.org/assignments/http-status-codes/http-status-codes.xhtml
        if status == 400 { description = "Bad Request" }
        if status == 401 { description = "Unauthorized" }
        if status == 402 { description = "Payment Required" }
        if status == 403 { description = "Forbidden" }
        if status == 404 { description = "Not Found" }
        if status == 405 { description = "Method Not Allowed" }
        if status == 406 { description = "Not Acceptable" }
        if status == 407 { description = "Proxy Authentication Required" }
        if status == 408 { description = "Request Timeout" }
        if status == 409 { description = "Conflict" }
        if status == 410 { description = "Gone" }
        if status == 411 { description = "Length Required" }
        if status == 412 { description = "Precondition Failed" }
        if status == 413 { description = "Payload Too Large" }
        if status == 414 { description = "URI Too Long" }
        if status == 415 { description = "Unsupported Media Type" }
        if status == 416 { description = "Requested Range Not Satisfiable" }
        if status == 417 { description = "Expectation Failed" }
        if status == 422 { description = "Unprocessable Entity" }
        if status == 423 { description = "Locked" }
        if status == 424 { description = "Failed Dependency" }
        if status == 425 { description = "Unassigned" }
        if status == 426 { description = "Upgrade Required" }
        if status == 427 { description = "Unassigned" }
        if status == 428 { description = "Precondition Required" }
        if status == 429 { description = "Too Many Requests" }
        if status == 430 { description = "Unassigned" }
        if status == 431 { description = "Request Header Fields Too Large" }
        if status == 432 { description = "Unassigned" }
        if status == 500 { description = "Internal Server Error" }
        if status == 501 { description = "Not Implemented" }
        if status == 502 { description = "Bad Gateway" }
        if status == 503 { description = "Service Unavailable" }
        if status == 504 { description = "Gateway Timeout" }
        if status == 505 { description = "HTTP Version Not Supported" }
        if status == 506 { description = "Variant Also Negotiates" }
        if status == 507 { description = "Insufficient Storage" }
        if status == 508 { description = "Loop Detected" }
        if status == 509 { description = "Unassigned" }
        if status == 510 { description = "Not Extended" }
        if status == 511 { description = "Network Authentication Required" }

        if (description != nil) {
            s = s + ": " + description! + ", Response: " + responseString
        }
        
        return s
    }
    
}
