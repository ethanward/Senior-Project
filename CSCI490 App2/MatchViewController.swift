//
//  MatchViewController.swift
//  CSCI490 App2
//
//  Created by Ron Ward on 3/23/16.
//  Copyright © 2016 Ethan Ward. All rights reserved.
//

import UIKit

class MatchViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var Name: UILabel!
    
    var user: (user: BackendlessUser, images: [UserImage])?
    var currentIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addGesturetoImageView()
        
        self.Name.text = user!.user.getProperty("fb_first_name") as? String
        self.pageControl.currentPage = 0
        self.pageControl.numberOfPages = user!.images.count
        changeImage(0)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func addGesturetoImageView() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.imageView.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.imageView.addGestureRecognizer(swipeLeft)
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Right:
                if(currentIndex > 0) {
                    currentIndex--
                    
                    self.pageControl.currentPage = currentIndex
                    
                    showAminationOnAdvert(kCATransitionFromLeft)
                }
                
                changeImage(currentIndex)
                
            case UISwipeGestureRecognizerDirection.Left:
                if(currentIndex < self.user!.images.count-1) {
                    
                    currentIndex++
                    self.pageControl.currentPage = currentIndex
                    showAminationOnAdvert(kCATransitionFromRight)
                }
                
                changeImage(currentIndex)
                
            default:
                break
            }
        }
    }
    
    func showAminationOnAdvert(subtype :String){
        let transitionAnimation = CATransition()
        transitionAnimation.type = kCATransitionPush
        transitionAnimation.subtype = subtype
        
        transitionAnimation.duration = 0.5
        
        transitionAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transitionAnimation.fillMode = kCAFillModeBoth
        
        imageView.layer.addAnimation(transitionAnimation, forKey: "fadeAnimation")
    }
    
    func changeImage(index:Int) {
        if(user!.images.count > 0) {
            let imgUrl = user!.images[index].imageURL
            let url = NSURL(string: imgUrl!)
            let data = NSData(contentsOfURL: url!)
            self.imageView.image = UIImage(data: data!)
        }
        else {
            self.imageView.image = UIImage(named: "defaultImage")
        }
    }
    
    @IBAction func changeAdvert(sender: AnyObject) {
//        print("change image \(self.pageControl.currentPage)")
        
        if(self.currentIndex > self.pageControl.currentPage) {
            changeImage(self.pageControl.currentPage)
            showAminationOnAdvert(kCATransitionFromRight)
        }
        else if self.currentIndex < self.pageControl.currentPage {
            changeImage(self.pageControl.currentPage)
            showAminationOnAdvert(kCATransitionFromLeft)
        }
        
        self.currentIndex = self.pageControl.currentPage
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
}

