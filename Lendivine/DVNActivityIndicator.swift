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
    
    fileprivate var activityIndicatorBackView: UIView?
    fileprivate var indicator = UIActivityIndicatorView()
    

    //*! Create and render an activity indicator on the visible portion of the specified view. The activity indicator has a backing view. */
    internal func startActivityIndicator(_ view: UIView?) {
        
        guard let view = view else {
            return
        }
        
        // determine which portion of the table view controller is visible
        let visibleRect: CGRect = view.convert(view.bounds, to:view)
        
        // create the background view
        activityIndicatorBackView = UIView(frame: CGRect(x: 100, y: 200, width: 100, height: 100))
        if let backView = activityIndicatorBackView {
            
            backView.backgroundColor = UIColor(red: 240/255, green: 170/255, blue: 43/255, alpha: 1.0)  // UIColor.lightGrayColor()
            backView.layer.cornerRadius = 10
            backView.layer.borderWidth = 2
            backView.layer.borderColor = UIColor.white.cgColor
            let center: CGPoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
            backView.center = center
            view.addSubview(backView)
            
            // create the indicator
            indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40.0, height: 40.0))
            indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
            indicator.center = center
            indicator.hidesWhenStopped = true
            view.addSubview(indicator)
            
            // render the indicator
            self.indicator.startAnimating()
        }
    }
    
    /*! Destroy the activity indicator and it's backing view. */
    internal func stopActivityIndicator() {
        
        DispatchQueue.main.async {
            self.indicator.stopAnimating()
            if let backView = self.activityIndicatorBackView {
                backView.removeFromSuperview()
                self.activityIndicatorBackView = nil
            }
        }
    }
}
