//
//  MatchPickerViewController.swift
//  CSCI490 App2
//
//  Created by Ron Ward on 3/22/16.
//  Copyright © 2016 Ethan Ward. All rights reserved.
//

import UIKit
import Koloda

private var numberOfCards: UInt = 0
private var cardIndex = 0

class MatchPickerViewController: UIViewController {
    
    var backendless = Backendless.sharedInstance()
    
    @IBOutlet weak var kolodaView: KolodaView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let vc: ViewController = ViewController()
//        localUsers = vc.localUsers
//        print(localUsers)
        numberOfCards = UInt(localUsers.count)
        
        kolodaView.dataSource = self
        kolodaView.delegate = self
        
        self.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "MatchView") {
            
            let mvc = (segue.destinationViewController as! MatchViewController)
            print(cardIndex)
            mvc.user = localUsers[cardIndex]
        }
    }
    
    //MARK: IBActions
    @IBAction func leftButtonTapped() {
        kolodaView?.swipe(SwipeResultDirection.Left)
    }
    
    @IBAction func rightButtonTapped() {
        kolodaView?.swipe(SwipeResultDirection.Right)
    }
    
    @IBAction func undoButtonTapped() {
        kolodaView?.revertAction()
    }
    
    
}

//MARK: KolodaViewDelegate
extension MatchPickerViewController: KolodaViewDelegate {
    
    func koloda(koloda: KolodaView, didSwipedCardAtIndex index: UInt, inDirection direction: SwipeResultDirection) {
        //Example: loading more cards
        if index >= 3 {
            numberOfCards = 6
            kolodaView.reloadData()
        }
    }
    
    func koloda(kolodaDidRunOutOfCards koloda: KolodaView) {
        //Example: reloading
        print("No more users.")
        kolodaView.resetCurrentCardNumber() // Try and load more users?
    }
    
    func koloda(koloda: KolodaView, didSelectCardAtIndex index: UInt) {
        cardIndex = Int(index)
        self.performSegueWithIdentifier("MatchView", sender: self)
    }
}

//MARK: KolodaViewDataSource
extension MatchPickerViewController: KolodaViewDataSource {
    
    func koloda(kolodaNumberOfCards koloda:KolodaView) -> UInt {
        return numberOfCards
    }
    
    func koloda(koloda: KolodaView, viewForCardAtIndex index: UInt) -> UIView {
        var imageView: UIImageView
        if(localUsers[Int(index)].images.count > 0) {
            let imgUrl = localUsers[Int(index)].images[0].imageURL
            let url = NSURL(string: imgUrl!)
            let data = NSData(contentsOfURL: url!)
            let image = UIImage(data: data!)!
            imageView = UIImageView(image: image)
        }
        else {
            imageView = UIImageView(image: UIImage(named: "defaultImage"))
        }

        imageView.autoresizingMask = UIViewAutoresizing.FlexibleBottomMargin
        imageView.autoresizingMask = UIViewAutoresizing.FlexibleHeight
        imageView.autoresizingMask = UIViewAutoresizing.FlexibleRightMargin
        imageView.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin
        imageView.autoresizingMask = UIViewAutoresizing.FlexibleTopMargin
        imageView.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        
        imageView.contentMode = UIViewContentMode.ScaleAspectFit

        return imageView
    }
    
    func koloda(koloda: KolodaView, viewForCardOverlayAtIndex index: UInt) -> OverlayView? {
        
        return NSBundle.mainBundle().loadNibNamed("OverlayView", owner: self, options: nil)[0] as? OverlayView
    }
}