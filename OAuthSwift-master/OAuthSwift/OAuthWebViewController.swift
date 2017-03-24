//
//  OAuthWebViewController.swift
//  OAuthSwift
//
//  Created by Dongri Jin on 2/11/15.
//  Copyright (c) 2015 Dongri Jin. All rights reserved.
//

import Foundation

#if os(iOS)
    import UIKit
    public typealias OAuthViewController = UIViewController
#elseif os(OSX)
    import AppKit
    public typealias OAuthViewController = NSViewController
#endif

open class OAuthWebViewController: OAuthViewController, OAuthSwiftURLHandlerType {

    open func handle(_ url: URL){
        #if os(iOS)
            UIApplication.shared.keyWindow?.rootViewController?.present(
                self, animated: true, completion: nil)
        #elseif os(OSX)
            if let p = self.parentViewController { // default behaviour if this controller affected as child controller
                p.presentViewControllerAsModalWindow(self)
            } else if let window = self.view.window {
                window.makeKeyAndOrderFront(nil)
            }
            // or create an NSWindow or NSWindowController (/!\ keep a strong reference on it)
        #endif
    }

    open func dismissWebViewController() {
        #if os(iOS)
            self.dismiss(animated: true, completion: nil)
        #elseif os(OSX)
            if self.presentingViewController != nil { // if presentViewControllerAsModalWindow
                self.dismissController(nil)
                if self.parentViewController != nil {
                    self.removeFromParentViewController()
                }
            }
            else if let window = self.view.window {
                window.performClose(nil)
            }
        #endif
    }
}
