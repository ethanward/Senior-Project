//
//  UserViewController.swift
//  CSCI490 App2
//
//  Created by Ron Ward on 3/9/16.
//  Copyright © 2016 Ethan Ward. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FacebookImagePicker

class UserViewController: UIViewController, OLFacebookImagePickerControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var userName: UINavigationItem!
    @IBOutlet weak var userImage1: UIImageView!
    @IBOutlet weak var userImage2: UIImageView!
    @IBOutlet weak var userImage3: UIImageView!
    @IBOutlet weak var userImage4: UIImageView!
    @IBOutlet weak var userImage5: UIImageView!
    
    var backendless = Backendless.sharedInstance()
    var fbUserId: String?
    var userPhotos: NSString = ""
    var photoArray: [UIImage]?
    var imagePicked = 0
    var userImageArray: [UserImage] = []
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userName.title = backendless.userService.currentUser.name
        self.fbUserId = backendless.userService.currentUser.getProperty("facebookId") as? String
        loadImages()
        
//        requestImages()
        
//        let singleTap = UITapGestureRecognizer(target: self, action:"tapDetected:")
//        singleTap.numberOfTapsRequired = 1
//
//        self.userImage1.addGestureRecognizer(singleTap)
//        self.userImage2.addGestureRecognizer(singleTap)
//        self.userImage3.addGestureRecognizer(singleTap)
//        self.userImage4.addGestureRecognizer(singleTap)
//        self.userImage5.addGestureRecognizer(singleTap)
        
        imagePicker.delegate = self
        
        FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch: UITouch? = touches.first
        if touch?.view == self.userImage1 || touch?.view == self.userImage2 || touch?.view == self.userImage3 || touch?.view == self.userImage4 || touch?.view == self.userImage5 {
            
            self.imagePicked = (touch?.view?.tag)!
            print(self.imagePicked, " has been tapped by the user.")
            
            // For FBPicker
            let picker: OLFacebookImagePickerController = OLFacebookImagePickerController()
            picker.delegate = self
            self.presentViewController(picker, animated: true, completion: { _ in })
            
            // For normal picker
//            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
        
        super.touchesEnded(touches, withEvent: event)
    }
    
