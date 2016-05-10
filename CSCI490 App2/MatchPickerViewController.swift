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
    var localUsers: [(user: BackendlessUser, images: [UserImage])] = []
    var matchList: [String] = []
    var leftList: [String] = []
    var rightList: [String] = []
    var touchedList: [String] = []
    var cardWidth: CGFloat?
    var cardHeight: CGFloat?
    var cardX: CGFloat?
    var firstLoad: Bool = true
    
    @IBOutlet weak var kolodaView: KolodaView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Split space-delimited into arrays
        if(backendless.userService.currentUser.getProperty("leftList") as? String != nil) {
            self.leftList = ((backendless.userService.currentUser.getProperty("leftList") as? String)?.characters.split{$0 == " "}.map(String.init))!
        }
        
        if(backendless.userService.currentUser.getProperty("rightList") as? String != nil) {
            self.rightList = ((backendless.userService.currentUser.getProperty("rightList") as? String)?.characters.split{$0 == " "}.map(String.init))!
        }
        
        if(backendless.userService.currentUser.getProperty("matchList") as? String != nil) {
            self.matchList = ((backendless.userService.currentUser.getProperty("matchList") as? String)?.characters.split{$0 == " "}.map(String.init))!
        }
        
        if(backendless.userService.currentUser.getProperty("touchedList") as? String != nil) {
            self.touchedList = ((backendless.userService.currentUser.getProperty("touchedList") as? String)?.characters.split{$0 == " "}.map(String.init))!
        }
        
        self.loadUsers()
        
        numberOfCards = UInt(localUsers.count)
        
        kolodaView.dataSource = self
        kolodaView.delegate = self
        
        self.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "MatchView") {
            
            let mvc = (segue.destinationViewController as! MatchViewController)
            mvc.user = localUsers[cardIndex]
        }
    }
    
    func loadUsers() -> Bool {
        var whereClause = "objectId NOT LIKE \'\(self.backendless.userService.currentUser.objectId)\' AND (matchList IS NULL OR matchList NOT LIKE \'%\(self.backendless.userService.currentUser.objectId)%\')"

        if backendless.userService.currentUser.getProperty("touchedList") != nil {
            for touched in self.touchedList {
                whereClause = whereClause + " AND objectId NOT LIKE \'\(touched)\'"
            }
        }
        
        print(whereClause)
        
        let dataQuery = BackendlessDataQuery()
        let queryOptions = QueryOptions()
        queryOptions.pageSize(10)
        
        dataQuery.whereClause = whereClause
        dataQuery.queryOptions = queryOptions
        
        var error: Fault?
        let bc = self.backendless.persistenceService.of(BackendlessUser.ofClass()).find(dataQuery, fault: &error)
        if error != nil {
            print("Server reported an error: \(error)")
        }
        
        if(bc != nil) {
            let users = bc.data as! [BackendlessUser]
            
            for user in users {
                // need to check if seen this user before?
//                if(!self.leftList.contains(user.objectId) && !self.rightList.contains(user.objectId)) {
                    let images = userImageRetrieval((user.objectId)!)
                    localUsers.append((user, images))
//                }
            }
        }
        
        return localUsers.count > 0
    }
    
    func userImageRetrieval(userId: String) -> [UserImage] {
        var images: [UserImage] = []
        
        var whereClause = ""
        let dataQuery = BackendlessDataQuery()
        let queryOptions = QueryOptions()
        queryOptions.related = ["ownerId", "ownerId.objectId"];
        dataQuery.queryOptions = queryOptions
        whereClause = "ownerId = \'\(userId)\'"
        
        dataQuery.whereClause = whereClause
        
        var error: Fault?
        let bc = backendless.data.of(UserImage.ofClass()).find(dataQuery, fault: &error)
        if error != nil {
            print("Server reported an error: \(error)")
        }
        
        if(bc != nil) {
            let tmp = bc.data as! [UserImage]
            images = tmp.sort {
                return $0.imageNum < $1.imageNum
            }
        }
        
        return images
    }
    
    //MARK: IBActions
    @IBAction func leftButtonTapped() {
        kolodaView?.swipe(SwipeResultDirection.Left)
    }
    
    @IBAction func rightButtonTapped() {
        kolodaView?.swipe(SwipeResultDirection.Right)
    }
        
//    @IBAction func undoButtonTapped() {
//        kolodaView?.revertAction()
//    }
}

//MARK: KolodaViewDelegate
extension MatchPickerViewController: KolodaViewDelegate {
    
    func koloda(koloda: KolodaView, didSwipedCardAtIndex index: UInt, inDirection direction: SwipeResultDirection) {

        // Update touchedlist
        self.touchedList.append(localUsers[Int(index)].user.objectId)
        self.backendless.userService.currentUser.updateProperties(["touchedList" : self.touchedList.joinWithSeparator(" ")])
        self.backendless.userService.update(self.backendless.userService.currentUser)
        
        if(direction == SwipeResultDirection.Right) {
            print(Int(index))
            print(localUsers.count)
            self.rightSwipe(localUsers[Int(index)].user.objectId, index: Int(index))
        }
        else {
            self.leftSwipe(localUsers[Int(index)].user.objectId)
        }
        
//        localUsers.removeAtIndex(Int(index))
        
//        if index >= 3 {
//            numberOfCards = 6
//            kolodaView.reloadData()
//        }
    }
    
