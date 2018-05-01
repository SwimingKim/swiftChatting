//
//  LoginViewController.swift
//  swiftChatting
//
//  Created by KimSuyoung on 2018. 5. 1..
//  Copyright © 2018년 KimSuyoung. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signup: UIButton!
    let remoteConfig = RemoteConfig.remoteConfig()
    var color: String!
    
    @objc func loginEvent() {
        
        Auth.auth().signIn(withEmail: email.text!, password: password.text!) { (user, err) in
            if err != nil {
                let alert = UIAlertController(title: "에러", message: err.debugDescription, preferredStyle: .alert)
                let ok = UIAlertAction(title: "확인", style: .default, handler: nil)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    @objc func presentSignup() {
        let view = self.storyboard?.instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController
        self.present(view, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        try! Auth.auth().signOut()
        let statusBar = UIView()
        self.view.addSubview(statusBar)
        statusBar.snp.makeConstraints { (make) in
            make.right.top.left.equalTo(self.view)
            make.height.equalTo(20)
        }
        
        color = remoteConfig["splash_background"].stringValue
        statusBar.backgroundColor = UIColor(hex: color)
        loginButton.backgroundColor = UIColor(hex: color)
        signup.backgroundColor = UIColor(hex: color)
        
        loginButton.addTarget(self, action: #selector(loginEvent), for: .touchUpInside)
        signup.addTarget(self, action: #selector(presentSignup), for: .touchUpInside)
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                let view = self.storyboard?.instantiateViewController(withIdentifier: "MainViewTabBarController") as! UITabBarController
                self.present(view, animated: true, completion: nil)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
