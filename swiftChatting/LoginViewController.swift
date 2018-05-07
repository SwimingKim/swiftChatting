//
//  LoginViewController.swift
//  swiftChatting
//
//  Created by KimSuyoung on 2018. 5. 1..
//  Copyright © 2018년 KimSuyoung. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: ViewController {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signup: UIButton!
    
    @IBAction func loginEvent(_ sender: UIButton) {
        Auth.auth().signIn(withEmail: email.text!, password: password.text!) { (user, err) in
            if err != nil {
                let alert = UIAlertController(title: "에러", message: err.debugDescription, preferredStyle: .alert)
                let ok = UIAlertAction(title: "확인", style: .default, handler: nil)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func presentSignup(_ sender: UIButton) {
        let view = self.storyboard?.instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController
        self.present(view, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        try! Auth.auth().signOut()
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                let view = self.storyboard?.instantiateViewController(withIdentifier: "MainViewTabBarController") as! UITabBarController
                self.present(view, animated: true, completion: nil)
                let uid = Auth.auth().currentUser?.uid
                let token = InstanceID.instanceID().token()
                
                Database.database().reference().child("users").child(uid!).updateChildValues(["pushToken": token!])
            }
        }
    }
    
}
