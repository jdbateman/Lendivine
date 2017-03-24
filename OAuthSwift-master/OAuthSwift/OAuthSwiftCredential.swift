//
//  OAuthSwiftCredential.swift
//  OAuthSwift
//
//  Created by Dongri Jin on 6/22/14.
//  Copyright (c) 2014 Dongri Jin. All rights reserved.
//
import Foundation

open class OAuthSwiftCredential: NSObject, NSCoding {

    static var staticCounter = 0
    
    struct OAuth {
        static let version = "1.0"
        static let signatureMethod = "HMAC-SHA1"
    }
    
    var consumer_key: String = String()
    var consumer_secret: String = String()
    open var oauth_token: String = String()
    open var oauth_token_secret: String = String()
    var oauth_verifier: String = String()
    open var oauth_header_type = String()
    
    override init(){
        
    }
    public init(consumer_key: String, consumer_secret: String){
        self.consumer_key = consumer_key
        self.consumer_secret = consumer_secret
    }
    public init(oauth_token: String, oauth_token_secret: String){
        self.oauth_token = oauth_token
        self.oauth_token_secret = oauth_token_secret
    }
    
    fileprivate struct CodingKeys {
        static let base = Bundle.main.bundleIdentifier! + "."
        static let consumerKey = base + "comsumer_key"
        static let consumerSecret = base + "consumer_secret"
        static let oauthToken = base + "oauth_token"
        static let oauthTokenSecret = base + "oauth_token_secret"
        static let oauthVerifier = base + "oauth_verifier"
    }
    
    // Cannot declare a required initializer within an extension.
    // extension OAuthSwiftCredential: NSCoding {
    public required convenience init?(coder decoder: NSCoder) {
        self.init()
        self.consumer_key = (decoder.decodeObject(forKey: CodingKeys.consumerKey) as? String) ?? String()
        self.consumer_secret = (decoder.decodeObject(forKey: CodingKeys.consumerSecret) as? String) ?? String()
        self.oauth_token = (decoder.decodeObject(forKey: CodingKeys.oauthToken) as? String) ?? String()
        self.oauth_token_secret = (decoder.decodeObject(forKey: CodingKeys.oauthTokenSecret) as? String) ?? String()
        self.oauth_verifier = (decoder.decodeObject(forKey: CodingKeys.oauthVerifier) as? String) ?? String()
    }
    
    open func encode(with coder: NSCoder) {
        coder.encode(self.consumer_key, forKey: CodingKeys.consumerKey)
        coder.encode(self.consumer_secret, forKey: CodingKeys.consumerSecret)
        coder.encode(self.oauth_token, forKey: CodingKeys.oauthToken)
        coder.encode(self.oauth_token_secret, forKey: CodingKeys.oauthTokenSecret)
        coder.encode(self.oauth_verifier, forKey: CodingKeys.oauthVerifier)
    }
    // } // End NSCoding extension

    open func makeHeaders(_ url:URL, method: String, parameters: Dictionary<String, AnyObject>) -> Dictionary<String, String> {
        if self.oauth_header_type == "oauth1" {
            return ["Authorization": self.authorizationHeaderForMethod(method, url: url, parameters: parameters)]
        }
        if self.oauth_header_type == "oauth2" {
            return ["Authorization": "Bearer \(self.oauth_token)"]
        }
        return [:]
    }

    // unencode the urlencoded input parameter oauth_token
    open func authorizationHeaderForMethod(_ method: String, url: URL, parameters: Dictionary<String, AnyObject>) -> String {
        var authorizationParameters = Dictionary<String, AnyObject>()
        authorizationParameters["oauth_version"] = OAuth.version as AnyObject?
        authorizationParameters["oauth_signature_method"] =  OAuth.signatureMethod as AnyObject?
        authorizationParameters["oauth_consumer_key"] = self.consumer_key as AnyObject?
        
        //TODO
//        let mySing = MySingleton.sharedInstance
//        print("timestampInHeader = \(mySing.timeStampInHeader) in OAuthSwiftCredential.swift")
//        if mySing.timeStampInHeader == true {
        
//        if OAuthSwiftCredential.staticCounter == 0 {
            authorizationParameters["oauth_timestamp"] = String(Int64(Date().timeIntervalSince1970)) as AnyObject?
//            OAuthSwiftCredential.staticCounter++
//        }
        
        authorizationParameters["oauth_nonce"] = (UUID().uuidString as NSString).substring(to: 8) as AnyObject?
        
        if (self.oauth_token != ""){
            //TODO: unencode
            authorizationParameters["oauth_token"] = self.oauth_token as AnyObject?
        }
        
        for (key, value) in parameters {
            if key.hasPrefix("oauth_") {
                authorizationParameters.updateValue(value, forKey: key)
            }
        }
        
        let combinedParameters = authorizationParameters.join(parameters)
        
        let finalParameters = combinedParameters
        
        authorizationParameters["oauth_signature"] = self.signatureForMethod(method, url: url, parameters: finalParameters) as AnyObject?
        var parameterComponents = authorizationParameters.urlEncodedQueryStringWithEncoding(dataEncoding).components(separatedBy: "&") as [String]
        parameterComponents.sort { $0 < $1 }
        
        var headerComponents = [String]()
        for component in parameterComponents {
            let subcomponent = component.components(separatedBy: "=") as [String]
            if subcomponent.count == 2 {
                headerComponents.append("\(subcomponent[0])=\"\(subcomponent[1])\"")
            }
        }
        
        return "OAuth " + headerComponents.joined(separator: ", ")
    }

    open func signatureForMethod(_ method: String, url: URL, parameters: Dictionary<String, AnyObject>) -> String {
        var tokenSecret: NSString = ""
        tokenSecret = self.oauth_token_secret.urlEncodedStringWithEncoding(dataEncoding) as NSString
        
        let encodedConsumerSecret = self.consumer_secret.urlEncodedStringWithEncoding(dataEncoding)
        
        let signingKey = "\(encodedConsumerSecret)&\(tokenSecret)"
        
        var parameterComponents = parameters.urlEncodedQueryStringWithEncoding(dataEncoding).components(separatedBy: "&") as [String]
        parameterComponents.sort { $0 < $1 }
        
        let parameterString = parameterComponents.joined(separator: "&")
        let encodedParameterString = parameterString.urlEncodedStringWithEncoding(dataEncoding)
        
        let encodedURL = url.absoluteString.urlEncodedStringWithEncoding(dataEncoding)
        
        let signatureBaseString = "\(method)&\(encodedURL)&\(encodedParameterString)"
        
        let key = signingKey.data(using: String.Encoding.utf8)!
        let msg = signatureBaseString.data(using: String.Encoding.utf8)!
        let sha1 = HMAC.sha1(key: key, message: msg)!
        return sha1.base64EncodedString(options: [])
    }
}
