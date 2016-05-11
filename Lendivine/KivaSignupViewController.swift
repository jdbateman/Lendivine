//
//  KivaSignupViewController.swift
//  Lendivine
//
//  Created by john bateman on 4/3/16.
//  Copyright © 2016 John Bateman. All rights reserved.
//
//  This view controller displays the Kiva.org signup web interface in an embedded web browser.

import UIKit

class KivaSignupViewController: UIViewController, UIWebViewDelegate {

    static let KivaSignInURL:String = "https://www.kiva.org/login?doneUrl=https%3A%2F%2Fwww.kiva.org%2Fportfolio"
    static let KivaSignUpURL:String = "https://www.kiva.org/register?doneUrl=https%3A%2F%2Fwww.kiva.org%2Fportfolio"
    
    var request = NSURLRequest(URL: NSURL(string: KivaSignUpURL)!)
    
    let webView : UIWebView = UIWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        loadAddressURL()
    }
    
    func setupView() {
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        //navigationItem.hidesBackButton = false
        createCustomBackButton()
        
        self.webView.frame = UIScreen.mainScreen().bounds
        self.webView.scalesPageToFit = true
        self.webView.delegate = self
        
        self.view.addSubview(self.webView)
    }
    
    /*! hide the status bar */
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadAddressURL() {
            self.webView.loadRequest(request)
    }
    
    
    // MARK: Navigation
    
    func createCustomBackButton() {
        let customBackButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(KivaSignupViewController.onCancelButton))
        navigationItem.setLeftBarButtonItem(customBackButton, animated: true)
    }
    
    func onCancelButton() {
        popViewController()
    }
    
    func popViewController() {
        navigationController?.popToRootViewControllerAnimated(true)
    }
}
