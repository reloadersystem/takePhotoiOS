//
//  SignUpViewController.swift
//  faceLogin
//
//  Created by Resembrink Correa on 6/27/20.
//  Copyright © 2020 Reloader. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SignUpViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var pwField: UITextField!
    @IBOutlet weak var pwConfField: UITextField!
    override func viewDidLoad() {
           super.viewDidLoad()

           // Do any additional setup after loading the view.
       }
    @IBAction func singPressed(_ sender: Any) {
        guard emailField.text != "", pwField.text != "",pwConfField.text != "" else {return}
        
        if pwField.text == pwConfField.text {
            
            Auth.auth().createUser(withEmail: emailField.text!, password: pwField.text!, completion:  { (user, error) in
                
                if error != nil{
                    print(error!)
                    return
                }
                
                let cameraVC = UIStoryboard(name:"Camera", bundle: nil).instantiateInitialViewController() as! CameraViewController
                
                cameraVC.photoType = .signup
                
                self.present(cameraVC, animated: true, completion: nil)
                
            })
            
        }else {
            let alert = UIAlertController(title: "Password does not match", message: "Please put correct password on both fields", preferredStyle:  .alert)
            
            let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
            alert.addAction(cancel)
            present(alert, animated: true, completion: nil)
            
        }
    }
}
