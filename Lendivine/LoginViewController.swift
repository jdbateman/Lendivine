//
//  LoginViewController.swift
//  Lendivine
//
//  Created by john bateman on 3/27/16.
//  Copyright © 2016 John Bateman. All rights reserved.
//
// This file implements the LoginViewController which allows the user to Login with an account previously created on the Kiva website. The website will offer an option to create an account if the user does not yet have an account.

import UIKit

var loginSessionActive = false

class LoginViewController: UIViewController {
    
    var appDelegate: AppDelegate!
    
    var kivaAPI: KivaAPI?
    
    @IBOutlet weak var loginButton: UIButton!
    
    let activityIndicator = DVNActivityIndicator()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupView()
        
        // get a reference to the app delegate
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        if let url = readOAuth() {
            
            let kivaOAuth = KivaOAuth.sharedInstance
            kivaOAuth.prepareShortcutLogin() {
                success, error, kivaAPI in
                
                if success {
                    self.kivaAPI = kivaOAuth.kivaAPI
                    self.appDelegate.loggedIn = success
                    
                    print("kivaOAuth.prepareShortcutLogin() succeeded. kivaAPI handle acquired.")
                    
                    // If already logged in to Kiva.org present the Loans view controller.
                    if self.appDelegate.loggedIn == true {
                        loginSessionActive = false
                        self.presentLoansController()
                    }
                    
                } else {
                    print("kivaOAuth.prepareShortcutLogin() failed. Unable to acquire kivaAPI handle.")
                }

            }
            
            print("Login is calling handleOAuthDeepLink with url = \(url)")
            appDelegate.handleOAuthDeepLink(openURL:url)
        }
        
//        // If already logged in to Kiva.org present the Loans view controller.
//        if appDelegate.loggedIn == true {
//            loginSessionActive = false
//            presentLoansController()
//        }
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        setupView()
        
        setupNotificationObservers()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        self.activityIndicator.stopActivityIndicator()
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        // Remove observer for all notifications.
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Setup view
    
    func setupView() {
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        loginButton.layer.cornerRadius = 3
        
        self.view.setNeedsDisplay()
    }
    

    // MARK: Actions

    /* SignUp button selected. Attempt Kiva.org OAuth. */
    @IBAction func onSignUpButtonTap(sender: AnyObject) {
        
        let storyboard = UIStoryboard (name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("KviaSignupStoryboardID") as! KivaSignupViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }

    /* User selected the Login button. Attempt to login to Kiva.org. */
    @IBAction func onLoginButtonTap(sender: AnyObject) {
        
        login()
    }

    // MARK: Navigation

    /* Present the Loans view controller on the main thread. */
    func presentLoansController() {
        dispatch_async(dispatch_get_main_queue()) {
            self.performSegueWithIdentifier("LoginSegueId", sender: self)
        }
    }


    // MARK: helper functions
// todo
//    /* show activity indicator */
//    func startActivityIndicator() {
//        activityIndicator.center = self.view.center
//        activityIndicator.hidesWhenStopped = true
//        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
//        view.addSubview(activityIndicator)
//        activityIndicator.startAnimating()
//    }
//
//    /* hide acitivity indicator */
//    func stopActivityIndicator() {
//        activityIndicator.stopAnimating()
//    }
    
    func login() {
     
        loginSessionActive = true
        
        //startActivityIndicator()
        activityIndicator.startActivityIndicator(self.view)
        
        doOAuth() {
            success, error in
            
            //self.stopActivityIndicator()
            self.activityIndicator.stopActivityIndicator()
            
            if success {
                
                print("doOAuth() succeeded")
                self.activityIndicator.stopActivityIndicator()
                loginSessionActive = false
                print("presentLoansController()")
                self.presentLoansController()
                
            } else {
                
                self.activityIndicator.stopActivityIndicator()
                print("doOAuth() failed")
            }
            
            self.afterLogin(success)
        }
    }
    
    func afterLogin(success:Bool) {
        
        if success {
            
            self.oAuthCompleted(success) {
                print("login process is complete!")
            }
            
        } else {
            
            if loginSessionActive {
                
                print("retry login()")
                
                self.login()
            }
        }
        
//        // Provide feedback on Oauth completion status to end user.
//        dispatch_async(dispatch_get_main_queue()) {
//            
//            print("oAuthCompleted() failed")
//            
//            self.oAuthCompleted(success) {
//                
//                print("completed first doOAuthRound2")
//                
//                if loginSessionActive {
//                    
//                    print("logging in again with login()")
//                    
//                    self.login()
//                }
//            }
//        }
    }
    
    // MARK: OAuth with Kiva.org
    
    // OAuth with Kiva.org. Login happens on Kiva website and is redirected to Lendivine app once an OAuth access token is granted.
    func doOAuth(completionHandler:(success:Bool, error: NSError?)->Void) {
        
        let kivaOAuth = KivaOAuth.sharedInstance // = KivaOAuth()
        
        // Do the oauth in a background queue.
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
            
            kivaOAuth.doOAuthKiva() {
                success, error, kivaAPI in
                
                if success {
                    self.kivaAPI = kivaOAuth.kivaAPI
                    self.appDelegate.loggedIn = success
                    
                    print("kivaOAuth.doOAuthKiva() succeeded. kivaAPI handle acquired.")
                    
                } else {
                    print("kivaOAuth.doOAuthKiva() failed. Unable to acquire kivaAPI handle.")
                }
                
                completionHandler(success: success, error: error)
            }
        }
    }
    
