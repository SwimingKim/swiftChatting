//
//  SignupViewController.swift
//  swiftChatting
//
//  Created by KimSuyoung on 2018. 5. 1..
//  Copyright © 2018년 KimSuyoung. All rights reserved.
//

import UIKit
import Firebase

class SignupViewController: ViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!

    var isFinishImage: Bool = false
    var isFinishEmail: Bool = false
    var isFinishName: Bool = false
    var isFinishPassword: Bool = false
    
    @IBAction func signupEvent(_ sender: UIButton) {
        Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!) { (user, err) in
            let uid = user?.uid
            let image = UIImageJPEGRepresentation(self.profileImageView.image!, 0.1)
            user?.createProfileChangeRequest().displayName = self.nameField.text
            user?.createProfileChangeRequest().commitChanges(completion: nil)
            Storage.storage().reference().child("userImages").child(uid!).putData(image!, metadata: nil, completion: { [unowned self] (data, error) in
                
                let imageUrl = data?.downloadURL()?.absoluteString
                let df = DateFormatter()
                df.dateFormat = "M월 d일(E)"
                let date = df.string(for: Date())

                let values = ["userName": self.nameField.text!, "profileImageUrl": imageUrl, "uid":Auth.auth().currentUser?.uid, "signupDate": date ]
                Database.database().reference().child("users").child(uid!).setValue(values, withCompletionBlock: { (err, ref) in
                    if err == nil {
                        self.cancleEvent(sender)
                    }
                })
            })
        }
    }
    
    @IBAction func cancleEvent(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signUpButton.isEnabled = false
        
        let statusBar = UIView()
        self.view.addSubview(statusBar)
        statusBar.snp.makeConstraints { (make) in
            make.right.top.left.equalTo(self.view)
            make.height.equalTo(20)
        }
        
        profileImageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imagePicker))
        profileImageView.addGestureRecognizer(gestureRecognizer)
    }
    
}

extension SignupViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        profileImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        dismiss(animated: true, completion: nil)
    }
    
    @objc func imagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true) {
            [weak self] in
            self?.isFinishImage = true
            
            if let isFinishImage = self?.isFinishImage, let isFinishEmail = self?.isFinishEmail, let isFinishName = self?.isFinishName, let isFinishPassword = self?.isFinishPassword {
                self?.signUpButton.isEnabled = isFinishImage && isFinishEmail && isFinishName && isFinishPassword
            }
        }
    }
    
}

extension SignupViewController: UITextFieldDelegate {
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        switch textField.tag {
        case 100:
            if let emailText = textField.text {
                isFinishEmail = emailText.contains("@")
            }
        case 200:
            if let nameText = textField.text {
                isFinishName = nameText.count > 0
            }
        case 300:
            if let passwordText = textField.text {
                isFinishPassword = passwordText.count >= 6
            }
        default:
            return
        }
        
        signUpButton.isEnabled = isFinishImage && isFinishEmail && isFinishName && isFinishPassword
    }
    
}
