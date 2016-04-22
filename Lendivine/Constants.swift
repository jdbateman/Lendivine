//
//  Constants.swift
//  OAuthSwift
//
//  Created by Dongri Jin on 7/17/14.
//  Copyright (c) 2014 Dongri Jin. All rights reserved.
//

import Foundation

let Kiva =
[
    "consumerKey": "self.JohnBateman.Lendivine",
    "consumerSecret": "eS-rbvgZ7KlqMB7hSyVN4L8dlaAR9AwT"
]

class Constants {
    
    struct OAuthKeys {
        static let consumerKey: String = "consumerKey"
        static let consumerSecret: String = "consumerSecret"
        
    }
    
    struct OAuthValues {
        static let consumerKey: String = "self.JohnBateman.Lendivine"
        static let consumerSecret: String = "eS-rbvgZ7KlqMB7hSyVN4L8dlaAR9AwT"
        static let consumerCallbackUrl: String = "oauth-swift://oauth-callback/kiva/Lendivine"
        static let consumerCallbackUrlHost: String = "oauth-callback"
        static let consumerCallbackUrlPath: String = "/kiva/Lendivine"
    }
    
}