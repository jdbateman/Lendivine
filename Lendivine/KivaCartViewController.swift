//
//  KivaCartViewController.swift
//  Lendivine
//
//  Created by john bateman on 11/15/15.
//  Copyright © 2015 John Bateman. All rights reserved.
//
// This table view controller displays the loans in the cart.

// TODO - support selecting a loan to display detailed information on the loan

import UIKit
//import OAuthSwift

class KivaCartViewController: UIViewController, UIWebViewDelegate {
    
    var request : NSMutableURLRequest!
    //var targetURL : NSURL = NSURL()
    let webView : UIWebView = UIWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.webView.frame = UIScreen.mainScreen().bounds
        self.webView.scalesPageToFit = true
        self.webView.delegate = self
        
        self.view.addSubview(self.webView)
        
        loadAddressURL()
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
        if let request = request {
            self.webView.loadRequest(request)
        } else {
            // load a default page for testing purposes
            let url = NSURL(string: "http://www.google.com")
            let request = NSURLRequest(URL: url!)
            self.webView.loadRequest(request)
        }
    }
    
    //    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
    //        if let url = request.URL where (url.scheme == "oauth-swift"){
    //            self.dismissWebViewController() // self.dismissViewControllerAnimated(true, completion: nil)
    //        }
    //        return true
    //    }
}

