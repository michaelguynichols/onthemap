//
//  PinTableViewController.swift
//  OnTheMap
//
//  Created by Michael Nichols on 7/24/15.
//  Copyright (c) 2015 Michael Nichols. All rights reserved.
//

import Foundation
import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class PinTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
    
    var userLocations = [StudentInformation]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBarItems()   
        
        // Setting userLocations equal to loaded Parse user locations if any from appDelegate.
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        userLocations = appDelegate.studentInformation
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reload data when view reappears with helper method.
        reloadUserLocations()
        
    }
    
    // Button method to segue to posting view.
    func toPostView() {
        performSegueWithIdentifier("TableToPostSegue", sender: self)
    }
    
    // Delegate method to get count for table
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userLocations.count
    }
    
    // Delegate method to set information for each table cell
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let CellReuseId = "pinData"
        let userLocation = userLocations[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(CellReuseId) as! UITableViewCell
        
        let firstName = userLocation.getInfoByKey("firstName") as! String
        let lastName = userLocation.getInfoByKey("lastName") as! String
        
        cell.textLabel!.text = "\(firstName) \(lastName)"
        cell.imageView!.image = UIImage(named: "Pin")
        
        return cell
    }
    
    // Delegate method to open up url associated with each name in table rows
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let userLocation = userLocations[indexPath.row]
        if let mediaURL = userLocation.getInfoByKey("mediaURL") as? String {
            let URL = NSURL(string: mediaURL)
            UIApplication.sharedApplication().openURL(URL!)
        }
        
    }
    
    // Helper function to reload data
    func reloadUserLocations() {
        
        // Loading User Locations
        var parseExample = ParseClient()
        
        parseExample.getStudentLocations() {JSONResult, error in
            
            if let error = error?.domain {
                println(error)
            } else {
                // Successful reload
            }
        }
        
    }
    
    func setBarItems() {
        // Setting bar button items and actions associated with tapping them
        var rightBarButtonRefresh: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "reloadUserLocations")
        
        var rightBarButtonPin: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "Pin"), landscapeImagePhone: nil, style: UIBarButtonItemStyle.Plain, target: self, action: "toPostView")
        
        navigationItem.setRightBarButtonItems([rightBarButtonRefresh, rightBarButtonPin], animated: true)
    }

    // Function to logout depending on how signed in. If facebook, use logout manager. If Udacity, use Udacity API Delete method.
    @IBAction func logOut(sender: UIBarButtonItem) {
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            
            // Creating a Facebook login manager and logging out programmatically.
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
            dismissViewControllerAnimated(true, completion: nil)
            
        } else {
            var udacityLogout = UdacityLogin(user: nil, pass: nil)
            udacityLogout.logout() { JSONResult, error in
                if let error = error {
                    println("Error")
                } else {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
    }
}