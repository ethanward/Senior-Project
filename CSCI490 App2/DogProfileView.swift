//
//  DogProfileView.swift
//  CSCI490 App2
//
//  Created by Ron Ward on 5/9/16.
//  Copyright © 2016 Ethan Ward. All rights reserved.
//

import Foundation

class DogProfileView: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var breed: UITextField!
    @IBOutlet weak var sizeWeight: UITextField!
    @IBOutlet weak var activities: UITextField!
    @IBOutlet weak var parks: UITextField!
    @IBOutlet weak var likesDislikes: UITextView!
    @IBOutlet weak var medTempIssies: UITextView!
//    @IBOutlet weak var navBar: UINavigationItem!
    
    var dog = Dog!()
    
    var backendless = Backendless.sharedInstance()
    var edit = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(self.edit)
        
        self.name.text = dog?.name
        self.breed.text = dog?.breed
        self.sizeWeight.text = dog?.sizeWeight
        self.activities.text = dog?.activities
        self.parks.text = dog?.parks
        self.likesDislikes.text = dog?.likesDislikes
        self.medTempIssies.text = dog?.medTempIssies
        
        if(self.backendless.userService.currentUser.getProperty("firstLogin") as! Bool == true) {
            navigationController?.title = "This is your first time using the app!"
        }
        else if(self.edit == false) {
            navigationController?.title = "Add Dog"
        }
        else {
            navigationController?.title = "Edit Dog"
        }
    
        
    }
    
    func setupEdit(dog: Dog) {
        self.dog = dog
        self.edit = true
    }
    
    @IBAction func saveDog(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue()) {
            if(self.edit == false) {
                let newDog = Dog()
                newDog.name = self.name.text
                newDog.breed = self.breed.text
                newDog.sizeWeight = self.sizeWeight.text
                newDog.activities = self.activities.text
                newDog.parks = self.parks.text
                newDog.likesDislikes = self.likesDislikes.text
                newDog.medTempIssies = self.medTempIssies.text
                newDog.dog_bcklsFK__ONE_TO_MANY = self.backendless.userService.currentUser.objectId
                
                let dataStore = Backendless.sharedInstance().data.of(Dog.ofClass())
                var error: Fault?
                
                dataStore.save(newDog, fault: &error) as? Dog
            }
            else {
                
                self.dog.name = self.name.text
                self.dog.breed = self.breed.text
                self.dog.sizeWeight = self.sizeWeight.text
                self.dog.activities = self.activities.text
                self.dog.parks = self.parks.text
                self.dog.likesDislikes = self.likesDislikes.text
                self.dog.medTempIssies = self.medTempIssies.text
                self.dog.dog_bcklsFK__ONE_TO_MANY = self.backendless.userService.currentUser.objectId
                
                let dataStore = Backendless.sharedInstance().data.of(Dog.ofClass())
                var error: Fault?

                dataStore.save(self.dog, fault: &error) as? Dog
            }
        }
        
        if(self.backendless.userService.currentUser.getProperty("firstLogin") as! Bool == true) {
            self.backendless.userService.currentUser.updateProperties(["firstLogin" : false])
            self.backendless.userService.update(self.backendless.userService.currentUser)
            self.performSegueWithIdentifier("loggedInFirstTime", sender: self)
        }
        else {
            navigationController?.popViewControllerAnimated(true)
        }
    }
}