//    func tapDetected() {
//        print("Single Tap on imageview")
//        
//        let picker: OLFacebookImagePickerController = OLFacebookImagePickerController()
//        picker.delegate = self
//        self.presentViewController(picker, animated: true, completion: { _ in })
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
/*
    // MARK: UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        if(self.imagePicked == 1) {
            self.userImage1.image = selectedImage
            self.userImage1.backgroundColor = UIColor.clearColor()
        }
        else if(self.imagePicked == 2) {
            self.userImage2.image = selectedImage
            self.userImage2.backgroundColor = UIColor.clearColor()
        }
        else if(self.imagePicked == 3) {
            self.userImage3.image = selectedImage
            self.userImage3.backgroundColor = UIColor.clearColor()
        }
        else if(self.imagePicked == 4) {
            self.userImage4.image = selectedImage
            self.userImage4.backgroundColor = UIColor.clearColor()
        }
        else if(self.imagePicked == 5) {
            self.userImage5.image = selectedImage
            self.userImage5.backgroundColor = UIColor.clearColor()
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }

    // Save userImages to userImages in backendless
    @IBAction func savePhotos(sender: UIButton) {
        let dataStore = Backendless.sharedInstance().data.of(UserImage.ofClass())
        var error: Fault?
        var newImageArray: [UserImage] = []
        var dbContains: [Int] = [1, 2, 3, 4, 5]
        
        for img in self.userImageArray {
            if(img.imageNum == 1 && self.userImage1.image != nil) {
                img.image = self.userImage1.image
            }
            else if(img.imageNum == 2 && self.userImage2.image != nil) {
                img.image = self.userImage2.image
            }
            else if(img.imageNum == 3 && self.userImage3.image != nil) {
                img.image = self.userImage3.image
            }
            else if(img.imageNum == 4 && self.userImage4.image != nil) {
                img.image = self.userImage4.image
            }
            else if(img.imageNum == 5 && self.userImage5.image != nil) {
                img.image = self.userImage5.image
            }
            
            newImageArray.append(img)
            dbContains[img.imageNum!] = 0
            
            let updatedImage = dataStore.save(img, fault: &error) as? UserImage
//            if error == nil {
//                print("Image has been updated: \(updatedImage!.objectId)")
//            }
//            else {
//                print("Server reported an error (2): \(error)")
//            }
        }
        
        // For if DB does not have img for userImageX to replace
        if(self.userImage1.image != nil && dbContains.contains(self.userImage1.tag)) {
            print("No image 1")
            let img = UserImage()
            img.imageNum = self.userImage1.tag
            //img.image = self.userImage1.image
            img.imageURL = ""
            img.user_Image_bcklsFK__ONE_TO_MANY = backendless.userService.currentUser.objectId

//            let fileName: String = String(format: "img/%0.0f.jpeg", NSDate().timeIntervalSince1970)
//            backendless.fileService.upload(fileName, content: UIImageJPEGRepresentation(self.userImage1.image!, 0.1))
            
            backendless.data.of(UserImage.ofClass()).save(img)
        }
        
        if(self.userImage2.image != nil && dbContains.contains(self.userImage2.tag)) {
            print("No image 2")
            let img = UserImage()
            img.imageNum = self.userImage2.tag
            img.image = self.userImage2.image
            img.imageURL = ""
            img.user_Image_bcklsFK__ONE_TO_MANY = backendless.userService.currentUser.objectId
        
            backendless.data.of(UserImage.ofClass()).save(img)
        }
        
        if(self.userImage3.image != nil && dbContains.contains(self.userImage3.tag)) {
            print("No image 3")
            let img = UserImage()
            img.imageNum = self.userImage3.tag
            img.image = self.userImage3.image
            img.imageURL = ""
            img.user_Image_bcklsFK__ONE_TO_MANY = backendless.userService.currentUser.objectId
            
            backendless.data.of(UserImage.ofClass()).save(img)
        }
        
        if(self.userImage4.image != nil && dbContains.contains(self.userImage4.tag)) {
            print("No image 4")
            let img = UserImage()
            img.imageNum = self.userImage4.tag
            img.image = self.userImage4.image
            img.imageURL = ""
            img.user_Image_bcklsFK__ONE_TO_MANY = backendless.userService.currentUser.objectId
            
            backendless.data.of(UserImage.ofClass()).save(img)
        }
        
        if(self.userImage5.image != nil && dbContains.contains(self.userImage5.tag)) {
            print("No image 5")
            let img = UserImage()
            img.imageNum = self.userImage5.tag
            img.image = self.userImage5.image
            img.imageURL = ""
            img.user_Image_bcklsFK__ONE_TO_MANY = backendless.userService.currentUser.objectId
            
            backendless.data.of(UserImage.ofClass()).save(img)
        }
    }
*/
    // MARK: - Facebook functions
    
    @IBAction func loadFBPicker(sender: AnyObject) {
        let picker: OLFacebookImagePickerController = OLFacebookImagePickerController()
        picker.delegate = self
        self.presentViewController(picker, animated: true, completion: { _ in })
    }
    