    func koloda(kolodaDidRunOutOfCards koloda: KolodaView) {
        //Example: reloading
        print("No more users.")
        
        localUsers.removeAll()
        
        dispatch_async(dispatch_get_main_queue()) {
            self.loadUsers()
        }
        
        numberOfCards = UInt(localUsers.count)
        
        if(localUsers.count > 0) {
            kolodaView.reloadData() // Try and load more users?
        }

    }
    
    func koloda(koloda: KolodaView, didSelectCardAtIndex index: UInt) {
        cardIndex = Int(index)
        self.performSegueWithIdentifier("MatchView", sender: self)
    }
    
    func rightSwipe(userId: String, index: Int) {
        if(self.rightList.contains(userId)) { // There's a match!
            print("Its a match!")
            
            
            self.rightList = self.rightList.filter( {$0 != userId} )
            matches.append(self.localUsers[index])
            self.matchList.append(userId)
            
            self.backendless.userService.currentUser.updateProperties(["matchList" : self.matchList.joinWithSeparator(" ")])
            self.backendless.userService.currentUser.updateProperties(["rightList" : self.rightList.joinWithSeparator(" ")])
            self.backendless.userService.update(self.backendless.userService.currentUser)
            
            let user = self.backendless.userService.findById(userId)
            var mList = user.getProperty("matchList") as? String
            
            if(mList != nil) {
                mList = mList! + " " + self.backendless.userService.currentUser.objectId
            }
            else {
                mList = self.backendless.userService.currentUser.objectId
            }
            
            user.updateProperties(["matchList" : mList!])
            self.backendless.userService.update(user)
        }
        else if(self.leftList.contains(userId)) {
            // Remove from left list? Do nothing?
        }
        else {
            let user = self.backendless.userService.findById(userId)
            var rList = user.getProperty("rightList") as? String
            if(rList != nil) {
                rList = rList! + " " + self.backendless.userService.currentUser.objectId
            }
            else {
                rList = self.backendless.userService.currentUser.objectId
            }
            
            user.updateProperties(["rightList" : rList!])
            self.backendless.userService.update(user)
        }
    }
    
    func leftSwipe(userId: String) {
        if(self.rightList.contains(userId)) {
            // Remove from list? Do nothing?
        }
        else if(self.leftList.contains(userId)) {
            // Remove from left list? Add to DND list?
        }
        else {
            let user = self.backendless.userService.findById(userId)
            var lList = user.getProperty("leftList") as? String
            if(lList != nil) {
                lList = lList! + " " + self.backendless.userService.currentUser.objectId
            }
            else {
                lList = self.backendless.userService.currentUser.objectId
            }
            user.updateProperties(["leftList" : lList!])
            self.backendless.userService.update(user)
        }
    }
}

//MARK: KolodaViewDataSource
extension MatchPickerViewController: KolodaViewDataSource {
    
    func koloda(kolodaNumberOfCards koloda:KolodaView) -> UInt {
        return numberOfCards
    }
    
    func koloda(koloda: KolodaView, viewForCardAtIndex index: UInt) -> UIView {
        var name: String!
        var imageView: UIImageView
        
        if(localUsers.count == 0) {
            self.loadUsers()
        }
        
        if(self.firstLoad) {
            self.cardHeight = koloda.frame.height
            self.cardWidth = koloda.frame.width
            self.cardX = koloda.frame.origin.x
            self.firstLoad = false
        }
        
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
        
        name = localUsers[Int(index)].user.getProperty("fb_first_name") as! String
        
        let borderWidth: CGFloat = 2.0
        imageView.frame = CGRectInset(koloda.frame, -borderWidth, -borderWidth)
        imageView.layer.borderColor = UIColor.lightGrayColor().CGColor;
        imageView.layer.borderWidth = borderWidth;
        imageView.layer.cornerRadius = 8.0
        imageView.backgroundColor = UIColor.whiteColor()
        
        print("Width - \(self.cardWidth)")
        print("Height - \(self.cardHeight)")
        print("X - \(self.cardX)")
        
        let label = UILabel(frame: CGRectMake(self.cardX!, self.cardHeight!,self.cardWidth!,75))
        label.text = name
        imageView.addSubview(label)
        
        return imageView
    }
    
    func koloda(koloda: KolodaView, viewForCardOverlayAtIndex index: UInt) -> OverlayView? {
        return NSBundle.mainBundle().loadNibNamed("OverlayView", owner: self, options: nil)[0] as? OverlayView
    }
}


// TODO: 
//  Add matches to space delimited string in swiped user's "rightList"(good name?) on swipe right
//  Load local users that are NOT in user's right list and matchList
//  Add to leftList on swipe left
//  Add animations?
//  If someone has been in rightList for a while, simply remove them