    func oAuthCompleted(success: Bool, completionHandler:(Void)->Void) {
    
        let resultText: String = success ? "succeeded" : "failed"
        
        if !success {
            let alert = UIAlertController(title: "Kiva OAuth Complete", message: "The OAuth operation with Kiva.org \(resultText).", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:nil)
            alert.addAction(okAction)
            self.presentViewController(alert, animated: true) {
                completionHandler()
            }
        }
    }
    
    // OAuth with Kiva.org. Login happens on Kiva website and is redirected to Lendivine app once an OAuth access token is granted.
//    func doOAuthRound2() {
//        
//        let kivaOAuth = KivaOAuth.sharedInstance // = KivaOAuth()
//        
//        // Do the oauth in a background queue.
//        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
//            
//            print("try poking KivaOauth()")
//            
//            kivaOAuth.pokeKivaOAuth() {success, error, kivaAPI in
//                if success {
//                    print("pokeKivaOauth() succeeded.")
//                } else {
//                    print("pokeKivaOauth() failed.")
//                }
//                
////                // Call oAuthCompleted on main queue.
////                dispatch_async(dispatch_get_main_queue()) {
////                    self.oAuthCompleted(success) {
////                        print("completed second doOAuthRound2")
////                    }
////                }
//            }
//        }
//    }
    
    // MARK: Notifications
    
    func setupNotificationObservers() {
        
        // Add a notification observer for the app becoming active.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onAppDidBecomeActive", name: appDidBecomeActiveNotificationKey, object: nil)
        
        // Add a notification observer for when the app receives a Kiva OAuth deep link.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onKivaOAuthDeepLinkNotification", name: KivaOAuthDeepLinkNotificationKey, object: nil)
    }
    
    /* Received a notification that the app has become active. */
    func onAppDidBecomeActive() {
    
        print("received AppDidBecomeActive notification.")
        
        if loginSessionActive {
            
            // We will only go through this login flow once per session: meaning the AppDidBecomeActive will only be fired once during a login session per app session. This call will disable the notification after it has been received once during a login session.
            NSNotificationCenter.defaultCenter().removeObserver(self)
            
            self.activityIndicator.stopActivityIndicator()
            
            let alert = UIAlertController(title: "Login", message: "Select Login to continue, else Cancel.", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "Login", style: UIAlertActionStyle.Default) {
                UIAlertAction in
                self.login()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
                UIAlertAction in
                // do nothing
            }
            alert.addAction(okAction)
            alert.addAction(cancelAction)

            self.presentViewController(alert, animated: true, completion: nil)
            
//            self.login()
            
//            doOAuthRound2()
            
            
        }
    }
    
    /*! Receive a notificat that the app received a Kiva OAuth deep link. */
    func onKivaOAuthDeepLinkNotification() {
        
        loginSessionActive = false
    }
    
    // MARK: Persisted OAuth access token
    
    func readOAuth() -> NSURL? {
        
        let appSettings = NSUserDefaults.standardUserDefaults()
        let nsurl = appSettings.URLForKey("KivaOAuthUrl")
        return nsurl
    }
}
