//
//  OAuthSwiftClient.swift
//  OAuthSwift
//
//  Created by Dongri Jin on 6/21/14.
//  Copyright (c) 2014 Dongri Jin. All rights reserved.
//

import Foundation
import Accounts

var dataEncoding: String.Encoding = String.Encoding.utf8

open class OAuthSwiftClient {

    fileprivate(set) open var credential: OAuthSwiftCredential
    
    public init(consumerKey: String, consumerSecret: String) {
        self.credential = OAuthSwiftCredential(consumer_key: consumerKey, consumer_secret: consumerSecret)
    }
    
    public init(consumerKey: String, consumerSecret: String, accessToken: String, accessTokenSecret: String) {
        self.credential = OAuthSwiftCredential(oauth_token: accessToken, oauth_token_secret: accessTokenSecret)
        self.credential.consumer_key = consumerKey
        self.credential.consumer_secret = consumerSecret
    }
    
    open func get(_ urlString: String, parameters: Dictionary<String, AnyObject>, success: OAuthSwiftHTTPRequest.SuccessHandler?, failure: OAuthSwiftHTTPRequest.FailureHandler?) {
        self.request(urlString, method: "GET", parameters: parameters, success: success, failure: failure)
    }
    
    open func post(_ urlString: String, parameters: Dictionary<String, AnyObject>, success: OAuthSwiftHTTPRequest.SuccessHandler?, failure: OAuthSwiftHTTPRequest.FailureHandler?) {
        self.request(urlString, method: "POST", parameters: parameters, success: success, failure: failure)
    }

    open func put(_ urlString: String, parameters: Dictionary<String, AnyObject>, success: OAuthSwiftHTTPRequest.SuccessHandler?, failure: OAuthSwiftHTTPRequest.FailureHandler?) {
        self.request(urlString, method: "PUT", parameters: parameters, success: success, failure: failure)
    }

    open func delete(_ urlString: String, parameters: Dictionary<String, AnyObject>, success: OAuthSwiftHTTPRequest.SuccessHandler?, failure: OAuthSwiftHTTPRequest.FailureHandler?) {
        self.request(urlString, method: "DELETE", parameters: parameters, success: success, failure: failure)
    }

    open func patch(_ urlString: String, parameters: Dictionary<String, AnyObject>, success: OAuthSwiftHTTPRequest.SuccessHandler?, failure: OAuthSwiftHTTPRequest.FailureHandler?) {
        self.request(urlString, method: "PATCH", parameters: parameters, success: success, failure: failure)
    }

    open func request(_ url: String, method: String, parameters: Dictionary<String, AnyObject>, success: OAuthSwiftHTTPRequest.SuccessHandler?, failure: OAuthSwiftHTTPRequest.FailureHandler?) {
        if let request = makeRequest(url, method: method, parameters: parameters) {
            
            request.successHandler = success
            request.failureHandler = failure
            
            // print("Step 1: Request Unauthorized Request Token")
            // print("request:")
            // print("method = \(method)")
            // print("headers = \(request.headers)")
            // print("url = \(url)")
            // print("parameters = \(request.parameters)")
            
            request.start()
        }
    }

    open func makeRequest(_ urlString: String, method: String, parameters: Dictionary<String, AnyObject>) -> OAuthSwiftHTTPRequest? {
        if let url = URL(string: urlString) {
            let request = OAuthSwiftHTTPRequest(URL: url, method: method, parameters: parameters)
            request.headers = self.credential.makeHeaders(url, method: method, parameters: parameters)
            request.dataEncoding = dataEncoding
            request.encodeParameters = true
            return request
        }
        return nil
    }

    open func postImage(_ urlString: String, parameters: Dictionary<String, AnyObject>, image: Data, success: OAuthSwiftHTTPRequest.SuccessHandler?, failure: OAuthSwiftHTTPRequest.FailureHandler?) {
        self.multiPartRequest(urlString, method: "POST", parameters: parameters, image: image, success: success, failure: failure)
    }

    func multiPartRequest(_ url: String, method: String, parameters: Dictionary<String, AnyObject>, image: Data, success: OAuthSwiftHTTPRequest.SuccessHandler?, failure: OAuthSwiftHTTPRequest.FailureHandler?) {

        if let request = makeRequest(url, method: method, parameters: parameters) {
            
            var parmaImage = [String: AnyObject]()
            parmaImage["media"] = image as AnyObject?
            let boundary = "AS-boundary-\(arc4random())-\(arc4random())"
            let type = "multipart/form-data; boundary=\(boundary)"
            let body = self.multiPartBodyFromParams(parmaImage, boundary: boundary)
            
            request.HTTPBodyMultipart = body
            request.contentTypeMultipart = type
            
            request.successHandler = success
            request.failureHandler = failure
            request.start()
        }
    }

