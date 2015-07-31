//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by Michael Nichols on 7/27/15.
//  Copyright (c) 2015 Michael Nichols. All rights reserved.
//

import Foundation
import UIKit

// Student information dictionary/struct to pass to map view.
struct StudentInformation {
    
    var UdacityUserDictionary: [String: AnyObject]
    
    init(responseData: [String: AnyObject]) {
        UdacityUserDictionary = responseData
    }
    
    func getUserData() -> [String: AnyObject] {
        return UdacityUserDictionary
    }
    
    func getInfoByKey(key: String) -> AnyObject {
        return UdacityUserDictionary[key]!
    }
    
}