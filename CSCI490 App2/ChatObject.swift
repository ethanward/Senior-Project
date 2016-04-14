//
//  ChatObject.swift
//  CSCI490 App2
//
//  Created by Ron Ward on 3/19/16.
//  Copyright © 2016 Ethan Ward. All rights reserved.
//

import Foundation

protocol ChatProtocol {
    func getMessage(message: String, fromUser user: String)
    
    func getConnectionRequest(userId: String, message: String)
    
    func getError(error: Fault)
}

class ChatObject: NSObject, IResponder {
    weak var delegate: ChatProtocol
    weak var returned: ChatProtocol
    
    func publish(message: String) {
    }
    
    func subscribe(channel: String) {
    }
    
    func unsubscribe() {
    }
    
    func setPublisher(publisherId: String) {
    }
    
    func connectToUser(userId: String) {
    }
    
    func dismissUser(userId: String) {
    }
    
    func cancelConnection() {
    }
    
    func connectionStatus() -> Bool {
    }
}