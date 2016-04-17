//
//  KivaCartViewController.swift
//  Lendivine
//
//  Created by john bateman on 11/15/15.
//  Copyright © 2015 John Bateman. All rights reserved.
//
//  This table view controller displays the kiva.org cart in an embedded web view.

import UIKit

class KivaCartViewController: UIViewController, UIWebViewDelegate {
    
    var request : NSMutableURLRequest!
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
    
    func loadAddressURL() {

        if let request = request {
            self.webView.loadRequest(request)
        } else {
            // load a default page for testing purposes
            let url = NSURL(string: "http://www.google.com")
            let request = NSURLRequest(URL: url!)
            self.webView.loadRequest(request)
        }
    }
}

