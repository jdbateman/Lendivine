//
//  OAuth1Swift.swift
//  OAuthSwift
//
//  Created by Dongri Jin on 6/22/14.
//  Copyright (c) 2014 Dongri Jin. All rights reserved.
//
//  This class contains implementation of the OAuth 1.0a protocol. I've modified it to communicate with Kiva.org.
//  Acknowledgement: Thanks to Congri Jin for this OAuth 1.0a stack.

import Foundation

// OAuthSwift errors
public let OAuthSwiftErrorDomain = "oauthswift.error"

public class OAuth1Swift: NSObject {

    public var client: OAuthSwiftClient

    public var authorize_url_handler: OAuthSwiftURLHandlerType = OAuthSwiftOpenURLExternally.sharedInstance

    public var allowMissingOauthVerifier: Bool = false

    var consumer_key: String
    var consumer_secret: String
    var request_token_url: String
    var authorize_url: String
    var access_token_url: String

    var observer: AnyObject?

    public init(consumerKey: String, consumerSecret: String, requestTokenUrl: String, authorizeUrl: String, accessTokenUrl: String){
        self.consumer_key = consumerKey
        self.consumer_secret = consumerSecret
        self.request_token_url = requestTokenUrl
        self.authorize_url = authorizeUrl
        self.access_token_url = accessTokenUrl
        self.client = OAuthSwiftClient(consumerKey: consumerKey, consumerSecret: consumerSecret)
    }

    struct CallbackNotification {
        static let notificationName = "OAuthSwiftCallbackNotificationName"
        static let optionsURLKey = "OAuthSwiftCallbackNotificationOptionsURLKey"
    }

    struct OAuthSwiftError {
        static let domain = "OAuthSwiftErrorDomain"
        static let appOnlyAuthenticationErrorCode = 1
    }

    public typealias TokenSuccessHandler = (credential: OAuthSwiftCredential, response: NSURLResponse) -> Void
    public typealias FailureHandler = (error: NSError) -> Void

    // 0. Start
    public func authorizeWithCallbackURL(callbackURL: NSURL, success: TokenSuccessHandler, failure: ((error: NSError) -> Void)) {

        // Post unauthorized OAuth Request token
        
        self.postOAuthRequestTokenWithCallbackURL(callbackURL, success: {
            credential, response in

            self.observer = NSNotificationCenter.defaultCenter().addObserverForName(CallbackNotification.notificationName, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock:{
                
                notification in
                
                // This block is a Handler for the OAuth deep link notification triggered by a deep link from the Kiva Oauth server.
                
                NSNotificationCenter.defaultCenter().removeObserver(self.observer!)
                
                let url = notification.userInfo![CallbackNotification.optionsURLKey] as! NSURL
                
                var parameters: Dictionary<String, String> = Dictionary()
                if ((url.query) != nil){
                    parameters += url.query!.parametersFromQueryString()
                }
                if ((url.fragment) != nil && url.fragment!.isEmpty == false) {
                    parameters += url.fragment!.parametersFromQueryString()
                }
                if let token = parameters["token"] {
                    parameters["oauth_token"] = token
                }
                if (parameters["oauth_token"] != nil && (self.allowMissingOauthVerifier || parameters["oauth_verifier"] != nil)) {
                    
                    //var credential: OAuthSwiftCredential = self.client.credential
                    self.client.credential.oauth_token = parameters["oauth_token"]!
                    if (parameters["oauth_verifier"] != nil) {
                        self.client.credential.oauth_verifier = parameters["oauth_verifier"]!
                    }
                    
                    // Post OAuth Access Token
                    
                    self.postOAuthAccessTokenWithRequestToken({
                        credential, response in
                        success(credential: credential, response: response)
                        //print("OAuth Result: SUCCESS")
                    },
                        failure: failure)
                    
                } else {
                    
                    let userInfo = [NSLocalizedFailureReasonErrorKey: NSLocalizedString("Oauth problem.", comment: "")]
                    failure(error: NSError(domain: OAuthSwiftErrorDomain, code: -1, userInfo: userInfo))
                    //print("OAuth Result: ERROR")
                    return
                }
            })
            
            // 2. Authorize
            let clientId: String = "self.JohnBateman.Lendivine"
            let scope: String = "access,user_balance,user_email,user_expected_repayments,user_anon_lender_data,user_anon_lender_loans,user_stats,user_loan_balances,user_anon_lender_teams"
            let callbackUrl: String = "oauth-swift%3A%2F%2Foauth-callback%2Fkiva%2FLendivine"
            let parameters: String = String(format: "client_id=%@&response_type=code&scope=%@&oauth_callback=%@&state=6ED1279AB3340E9&", clientId, scope, callbackUrl)
            let authorizationParameters = parameters
            
            
//            let authorizationParameters = "client_id=self.JohnBateman.Lendivine&response_type=code&scope=access,user_balance,user_email,user_expected_repayments,user_anon_lender_data,user_anon_lender_loans,user_stats,user_loan_balances,user_anon_lender_teams&oauth_callback=oauth-swift%3A%2F%2Foauth-callback%2Fkiva%2FLendivine&state=6ED1279AB3340E9&"
            
            if let queryURL = NSURL(string: self.authorize_url + (self.authorize_url.has("?") ? "&" : "?")
                + authorizationParameters
                + "oauth_token=\(credential.oauth_token)")
            {
                //print("oauth_token: \(credential.oauth_token) request: \(queryURL)")
                self.authorize_url_handler.handle(queryURL)
            }
        },
        failure: failure)
    }

