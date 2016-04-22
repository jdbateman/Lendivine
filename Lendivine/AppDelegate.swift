//
//  AppDelegate.swift
//  Lendivine
//
//  Created by john bateman on 11/12/15.
//  Copyright © 2015 John Bateman. All rights reserved.
//

import UIKit
import OAuthSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var loggedIn: Bool = false

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        Countries.persistCountriesFromWebService(nil)
        
        UITabBar.appearance().translucent = false
        UITabBar.appearance().barTintColor = UIColor(rgb:0x122950)
        UITabBar.appearance().tintColor = UIColor.whiteColor()
        
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
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        // remove all the loans from the scratch context
        let storyboard = UIStoryboard (name: "Main", bundle: nil)
        let controller: LoansTableViewController = storyboard.instantiateViewControllerWithIdentifier("LoansTableViewControllerStoryboardID") as! LoansTableViewController
        controller.removeAllLoans()
        
        // Save changes in the application's managed object context before the application terminates.
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    // Handle launch by URL scheme.
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        /*"oauth-callback"*/
        if (url.host == Constants.OAuthValues.consumerCallbackUrlHost ) {
            if (url.path!.hasPrefix(Constants.OAuthValues.consumerCallbackUrlPath )) {
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
        } else {
            print("Error: unexpected: not Oauth1")
        }
        return true
    }


}

