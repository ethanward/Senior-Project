//
//  ViewController.swift
//  IPMQuickstart
//
//  Created by Brent Schooley on 12/8/15.
//  Copyright © 2015 Twilio. All rights reserved.
//

import UIKit
import SlackTextViewController
import SnapKit

class MessageViewController: SLKTextViewController {
    
    @IBOutlet weak var navBar: UINavigationItem!
    
    var backendless = Backendless.sharedInstance()
    var publishOptions: PublishOptions!
    var subscriptionOptions: SubscriptionOptions!
    var subscription: BESubscription!
    var connectTouserId: String!
    var connectToUserName: String!
    var responder: Responder!
    var connectionStatus: Bool?
    var connectToUserImage: UIImage?
    var index: Int?
    
    // A list of all the messages displayed in the UI
    var messages: [UserMessage] = []
//    var userMessages: [Message]?
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.inverted = false
        let singleTap = UITapGestureRecognizer(target: self, action:"tapDetected")
        singleTap.numberOfTapsRequired = 1
        
        if(self.connectToUserImage != nil) {
            let headerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            imageView.image = self.connectToUserImage
            imageView.autoresizingMask = UIViewAutoresizing.FlexibleWidth
            imageView.layer.borderWidth = 1
            imageView.layer.masksToBounds = false
            imageView.layer.borderColor = UIColor.clearColor().CGColor
            imageView.layer.cornerRadius = imageView.frame.height/2
            imageView.clipsToBounds = true
            imageView.contentMode = UIViewContentMode.ScaleAspectFit

            headerView.addGestureRecognizer(singleTap)
            headerView.addSubview(imageView)
            self.navBar.titleView = headerView
            
        }
        else {
            self.navBar.title = self.connectToUserName
//            self.navBar..addGestureRecognizer(singleTap)
        }
        
        // Set up UI controls
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        self.tableView!.estimatedRowHeight = 64.0
        self.tableView!.separatorStyle = .None
        
        self.tableView!.registerClass(MessageTableViewCell.self, forCellReuseIdentifier: "MessageTableViewCell")
        
