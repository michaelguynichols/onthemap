//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Michael Nichols on 7/24/15.
//  Copyright (c) 2015 Michael Nichols. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import FBSDKCoreKit
import FBSDKLoginKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    // The map. See the setup in the Storyboard file. Note particularly that the view controller
    // is set up as the map view's delegate.
    @IBOutlet weak var map: MKMapView!
    
    // Create an MKPointAnnotation for each student info struct in studentInfo.
    var annotations = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        map.delegate = self
        
        // Setting the bar items with helper method
        setBarItems()
        
        // Loading user locations with helper method
        loadUserLocations()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Refreshing the latest data with helper method
        refresh()
        
    }
    
    func refresh() {
        loadUserLocations()
    }
    
    func loadUserLocations() {
        
        // Loading User Locations through parse client getStudentlocations method
        var parseExample = ParseClient()
        
        parseExample.getStudentLocations() {JSONResult, error in
            
            // If download error, create a UIAlertController
            if let error = error?.domain {
                
                let alert = UIAlertController(title: "Download Error", message: "Download Error.", preferredStyle: .Alert)
                
                let cancel = UIAlertAction(title: "OK", style: .Cancel, handler: {(action) -> Void in})
                alert.addAction(cancel)
                
                self.presentViewController(alert, animated: true, completion: nil)
                
            } else {
                
                // Grabbing the JSONResult to iterate over
                let studentInfo = JSONResult as [StudentInformation]
                
                // Iterating through StudentInformation structs
                for studentInfoEntry in studentInfo {
                    
                    // Grabbing the latitude and longitude from the studentinfo struct
                    let lat = CLLocationDegrees(studentInfoEntry.getInfoByKey("latitude") as! Double)
                    let long = CLLocationDegrees(studentInfoEntry.getInfoByKey("longitude") as! Double)
                    
                    // The lat and long are used to create a CLLocationCoordinates2D instance.
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    
                    // Grabbing user information from the StudentInformation array
                    let first = studentInfoEntry.getInfoByKey("firstName") as! String
                    let last = studentInfoEntry.getInfoByKey("lastName") as! String
                    let mediaURL = studentInfoEntry.getInfoByKey("mediaURL") as! String
                    
                    // Here we create the annotation and set its coordiate, title, and subtitle properties
                    var annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    annotation.title = "\(first) \(last)"
                    annotation.subtitle = mediaURL
                    
                    // Finally we place the annotation in an array of annotations.
                    self.annotations.append(annotation)
                }
                
                // When the array is complete, we add the annotations to the map.
                self.map.addAnnotations(self.annotations)
            }
        }

    }
    
    // Here we create a view with right callout accessory view.
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Purple
            pinView!.rightCalloutAccessoryView = UIButton.buttonWithType(.InfoDark) as! UIButton
        }
        else {
            pinView!.annotation = annotation
        }
        
       return pinView
    }
    
    func toPostView() {
        performSegueWithIdentifier("MapToPostSegue", sender: self)
    }
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string: view.annotation.subtitle!)!)
        } else {
            println("Tapped")
        }
    }
    
    func setBarItems() {
        // Setting bar button items and their action events
        var rightBarButtonRefresh: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "refresh")
        
        var rightBarButtonPin: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "Pin"), landscapeImagePhone: nil, style: UIBarButtonItemStyle.Plain, target: self, action: "toPostView")
        
        navigationItem.setRightBarButtonItems([rightBarButtonRefresh, rightBarButtonPin], animated: true)
    }
    
    @IBAction func logOut(sender: UIBarButtonItem) {
        
        // Checking if user logged in through Facebook
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            
            // Creating a Facebook login manager and logging out programmatically.
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
            dismissViewControllerAnimated(true, completion: nil)
            
        } else {
            
            // If user not logged in through Facebook, use Udacity api logout method to sign out
            var udacityLogout = UdacityLogin(user: nil, pass: nil)
            udacityLogout.logout() { JSONResult, error in
                if let error = error {
                    println(error)
                } else {
                    // If method successful, dismiss VC
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
    }
    
}