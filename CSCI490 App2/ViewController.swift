//
//  ViewController.swift
//  CSCI490 App2
//
//  Created by Ron Ward on 3/9/16.
//  Copyright © 2016 Ethan Ward. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

var matches: [(user: BackendlessUser, images: [UserImage])] = []

class ViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    let APP_ID = "F94794D7-9623-1423-FFA0-23A0B43E4700"
    let SECRET_KEY = "030F931A-CA13-545E-FF62-B5795C9D9600"
    let VERSION_NUM = "v1"
    var backendless = Backendless.sharedInstance()
    
    var matchList: [String] = []
    var leftList: [String] = []
    var rightList: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        backendless.initApp(APP_ID, secret:SECRET_KEY, version:VERSION_NUM)
        
        if(backendless.userService.isStayLoggedIn == false)// && self.backendless.userService.isValidUserToken() == false)
        {
            print("Not logged in.")
            
            let loginManager = FBSDKLoginManager()
            loginManager.loginBehavior = FBSDKLoginBehavior.Web
            let loginButton = FBSDKLoginButton()
            loginButton.center = self.view.center
            loginButton.readPermissions = ["public_profile", "user_photos", "email"]
            loginButton.loginBehavior = FBSDKLoginBehavior.Web
            loginButton.delegate = self
            
            self.view.addSubview(loginButton)
        }
        else
        {   
            print("Logged in.")

        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if(backendless.userService.isStayLoggedIn)// && self.backendless.userService.isValidUserToken() == true)
        {
            // Split space-delimited into arrays
//            if(backendless.userService.currentUser.getProperty("leftList") as? String != nil) {
//                self.leftList = ((backendless.userService.currentUser.getProperty("leftList") as? String)?.characters.split{$0 == " "}.map(String.init))!
//            }
//            
//            if(backendless.userService.currentUser.getProperty("rightList") as? String != nil) {
//                self.rightList = ((backendless.userService.currentUser.getProperty("rightList") as? String)?.characters.split{$0 == " "}.map(String.init))!
//            }
//            
//            if(backendless.userService.currentUser.getProperty("matchList") as? String != nil) {
//                self.matchList = ((backendless.userService.currentUser.getProperty("matchList") as? String)?.characters.split{$0 == " "}.map(String.init))!
//            }
            
            self.performSegueWithIdentifier("loggedIn", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Textfield Functions
//    
//    @IBAction func normalLogin(sender: UIButton) {
//        Types.tryblock({ () -> Void in
//            
//            let user = self.backendless.userService.login(self.userName.text, password: self.userPW.text)
//            print("User has been logged in (SYNC): \(user)")
//            },
//            
//            catchblock: { (exception) -> Void in
//                print("Server reported an error: \(exception as! Fault)")
//        })
//    }
//    
//    func textFieldShouldReturn(textField: UITextField) -> Bool {
//        if textField == self.userName {
//            self.userPW.becomeFirstResponder()
//            print("next")
//        }
//        
//        return true
//    }
    
    // MARK: - Facebook Login
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if (error == nil)
        {
            print("Login Complete.")
            loginButton.enabled = false
            
            let token = FBSDKAccessToken.currentAccessToken()
            let fieldsMapping = [
                "id" : "facebookId",
                "name" : "name",
                "birthday": "birthday",
                "first_name": "fb_first_name",
                "last_name" : "fb_last_name",
                "gender": "gender",
                "email": "email"
            ]
            

            backendless.userService.loginWithFacebookSDK(
                token,
                fieldsMapping: fieldsMapping,
                response: { (user: BackendlessUser!) -> () in
                    print(user)
                    self.backendless.userService.setStayLoggedIn(true)
                    
                    if((user.getProperty("firstLogin")) as? Bool == true) {
                        self.performSegueWithIdentifier("firstLogin", sender: self)
                    }
                    else {
                        self.performSegueWithIdentifier("loggedIn", sender: self)
                    }
                },
                error: { (fault: Fault!) -> Void in
                    loginButton.enabled = true
                    print("Server reported an error: \(fault)")
            })
            
        }
        else if result.isCancelled {
            print("Cancelled")
        }
        else
        {
            print("Error.")
            print(error.localizedDescription)
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User logged out.")
    }
    
//    func validUserTokenAsync() -> Bool {
//        self.backendless.userService.isValidUserToken(
//            { (let result : AnyObject!) -> () in
//                print("isValidUserToken (ASYNC): \(result.boolValue)")
//                return result.boolValue
//            },
//            error: { (let fault : Fault!) -> () in
//                print("Server reported an error (ASYNC): \(fault)")
//
//            }
//        )
//    }
}

