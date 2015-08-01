//
//  UdacityLogin.swift
//  OnTheMap
//
//  Created by Michael Nichols on 7/27/15.
//  Copyright (c) 2015 Michael Nichols. All rights reserved.
//

import Foundation
import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class UdacityLogin {
    
    var userName: String?
    var userPassword: String?
    let object = UIApplication.sharedApplication().delegate
    var appDelegate: AppDelegate!
    
    /* Shared session */
    var session: NSURLSession
    
    init(user: String?, pass: String?) {
        userName = user
        userPassword = pass
        session = NSURLSession.sharedSession()
        appDelegate = object as! AppDelegate
    }
    
    // Helper function to parse data.
    func parseJSONResult(data: AnyObject) -> NSDictionary?  {
        let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
        var parsingError: NSError? = nil
        let parsedResult = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
        return parsedResult
    }
    
    // Login function
    func login(completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        // Creating request and adding values and body
        let request = NSMutableURLRequest(URL: UdacityLogin.URLs.udacityAPIURL)
    
        request.HTTPMethod = UdacityLogin.Methods.POST
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(userName!)\", \"password\": \"\(userPassword!)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
    
        // Creating task
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                completionHandler(result: nil, error: NSError(domain: "Download", code: 0, userInfo: [NSLocalizedDescriptionKey: "Download Error"]))
            } else {
                // If there is a valid parsed result, grab the account key for the unique ID and send completion handler.
                if let parsedResult = self.parseJSONResult(data) {
                    if let account = parsedResult["account"] as? NSDictionary {
                        if let registered = account["registered"] as? Bool {
                            if registered {
                                dispatch_async(dispatch_get_main_queue(), {
                                    // Setting memes array equal to AppDelegate memes data model
                                    self.appDelegate.userID = account["key"]
                                    completionHandler(result: registered, error: nil)
                                })
                            }
                        }
                    } else {
                        // If account credentials invalid.
                        completionHandler(result: nil, error: NSError(domain: "Account", code: 0, userInfo: [NSLocalizedDescriptionKey: "Account not found or invalid credentials."]))
                    }
                }
            }
        }
    
        task.resume()
        
        return task
    }
    
    // Logout function
    func logout(completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        // Creating and setting up request
        let request = NSMutableURLRequest(URL: UdacityLogin.URLs.udacityAPIURL)
        request.HTTPMethod = UdacityLogin.Methods.DELETE
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies as! [NSHTTPCookie] {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.addValue(xsrfCookie.value!, forHTTPHeaderField: "X-XSRF-Token")
        }
        
        // Creating task
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                completionHandler(result: nil, error: NSError(domain: "Logout", code: 0, userInfo: [NSLocalizedDescriptionKey: "Logout Error"]))
            }
            // If valid result, then logout.
            if let parsedResult = self.parseJSONResult(data) {
                if let sessionEnded = parsedResult["session"] as? NSDictionary {
                    if let deleteSuccessful = sessionEnded["expiration"] as? NSObject {
                        completionHandler(result: deleteSuccessful, error: nil)
                    }
                }
            }
        }
        task.resume()
        return task
    }
    
    // Function to get user info based on unique id
    func getUserInfo(completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        // Using app delegate to get current user info
        let userID = appDelegate.userID as! String
        let URL = UdacityLogin.URLs.udacityUserInfoURL + userID
        
        // Creating request
        let request = NSMutableURLRequest(URL: NSURL(string: URL)!)
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                return
            }
            // If valid, pass to completion handler.
            if let parsedResult = self.parseJSONResult(data) {
                if let user = parsedResult["user"] as? NSDictionary {
                    completionHandler(result: user, error: nil)
                }
            }
        }
        task.resume()
        return task
    }
}

