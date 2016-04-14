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

var localUsers: [(user: BackendlessUser, images: [UserImage])] = []

class ViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    let APP_ID = "F94794D7-9623-1423-FFA0-23A0B43E4700"
    let SECRET_KEY = "030F931A-CA13-545E-FF62-B5795C9D9600"
    let VERSION_NUM = "v1"
    let loginManager = FBSDKLoginManager()
    var backendless = Backendless.sharedInstance()
    
    //var uvc:ChatObject = ChatObject()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backendless.initApp(APP_ID, secret:SECRET_KEY, version:VERSION_NUM)
        
        if(FBSDKAccessToken.currentAccessToken() == nil)
        {
            print("Not logged in.")
            let loginButton = FBSDKLoginButton()
            loginButton.center = self.view.center
            loginButton.readPermissions = ["public_profile", "user_photos", "email"]
            loginButton.delegate = self
            FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
            
            self.view.addSubview(loginButton)
        }
        else
        {
//            loginManager.logOut()
            print("Logged in.")
            self.performSegueWithIdentifier("loggedIn", sender: self)
            
        }
        
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        if(FBSDKAccessToken.currentAccessToken() != nil) // if logged in
        {
            fetchLocalUsers()
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
    
    // MARK: - Backendless Functions
    
    func fetchLocalUsers() {
        // This function should load users within x miles that are not current users friends
        do {
            let users = try self.backendless.persistenceService.of(BackendlessUser.ofClass()).find()
            //print("Users have been fetched (SYNC): \(users.data)")
            
            print("Num users: ", users.data.count)
            for i in 0...(users.data.count-1) {

                let images = userImageRetrieval((users.data[i].getProperty("objectId") as? String)!)
                localUsers.append((users.data[i] as! BackendlessUser, images))
            }
        } catch (let e) {
            print("Server reported an error (SYNC): \(e as! Fault)")
        }
    }
    
    func userImageRetrieval(userId: String) -> [UserImage] {
        var images: [UserImage] = []
        
        var whereClause = ""
        let dataQuery = BackendlessDataQuery()
        let queryOptions = QueryOptions()
        queryOptions.related = ["ownerId", "ownerId.objectId"];
        dataQuery.queryOptions = queryOptions
        whereClause = "ownerId = \'\(userId)\'"
        
        //print(whereClause)
        dataQuery.whereClause = whereClause
        
        var error: Fault?
        let bc = backendless.data.of(UserImage.ofClass()).find(dataQuery, fault: &error)
        if error == nil {
            //print("Images have been retrieved: \(bc.data)")
        }
        else {
            print("Server reported an error: \(error)")
        }
        
        if(bc != nil) {
            images = bc.data as! [UserImage]
        }
//        else {
//            var defaultImage: UserImage
//            
//            defaultImage.
//            images.append(UIImage(named: "green-square-Retina"))
//        }
        
        return images
    }


    // MARK: - Facebook Login
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if (error == nil)
        {
            print("Login Complete.")
            
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
                    self.performSegueWithIdentifier("loggedIn", sender: self)
                },
                error: { (fault: Fault!) -> Void in
                    print("Server reported an error: \(fault)")
            })
            
        }
        else
        {
            print(error.localizedDescription)
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User logged out.")
    }


}

