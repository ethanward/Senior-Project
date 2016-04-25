//
//  ChatViewController.swift
//  CSCI490 App2
//
//  Created by Ron Ward on 4/15/16.
//  Copyright © 2016 Ethan Ward. All rights reserved.
//

import Foundation
import UIKit

class ChatViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textField: UITextField!
    
    var backendless = Backendless.sharedInstance()
    var publishOptions: PublishOptions!
    var subscriptionOptions: SubscriptionOptions!
    var subscription: BESubscription!
    var connectTouserId: String!
    var responder: Responder!
    var connectionStatus: Bool?
    
    var MESSAGING_CHANNEL: String = "checking"
    var PUBLISHER_ANONYMOUS: String = "Anonymous"
    var PUBLISHER_NAME_HEADER: String = "publisher_name"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.delegate = self
        self.subscribe() //self.backendless.userService.currentUser.objectId)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func chatSetup(userId: String) {
        print(connectTouserId ?? connectionStatus)
        NSLog("ChatViewController -> chatSetup: userId = %@", userId)
        publishOptions = PublishOptions()
        publishOptions.publisherId = backendless.userService.currentUser.objectId
        connectTouserId = userId
        subscriptionOptions = SubscriptionOptions()
    }
    
//    func showAlert(message: String) {
//        var av: UIAlertView = UIAlertView(title: "Error:", message: message, delegate: nil, cancelButtonTitle: "Ok", otherButtonTitles: "")
//        av.show()
//    }
    
//    func publish() {
//        var message: String = self.textField.text!
//        
//        if message.isEmpty || message.characters.count == 0 {
//            return
//        }
//        
//        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
//        defer {
//            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
//        }
//        backendless.messagingService.publish(self.connectTouserId, message: message, publishOptions: publishOptions)
//        self.textField.text = ""
//    }

    func publish(message: String) {
        if connectTouserId.isEmpty {
            print("You have to connect to the user.")
            return
        }
        
        publishOptions.headers = ["user": self.backendless.userService.currentUser.objectId]
        print("publishing " )
        backendless.messaging.publish("default", message: message, publishOptions:publishOptions,
            response:{ ( messageStatus : MessageStatus!) -> () in
                print("MessageStatus = \(messageStatus.status) ['\(messageStatus.messageId)']")
            },
            error: { ( fault : Fault!) -> () in
                print("Server reported an error: \(fault)")
            }
        )
        
//        backendless.messagingService.publish(connectTouserId, message: message, publishOptions: publishOptions, response: {(status: MessageStatus!) -> Void in
//            print("MESSAGE SENT")
//            NSLog("ChatObject -> publish: %@ -> '%@>'", self.connectTouserId, message)
//            }, error: {(error: Fault!) -> Void in
//                self.errorHandler(error)
//        })
    }
    
    func subscribe() {
//        do {
//            self.responder = Responder(responder: self, selResponseHandler: "responseHandler:", selErrorHandler: "errorHandler:")
//            self.subscription = backendless.messagingService.subscribe("default", subscriptionResponder: self.responder, subscriptionOptions: subscriptionOptions)
//            NSLog("SUBSCRIPTION: %@", subscription)
//        } catch let fault {
//            NSLog("FAULT = %@", fault as! String)
//        } 
        backendless.messaging.subscribe(
            "default",
            subscriptionResponse: { (let messages) -> () in
                
//                for message in messages as [Message] {
//                    //            NSLog("ChatObject -> responseHandler: MESSAGE = %@ (= %@?) <%@>\n%@]", message.publisherId, connectTouserId,message.data as! String, message.headers)
//                    
//                    let publisher: String = message.publisherId
//                    print("Recieved message from: ", publisher)
//                    let request: String = message.headers["request"]!
//                    if (request != "") {
//                        if (request == "finish") {
//                            self.connectionStatus = false
//                            self.connectTouserId = nil
//                        }
//                    }
//                    //            else {
//                    if (publisher == self.connectTouserId) {
//                        //                    if (self.delegate as! NSObject).respondsToSelector("getMessage:fromUser:") {
//                        //                        self.delegate.getMessage(message.data, fromUser: message.headers["user"])
//                        //                    }
//                        self.textView.text = self.textView.text!.stringByAppendingFormat("%@: %@\n", self.connectTouserId, self.textField.text!)
//                        //                }
//                    }
//                }
                for message in messages as [Message] {
                    print("Received message - \(message.data)")
                }
            },
            subscriptionError: { (let fault : Fault!) ->() in
                print("Server reported an error (FAULT): \(fault)")
            },
            response: { (let response) -> () in
                self.subscription = response
                print("subscribe -  \(response)")
            },
            error: { (let fault : Fault!) -> () in
                print("Server reported an error (SUBSCRIPTION ERROR): \(fault)")
            }
        ) 
    }
    
    func unsubscribe() {
        print("unsubscribe...")
        if(self.subscription != nil) {
            print("unsubscribing...")
            self.subscription.cancel()
        }
    }
    
    func responseHandler(response: AnyObject) -> AnyObject {
        let messages = response as! [Message]
        if messages.isEmpty {
            return response
        }
        
        for message in messages {
//            NSLog("ChatObject -> responseHandler: MESSAGE = %@ (= %@?) <%@>\n%@]", message.publisherId, connectTouserId,message.data as! String, message.headers)
            
            let publisher: String = message.publisherId
            print("Recieved message from: ", publisher)
            let request: String = message.headers["request"]!
            if (request != "") {
                if (request == "finish") {
                    self.connectionStatus = false
                    connectTouserId = nil
                }
            }
//            else {
                if (publisher == connectTouserId) {
//                    if (self.delegate as! NSObject).respondsToSelector("getMessage:fromUser:") {
//                        self.delegate.getMessage(message.data, fromUser: message.headers["user"])
//                    }
                    self.textView.text = textView.text!.stringByAppendingFormat("%@: %@\n", connectTouserId, textField.text!)
//                }
            }
        }
        
        return response;
    }
    
