//
//  UserTableViewController.swift
//  CSCI490 App2
//
//  Created by Ron Ward on 3/20/16.
//  Copyright © 2016 Ethan Ward. All rights reserved.
//

import UIKit



class UserTableViewController: UITableViewController {
    
    var data: [AnyObject] = []
    var backendless = Backendless.sharedInstance()
    var userId: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(self.data.count)
        return localUsers.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserTableViewCell", forIndexPath: indexPath) as! UserTableViewCell
        print(localUsers)
        print(indexPath.row)
        let user = localUsers[indexPath.row]
        
        let images = user.images
        if(images.first != nil) {
            let url = NSURL(string: (images.first?.imageURL)!)
            if let data = NSData(contentsOfURL: url!){
                cell.userImage.image = UIImage(data: data)
            }
        }
        else {
            cell.userImage.image = UIImage(named: "defaultImage")
        }

        cell.userName.text = user.user.name
        print(user.user.name)
        //(cell.viewWithTag(1) as! UILabel).text = user.email
        return cell
    }
    
    func userImageRetrieval() -> [AnyObject] {
        
        let dataQuery = BackendlessDataQuery()
        let queryOptions = QueryOptions()
        queryOptions.related = ["ownerId", "ownerId.objectId"];
        dataQuery.queryOptions = queryOptions
        
        var error: Fault?
        let bc = backendless.data.of(UserImage.ofClass()).find(dataQuery, fault: &error)
        if error == nil {
            print("Images have been retrieved: \(bc.data)")
        }
        else {
            print("Server reported an error: \(error)")
        }
        
        return bc.data
    }
    
//    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject) {
//        // Get the new view controller using [segue destinationViewController].
//        // Pass the selected object to the new view controller.
//        var indexPath: NSIndexPath = tableView(forCell: sender)
//        self.chat.returned = self
//        self.chat.delegate = segue.destinationViewController
//        (segue.destinationViewController as! ChatViewController).chat = chat
//        chat.connectToUser(((data[indexPath.row] as! BackendlessUser)).objectId)
//    }
}