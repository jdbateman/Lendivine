//
//  Constants.swift
//  OAuthSwift
//
//  Created by Dongri Jin on 7/17/14.
//  Copyright (c) 2014 Dongri Jin. All rights reserved.
//
// This class contains constant values used in the Oauth exchange with the Kiva.org service.

import Foundation

let Kiva =
[
    "consumerKey": "self.JohnBateman.Lendivine",
    "consumerSecret": "eS-rbvgZ7KlqMB7hSyVN4L8dlaAR9AwT"
]

class Constants {
    
    struct OAuthValues {
        static let consumerKey: String = "self.JohnBateman.Lendivine"
        static let consumerSecret: String = "eS-rbvgZ7KlqMB7hSyVN4L8dlaAR9AwT"
        static let consumerCallbackUrl: String = "oauth-swift://oauth-callback/kiva/Lendivine"
        static let consumerCallbackUrlHost: String = "oauth-callback"
        static let consumerCallbackUrlPath: String = "/kiva/Lendivine"
    }
    
}