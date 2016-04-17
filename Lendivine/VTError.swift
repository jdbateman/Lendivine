//
//  VTError.swift
//  Lendivine
//
//  Created by john bateman on 11/15/15.
//  Copyright © 2015 John Bateman. All rights reserved.
//
//  This convenience class can be used to define an application error.

import Foundation

class VTError {
    
    var error: NSError?
    
    struct Constants {
        static let ERROR_DOMAIN: String = "self.Lendivine.Error"
    }
    
    enum ErrorCodes: Int {
        case CORE_DATA_INIT_ERROR = 9000
        case JSON_PARSE_ERROR = 9001
        case KIVA_REQUEST_ERROR = 9002
        case S3_FILE_DOWNLOAD_ERROR = 9003
        case IMAGE_CONVERSION_ERROR = 9004
        case FILE_NOT_FOUND_ERROR = 9005
        case KIVA_OAUTH_ERROR = 9006
        case KIVA_API_NO_LOANS = 9007
        case KIVA_API_LOAN_NOT_FOUND = 9008
    }
    
    init(errorString: String, errorCode: ErrorCodes) {
        // output to console
        print(errorString)
        
        // construct NSError
        var dict = [String: AnyObject]()
        dict[NSLocalizedDescriptionKey] = errorString
        error = NSError(domain: VTError.Constants.ERROR_DOMAIN, code: errorCode.rawValue, userInfo: dict)
    }
}