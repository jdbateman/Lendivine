//
//  LoginViewController.swift
//  Lendivine
//
//  Created by john bateman on 3/27/16.
//  Copyright © 2016 John Bateman. All rights reserved.
//
// This file implements the LoginViewController which allows the user to Login with an account previously created on the Kiva website. The website will offer an option to create an account if the user does not yet have an account.

import UIKit
import SafariServices

var loginSessionActive = false

class LoginViewController: UIViewController, SFSafariViewControllerDelegate {
    
    var shakeTimer:Timer?
    
    var appDelegate: AppDelegate!
    
    var kivaAPI: KivaAPI?
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!

    
    let activityIndicator = DVNActivityIndicator()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupView()
        
        // get a reference to the app delegate
        appDelegate = UIApplication.shared.delegate as! AppDelegate
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // If already logged in to Kiva.org present the Loans view controller.
        if appDelegate.loggedIn == true {
            loginSessionActive = false
            //presentLoansController() <-- already handled in doOAuth block
        }
        
        setupView()
        
        setupNotificationObservers()
        
        shakeTimer = Timer.scheduledTimer(timeInterval: 10.0 , target: self, selector: #selector(LoginViewController.shakeLoginButton), userInfo: nil, repeats: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        self.activityIndicator.stopActivityIndicator()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        // Remove observer for all notifications.
        NotificationCenter.default.removeObserver(self)
        
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
        signupString.addAttribute(NSForegroundColorAttributeName, value: UIColor.white, range: NSRange(location: 0,length: 22))
        signupString.addAttribute(NSForegroundColorAttributeName, value: blueColor, range: NSRange(location: 23,length: 7))
        signupButton.setAttributedTitle(signupString, for: UIControlState())
        
        self.view.setNeedsDisplay()
    }
    

    // MARK: Actions

    /* SignUp button selected. Do Kiva.org OAuth. */
    @IBAction func onSignUpButtonTap(_ sender: AnyObject) {
        
        //authenticate()
        
        if let kivaSignUpURL = URL(string:"https://www.kiva.org/register?doneUrl=https%3A%2F%2Fwww.kiva.org%2Fportfolio") {
            let safariVC = SFSafariViewController(url: kivaSignUpURL)
            safariVC.delegate = self
            self.present(safariVC, animated: true, completion: nil)
        }
    }

    /* Login button selected. Do Kiva.org OAuth. */
    @IBAction func onLoginButtonTap(_ sender: AnyObject) {
        
        authenticate()
    }
    

    // MARK: Navigation

    /* Present the Loans view controller on the main thread. */
    func presentLoansController() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "LoginSegueId", sender: self)
            
            // kill the sfsafariviewcontroller
            self.dismiss(animated: true, completion: nil)
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
                
                //print("OAuth succeeded")
                self.activityIndicator.stopActivityIndicator()
                loginSessionActive = false
                self.presentLoansController()
                
            } else {
                
                self.activityIndicator.stopActivityIndicator()
                print("doOAuth() failed")
            }
            
            self.afterLogin(success)
        }
    }
    
    func afterLogin(_ success:Bool) {
        
        if success {
            
            print("login process is complete!")
            
        } else {
            
            print("login process failed.")
        }
    }
    
    /*! @brief Display the Kiva.org signup page in an embedded browser to allow the user to create an account on Kiva.org.
        @discussion Displaying the signup page directly does allow the user to create an account on Kiva.org. However, the service will not deep link back to the application after signup.
    */
    //TODO: May need to present Kiva.org signup in SFSafariViewController as well!
    func signup() {
        
        let storyboard = UIStoryboard (name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "KviaSignupStoryboardID") as! KivaSignupViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: OAuth with Kiva.org
    
    // OAuth with Kiva.org. Login happens on Kiva website and is redirected to Lendivine app once an OAuth access token is granted.
    func doOAuth(_ completionHandler:@escaping (_ success:Bool, _ error: NSError?)->Void) {
        
        let kivaOAuth = KivaOAuth.sharedInstance // = KivaOAuth()
        
        // Do the oauth in a background queue.
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            
            kivaOAuth.doOAuthKiva(self) {
                success, error, kivaAPI in
                
                if success {
                    self.kivaAPI = kivaOAuth.kivaAPI
                    self.appDelegate.loggedIn = success
                    
                    print("OAuth succeeded and kivaAPI handle was acquired.")
                    
                } else {
                    print("kivaOAuth.doOAuthKiva() failed. Unable to acquire kivaAPI handle.")
                }
                
                completionHandler(success, error)
            }
        }
    }

    // MARK: - SFSafariViewControllerDelegate
    // Called on "Done" button
    @available(iOS 9.0, *)
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Notifications
    
    func setupNotificationObservers() {
        
        // Add a notification observer for the app becoming active.
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.onAppDidBecomeActive), name: NSNotification.Name(rawValue: appDidBecomeActiveNotificationKey), object: nil)
    }
    
    /* Received a notification that the app has become active. */
    func onAppDidBecomeActive() {

        self.activityIndicator.stopActivityIndicator()
        
        shakeTimer?.invalidate()
        shakeTimer = Timer.scheduledTimer(timeInterval: 3.0 , target: self, selector: #selector(LoginViewController.shakeLoginButton), userInfo: nil, repeats: true)
    }

    
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
        
        shakeAnimation.fromValue = NSValue(cgPoint: CGPoint(x: (button?.center.x)! + 3, y: (button?.center.y)! + 1))
        shakeAnimation.toValue = NSValue(cgPoint: CGPoint(x: (button?.center.x)! - 0, y: (button?.center.y)! - 0))
        button?.layer.add(shakeAnimation, forKey: "position")
    }
}
