//
//  KivaPaging.swift
//  Lendivine
//
//  Created by john bateman on 11/18/15.
//  Copyright © 2015 John Bateman. All rights reserved.
//
//  This helper class contains paging information contained in certain Kiva API responses.

import Foundation

struct KivaPaging {
    
    var page = 0        // the current page
    var pageSize = 0    // the number of items per page
    var pages = 0       // the total number of pages
    var total = 0       // the total number of items in all pages combined
    
    init() {
        
    }
    
    init(dictionary: [String: AnyObject?]) {
        
        if let pg = dictionary["page"] as? Int {
            page = pg
        }
        if let size = dictionary["page_size"] as? Int {
            pageSize = size
        }
        if let pgs = dictionary["pages"] as? Int {
            pages = pgs
        }
        if let t = dictionary["total"] as? Int {
            total = t
        }
    }
}