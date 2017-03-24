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
    
    fileprivate init () {
        //MySingleton.timestampInHeader = true
        //print("timestampInHeader.init() in MySingleton.init() reports timestampInHeader = \(MySingleton._bTimeStampInHeader)")
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
