//
//  DogCollectionViewController.swift
//  CSCI490 App2
//
//  Created by Ron Ward on 5/9/16.
//  Copyright © 2016 Ethan Ward. All rights reserved.
//

import UIKit
class DogCollectionViewController: UICollectionViewController {
    
    var backendless = Backendless.sharedInstance()
    let reuseIdentifier = "cell" // also enter this string as the cell identifier in the storyboard
    var dogList = [Dog]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.loadDogs()
        self.collectionView?.reloadData()
    }
    
    // MARK: - UICollectionViewDataSource protocol
    
    // tell the collection view how many cells to make
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("count - \(self.dogList.count)")
        return self.dogList.count + 1
    }
    
    // make a cell for each cell index path
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! DogCollectionViewCell
        
        if(indexPath.item == self.dogList.count) {
            cell.name.text = "Add"
            cell.name.textColor = UIColor.blueColor()
        }
        else {
            cell.name.text = self.dogList[indexPath.item].name
        }
        
        cell.layer.borderColor = UIColor.lightGrayColor().CGColor;
        cell.layer.borderWidth = 1.0;
        cell.layer.cornerRadius = 3.0
        cell.backgroundColor = UIColor.whiteColor()
    
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
        
        let dogProfileView = self.storyboard!.instantiateViewControllerWithIdentifier("DogProfileView") as! DogProfileView
        
        if(indexPath.item != self.dogList.count) {
            dogProfileView.setupEdit(self.dogList[indexPath.item])
        }
        else {
            print("Adding new doggo")
        }

        navigationController?.pushViewController(dogProfileView, animated: true)
    }
    
    func loadDogs() {
        var whereClause = ""
        let dataQuery = BackendlessDataQuery()
        let queryOptions = QueryOptions()
        queryOptions.related = ["ownerId", "ownerId.objectId"];
        dataQuery.queryOptions = queryOptions
        whereClause = "ownerId = \'\(backendless.userService.currentUser.objectId)\'"
        dataQuery.whereClause = whereClause
        
        var error: Fault?
        let bc = backendless.data.of(Dog.ofClass()).find(dataQuery, fault: &error)
        
        if(bc != nil) {
            self.dogList = (bc.data as? [Dog])!
        }
    }
}

