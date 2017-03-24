//
//  DVNCache.swift
//  Lendivine
//
//  Created by john bateman on 3/21/17.
//  Copyright © 2017 John Bateman. All rights reserved.
//

import Foundation

class DVNCache: NSCache<AnyObject, AnyObject> {
    
    static let sharedInstance = NSCache<AnyObject, AnyObject>()
    
    private override init() {
        super.init()
    }
}
