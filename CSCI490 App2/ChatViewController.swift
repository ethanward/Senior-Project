//
//  ChatViewController.swift
//  CSCI490 App2
//
//  Created by Ron Ward on 3/19/16.
//  Copyright © 2016 Ethan Ward. All rights reserved.
//

import Foundation
import UIKit

class ChatViewController: UIViewController, UITextView {
    
    var chat: ChatObject
    @IBOutlet weak var textView: UITextView!
    
    @IBAction func disconnect(sender: AnyObject) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    func disconnect(sender: AnyObject) {
        chat.cancelConnection()
        self.chat.delegate = chat.returned
        self.navigationController!.popViewControllerAnimated(true)
    }

}