    // 1. Request token
    public func postOAuthRequestTokenWithCallbackURL(callbackURL: NSURL, success: TokenSuccessHandler, failure: FailureHandler?) {
        var parameters =  Dictionary<String, AnyObject>()
        if let callbackURLString: String = callbackURL.absoluteString {
            parameters["oauth_callback"] = callbackURLString
        }
        self.client.credential.oauth_header_type = "oauth1"
        
        //print("Step 1: Request Unauthorized OAUth Request Token")
        
        self.client.post(self.request_token_url, parameters: parameters, success: {
            data, response in
            let responseString = NSString(data: data, encoding: NSUTF8StringEncoding) as String!
            //print("Request token response: \(responseString)")
            let parameters = responseString.parametersFromQueryString()
            self.client.credential.oauth_token = parameters["oauth_token"]!
            self.client.credential.oauth_token_secret = parameters["oauth_token_secret"]!
            success(credential: self.client.credential, response: response)
        },
        failure: failure)
    }

    // 3. Get Access token
    func postOAuthAccessTokenWithRequestToken(success: TokenSuccessHandler, failure: FailureHandler?) {
        var parameters = Dictionary<String, AnyObject>()
        
        // fixup the oauth_token to remove % encoding
        var oauthToken = self.client.credential.oauth_token
        oauthToken = oauthToken.stringByRemovingPercentEncoding!
        
        parameters["oauth_token"] = oauthToken  // self.client.credential.oauth_token
        parameters["oauth_verifier"] = self.client.credential.oauth_verifier
        
        // print("kiva.org returned oauth_token = \(self.client.credential.oauth_token)")
        //print("3. Get Kiva OAuth Access token")
        // print("POST \(self.access_token_url) with parameters: \(parameters)")
        
        self.client.post(self.access_token_url, parameters: parameters, success: {
            data, response in
            
            let responseString = NSString(data: data, encoding: NSUTF8StringEncoding) as String!
            let parameters = responseString.parametersFromQueryString()
            self.client.credential.oauth_token = parameters["oauth_token"]!
            self.client.credential.oauth_token_secret = parameters["oauth_token_secret"]!
            
            // print("response: \(responseString)")

            success(credential: self.client.credential, response: response)
        },
            failure: failure)
    }

    /*! Handler for OAuth deep link from Kiva Oauth server. */
    public class func handleOpenURL(url: NSURL) {
        
        let notification = NSNotification(name: CallbackNotification.notificationName, object: nil,
            userInfo: [CallbackNotification.optionsURLKey: url])
        
        //print("handleOpenURL for url: \(url)")
        
        NSNotificationCenter.defaultCenter().postNotification(notification)
    }
}
