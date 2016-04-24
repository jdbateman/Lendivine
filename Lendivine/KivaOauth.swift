//
//  KivaOauth.swift
//  OAuthSwift
//
//  Created by john bateman on 10/28/15.
//  Copyright © 2015 John Bateman. All rights reserved.
//
//  This class implements the client portion of the OAuth 1.0a protocol for the Kiva.org service.

/*! OAuth 1.0 protocol:

    1. Request unauthorized token:
    Request an unauthorized oauth Request Token.

    2. Kiva sends the unauthorized oauth request token to the client.

    3. Redirect to Kiva.org:
    The client, upon receipt of the unauthorized request token from Kiva use it to redirect to Kiva.org for user authentication and user authorization of app.

    4. User authentication & authorization:
    If the user authorizes this app then Kiva.org redirects to the callback url by appending an oauth_verifier code.

    5. Request long lived access token
    The app will exchange the unauthorized oauth request token and oauth_verifier code for a long lived Access Token.

    6. Kiva sends access token to client.

    7. Client calls Kiva's protected APIs.
    The app uses the long lived access token to make Kiva API calls to access protected resources.
*/


import Foundation
import OAuthSwift

class KivaOAuth {
    
    var oAuthAccessToken: String?
    var oAuthSecret: String?
    
    var kivaAPI: KivaAPI?
    
    static let sharedInstance = KivaOAuth()
    
    func doOAuthKiva(completionHandler: (success: Bool, error: NSError?, kivaAPI: KivaAPI?) -> Void){
        
        let oauthswift = OAuth1Swift(
            consumerKey:    Kiva["consumerKey"]!,
            consumerSecret: Kiva["consumerSecret"]!,
            requestTokenUrl: "https://api.kivaws.org/oauth/request_token",
            authorizeUrl:    "https://www.kiva.org/oauth/authorize",
            accessTokenUrl:  "https://api.kivaws.org/oauth/access_token" 
        )
        
        // Request an unauthorized oauth Request Token. Upon receipt of the request token from Kiva use it to redirect to Kiva.org for user authentication and user authorization of app. If the user authorizes this app then Kiva.org redirects to the callback url below by appending an oauth_verifier code. The app will exchange the unauthorized oauth request token and oauth_verifier code for a long lived Access Token that can be used to make Kiva API calls to access protected resources.
        
        oauthswift.authorizeWithCallbackURL( NSURL(string: Constants.OAuthValues.consumerCallbackUrl)!,
            success: { credential, response in
            
                print("oauth_token:\(credential.oauth_token)\n\noauth_token_secret:\(credential.oauth_token_secret)")
                //self.showAlertView("Kiva", message: "oauth_token:\(credential.oauth_token)\n\noauth_token_secret:\(credential.oauth_token_secret)")

                // get the kivaAPI handle
                self.kivaAPI = KivaAPI.sharedInstance

                // Enable KivaAPI calls requiring an OAuth access token.
                KivaAPI.sharedInstance.setOAuthAccessToken(credential.oauth_token, oAuth1: oauthswift)
                
                completionHandler(success: true, error: nil, kivaAPI: self.kivaAPI)
            },
            failure: {
                
                (error:NSError!) -> Void in
                print(error.localizedDescription)
                completionHandler(success: false, error: error, kivaAPI: nil)
            }
        )
    }
    
//    func pokeKivaOAuth(completionHandler: (success: Bool, error: NSError?, kivaAPI: KivaAPI?) -> Void) {
//        
//        let oauthswift1 = OAuth1Swift(
//            consumerKey:    Kiva["consumerKey"]!,
//            consumerSecret: Kiva["consumerSecret"]!,
//            requestTokenUrl: "https://api.kivaws.org/oauth/request_token",
//            authorizeUrl:    "https://www.kiva.org/oauth/authorize",
//            accessTokenUrl:  "https://api.kivaws.org/oauth/access_token"
//        )
//        
//        oauthswift1.pokeKivaOAuthAPI( NSURL(string: Constants.OAuthValues.consumerCallbackUrl)!,
//            success: { credential, response in
//                
//                print("oauth_token:\(credential.oauth_token)\n\noauth_token_secret:\(credential.oauth_token_secret)")
//                //self.showAlertView("Kiva", message: "oauth_token:\(credential.oauth_token)\n\noauth_token_secret:\(credential.oauth_token_secret)")
//                
//                // get the kivaAPI handle
//                self.kivaAPI = KivaAPI.sharedInstance
//                
//                // Enable KivaAPI calls requiring an OAuth access token.
//                KivaAPI.sharedInstance.setOAuthAccessToken(credential.oauth_token, oAuth1: oauthswift1)
//                
//                completionHandler(success: true, error: nil, kivaAPI: self.kivaAPI)
//            },
//            failure: {
//                
//                (error:NSError!) -> Void in
//                print(error.localizedDescription)
//                completionHandler(success: false, error: error, kivaAPI: nil)
//            }
//        )
    

        
//        oauthswift.doOAuthKiva( NSURL(string: Constants.OAuthValues.consumerCallbackUrl)!,
//            success: { credential, response in
//                
//                completionHandler(success: true, error: nil, kivaAPI: nil)
//            },
//            failure: {
//                
//                (error:NSError!) -> Void in
//                print(error.localizedDescription)
//                completionHandler(success: false, error: error, kivaAPI: nil)
//            }
//        )
//    }
    
//    func prepareShortcutLogin(completionHandler: (success: Bool, error: NSError?, kivaAPI: KivaAPI?) -> Void) {
//        
//        let oauthswift1 = OAuth1Swift(
//            consumerKey:    Kiva["consumerKey"]!,
//            consumerSecret: Kiva["consumerSecret"]!,
//            requestTokenUrl: "https://api.kivaws.org/oauth/request_token",
//            authorizeUrl:    "https://www.kiva.org/oauth/authorize",
//            accessTokenUrl:  "https://api.kivaws.org/oauth/access_token"
//        )
//        
//        oauthswift1.shortcutLogin( { credential, response in
//                
//                print("oauth_token:\(credential.oauth_token)\n\noauth_token_secret:\(credential.oauth_token_secret)")
//                //self.showAlertView("Kiva", message: "oauth_token:\(credential.oauth_token)\n\noauth_token_secret:\(credential.oauth_token_secret)")
//                
//                // get the kivaAPI handle
//                self.kivaAPI = KivaAPI.sharedInstance
//                
//                // Enable KivaAPI calls requiring an OAuth access token.
//                KivaAPI.sharedInstance.setOAuthAccessToken(credential.oauth_token, oAuth1: oauthswift1)
//                
//                completionHandler(success: true, error: nil, kivaAPI: self.kivaAPI)
//            },
//            failure: {
//                
//                (error:NSError) -> Void in
//                print(error.localizedDescription)
//                completionHandler(success: false, error: error, kivaAPI: nil)
//            }
//        )
//    }
}