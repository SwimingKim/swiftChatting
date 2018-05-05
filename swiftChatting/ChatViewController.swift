//
//  ChatViewController.swift
//  swiftChatting
//
//  Created by KimSuyoung on 2018. 5. 1..
//  Copyright © 2018년 KimSuyoung. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textFieldMessage: UITextField!
    var uid: String?
    var chatRoomUid: String?
    var comments: [ChatModel.Comment] = []
    var userModel: UserModel?
    
    public var destinationUid: String? // 나중에 내가 채팅할 대상 uid
    
    @objc func createRoom() {
        if let length = textFieldMessage.text?.count, length == 0 {
            return
        }
        
        let createRoomInfo: Dictionary<String, Any> = [
            "users" : [
                uid!: true,
                destinationUid!: true
            ]
        ]

        
        if(chatRoomUid == nil){
            self.sendButton.isEnabled = false
            // 방 생성 코드
            Database.database().reference().child("chatrooms").childByAutoId().setValue(createRoomInfo, withCompletionBlock: { (err, ref) in
                if(err == nil){
                    self.checkChatRoom()
                }
            })
            
        }else{
            let value :Dictionary<String,Any> = [
                
                "uid" : uid!,
                "message" : textFieldMessage.text!
            ]
            
            Database.database().reference().child("chatrooms").child(chatRoomUid!).child("comments").childByAutoId().setValue(value) { (err, ref) in
                self.textFieldMessage.text = ""
            }
        }
        
        
    }
    
    @objc func checkChatRoom() {
        Database.database().reference().child("chatrooms").queryOrdered(byChild: "users/"+uid!).queryEqual(toValue: true).observeSingleEvent(of: .value, with: { (datasnapshot) in
            for item in datasnapshot.children.allObjects as! [DataSnapshot] {
                if let chatRoomdic = item.value as? [String: AnyObject] {
                    let chatModel = ChatModel(JSON: chatRoomdic)
                    if chatModel?.users[self.destinationUid!] == true {
                        self.chatRoomUid = item.key
                        self.sendButton.isEnabled = true
                        self.getDestinationInfo()
                    }
                }
            }
        })
    }
    
    func getDestinationInfo() {
        
        Database.database().reference().child("users").child(self.destinationUid!).observeSingleEvent(of: .value, with: { (datasnapshot) in
            self.userModel = UserModel()
            self.userModel?.setValuesForKeys(datasnapshot.value as! [String: Any])
            self.getMessageList()
        })
    
    }
    
    func getMessageList() {
        Database.database().reference().child("chatrooms").child(self.chatRoomUid!).child("comments").observe(DataEventType.value, with: { (datasnapshot) in
            self.comments.removeAll()
            
            for item in datasnapshot.children.allObjects as! [DataSnapshot]{
                let comment = ChatModel.Comment(JSON: item.value as! [String:AnyObject])
                self.comments.append(comment!)
            }
            self.tableView.reloadData()
            
            if self.comments.count > 0 {
                self.tableView.scrollToRow(at: IndexPath(item: self.comments.count-1, section: 0), at: UITableViewScrollPosition.bottom, animated: true)
            }
            
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uid = Auth.auth().currentUser?.uid
        sendButton.addTarget(self, action: #selector(createRoom), for: .touchUpInside)
        checkChatRoom()
        self.tabBarController?.tabBar.isHidden = true
        
        let backView = UIView()
        view.insertSubview(backView, at: 0)
        view.addSubview(backView)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(disimissKeyboard))
        backView.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.bottomConstraint.constant = keyboardSize.height + 20
        }
        
        UIView.animate(withDuration: 0) {
            self.view.layoutIfNeeded()
            if self.comments.count > 0 {
                self.tableView.scrollToRow(at: IndexPath(item: self.comments.count-1, section: 0), at: UITableViewScrollPosition.bottom, animated: true)
            }
        }
    }
    
    func keyboardWillHide(notification: Notification) {
        self.bottomConstraint.constant = 20
        self.view.layoutIfNeeded()
    }
    
    func disimissKeyboard() {
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.comments[indexPath.row].uid == uid {
            let view = tableView.dequeueReusableCell(withIdentifier: "MyMessageCell", for: indexPath) as! MyMessageCell
            view.labelMessage.text = self.comments[indexPath.row].message
            view.labelMessage.numberOfLines = 0
            return view
        }
        else {
            let view = tableView.dequeueReusableCell(withIdentifier: "DestinationMessageCell", for: indexPath) as! DestinationMessageCell
            view.labelName.text = userModel?.userName
            view.labelMessage.text = self.comments[indexPath.row].message
            view.labelMessage.numberOfLines = 0
            
            let url = URL(string: (self.userModel?.profileImageUrl)!)
            URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, err) in
                DispatchQueue.main.async {
                    view.imageViewProfile.image = UIImage(data: data!)
                    view.imageViewProfile.layer.cornerRadius = view.imageViewProfile.frame.width / 2
                    view.imageViewProfile.clipsToBounds = true
                }
            }).resume()
            return view
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

}

class MyMessageCell: UITableViewCell {
    @IBOutlet weak var labelMessage: UILabel!
    @IBOutlet weak var labelTimestamp: UILabel!
}

class DestinationMessageCell: UITableViewCell {
    @IBOutlet weak var labelMessage: UILabel!
    @IBOutlet weak var imageViewProfile: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelTimestamp: UILabel!
}
