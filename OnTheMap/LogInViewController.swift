//
//  LogInViewController.swift
//  OnTheMap
//
//  Created by Michael Nichols on 7/19/15.
//  Copyright (c) 2015 Michael Nichols. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class LogInViewController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {

    @IBOutlet weak var EmailTextField: CustomTextField!
    @IBOutlet weak var PasswordTextField: CustomTextField!
    @IBOutlet weak var LoginButton: UIButton!
    @IBOutlet weak var signUpLabel: UILabel!
    let udacitySignUpURL = NSURL(string: "https://www.udacity.com/account/auth#!/signup")
    var firstName = String()
    var lastName = String()
    let object = UIApplication.sharedApplication().delegate
    var appDelegate: AppDelegate!
    
    // Creating Facebook Login Button View
    let loginView : FBSDKLoginButton = FBSDKLoginButton()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configuring the UI and Facebook parameters
        configureUIAndFacebook()
        
        // Assigning delegates
        assignDelegates()
        
        appDelegate = object as! AppDelegate
        
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            
            // If logged in on facebook, get user info
            returnUserData()
            
        }
        
    }
    
    // Facebook login delegate function
    func loginButton(loginButton: FBSDKLoginButton!,
        didCompleteWithResult result: FBSDKLoginManagerLoginResult!,
        error: NSError!) {
        if ((error) != nil) {
            // Process error
            println(error)
        } else if result.isCancelled {
            // Handle cancellations
        } else {
            
            // If log in successful on facebook, get user info and segue to map
            returnUserData()
            self.performSegueWithIdentifier("ToMapSegue", sender: self)
        }
    }
    
    // Facebook login delegate function
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        // Creating a Facebook login manager and logging out programmatically.
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()

    }
    
    // Facebook login delegate function
    func returnUserData() {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            if ((error) != nil) {
                // Process error
                println("Error: \(error)")
            }
            else
            {
                // Setting memes array equal to AppDelegate memes data model
                self.appDelegate.userID = result.valueForKey("id") as! String
                println(self.appDelegate.userID)
                let userName : NSString = result.valueForKey("name") as! NSString
                self.splitName(userName as String)
                
            }
        })
    }
    
    // Helper functiont to get first and last name of facebook user.
    func splitName(userName: String) {
        let fullName = split(userName) {$0 == " "}
        if fullName.count == 2 {
            firstName = fullName[0]
            lastName = fullName[1]
            appDelegate.FBFirstName = firstName
            appDelegate.FBLastName = lastName
        }
        
    }

    // Function to dismiss keyboard
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        dismissKeyboard()
        return false
    }

    func textFieldDidBeginEditing(textField: UITextField) {
        if EmailTextField.text == "Email" {
            EmailTextField.text = ""
        } else if PasswordTextField.text == "Password" {
            PasswordTextField.text = ""
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // Segue to the Map
        if segue.identifier == "ToMapSegue" {
            let mapViewController = segue.destinationViewController as! UITabBarController
        }
        
    }
    
    func openSafariUdacityURL() {
        signUpLabel.textColor = UIColor.blueColor()
        UIApplication.sharedApplication().openURL(udacitySignUpURL!)
    }
    
    @IBAction func LoginTouchUpInside(sender: UIButton) {
        loginWithUdacityCredentials()
    }
    
    func loginWithUdacityCredentials() {
        // Dismiss keyboard if login pressed while entering password or username.
        dismissKeyboard()
        
        // Calling UdacityLogin class's login function
        var udacityLogin = UdacityLogin(user: EmailTextField.text, pass: PasswordTextField.text)
        
        udacityLogin.login() {JSONResult, error in
            if let error = error?.domain {
                if error == "Account" {
                    self.loginError("Account")
                } else if error == "Download" {
                    self.loginError("Download")
                }
            } else {
                self.performSegueWithIdentifier("ToMapSegue", sender: self)
            }
        }

    }
    
    func loginError(type: String) {
        
        switch (type) {
        case let type where type == "Account":
            // Alert for no account or invalid user credentials.
            let alert = UIAlertController(title: "Sign-in Error", message: "Account not found or invalid credentials.  If you do not have an account, click on 'Sign Up'. Otherwise, make sure your user email and password were correctly entered.", preferredStyle: .Alert)
            
            let cancel = UIAlertAction(title: "OK", style: .Cancel, handler: {(action) -> Void in})
            alert.addAction(cancel)
            
            self.presentViewController(alert, animated: true, completion: nil)
            
        case let type where type == "Download":
            // Alert for connection error.
            let alert = UIAlertController(title: "Connection Error", message: "Connection Error.", preferredStyle: .Alert)
            
            let cancel = UIAlertAction(title: "OK", style: .Cancel, handler: {(action) -> Void in})
            alert.addAction(cancel)
            
            self.presentViewController(alert, animated: true, completion: nil)
            
        default:
            ""
        }
        
    }
    
    func configureUIAndFacebook() {
        // Formatting LoginButton's edges
        LoginButton.layer.cornerRadius = 5
        
        // Creating a tap gesture recognizer for the signup label
        let tapGesture = UITapGestureRecognizer(target: self, action: "openSafariUdacityURL")
        signUpLabel.addGestureRecognizer(tapGesture)
        signUpLabel.userInteractionEnabled = true
        
        // Adding loginView to the view
        self.view.addSubview(loginView)
        
        // Adjusting loginView's positioning
        loginView.center = self.view.center
        loginView.frame.origin.y += 300
        loginView.frame = CGRectMake(15, 600, 345, 40)
        
        // Setting loginView's permissions
        loginView.readPermissions = ["public_profile"]
    }
    
    func assignDelegates() {
        // Assigning delegates
        loginView.delegate = self
        EmailTextField.delegate = self
        PasswordTextField.delegate = self
    }
    
}

