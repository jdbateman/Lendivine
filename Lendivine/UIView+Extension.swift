//
//  UIView+Extension.swift
//  Lendivine
//
//  Created by john bateman on 4/28/16.
//  Copyright © 2016 John Bateman. All rights reserved.
//
//  This extension allows any UIView derived class to make a single call to do a fade in or fade out animation.
//  Acknowledgement: Andrew Bancroft

import Foundation
import UIKit

extension UIView {

    func fadeOutAnimation(duration: NSTimeInterval = 1.0, delay: NSTimeInterval = 0.0, completion: ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions.CurveEaseOut, animations: {
        self.alpha = 0.0
        self.center = CGPoint(x: self.center.x, y: self.center.y)
        }, completion: completion)
    }
    
    func fadeInAnimation(duration: NSTimeInterval = 1.0, delay: NSTimeInterval = 0.0, completion: ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.alpha = 1.0
            self.center = CGPoint(x: self.center.x - 600, y: self.center.y)
            }, completion: completion)
    }
}