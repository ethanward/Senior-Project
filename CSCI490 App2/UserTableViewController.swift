//
//  UserTableViewController.swift
//  CSCI490 App2
//
//  Created by Ron Ward on 3/20/16.
//  Copyright © 2016 Ethan Ward. All rights reserved.
//

import UIKit



class UserTableViewController: UITableViewController {
    
    var backendless = Backendless.sharedInstance()
    var userId: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matches.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserTableViewCell", forIndexPath: indexPath) as! UserTableViewCell
//        print(localUsers)
//        print(indexPath.row)
        let user = matches[indexPath.row]
        
        let images = user.images
        if(images.first != nil) {
            let url = NSURL(string: (images.first?.imageURL)!)
            if let imgData = NSData(contentsOfURL: url!){
                cell.userImage.image = UIImage(data: imgData)
            }
        }
        else {
            cell.userImage.image = UIImage(named: "defaultImage")
        }

        cell.userName.text = user.user.name
//        print(user.user.name)
        //(cell.viewWithTag(1) as! UILabel).text = user.email
        return cell
    }
    
//    func userImageRetrieval() -> [AnyObject] {
//        
//        let dataQuery = BackendlessDataQuery()
//        let queryOptions = QueryOptions()
//        queryOptions.related = ["ownerId", "ownerId.objectId"];
//        dataQuery.queryOptions = queryOptions
//        
//        var error: Fault?
//        let bc = backendless.data.of(UserImage.ofClass()).find(dataQuery, fault: &error)
//        if error == nil {
//            print("Images have been retrieved: \(bc.data)")
//        }
//        else {
//            print("Server reported an error: \(error)")
//        }
//        
//        return bc.data
//    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        let userChatViewController = segue.destinationViewController as! ChatViewController
//        
//        if let selectedImageCell = sender as? UserTableViewCell {
//            let indexPath = tableView.indexPathForCell(selectedImageCell)
////            print(indexPath)
//            let userId = localUsers[indexPath!.row].user.objectId // Should eventually be "friends", not local users
//            
//            userChatViewController.chatSetup(userId)
//        }
        
        let messageViewController = segue.destinationViewController as! MessageViewController
        
        if let selectedImageCell = sender as? UserTableViewCell {
            let indexPath = tableView.indexPathForCell(selectedImageCell)
            //            print(indexPath)
            let userId = matches[indexPath!.row].user.objectId // Should eventually be "friends", not local users
            let userName = matches[indexPath!.row].user.getProperty("fb_first_name") as! String
            
            messageViewController.chatSetup(userId, userName: userName)
        }

    }
}