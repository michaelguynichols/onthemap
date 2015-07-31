//
//  PostingViewController.swift
//  OnTheMap
//
//  Created by Michael Nichols on 7/24/15.
//  Copyright (c) 2015 Michael Nichols. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation
import FBSDKCoreKit

class PostingViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    // UI outlets
    @IBOutlet weak var findOnTheMapButton: UIButton!
    @IBOutlet weak var searchTextView: UITextView!
    @IBOutlet weak var bottomAreaTextView: UITextView!
    @IBOutlet weak var topAreaTextView: UITextView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // Student Struct variables for posting submission from map
    var firstName = String()
    var lastName = String()
    var latitude = Double()
    var longitude = Double()
    var uniqueID = String()
    
    
    @IBOutlet weak var initialTextView: UITextView!
    var coords: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configuring the initial UI with helper method
        configureInitialUI()
        
        // Determining whether logged in with Facebook or Udacity to set variables for the Student struct correctly
        determineHowLoggedIn()
        
        // Using app delegate to grab user id for student struct
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        
        if let ID = appDelegate.userID as? String {
            self.uniqueID = ID
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Assigning delegate
        initialTextView.delegate = self
        
        // Changing font
        initialTextView.font = UIFont(name: initialTextView.font.fontName, size: 30)
        
    }
    
    // Centering the top area text vertically
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        
        var topCorrect : CGFloat = (topAreaTextView.frame.height - topAreaTextView.contentSize.height);
        topCorrect = topCorrect < 0.0 ? 0.0 : topCorrect / 2
        topAreaTextView.contentOffset = CGPoint(x: 0, y: -topCorrect)
        
    }
    
    // Function to cancel post from posting view at any time
    @IBAction func cancelPost(sender: UIButton) {
        topAreaTextView.removeObserver(self, forKeyPath: "contentSize")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Textview delegate to dismiss keyboard
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    // Textview delegate function to clear text when editing begins if equal to certain values
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.text == "Please enter a location." || textView.text == "Please enter an annotation." {
            textView.text = ""
        } else {
            textView.text = textView.text!
        }
    }
    
    // Helper method to change layout once sent to the map view
    func changeLayoutForMapView() {
        findOnTheMapButton.hidden = true
        bottomAreaTextView.hidden = true
        searchTextView.hidden = true
        topAreaTextView.editable = true
        topAreaTextView.text = "Please enter an annotation."
        var newBackgroundColor = UIColor(red: 64.0/255.0, green: 131.0/255.0, blue: 183.0/255.0, alpha: 1.0)
        topAreaTextView.backgroundColor = newBackgroundColor
        topAreaTextView.textColor = UIColor.whiteColor()
        cancelButton.tintColor = UIColor.whiteColor()
        submitButton.hidden = false
        mapView.hidden = false
    }
    
    // Helper method to configure initial UI elements
    func configureInitialUI() {
        activityIndicator.hidden = true
        findOnTheMapButton.layer.cornerRadius = 10
        submitButton.layer.cornerRadius = 10
        topAreaTextView.delegate = self
        bottomAreaTextView.delegate = self
        bottomAreaTextView.editable = false
        searchTextView.delegate = self
        topAreaTextView.editable = false
        topAreaTextView.textAlignment = .Center
        topAreaTextView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.New, context: nil)
        view.addSubview(topAreaTextView)
        submitButton.hidden = true
        mapView.hidden = true

    }
    
    // Find on the map function that generates a geocode, and if successful, sends it to the submission layout
    @IBAction func findOnTheMap(sender: UIButton) {
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        
        // Initialize new geocoder
        let geoCoder = CLGeocoder()
        var address = searchTextView.text!
        
        // Pass textview address to geocoder to determine if valid search item
        geoCoder.geocodeAddressString(address, completionHandler: {(placemarks: [AnyObject]!, error: NSError!) -> Void in
            
            if let placemark = placemarks?[0] as? CLPlacemark {
                
                var location = CLLocationCoordinate2D(
                    latitude: placemark.location.coordinate.latitude,
                    longitude: placemark.location.coordinate.longitude
                )
                
                // Setting latitude and longitude for student struct
                self.latitude = placemark.location.coordinate.latitude
                self.longitude = placemark.location.coordinate.longitude
                
                var span = MKCoordinateSpanMake(0.5, 0.5)
                var region = MKCoordinateRegion(center: location, span: span)
                
                // Setting regions
                self.mapView.setRegion(region, animated: true)
                
                // Creating new annotation
                var annotation = MKPointAnnotation()
                annotation.coordinate = location
                
                // Adding annotation
                self.mapView.addAnnotation(annotation)
                
                // Since this is successful, changing layout to reveal map view
                dispatch_async(dispatch_get_main_queue(), {
                    self.changeLayoutForMapView()
                    self.activityIndicator.hidden = true
                    self.activityIndicator.stopAnimating()
                })
                
                
            } else {
                // Alert for invalid search string.
                let alert = UIAlertController(title: "Error", message: "The search failed. Please try re-entering a valid string such as 'Mountain View, CA'.", preferredStyle: .Alert)
                
                let cancel = UIAlertAction(title: "OK", style: .Cancel, handler: {(action) -> Void in})
                alert.addAction(cancel)
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
            
        })
        
    }
    
    @IBAction func submit(sender: UIButton) {
        
        // Setting variables for Student struct to pass to post method
        let mediaURL = topAreaTextView.text
        let mapString = searchTextView.text!
        let student = Student(unique: uniqueID, first: firstName, last: lastName, map: mapString, media: mediaURL, lat: latitude, lon: longitude)
        
        // Storing student struct in app delegate
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        appDelegate.currentUser = student
        
        // Initializing ParseClient to call postToStudentLocations
        var parser = ParseClient()
        
        parser.postStudentLocations() { JSONResult, error in
            
            if let error = error {
                // Alert for failed post.
                let alert = UIAlertController(title: "Post Error", message: "The post failed. Please make sure you have entered all data correctly.", preferredStyle: .Alert)
                
                let cancel = UIAlertAction(title: "OK", style: .Cancel, handler: {(action) -> Void in})
                alert.addAction(cancel)
                
                self.presentViewController(alert, animated: true, completion: nil)

            } else {
                // If successful, remove observers and dismiss view
                self.topAreaTextView.removeObserver(self, forKeyPath: "contentSize")
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        
    }

    // Helper function to determine how the user is signed in - with FB or Udacity
    func determineHowLoggedIn() {
    
        // Using app delegate to get data for student struct
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
    
        if (FBSDKAccessToken.currentAccessToken() != nil) {
        
            // If logged in to FB, then grab user name from app delegate.
            if let first = appDelegate.FBFirstName {
                self.firstName = first
            }
        
            if let last = appDelegate.FBLastName {
                self.lastName = last
            }
        
        } else {
        
            // If logged in to Udacity, use Udacity login API to grab user info.
            var udacityLogin = UdacityLogin(user: nil, pass: nil)
        
            udacityLogin.getUserInfo() { JSONResult, error in
                if let error = error {
                    // Alert for failed user info download.
                    let alert = UIAlertController(title: "User Download Error", message: "The download failed. Please enter all information correctly.", preferredStyle: .Alert)
                
                    let cancel = UIAlertAction(title: "OK", style: .Cancel, handler: {(action) -> Void in})
                    alert.addAction(cancel)
                
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    let user = JSONResult as! NSDictionary
                
                    self.firstName = user["first_name"] as! String
                    self.lastName = user["last_name"] as! String
                
                    self.uniqueID = appDelegate.userID! as! String
                
                }
            }

        }

    }
}