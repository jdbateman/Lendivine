//
//  LoginViewController.swift
//  Lendivine
//
//  Created by john bateman on 3/27/16.
//  Copyright © 2016 John Bateman. All rights reserved.
//
// This file implements the LoginViewController which allows the user to Login with an account previously created on the Kiva website. The website will offer an option to create an account if the user does not yet have an account.

import UIKit

class LoginViewController: UIViewController {
    
    var appDelegate: AppDelegate!
    
    var kivaAPI: KivaAPI?
    
    @IBOutlet weak var loginButton: UIButton!
    
//    var activityIndicator : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50)) as UIActivityIndicatorView
    
    let activityIndicator = DVNActivityIndicator()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupView()
        
        // get a reference to the app delegate
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // If already logged in to Kiva.org present the Loans view controller.
        if appDelegate.loggedIn == true {
            presentLoansController()
        }
    }
    
    func setupView() {
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        loginButton.layer.cornerRadius = 3
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        setupView()
        
        self.view.setNeedsDisplay()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        //startActivityIndicator()
        activityIndicator.startActivityIndicator(self.view)
        
        doOAuth() {
            success, error in
            
            //self.stopActivityIndicator()
            self.activityIndicator.stopActivityIndicator()
            
            if success {
                
                self.presentLoansController()
                
                
            } else {
                
            }
            
            // Provide feedback on Oauth completion status to end user.
            dispatch_async(dispatch_get_main_queue()) {
                self.oAuthCompleted(success)
            }
        }
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
                    
                } else {
                    print("kivaOAuth failed. Unable to acquire kivaAPI handle.")
                }
                
                completionHandler(success: success, error: error)
            }
        }
    }
    
    func oAuthCompleted(success: Bool) {
    
        let resultText: String = success ? "succeeded" : "failed"
        
        if !success {
            let alert = UIAlertController(title: "Kiva OAuth Complete", message: "The OAuth operation with Kiva.org \(resultText).", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:nil)
            alert.addAction(okAction)
            self.presentViewController(alert, animated: true, completion:nil)
        }
    }
}