//    func responseHandler(response: AnyObject) -> AnyObject {
//        dispatch_async(dispatch_get_main_queue(), {() -> Void in
//            //NSLog(@"ChatViewController -> responseHandler: RESPONSE = %@ <%@>", response, response?[response class]:@"NULL");
//            let messages: [AnyObject] = response as! [AnyObject]
//            for obj: AnyObject in messages {
//                if (obj is Message) {
//                    let message: Message = (obj as! Message)
//                    let publisher: String = message.publisherId
//                    if(self.isTextAppended ?? false) {
//                        self.textView.text = self.textView.text!.stringByAppendingFormat("%@ : '%@'\n", !publisher.isEmpty ? publisher : self.PUBLISHER_ANONYMOUS, message.data as! String)
//                    }
//                    else {
//                        self.textView.text = "\(!publisher.isEmpty ? publisher : self.PUBLISHER_ANONYMOUS) : '\(message.data)'\n\(self.textView.text!)"
//                    }
////                    self.textView.text = self.isTextAppended ? self.textView.text!.stringByAppendingFormat("%@ : '%@'\n", !publisher.isEmpty ? publisher : self.PUBLISHER_ANONYMOUS, message.data as! String) : "\(!publisher.isEmpty ? publisher : self.PUBLISHER_ANONYMOUS) : '\(message.data)'\n\(self.textView.text!)"
//                }
//            }
//        })
//        return response
//    }
    
    func dismissUser(userId: String) {
        NSLog("ChatObject -> dismissUser: %@", userId)
        connectionStatus = false
        connectTouserId = userId
        publishOptions.headers = ["request": "start"]
        backendless.messagingService.publish(connectTouserId, message: "dismiss", publishOptions: publishOptions, response: {(status: MessageStatus!) -> Void in
            self.connectionStatus = true
            self.cancelConnection()
            }, error: {(error: Fault!) -> Void in
                self.errorHandler(error)
        })
    }
    
    func cancelConnection() {
//        if (connectionStatus ?? false) {
//            return
//        }
        NSLog("ChatObject -> cancelConnection: %@", connectTouserId)
        publishOptions.headers = ["request": "finish"]
        backendless.messagingService.publish(connectTouserId, message: "finish", publishOptions: publishOptions, response: {(status: MessageStatus!) -> Void in
            self.connectionStatus = false
            self.connectTouserId = nil
            }, error: {(error: Fault!) -> Void in
                self.errorHandler(error)
        })
    }
    
    func errorHandler(fault: Fault) {
        NSLog("ChatViewController -> errorHandler: %@", fault)
    }
    
    @IBAction func done(sender: UIBarButtonItem) {
        //self.dismissUser(self.connectTouserId)
        //self.unsubscribe()
        sleep(1)
        navigationController?.popViewControllerAnimated(true)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {    //delegate method
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {  //delegate method
        return false
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.publish(textField.text!)
        self.textView.text = textView.text!.stringByAppendingFormat("%@: %@\n", backendless.userService.currentUser.name, textField.text!)
        textField.text = ""
        
        return true
    }
}

