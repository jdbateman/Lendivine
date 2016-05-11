//
//  KivaCountry.swift
//  OAuthSwift
//
//  Created by john bateman on 11/7/15.
//  Copyright © 2015 Dongri Jin. All rights reserved.
//

import Foundation

class KivaCountry {
    
    var iso_code: String = ""
    var locationGeoLevel: String = ""
    var locationGeoCoordinatePair: String = ""
    var locationGeoType: String = ""
    var name: String = ""
    var region: String = ""
    
    
    // designated initializer
    init(dictionary: [String: AnyObject]?) {
        if let dictionary = dictionary {
            
            if let code = dictionary["iso_code"] as? String {
                iso_code = code
            }
            
            // location
            if let locationDict = dictionary["location"] as? [String: AnyObject] {
                // geo
                if let geoDict = locationDict["geo"] as? [String: AnyObject] {
                    if let l = geoDict["level"] as? String {
                        locationGeoLevel = l
                    }
                    if let p = geoDict["pairs"] as? String {
                        locationGeoCoordinatePair = p
                    }
                    if let t = geoDict["type"] as? String {
                        locationGeoType = t
                    }
                }
            }
            
            if let n = dictionary["name"] as? String {
                name = n
            }
            if let r = dictionary["region"] as? String {
                region = r
            }
        }
    }
    
    /* Kiva countries JSON found contained in partner JSON
    countries =             (
    {
        "iso_code" = PS;
        location =                     {
            geo =                         {
                level = country;
                pairs = "31.92157 35.203285";
                type = point;
            };
        };
        name = Palestine;
        region = "Middle East";
        }
    );
    */
}
