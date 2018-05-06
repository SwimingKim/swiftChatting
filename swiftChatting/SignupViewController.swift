//
//  SignupViewController.swift
//  swiftChatting
//
//  Created by KimSuyoung on 2018. 5. 1..
//  Copyright © 2018년 KimSuyoung. All rights reserved.
//

import UIKit
import Firebase
import TextFieldEffects

class SignupViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var email: HoshiTextField!
    @IBOutlet weak var name: HoshiTextField!
    @IBOutlet weak var password: HoshiTextField!
    @IBOutlet weak var signup: UIButton!
    @IBOutlet weak var cancel: UIButton!
    
    let remoteConfig = RemoteConfig.remoteConfig()
    var color: String!
    
    @objc func signupEvent() {
        Auth.auth().createUser(withEmail: email.text!, password: password.text!) { (user, err) in
            let uid = user?.uid
            let image = UIImageJPEGRepresentation(self.imageView.image!, 0.1)
            user?.createProfileChangeRequest().displayName = self.name.text
            user?.createProfileChangeRequest().commitChanges(completion: nil)
            Storage.storage().reference().child("userImages").child(uid!).putData(image!, metadata: nil, completion: { [unowned self] (data, error) in
                let imageUrl = data?.downloadURL()?.absoluteString
                let values = ["userName": self.name.text!, "profileImageUrl": imageUrl,"uid":Auth.auth().currentUser?.uid ]
                Database.database().reference().child("users").child(uid!).setValue(values, withCompletionBlock: { (err, ref) in
                    if err == nil {
                        self.cancleEvent()
                    }
                })
            })
        }
    }
    
    @objc func cancleEvent() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let statusBar = UIView()
        self.view.addSubview(statusBar)
        statusBar.snp.makeConstraints { (make) in
            make.right.top.left.equalTo(self.view)
            make.height.equalTo(20)
        }
        
        imageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imagePicker))
        imageView.addGestureRecognizer(gestureRecognizer)
        
        color = remoteConfig["splash_background"].stringValue
        statusBar.backgroundColor = UIColor(hex: color)
        signup.backgroundColor = UIColor(hex: color)
        cancel.backgroundColor = UIColor(hex: color)
        
        signup.addTarget(self, action: #selector(signupEvent), for: .touchUpInside)
        cancel.addTarget(self, action: #selector(cancleEvent), for: .touchUpInside)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension SignupViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imageView.image = info[UIImagePickerControllerOriginalImage] as! UIImage
        dismiss(animated: true, completion: nil)
    }
    
    @objc func imagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
}
