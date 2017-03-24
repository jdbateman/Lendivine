//
//  OAuth2Swift.swift
//  OAuthSwift
//
//  Created by Dongri Jin on 6/22/14.
//  Copyright (c) 2014 Dongri Jin. All rights reserved.
//

import Foundation

open class OAuth2Swift: NSObject {

    open var client: OAuthSwiftClient

    open var authorize_url_handler: OAuthSwiftURLHandlerType = OAuthSwiftOpenURLExternally.sharedInstance

    var consumer_key: String
    var consumer_secret: String
    var authorize_url: String
    var access_token_url: String?
    var response_type: String
    var observer: AnyObject?
    var content_type: String?

    public convenience init(consumerKey: String, consumerSecret: String, authorizeUrl: String, accessTokenUrl: String, responseType: String){
        self.init(consumerKey: consumerKey, consumerSecret: consumerSecret, authorizeUrl: authorizeUrl, responseType: responseType)
        self.access_token_url = accessTokenUrl
    }

    public convenience init(consumerKey: String, consumerSecret: String, authorizeUrl: String, accessTokenUrl: String, responseType: String, contentType: String){
        self.init(consumerKey: consumerKey, consumerSecret: consumerSecret, authorizeUrl: authorizeUrl, responseType: responseType)
        self.access_token_url = accessTokenUrl
        self.content_type = contentType
    }

    public init(consumerKey: String, consumerSecret: String, authorizeUrl: String, responseType: String){
        self.consumer_key = consumerKey
        self.consumer_secret = consumerSecret
        self.authorize_url = authorizeUrl
        self.response_type = responseType
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
    
    public typealias TokenSuccessHandler = (_ credential: OAuthSwiftCredential, _ response: URLResponse?, _ parameters: NSDictionary) -> Void
    public typealias FailureHandler = (_ error: NSError) -> Void
    

    open func authorizeWithCallbackURL(_ callbackURL: URL, scope: String, state: String, params: Dictionary<String, String> = Dictionary<String, String>(), success: @escaping TokenSuccessHandler, failure: @escaping ((_ error: NSError) -> Void)) {
        self.observer = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: CallbackNotification.notificationName), object: nil, queue: OperationQueue.main, using:{
            notification in
            NotificationCenter.default.removeObserver(self.observer!)
            let url = notification.userInfo![CallbackNotification.optionsURLKey] as! URL
            var responseParameters: Dictionary<String, String> = Dictionary()
            if let query = url.query {
                responseParameters += query.parametersFromQueryString()
            }
            if ((url.fragment) != nil && url.fragment!.isEmpty == false) {
                responseParameters += url.fragment!.parametersFromQueryString()
            }
            if let accessToken = responseParameters["access_token"] {
                self.client.credential.oauth_token = accessToken
                success(self.client.credential, nil, responseParameters as NSDictionary)
            }
            if let code:String = responseParameters["code"] {
                self.postOAuthAccessTokenWithRequestTokenByCode(code.removingPercentEncoding!,
                    callbackURL:callbackURL,
                    success: { credential, response, responseParameters in
                        success(credential, response, responseParameters)
                }, failure: failure)
            }
            if let error = responseParameters["error"], let error_description = responseParameters["error_description"] {
                let errorInfo = [NSLocalizedFailureReasonErrorKey: NSLocalizedString(error, comment: error_description)]
                failure(NSError(domain: OAuthSwiftErrorDomain, code: -1, userInfo: errorInfo))
            }
        })
        //let authorizeURL = NSURL(string: )
        var urlString = String()
        urlString += self.authorize_url
        urlString += (self.authorize_url.has("?") ? "&" : "?") + "client_id=\(self.consumer_key)"
        urlString += "&redirect_uri=\(callbackURL.absoluteString)"
        urlString += "&response_type=\(self.response_type)"
        if (scope != "") {
          urlString += "&scope=\(scope)"
        }
        if (state != "") {
            urlString += "&state=\(state)"
        }

        for param in params {
            urlString += "&\(param.0)=\(param.1)"
        }

        if let queryURL = URL(string: urlString) {
           self.authorize_url_handler.handle(queryURL)
        }
    }
    
    func postOAuthAccessTokenWithRequestTokenByCode(_ code: String, callbackURL: URL, success: @escaping TokenSuccessHandler, failure: FailureHandler?) {
        var parameters = Dictionary<String, AnyObject>()
        parameters["client_id"] = self.consumer_key as AnyObject?
        parameters["client_secret"] = self.consumer_secret as AnyObject?
        parameters["code"] = code as AnyObject?
        parameters["grant_type"] = "authorization_code" as AnyObject?
        parameters["redirect_uri"] = callbackURL.absoluteString.removingPercentEncoding as AnyObject? //todo:swift3 - added cast as AnyObject?
        
        if self.content_type == "multipart/form-data" {
            self.client.postMultiPartRequest(self.access_token_url!, method: "POST", parameters: parameters, success: {
                data, response in
                let responseJSON: AnyObject? = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject?
                
                var responseParameters = [String:AnyObject]() //todo:swift3 - init as empty dictionary instead of NSDictionary
                
                if responseJSON != nil {
                    responseParameters = responseJSON as! [String:AnyObject] //as! NSDictionary
                } else {
                    if let responseString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as? String {
                        responseParameters = responseString.parametersFromQueryString() as [String:AnyObject] //as NSDictionary //todo:swift3 - cast to NSDictionary
                    }
                }
                
                let accessToken = responseParameters["access_token"] as! String
                self.client.credential.oauth_token = accessToken
                success(self.client.credential, response, responseParameters as NSDictionary) // todo:swift3 - return as NSDictionary via cast
                }, failure: failure)
        } else {
            self.client.credential.oauth_header_type = "oauth2"
            self.client.post(self.access_token_url!, parameters: parameters, success: {
                data, response in
                let responseJSON: AnyObject? = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject?

                var responseParameters = [String:AnyObject]() //todo:swift3 - init as empty dictionary instead of NSDictionary

                if responseJSON != nil {
                    responseParameters = responseJSON as! [String:AnyObject] //as! NSDictionary
                } else {
                    if let responseString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as? String {
                        responseParameters = responseString.parametersFromQueryString() as [String:AnyObject] //as NSDictionary //todo:swift3 - cast to NSDictionary
                    }
                }

                let accessToken = responseParameters["access_token"] as! String
                self.client.credential.oauth_token = accessToken
                success(self.client.credential, response, responseParameters as NSDictionary)  // todo:swift3 - return as NSDictionary via cast
            }, failure: failure)
        }
    }
    
    open class func handleOpenURL(_ url: URL) {
        let notification = Notification(name: Notification.Name(rawValue: CallbackNotification.notificationName), object: nil,
            userInfo: [CallbackNotification.optionsURLKey: url])
        NotificationCenter.default.post(notification)
    }
    
}
