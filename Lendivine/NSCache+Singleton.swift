//
//  NSCache+Singleton.swift
//  Lendivine
//
//  Created by john bateman on 11/16/15.
//  Copyright © 2015 John Bateman. All rights reserved.
//
// Acknowledgement: Thanks to PointZeroTwo's post on SO (http://stackoverflow.com/questions/5755902/how-to-use-nscache) for the idea to use an extension to create a shared instance of a UIKit class.

import Foundation
import UIKit

extension NSCache {
    static var sharedInstance: NSCache {
        struct Singleton {
            static let sharedCache: NSCache = NSCache()
        }
        return Singleton.sharedCache
    }
}