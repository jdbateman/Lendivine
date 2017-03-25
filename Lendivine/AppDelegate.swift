//
//  AppDelegate.swift
//  Lendivine
//
//  Created by john bateman on 11/12/15.
//  Copyright © 2015 John Bateman. All rights reserved.
//

import UIKit
import OAuthSwift
import Fabric
import Crashlytics

/* A custom NSNotification that indicates any updated country data from the web service is now available in core data. */
let appDidBecomeActiveNotificationKey = "com.lendivine.appdelegate.appdidbecomeactive"

/* A custom NSNotification that indicates an OAuth deep link was received from Kiva.org. */
let KivaOAuthDeepLinkNotificationKey = "com.lendivine.appdelegate.kivaoauthdeeplink"


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var OAuthSession: URLSession?
    
    var window: UIWindow?
    var loggedIn: Bool = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        Fabric.with([Crashlytics.self])
        
        Countries.persistCountriesFromWebService() {
            success, error in
            if (error != nil) && ((error?.code)! == -1009) && (error?.localizedDescription.contains("offline"))! {
                let topViewController = ((self.window!.rootViewController) as! UINavigationController).visibleViewController
                LDAlert(viewController: topViewController!).displayErrorAlertView("No Internet Connection", message: (error?.localizedDescription)!)
            }
        }
        
        UITabBar.appearance().isTranslucent = false
        UITabBar.appearance().barTintColor = UIColor(rgb:0x122950)
        UITabBar.appearance().tintColor = UIColor.white
        
        UINavigationBar.appearance().barTintColor = UIColor(rgb:0xFFE8A1)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        postAppDidBecomeActiveNotification()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        CoreDataLoanHelper.cleanup()
        
        // Note: enable this line in future if you want to save changes in the application's managed object context before the application terminates.
        // CoreDataStackManager.sharedInstance().saveContext()
    }
    
    // Handle launch by URL scheme.
//    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
//        
//        /*"oauth-callback"*/
//        
//        if (url.host == Constants.OAuthValues.consumerCallbackUrlHost ) {
//            
//            handleOAuthDeepLink(openURL:url)
//            /* The Kiva OAuth deep link url is:
//            oauth-swift://oauth-callback/kiva/Lendivine?oauth_verifier=KV-Q8wmUyTv&oauth_token=xZ7vISo4Sw8.4EC6NYC7teRlMisLDb0I%3Bself.JohnBateman.Lendivine&scope=access%2Cuser_balance%2Cuser_email%2Cuser_expected_repayments%2Cuser_anon_lender_data%2Cuser_anon_lender_loans%2Cuser_stats%2Cuser_loan_balances%2Cuser_anon_lender_teams&state=6ED1279AB3340E9
//            */
//            
//        } else {
//            print("Error: unexpected. Not Oauth1")
//        }
//        return true
//    }
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        //        print("app: \(app)")
        //        print("url: \(url)")
        //        print("options: \(options)")
        
        if let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication]  {
            
            if (String(describing:sourceApplication) == "com.apple.SafariViewService") { //todo:swift3
                
                
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
        }
        
        return true
    }
    
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
//        return true
//    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if (url.host == Constants.OAuthValues.consumerCallbackUrlHost ) {
            handleOAuthDeepLink(openURL:url)
        }
        else {
            print("Error: unexpected. Not Oauth1")
        }
        return true
    }
 
    /* Handle the open URL and TODO: dismiss SFSafariViewController */
    func handleOAuthDeepLink(openURL url: URL) {
 
        if (url.path.hasPrefix(Constants.OAuthValues.consumerCallbackUrlPath )) {
            
            let mySing = MySingleton.sharedInstance
            mySing.timeStampInHeader = false
            
            /* Helpful OAuth debug info.
            print("Step 3: Request Access Token. Parse redirect url and params from Kiva:")
            print("url: \(url)")
            print("timestampInHeader = \(mySing.timeStampInHeader) in AppDelegate")
            */
            
            OAuth1Swift.handleOpenURL(url)
        }
    }

    
    // MARK - notifications
    
    /*! Post a notification indicating that the application became active. */
    func postAppDidBecomeActiveNotification() {
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: appDidBecomeActiveNotificationKey), object: self)
    }
}

