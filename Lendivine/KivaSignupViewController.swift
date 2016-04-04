//
//  KivaSignupViewController.swift
//  Lendivine
//
//  Created by john bateman on 4/3/16.
//  Copyright © 2016 John Bateman. All rights reserved.
//

import UIKit

class KivaSignupViewController: UIViewController, UIWebViewDelegate {

    static let KivaSignInURL:String = "https://www.kiva.org/login?doneUrl=https%3A%2F%2Fwww.kiva.org%2Fportfolio"
    static let KivaSignUpURL:String = "https://www.kiva.org/register?doneUrl=https%3A%2F%2Fwww.kiva.org%2Fportfolio"
    
    var request = NSURLRequest(URL: NSURL(string: KivaSignUpURL)!)
    
    //var targetURL : NSURL = NSURL()
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
    
    //    override func handle(url: NSURL) {
    //        targetURL = url
    //        super.handle(url)
    
    //    UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(self, animated: true, completion: nil)
    //    }
    
    func loadAddressURL() {
        //        let req = NSURLRequest(URL: targetURL)
//        if let request = request {
            self.webView.loadRequest(request)
//        } else {
//            // load a default page for testing purposes
//            let url = NSURL(string: "http://www.kiva.org/home")
//            let request = NSURLRequest(URL: url!)
//            self.webView.loadRequest(request)
//        }
    }
    
    //    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
    //        if let url = request.URL where (url.scheme == "oauth-swift"){
    //            self.dismissWebViewController() // self.dismissViewControllerAnimated(true, completion: nil)
    //        }
    //        return true
    //    }
    
    
    // MARK: Navigation
    
    func createCustomBackButton() {
        let customBackButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "onCancelButton")
        navigationItem.setLeftBarButtonItem(customBackButton, animated: true)
    }
    
    func onCancelButton() {
        popViewController()
    }
    
    func popViewController() {
        
       // if let src = self.sourceViewController {
            navigationController?.popToRootViewControllerAnimated(true)
       // }
    }
}
