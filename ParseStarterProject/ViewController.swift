/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse

class ViewController: UIViewController {

    @IBOutlet weak var usernameTextfield: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBAction func signupOrLogin(_ sender: Any) {
    
        if usernameTextfield.text == "" {
        
            errorLabel.text = "A username is required"
        
        } else {
        
            PFUser.logInWithUsername(inBackground: usernameTextfield.text!, password: "password", block: { (success, error) in
                
                if error != nil {
                
                    let user = PFUser()
                    
                    user.username = self.usernameTextfield.text
                    user.password = "password"
                    
                    user.signUpInBackground(block: { (success, error) in
                        
                        if let error = error as? NSError {
                        
                            var errorMessage = "Signup failed - please try later"
                            
                            if let errorString = error.userInfo["error"] as? String {
                            
                                errorMessage = errorString
                            
                            }
                            
                            self.errorLabel.text = errorMessage
                        
                        } else {
                            
                            print("Signed up")
                        
                            self.performSegue(withIdentifier: "showUserTable", sender: self)
                        
                        }
                        
                    })
                
                } else {
                
                    print("Logged in")
                    
                    self.performSegue(withIdentifier: "showUserTable", sender: self)
                
                }
                
            })
        
        }
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if PFUser.current() != nil {
        
            performSegue(withIdentifier: "showUserTable", sender: self)
        
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
