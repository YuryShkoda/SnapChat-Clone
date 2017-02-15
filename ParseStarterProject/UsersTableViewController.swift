//
//  UsersTableViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Yuri Shkoda on 2/14/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import Parse

class UsersTableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var usernames = [String]()
    var recipientUsername = ""
    var timer = Timer()
    
    
    func checkForMessage() {
    
        let query = PFQuery(className: "Image")
        
        query.whereKey("recipientUsername", equalTo: (PFUser.current()?.username)!)
        
        do {
        
            let images = try query.findObjects()
            
            if images.count > 0 {
            
                var senderUsername = "Unknown User"
                
                if let username = images[0]["senderUsername"] as? String {
                
                    senderUsername = username
                
                }
                
                if let pfFile = images[0]["photo"] as? PFFile {
                
                    pfFile.getDataInBackground(block: { (data, error) in
                        
                        if let imageData = data {
                        
                            images[0].deleteInBackground()
                            
                            self.timer.invalidate()
                            
                            if let imageToDisplay = UIImage(data: imageData) {
                            
                                let alertController = UIAlertController(title: "You have a message", message: "Message from \(senderUsername)", preferredStyle: .alert)
                                
                                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                    
                                    let backgroundImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
                                    
                                    backgroundImageView.backgroundColor = UIColor.black
                                    
                                    backgroundImageView.alpha = 0.8
                                    
                                    backgroundImageView.tag = 10
                                    
                                    self.view.addSubview(backgroundImageView)
                                    
                                    let displayedImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
                                    
                                    displayedImageView.image = imageToDisplay
                                    
                                    displayedImageView.tag = 10
                                    
                                    displayedImageView.contentMode = UIViewContentMode.scaleAspectFit
                                    
                                    self.view.addSubview(displayedImageView)
                                    
                                    _ = Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { (timer) in
                                        
                                        self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(UsersTableViewController.checkForMessage), userInfo: nil, repeats: true)
                                        
                                        for subview in self.view.subviews {
                                            
                                            if subview.tag == 10 {
                                                
                                                subview.removeFromSuperview()
                                                
                                            }
                                            
                                        }
                                        
                                    })
                                    
                                }))
                                
                                self.present(alertController, animated: true, completion: nil)
                            
                            }
                        
                        }
                        
                    })
                
                }
            
            }
        
        } catch {
        
            print("Could not get image")
        
        }
    
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.isHidden = false
        
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(UsersTableViewController.checkForMessage), userInfo: nil, repeats: true)
        
        let query = PFUser.query()
        
        query?.whereKey("username", notEqualTo: (PFUser.current()?.username)!)
        
        do {
        
            let users = try query?.findObjects()
            
            if let users = users as? [PFUser] {
                
                for user in users {
                
                    usernames.append(user.username!)
                
                }
            
            }
            
            tableView.reloadData()
        
        } catch {
            
            print("Could not get users")
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usernames.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = usernames[indexPath.row]

        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "logoutSegue" {
        
            PFUser.logOut()
            
            self.navigationController?.navigationBar.isHidden = true
            
            timer.invalidate()
        
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        recipientUsername = usernames[indexPath.row]
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
        
            UIApplication.shared.beginIgnoringInteractionEvents()
            
            let imageToSend = PFObject(className: "Image")
            
            imageToSend["senderUsername"] = PFUser.current()?.username
            imageToSend["recipientUsername"] = recipientUsername
            
            let imageData = UIImagePNGRepresentation(image)
            let imageFile = PFFile(name: "photo.png", data: imageData!)
            
            imageToSend["photo"] = imageFile
            
            let acl = PFACL()
            
            acl.getPublicReadAccess  = true
            acl.getPublicWriteAccess = true
            
            imageToSend.acl = acl
            
            imageToSend.saveInBackground(block: { (success, error) in
                
                if error == nil {
                
                    UIApplication.shared.endIgnoringInteractionEvents()
                    
                    self.createAlert(title: "Message sent", message: "Message has been sent")
                
                } else {
                
                    self.createAlert(title: "Could not sent image", message: "Please try again later")
                
                }
                
            })
            
            self.dismiss(animated: true, completion: nil)
        
        }
    }
    
    func createAlert(title: String, message: String) {
    
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            
            alert.dismiss(animated: true, completion: nil)
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    
    }

}