    open func multiPartBodyFromParams(_ parameters: [String: AnyObject], boundary: String) -> Data {
        let data = NSMutableData()
        
        let prefixData = "--\(boundary)\r\n".data(using: String.Encoding.utf8)
        let seperData = "\r\n".data(using: String.Encoding.utf8)
        
        for (key, value) in parameters {
            var sectionData: Data?
            var sectionType: String?
            var sectionFilename = ""
            
            if key == "media" {
                let multiData = value as! Data
                sectionData = multiData
                sectionType = "image/jpeg"
                sectionFilename = " filename=\"file\""
            } else {
                sectionData = "\(value)".data(using: String.Encoding.utf8)
            }
            
            data.append(prefixData!)
            
            let sectionDisposition = "Content-Disposition: form-data; name=\"media\";\(sectionFilename)\r\n".data(using: String.Encoding.utf8)
            data.append(sectionDisposition!)
            
            if let type = sectionType {
                let contentType = "Content-Type: \(type)\r\n".data(using: String.Encoding.utf8)
                data.append(contentType!)
            }
            
            // append data
            data.append(seperData!)
            data.append(sectionData!)
            data.append(seperData!)
        }
        
        data.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        return data as Data
    }

    open func postMultiPartRequest(_ url: String, method: String, parameters: Dictionary<String, AnyObject>, success: OAuthSwiftHTTPRequest.SuccessHandler?, failure: OAuthSwiftHTTPRequest.FailureHandler?) {
        
        if let request = makeRequest(url, method: method, parameters: parameters) {

            let boundary = "POST-boundary-\(arc4random())-\(arc4random())"
            let type = "multipart/form-data; boundary=\(boundary)"
            let body = self.multiDataFromObject(parameters, boundary: boundary)

            request.HTTPBodyMultipart = body
            request.contentTypeMultipart = type
            
            request.successHandler = success
            request.failureHandler = failure
            request.start()
        }
    }

    func multiDataFromObject(_ object: [String:AnyObject], boundary: String) -> Data? {
        let data = NSMutableData()

        let prefixString = "--\(boundary)\r\n"
        let prefixData = prefixString.data(using: String.Encoding.utf8)!

        let seperatorString = "\r\n"
        let seperatorData = seperatorString.data(using: String.Encoding.utf8)!

        for (key, value) in object {

            var valueData: Data?
            let valueType: String = ""
            let filenameClause = ""

            let stringValue = "\(value)"
            valueData = stringValue.data(using: String.Encoding.utf8)!

            if valueData == nil {
                continue
            }
            data.append(prefixData)
            let contentDispositionString = "Content-Disposition: form-data; name=\"\(key)\";\(filenameClause)\r\n"
            let contentDispositionData = contentDispositionString.data(using: String.Encoding.utf8)
            data.append(contentDispositionData!)
            //if let type: String = valueType { //todo:swift3
            let type: String = valueType
                let contentTypeString = "Content-Type: \(type)\r\n"
                let contentTypeData = contentTypeString.data(using: String.Encoding.utf8)
                data.append(contentTypeData!)
            //}
            data.append(seperatorData)
            data.append(valueData!)
            data.append(seperatorData)
        }

        let endingString = "--\(boundary)--\r\n"
        let endingData = endingString.data(using: String.Encoding.utf8)!
        data.append(endingData)

        return data as Data
    }

    @available(*, deprecated: 0.4.6, message: "Because method moved to OAuthSwiftCredential!")
    open class func authorizationHeaderForMethod(_ method: String, url: URL, parameters: Dictionary<String, AnyObject>, credential: OAuthSwiftCredential) -> String {
        return credential.authorizationHeaderForMethod(method, url: url, parameters: parameters)
    }
    
    @available(*, deprecated: 0.4.6, message: "Because method moved to OAuthSwiftCredential!")
    open class func signatureForMethod(_ method: String, url: URL, parameters: Dictionary<String, AnyObject>, credential: OAuthSwiftCredential) -> String {
        return credential.signatureForMethod(method, url: url, parameters: parameters)
    }
}
