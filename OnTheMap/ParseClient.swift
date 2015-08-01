//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Michael Nichols on 7/27/15.
//  Copyright (c) 2015 Michael Nichols. All rights reserved.
//

import Foundation
import UIKit

class ParseClient {
    
    /* Shared session */
    var session: NSURLSession
    let object = UIApplication.sharedApplication().delegate
    var appDelegate: AppDelegate!
    
    
    init() {
        session = NSURLSession.sharedSession()
        appDelegate = object as! AppDelegate
    }
    
    // Helper function to parse JSON data.
    func parseJSONResult(data: NSData) -> NSDictionary?  {
        var parsingError: NSError? = nil
        let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
        return parsedResult
    }
    
    func getStudentLocations(completionHandler: (result: [StudentInformation]!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        // Emptying old data to add new data from call
        self.appDelegate.studentInformation.removeAll(keepCapacity: false)
        
        // Making request
        let request = NSMutableURLRequest(URL: NSURL(string: ParseClient.URL.baseURL)!)
        
        // Adding required elements to request
        request.addValue(ParseClient.API.parseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(ParseClient.API.RESTAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")

        // Task with request
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                // Handle error
                completionHandler(result: nil, error: NSError(domain: "Download", code: 0, userInfo: [NSLocalizedDescriptionKey: "Download Error"]))
            } else {
                //let response = NSString(data: data, encoding: NSUTF8StringEncoding)
                if let userLocations = self.parseJSONResult(data) {
                    if let studentLocations = userLocations["results"] as? [[String: AnyObject]] {
                        
                        // Create student structs
                        for studentlocationInformation in studentLocations {
                            
                            // Initializing student struct
                            var studentInformation = StudentInformation(responseData: studentlocationInformation)
                            
                            // Appending to student struct array in App Delegate
                            self.appDelegate.studentInformation.append(studentInformation)

                        }
                        
                        // If data is good, send it to the completion handler.
                        completionHandler(result: self.appDelegate.studentInformation, error: nil)
                    }
                }
            }
        }
        task.resume()
        return task
    }
    
    func postStudentLocations(completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        
        // Post method
        request.HTTPMethod = UdacityLogin.Methods.POST
        
        // Adding required elements to request
        request.addValue(ParseClient.API.parseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(ParseClient.API.RESTAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Getting current logged in student info
        let student = appDelegate.currentUser!

        
        // Adding HTTPBody elements
        request.HTTPBody = "{\"uniqueKey\": \"1234\", \"firstName\": \"\(student.firstName)\", \"lastName\": \"\(student.lastName)\",\"mapString\": \"\(student.mapString)\", \"mediaURL\": \"\(student.mediaURL)\",\"latitude\": \(student.latitude), \"longitude\": \(student.longitude)}".dataUsingEncoding(NSUTF8StringEncoding)
        
        // Creating task.
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                completionHandler(result: nil, error: NSError(domain: "Post", code: 0, userInfo: [NSLocalizedDescriptionKey: "Post Error"]))
            } else {
                // Post was successful
                completionHandler(result: "Success", error: nil)
            }
        }
        task.resume()
        return task
    }
}