        dispatch_async(dispatch_get_main_queue()) {
            if(self.subscription == nil) {
                self.subscribe()
            }
        }
    }
    
    func tapDetected() {
        print("Single Tap on navbar")
        let user = matches[self.index!]
        print(user.user.name)
        self.performSegueWithIdentifier("MatchViewFromChat", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let user = matches[self.index!]
        print(user.user.name)
        if(segue.identifier == "MatchViewFromChat") {
            let mvc = (segue.destinationViewController as! MatchViewController)
            mvc.user = user
        }
    }
    
    // MARK: Setup IP Messaging Channel
    
    func chatSetup(userId: String, userName: String, userImage: UIImage?, index: Int) {
        // Set the publisher
        self.publishOptions = PublishOptions()
        self.publishOptions.publisherId = backendless.userService.currentUser.objectId

        // Set subscription
        self.connectTouserId = userId
        self.connectToUserName = userName
        self.subscriptionOptions = SubscriptionOptions()
        self.connectToUserImage = userImage
        self.loadMessages()
        self.index = index
    }
    
    func loadMessages() {
        self.messages.removeAll()
        
        var whereClause = ""
        let dataQuery = BackendlessDataQuery()
        whereClause = "(to = \'\(backendless.userService.currentUser.objectId)\' AND from = \'\(self.connectTouserId)\') OR (to = \'\(self.connectTouserId)\' AND from = \'\(backendless.userService.currentUser.objectId)\')"
        
        print(whereClause)
        dataQuery.whereClause = whereClause
        
        var error: Fault?
        let bc = backendless.data.of(UserMessage.ofClass()).find(dataQuery, fault: &error)
        if error != nil {
            print("Server reported an error: \(error)")
        }
        
        if(bc != nil) {        
            let uMessages = bc.data as! [UserMessage]
            addMessages(uMessages)
        }
    }
    
    func addMessages(messages: [UserMessage]) {
        self.messages.appendContentsOf(messages)
        self.messages.sortInPlace { $1.timestamp?.compare($0.timestamp!) == NSComparisonResult.OrderedDescending}
        
        dispatch_async(dispatch_get_main_queue()) {
            () -> Void in
            self.tableView!.reloadData()
            if self.messages.count > 0 {
                self.scrollToBottomMessage()
            }
        }
    }
    
    func publish(message: String) {
        if connectTouserId.isEmpty {
            print("You have to connect to the user.")
            return
        }
        
        let dataStore = Backendless.sharedInstance().data.of(UserMessage.ofClass())
        var error: Fault?
        
        publishOptions.headers = ["userId": self.backendless.userService.currentUser.objectId]
        publishOptions.headers = ["userName": self.backendless.userService.currentUser.getProperty("fb_first_name") as! String]
        
        print("publishing..." )
        backendless.messaging.publish(self.backendless.userService.currentUser.objectId, message: message, publishOptions:publishOptions,
            response:{ ( messageStatus : MessageStatus!) -> () in
                print("MessageStatus = \(messageStatus.status) ['\(messageStatus.messageId)']")
                var messagesTmp = [UserMessage]()
                let uMessage = UserMessage()
                uMessage.message = message
                uMessage.timestamp = NSDate()
                uMessage.to = self.connectTouserId // This seems dumb...
                uMessage.from = self.backendless.userService.currentUser.objectId
                
                dataStore.save(uMessage, fault: &error) as? UserMessage
                if error != nil {
                    print("Server reported an error: \(error)")
                }
                
                messagesTmp.append(uMessage)
                self.addMessages(messagesTmp)
            },
            error: { ( fault : Fault!) -> () in
                print("Publish error... ")
                print("Server reported an error: \(fault)")
            }
        )
    }
    
    func subscribe() {
        self.responder = Responder(responder: self, selResponseHandler: "responseHandler:", selErrorHandler: "errorHandler:")
        self.subscription = backendless.messagingService.subscribe(self.connectTouserId, subscriptionResponder: self.responder, subscriptionOptions: subscriptionOptions)
        subscription.setPollingInterval(5000)
        
        NSLog("SUBSCRIPTION: %@", self.subscription)
    }
    
    func responseHandler(response: AnyObject!) -> AnyObject {
        let messages = response as! [Message]
        
        var uMessages = [UserMessage]()
        
        for message in messages {
            if(message.headers["userId"] == self.connectTouserId) {
                let uMessage = UserMessage()
                uMessage.message = message.data as? String
                uMessage.timestamp = NSDate()
                uMessage.to = self.connectTouserId // This seems dumb...
                uMessage.from = backendless.userService.currentUser.objectId
                uMessages.append(uMessage)
            }
        }
    
        addMessages(uMessages)
        
        return response
    }
    
    func errorHandler(fault: Fault!) {
        print("FAULT: \(fault)")
    }
    
    func unsubscribe() {
        if(self.subscription != nil) {
            print("unsubscribing...")
            self.subscription.cancel()
        }
        else {
            print("Did not unsubscribe.")
        }
    }

    // MARK: UI Logic
    // Scroll to bottom of table view for messages
    func scrollToBottomMessage() {
        if self.messages.count == 0 {
            return
        }
        let bottomMessageIndex = NSIndexPath(forRow: self.tableView!.numberOfRowsInSection(0) - 1,
            inSection: 0)
        self.tableView!.scrollToRowAtIndexPath(bottomMessageIndex, atScrollPosition: .Bottom,
            animated: true)
    }
    
    // MARK: UITableView Delegate
    // Return number of rows in the table
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    // Create table view rows
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MessageTableViewCell", forIndexPath: indexPath) as! MessageTableViewCell
        
        let message = self.messages[indexPath.row]
        
        if(message.from == self.connectTouserId) {
            cell.nameLabel.text = self.connectToUserName
        }
        else {
            cell.nameLabel.text = self.backendless.userService.currentUser.getProperty("fb_first_name") as? String
        }
        
        // CHANGE THIS
        if(cell.nameLabel.text == self.connectToUserName) {
            cell.nameLabel.textColor = UIColor.redColor()
            cell.updateSubviewsLeft()
        }
        else {
            cell.nameLabel.textColor = UIColor(red: 0/255.0, green: 128/255.0, blue: 64/255.0, alpha: 1.0)
            cell.updateSubviewsRight()
        }
        
        cell.bodyLabel.text = message.message
        cell.selectionStyle = .None
        
        return cell
    }
    
    // MARK: UITableViewDataSource Delegate
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func didPressRightButton(sender: AnyObject!) {
        self.textView.refreshFirstResponder()
        
        dispatch_async(dispatch_get_main_queue()) {
            self.publish(self.textView.text)
            self.textView.text = ""
        }
    }
    
    @IBAction func done(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
}
