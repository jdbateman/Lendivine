//
//  DVNActivityIndicator.swift
//  Lendivine
//
//  Created by john bateman on 3/15/16.
//  Copyright © 2016 John Bateman. All rights reserved.
//
//  This class implements a styled ActivityIndicator to be used in the view.

import Foundation
import UIKit

class DVNActivityIndicator {
    
    var activityIndicatorBackView: UIView?
    var indicator = UIActivityIndicatorView()
    

    //*! Create and render an activity indicator on the visible portion of the specified view. The activity indicator has a backing view. */
    func startActivityIndicator(view: UIView?) {
        
        guard let view = view else {
            return
        }
        
        // determine which portion of the table view controller is visible
        let visibleRect: CGRect = view.convertRect(view.bounds, toView:view)
        
        // create the background view
        activityIndicatorBackView = UIView(frame: CGRectMake(100, 200, 100, 100))
        if let backView = activityIndicatorBackView {
            
            backView.backgroundColor = UIColor(red: 240/255, green: 170/255, blue: 43/255, alpha: 1.0)  // UIColor.lightGrayColor()
            backView.layer.cornerRadius = 10
            backView.layer.borderWidth = 2
            backView.layer.borderColor = UIColor.whiteColor().CGColor
            let center: CGPoint = CGPointMake(CGRectGetMidX(visibleRect), CGRectGetMidY(visibleRect))
            backView.center = center
            view.addSubview(backView)
            
            // create the indicator
            indicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 40.0, 40.0))
            indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
            indicator.center = center
            indicator.hidesWhenStopped = true
            view.addSubview(indicator)
            
            // render the indicator
            self.indicator.startAnimating()
        }
    }
    
    /*! Destroy the activity indicator and it's backing view. */
    func stopActivityIndicator() {
        
        self.indicator.stopAnimating()
        if let backView = activityIndicatorBackView {
            backView.removeFromSuperview()
            activityIndicatorBackView = nil
        }
    }
}