//
//  Constants.swift
//  OnTheMap
//
//  Created by Michael Nichols on 7/27/15.
//  Copyright (c) 2015 Michael Nichols. All rights reserved.
//

import Foundation

extension UdacityLogin {
    
    struct URLs {
        // Base URL for Udacity API
        static let udacityAPIURL = NSURL(string: "https://www.udacity.com/api/session")!
        static let udacityUserInfoURL = "https://www.udacity.com/api/users/"
    }
    
    struct Methods {
        // HTTP Methods for Udacity
        static let POST = "POST"
        static let DELETE = "DELETE"
        static let GET = "GET"
    }
}