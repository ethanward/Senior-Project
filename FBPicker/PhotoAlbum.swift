//
//  PhotoAlbum.swift
//  DSFacebookImagePicker
//
//  Created by Home on 2014-10-13.
//  Copyright (c) 2014 Sanche. All rights reserved.
//

import FBSDKCoreKit

class PhotoAlbum {
    let name : String
    let albumID : String
    let count : Int
    let coverPhotoID : String
    var coverPhoto : UIImage?
    var imageLoadFailed : Bool
    
    init(json:NSDictionary) {
        if let jsonName = json["name"] as? String {
            name = jsonName
        } else {
            name = "-"
        }
        if let jsonAlbum = json["id"] as? String {
            albumID = jsonAlbum
        } else {
            albumID = "-"
        }
        if let jsonCount = json["count"] as? Int {
            count = jsonCount
        } else {
            count = 0
        }
        if let jsonCover = json["cover_photo"] as? String {
            coverPhotoID = jsonCover
        } else {
            coverPhotoID = ""
        }
        
        coverPhoto = nil
        imageLoadFailed = false
        
        //request cover image
        recieveCoverImage()

    }
    
    func recieveCoverImage(){
      self.imageLoadFailed = false
        let request = FBRequest(session: FBSession.activeSession(), graphPath:coverPhotoID)
        request.startWithCompletionHandler { (connection, result, error) -> Void in
        
            if error != nil{
                self.imageLoadFailed = true
            } else {
                if let entireResult = result as? NSDictionary, imageArray = entireResult["images"] as? NSArray {
                    
                    let bestImageURL = FacebookNetworking.findBestImageURL(imageArray, minImageSize:100)
                    if bestImageURL == nil{
                        self.imageLoadFailed = true
                    } else {
                        
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                          var writeError: NSError?
                          let data = NSData(contentsOfURL:bestImageURL!, options: nil, error: &writeError)
                      
                          if let error = writeError{
                            self.imageLoadFailed = true
                          } else if data != nil {
                            self.coverPhoto = UIImage(data:data!)
                          }
                          
                        })
                    }
                }
            }
        }
    }
    

}
