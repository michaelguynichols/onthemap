//
//  Student.swift
//  OnTheMap
//
//  Created by Michael Nichols on 7/29/15.
//  Copyright (c) 2015 Michael Nichols. All rights reserved.
//

import Foundation

// Student struct to pass to post method later.
struct Student {
    
    var uniqueKey: String
    var firstName: String
    var lastName: String
    var mapString: String
    var mediaURL: String
    var latitude: Double
    var longitude: Double
    
    init(unique: String, first: String, last: String, map: String, media: String, lat: Double, lon: Double) {
        uniqueKey = unique
        firstName = first
        lastName = last
        mapString = map
        mediaURL = media
        latitude = lat
        longitude = lon
    }
    
}