//
//  MySingleton.swift
//  OAuthSwift
//
//  Created by john bateman on 10/27/15.
//  Copyright © 2015 John Bateman. All rights reserved.
//

import Foundation


class MySingleton {
    
    static var _bTimeStampInHeader = true
    
    static let sharedInstance = MySingleton()
    
    private init () {
        //MySingleton.timestampInHeader = true
        print("timestampInHeader.init() in MySingleton.init() reports timestampInHeader = \(MySingleton._bTimeStampInHeader)")
    }
    
    var timeStampInHeader: Bool {
        get {
            return MySingleton._bTimeStampInHeader
        }
        set {
            MySingleton._bTimeStampInHeader = newValue
        }
    }
}

//class MySingleton {
//    
//    var timestampInHeader: Bool
//    
//    /* Get a shared instance */
//    static func sharedInstance() -> MySingleton {
//        struct Static {
//            static let instance = MySingleton()
//        }
//        print("returning Static.instance. timestampInHeader = \(Static.instance.timestampInHeader)")
//        return Static.instance
//    }
//    
//    init () {
//        self.timestampInHeader = true
//        print("timestampInHeader.init() in MySingleton.init() sets timestampInHeader = true")
//    }
//}