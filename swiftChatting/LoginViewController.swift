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
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    var isFinishEmail: Bool = false
    var isFinishPassword: Bool = false
    
    @IBAction func loginEvent(_ sender: UIButton) {
        Auth.auth().signIn(withEmail: emailField.text!, password: passwordField.text!) { (user, err) in
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
        
//        try! Auth.auth().signOut()
        loginButton.isEnabled = false
        
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

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        switch textField.tag {
        case 100:
            if let emailText = textField.text {
                isFinishEmail = emailText.contains("@")
            }
        case 200:
            if let passwordText = textField.text {
                isFinishPassword = passwordText.count >= 6
            }
        default:
            return
        }

        loginButton.isEnabled = isFinishEmail && isFinishPassword
    }
    
}
