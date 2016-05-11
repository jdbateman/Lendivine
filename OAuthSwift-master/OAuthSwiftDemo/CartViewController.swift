//
//  CartViewController.swift
//  OAuthSwift
//
//  Created by john bateman on 11/10/15.
//  Copyright © 2015 Dongri Jin. All rights reserved.
//

import UIKit
//import OAuthSwift

class CartViewController: UIViewController, UIWebViewDelegate {
    
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
