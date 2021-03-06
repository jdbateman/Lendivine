//
//  OAuthSwiftURLHandlerType.swift
//  OAuthSwift
//
//  Created by phimage on 11/05/15.
//  Copyright (c) 2015 Dongri Jin. All rights reserved.
//

import Foundation

#if os(iOS)
    import UIKit
#elseif os(OSX)
    import AppKit
#endif

@objc public protocol OAuthSwiftURLHandlerType {
    func handle(url: NSURL)
}

public class OAuthSwiftOpenURLExternally: OAuthSwiftURLHandlerType {
    class var sharedInstance : OAuthSwiftOpenURLExternally {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : OAuthSwiftOpenURLExternally? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = OAuthSwiftOpenURLExternally()
        }
        return Static.instance!
    }
    
    @objc public func handle(url: NSURL) {
        #if os(iOS)
            // TODO: Re-enable to see log of OAuth request.
            // print("openURL(\(url))")
            UIApplication.sharedApplication().openURL(url)
        #elseif os(OSX)
            NSWorkspace.sharedWorkspace().openURL(url)
        #endif
    }
}