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
    
    var shakeTimer:NSTimer?
    
    var appDelegate: AppDelegate!
    
    var kivaAPI: KivaAPI?
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!

    
    let activityIndicator = DVNActivityIndicator()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupView()
        
        // get a reference to the app delegate
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // If already logged in to Kiva.org present the Loans view controller.
        if appDelegate.loggedIn == true {
            loginSessionActive = false
            presentLoansController()
        }
        
        setupView()
        
        setupNotificationObservers()
        
        shakeTimer = NSTimer.scheduledTimerWithTimeInterval(10.0 , target: self, selector: "shakeLoginButton", userInfo: nil, repeats: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        self.activityIndicator.stopActivityIndicator()
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        // Remove observer for all notifications.
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        shakeTimer?.invalidate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Setup view
    
    func setupView() {
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        loginButton.layer.cornerRadius = 5
        
        // attribute the Signup button text
        let signupButtonText = "Don't have an account? Sign Up"
        let signupString = NSMutableAttributedString(string: signupButtonText, attributes: [NSFontAttributeName: UIFont(name: "Georgia", size: 17.0)!])
        let blueColor = UIColor(rgb: 0x0D5FFA)
        signupString.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: NSRange(location: 0,length: 22))
        signupString.addAttribute(NSForegroundColorAttributeName, value: blueColor, range: NSRange(location: 23,length: 7))
        signupButton.setAttributedTitle(signupString, forState: .Normal)
        
        self.view.setNeedsDisplay()
    }
    

    // MARK: Actions

    /* SignUp button selected. Do Kiva.org OAuth. */
    @IBAction func onSignUpButtonTap(sender: AnyObject) {
        
        authenticate()
    }

    /* Login button selected. Do Kiva.org OAuth. */
    @IBAction func onLoginButtonTap(sender: AnyObject) {
        
        authenticate()
    }
    

    // MARK: Navigation

    /* Present the Loans view controller on the main thread. */
    func presentLoansController() {
        dispatch_async(dispatch_get_main_queue()) {
            self.performSegueWithIdentifier("LoginSegueId", sender: self)
        }
    }


    // MARK: helper functions
    
    /*! Authenticate with Kiva.org using the OAuth 1.0a protocol. */
    func authenticate() {
     
        loginSessionActive = true
        
        activityIndicator.startActivityIndicator(self.view)
        
        doOAuth() {
            success, error in
            
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
            
            print("login process is complete!")
            
        } else {
            
            print("login process failed.")
//            if loginSessionActive {
//                
//                print("retry login()")
//                
//                self.login()
//            }
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
    
    /*! @brief Display the Kiva.org signup page in an embedded browser to allow the user to create an account on Kiva.org.
        @discussion Displaying the signup page directly does allow the user to create an account on Kiva.org. However, the service will not deep link back to the application after signup.
    */
    func signup() {
        
        let storyboard = UIStoryboard (name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("KviaSignupStoryboardID") as! KivaSignupViewController
        self.navigationController?.pushViewController(controller, animated: true)
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
    
//    func oAuthCompleted(success: Bool, completionHandler:(Void)->Void) {
//    
//        let resultText: String = success ? "succeeded" : "failed"
//        
//        if !success {
//            let alert = UIAlertController(title: "Kiva OAuth Complete", message: "The OAuth operation with Kiva.org \(resultText).", preferredStyle: .Alert)
//            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:nil)
//            alert.addAction(okAction)
//            self.presentViewController(alert, animated: true) {
//                completionHandler()
//            }
//        }
//    }

    
    // MARK: Notifications
    
    func setupNotificationObservers() {
        
        // Add a notification observer for the app becoming active.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onAppDidBecomeActive", name: appDidBecomeActiveNotificationKey, object: nil)
        
//        // Add a notification observer for when the app receives a Kiva OAuth deep link.
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onKivaOAuthDeepLinkNotification", name: KivaOAuthDeepLinkNotificationKey, object: nil)
    }
    
    /* Received a notification that the app has become active. */
    func onAppDidBecomeActive() {

        self.activityIndicator.stopActivityIndicator()
        
        shakeTimer?.invalidate()
        shakeTimer = NSTimer.scheduledTimerWithTimeInterval(3.0 , target: self, selector: "shakeLoginButton", userInfo: nil, repeats: true)
    }
    
//    /* Received a notification that the app has become active. */
//    func onAppDidBecomeActive() {
//    
//        print("received AppDidBecomeActive notification.")
//        
//        if loginSessionActive {
//            
//            // We will only go through this login flow once per session: meaning the AppDidBecomeActive will only be fired once during a login session per app session. This call will disable the notification after it has been received once during a login session.
//            NSNotificationCenter.defaultCenter().removeObserver(self)
//            
//            self.activityIndicator.stopActivityIndicator()
//            
//            let alert = UIAlertController(title: "Login", message: "Select Login to continue, else Cancel.", preferredStyle: .Alert)
//            let okAction = UIAlertAction(title: "Login", style: UIAlertActionStyle.Default) {
//                UIAlertAction in
//                self.login()
//            }
//            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
//                UIAlertAction in
//                // do nothing
//            }
//            alert.addAction(okAction)
//            alert.addAction(cancelAction)
//
//            self.presentViewController(alert, animated: true, completion: nil)
//            
////            self.login()
//            
////            doOAuthRound2()
//            
//            
//        }
//    }
//    
//    /*! Receive a notificat that the app received a Kiva OAuth deep link. */
//    func onKivaOAuthDeepLinkNotification() {
//        
//        loginSessionActive = false
//    }
    
    
    // MARK: Animation
    
    /*! @brief Create a shake animation for the specified Login button.
        @discussion Capture the attention of a user who may need a hint about how to proceed.
    */
    func shakeLoginButton() {
        
        let button = loginButton
        
        let shakeAnimation = CABasicAnimation(keyPath: "position")
        shakeAnimation.duration = 0.1
        shakeAnimation.repeatCount = 2
        shakeAnimation.autoreverses = true
        
        shakeAnimation.fromValue = NSValue(CGPoint: CGPointMake(button.center.x + 3, button.center.y + 1))
        shakeAnimation.toValue = NSValue(CGPoint: CGPointMake(button.center.x - 0, button.center.y - 0))
        button.layer.addAnimation(shakeAnimation, forKey: "position")
    }
    
}
