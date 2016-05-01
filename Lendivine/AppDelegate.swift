//
//  AppDelegate.swift
//  Lendivine
//
//  Created by john bateman on 11/12/15.
//  Copyright © 2015 John Bateman. All rights reserved.
//

import UIKit
import OAuthSwift

/* A custom NSNotification that indicates any updated country data from the web service is now available in core data. */
let appDidBecomeActiveNotificationKey = "com.lendivine.appdelegate.appdidbecomeactive"

/* A custom NSNotification that indicates an OAuth deep link was received from Kiva.org. */
let KivaOAuthDeepLinkNotificationKey = "com.lendivine.appdelegate.kivaoauthdeeplink"


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var loggedIn: Bool = false

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        Countries.persistCountriesFromWebService(nil)
        
        UITabBar.appearance().translucent = false
        UITabBar.appearance().barTintColor = UIColor(rgb:0x122950)
        UITabBar.appearance().tintColor = UIColor.whiteColor()
        
        UINavigationBar.appearance().barTintColor = UIColor(rgb:0xFFE8A1)
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        print("applicationWillEnterForeground")
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("applicationDidBecomeActive")
        
        postAppDidBecomeActiveNotification()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        // remove all the loans from the scratch context
        let storyboard = UIStoryboard (name: "Main", bundle: nil)
        let controller: LoansTableViewController = storyboard.instantiateViewControllerWithIdentifier("LoansTableViewControllerStoryboardID") as! LoansTableViewController
        controller.removeAllLoans()
        
        
        // Save changes in the application's managed object context before the application terminates.
//TODO        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    // Handle launch by URL scheme.
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        /*"oauth-callback"*/
        
        if (url.host == Constants.OAuthValues.consumerCallbackUrlHost ) {
            
            handleOAuthDeepLink(openURL:url)
            /* The Kiva OAuth deep link url is:
            oauth-swift://oauth-callback/kiva/Lendivine?oauth_verifier=KV-Q8wmUyTv&oauth_token=xZ7vISo4Sw8.4EC6NYC7teRlMisLDb0I%3Bself.JohnBateman.Lendivine&scope=access%2Cuser_balance%2Cuser_email%2Cuser_expected_repayments%2Cuser_anon_lender_data%2Cuser_anon_lender_loans%2Cuser_stats%2Cuser_loan_balances%2Cuser_anon_lender_teams&state=6ED1279AB3340E9
            */
            
        } else {
            print("Error: unexpected. Not Oauth1")
        }
        return true
    }
    
    func handleOAuthDeepLink(openURL url: NSURL) {
        
        if (url.path!.hasPrefix(Constants.OAuthValues.consumerCallbackUrlPath )) {
            
//            writeOAuth(url)
            
            print("")
            print("****************************************************************************")
            print("Step 3: Request Access Token")
            print("")
            print("Parsing redirect url and params from Kiva:")
            print("url: \(url)")
            
            let mySing = MySingleton.sharedInstance
            mySing.timeStampInHeader = false
            print("timestampInHeader = \(mySing.timeStampInHeader) in AppDelegate")
            
            OAuth1Swift.handleOpenURL(url)
        }
    }

//    // MARK: Persist OAuth access token
//    
//    func writeOAuth(url:NSURL) {
//        
//        print("appDelegate saved OAuth url  = \(url)")
//        let appSettings = NSUserDefaults.standardUserDefaults()
//        appSettings.setURL(url, forKey: "KivaOAuthUrl")
//    }
//    
//    func readOAuth() -> NSURL? {
//        
//        let appSettings = NSUserDefaults.standardUserDefaults()
//        let nsurl = appSettings.URLForKey("KivaOAuthUrl")
//        return nsurl
//    }
    
    // MARK - notifications
    
    /*! Post a notification indicating that the application became active. */
    func postAppDidBecomeActiveNotification() {
        
        NSNotificationCenter.defaultCenter().postNotificationName(appDidBecomeActiveNotificationKey, object: self)
    }
    
//    /*! Post a notification indicating that the Kiva OAuth deep link was received. */
//    func postKivaDeepLinkNotification() {
//        
//        NSNotificationCenter.defaultCenter().postNotificationName(KivaOAuthDeepLinkNotificationKey, object: self)
//    }
}

