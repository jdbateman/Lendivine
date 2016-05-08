//
//  UIApplication+Extension.swift
//  Lendivine
//
//  Created by john bateman on 5/7/16.
//  Copyright © 2016 John Bateman. All rights reserved.
//
// Acknowledgement: Thanks to Diaz on stack overflow for this extension allowing acquisition of the top controller anywhere in the app.

import UIKit

extension UIApplication {
    
    class func topViewController(base: UIViewController? = UIApplication.sharedApplication().keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }
}