//    func facebookImagePicker(imagePicker: OLFacebookImagePickerController!, didSelectImage image: OLFacebookImage!) {
//        print(imagePicker.selected)
//        self.dismissViewControllerAnimated(true, completion: { _ in })
//        let img = Image()
//        let url = image.fullURL as NSURL
//        img.imageURL = url.absoluteString
//        img.user_Image_bcklsFK__ONE_TO_MANY = backendless.userService.currentUser.objectId
//        
//        downloadImage(url)
//        
//        backendless.data.of(Image.ofClass()).save(img)
//    }
    
    func facebookImagePicker(imagePicker: OLFacebookImagePickerController, shouldSelectImage image: OLFacebookImage) -> Bool {
        self.dismissViewControllerAnimated(true, completion: { _ in })
        var contains = false
        
        let url = image.fullURL as NSURL
        downloadImage(url, imageNum: String(self.imagePicked))
        
        for i in self.userImageArray {
            if(i.imageNum == String(self.imagePicked)) {
                let dataStore = Backendless.sharedInstance().data.of(UserImage.ofClass())
                var error: Fault?
                
                i.imageURL = url.absoluteString
                dataStore.save(i, fault: &error) as? UserImage
                contains = true
            }
        }
        
        if(!contains) {
            let img = UserImage()
            img.imageURL = url.absoluteString
            img.imageNum = String(self.imagePicked)
            img.user_Image_bcklsFK__ONE_TO_MANY = backendless.userService.currentUser.objectId
            
            backendless.data.of(UserImage.ofClass()).save(img)
        }
    
        return true
    }
    
    func facebookImagePicker(imagePicker: OLFacebookImagePickerController, didFinishPickingImages images: [AnyObject]) {
        self.dismissViewControllerAnimated(true, completion: { _ in })
//        // do something with the OLFacebookImage image objects
//        for image in images {
//            let img = Image()
//            let url = image.fullURL as NSURL
//            img.imageURL = url.absoluteString
//            img.user_Image_bcklsFK__ONE_TO_MANY = backendless.userService.currentUser.objectId
//            
//            downloadImage(url)
//            
//            //self.photoArray?.append()
//            
//            backendless.data.of(Image.ofClass()).save(img)
//        }
    }
    
    func facebookImagePickerDidCancelPickingImages(imagePicker: OLFacebookImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: { _ in })
    }
    
    func facebookImagePicker(imagePicker: OLFacebookImagePickerController, didFailWithError error: NSError) {
        // do something with the error such as display an alert to the user
    }
    
    func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
    
    func downloadImage(url: NSURL, imageNum: String) {
//        print("Download Started")
//        print("lastPathComponent: " + (url.lastPathComponent ?? ""))
        getDataFromUrl(url) { (data, response, error)  in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                guard let data = data where error == nil else { return }
//                print(response?.suggestedFilename ?? "")
//                self.photoArray?.append(UIImage(data: data)!) // What does this do again?
                
                if(imageNum == "1") {
                    self.userImage1.image = UIImage(data: data)
//                    self.userImage1.backgroundColor = UIColor.clearColor()
                }
                else if(imageNum == "2") {
                    self.userImage2.image = UIImage(data: data)
//                    self.userImage2.backgroundColor = UIColor.clearColor()
                }
                else if(imageNum == "3") {
                    self.userImage3.image = UIImage(data: data)
//                    self.userImage3.backgroundColor = UIColor.clearColor()
                }
                else if(imageNum == "4") {
                    self.userImage4.image = UIImage(data: data)
//                    self.userImage4.backgroundColor = UIColor.clearColor()
                }
                else if(imageNum == "5") {
                    self.userImage5.image = UIImage(data: data)
//                    self.userImage5.backgroundColor = UIColor.clearColor()
                }
            }
        }
    }
    
    func loadImages() {
        var whereClause = ""
        let dataQuery = BackendlessDataQuery()
        let queryOptions = QueryOptions()
        queryOptions.related = ["ownerId", "ownerId.objectId"];
        dataQuery.queryOptions = queryOptions
        whereClause = "ownerId = \'\(backendless.userService.currentUser.objectId)\'"
        print(whereClause)
        dataQuery.whereClause = whereClause
    
        var error: Fault?
        let bc = backendless.data.of(UserImage.ofClass()).find(dataQuery, fault: &error)
        
        if(bc != nil) {
            let images = bc.data as? [UserImage]
            print("Count: ", images!.count)
        
            for img in images! {
                print(img.imageNum)
                
                if(img.imageNum == "1") {
                    let url = NSURL(string: img.imageURL!)
                    downloadImage(url!, imageNum: img.imageNum!)
                }
                else if(img.imageNum == "2") {
                    let url = NSURL(string: img.imageURL!)
                    downloadImage(url!, imageNum: img.imageNum!)
                }
                else if(img.imageNum == "3") {
                    let url = NSURL(string: img.imageURL!)
                    downloadImage(url!, imageNum: img.imageNum!)
                }
                else if(img.imageNum == "4") {
                    let url = NSURL(string: img.imageURL!)
                    downloadImage(url!, imageNum: img.imageNum!)
                }
                else if(img.imageNum == "5") {
                    let url = NSURL(string: img.imageURL!)
                    downloadImage(url!, imageNum: img.imageNum!)
                }
            }
            
            self.userImageArray = images!
        }
    }
    
    func requestFBImages() {
        
//        FBSDKGraphRequest(graphPath: "me/photos", parameters: ["fields": "uploaded"]).startWithCompletionHandler({ (connection, result, error) -> Void in
//            if (result != nil) {
//                NSLog("error = \(error)")
//                
//                
//                //self.userPhotos = result.valueForKey("data") as! NSString
//                
//                //let decodedData = NSData(base64EncodedString: base64String, options: NSDataBase64DecodingOptions(rawValue: 0))
//                
//                let tmpPhoto = result["data"]!![0]["id"] as! String
//                
//                print(tmpPhoto)
//                if let pArray = result.valueForKey("data") as? NSArray {
//                    for photo in pArray
//                    {
//                        
//                    }
//                }
//                
//                
//                FBSDKGraphRequest(graphPath: tmpPhoto, parameters: ["fields": "images"]).startWithCompletionHandler({ (connection, photo, error) -> Void in
//                    if (photo != nil) {
//                        print(photo)
//                    }
//                })
//
//                    
//                print(self.userPhotos)
//
//            }
//        })
        
    }
    
    
}

