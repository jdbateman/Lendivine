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
    func handle(_ url: URL)
}

open class OAuthSwiftOpenURLExternally: OAuthSwiftURLHandlerType {
    
    static let sharedInstance = OAuthSwiftOpenURLExternally() //todo:swift3
    
//    private static var __once: () = {
//            Static.instance = OAuthSwiftOpenURLExternally()
//        }()
//    class var sharedInstance : OAuthSwiftOpenURLExternally {
//        struct Static {
//            static var onceToken : Int = 0
//            static var instance : OAuthSwiftOpenURLExternally? = nil
//        }
//        _ = OAuthSwiftOpenURLExternally.__once
//        return Static.instance!
//    }

    
    @objc open func handle(_ url: URL) {
        #if os(iOS)
            // TODO: Re-enable to see log of OAuth request.
            // print("openURL(\(url))")
            UIApplication.shared.openURL(url)
        #elseif os(OSX)
            NSWorkspace.sharedWorkspace().openURL(url)
        #endif
    }
}
