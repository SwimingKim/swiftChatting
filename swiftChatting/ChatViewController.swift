//
//  ChatViewController.swift
//  swiftChatting
//
//  Created by KimSuyoung on 2018. 5. 1..
//  Copyright © 2018년 KimSuyoung. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import Kingfisher

class ChatViewController: ViewController {
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textFieldMessage: UITextField!
    var uid: String?
    var chatRoomUid: String?
    var comments: [ChatModel.Comment] = []
    var destinationUserModel: UserModel?
    
    public var destinationUid: String? // 나중에 내가 채팅할 대상 uid
    
    @IBAction func touchUpSending(_ sender: UIButton) {
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
            sender.isEnabled = false
            Database.database().reference().child("chatrooms").childByAutoId().setValue(createRoomInfo, withCompletionBlock: { [weak self] (err, ref) in
                if(err == nil){
                    self?.checkChatRoom()
                }
            })
        }else{
            let value :Dictionary<String,Any> = [
                "uid": uid!,
                "message": textFieldMessage.text!,
                "timestamp": ServerValue.timestamp()
            ]
            Database.database().reference().child("chatrooms").child(chatRoomUid!).child("comments").childByAutoId().setValue(value) { [weak self] (err, ref) in
                self?.textFieldMessage.text = ""
            }
        }
        
        
    }
    
    @objc func checkChatRoom() {
        Database.database().reference().child("chatrooms").queryOrdered(byChild: "users/"+uid!).queryEqual(toValue: true).observeSingleEvent(of: .value, with: { [weak self] (datasnapshot) in
            for item in datasnapshot.children.allObjects as! [DataSnapshot] {
                if let chatRoomdic = item.value as? [String: AnyObject], let chatModel = ChatModel(JSON: chatRoomdic), let destinationUid = self?.destinationUid {
                    if chatModel.users[destinationUid] == true {
                        self?.chatRoomUid = item.key
                        self?.sendButton.isEnabled = true
                        self?.getDestinationInfo()
                    }
                }
            }
        })
    }
    
    func getDestinationInfo() {
        Database.database().reference().child("users").child(self.destinationUid!).observeSingleEvent(of: .value, with: { (datasnapshot) in
            self.destinationUserModel = UserModel()
            self.destinationUserModel?.setValuesForKeys(datasnapshot.value as! [String: Any])
            Database.database().reference().child("chatrooms").child(self.chatRoomUid!).child("comments").observe(DataEventType.value, with: { [weak self] (datasnapshot) in
                self?.comments.removeAll()
                
                for item in datasnapshot.children.allObjects as! [DataSnapshot]{
                    let comment = ChatModel.Comment(JSON: item.value as! [String:AnyObject])
                    self?.comments.append(comment!)
                }
                self?.tableView.reloadData()
                
                if let count = self?.comments.count, count > 0 {
                    self?.tableView.scrollToRow(at: IndexPath(item: count-1, section: 0), at: UITableViewScrollPosition.bottom, animated: true)
                }
                
            })
        })
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uid = Auth.auth().currentUser?.uid
        checkChatRoom()
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(forName: Notification.Name.UIKeyboardWillShow, object: nil, queue: OperationQueue.main) { [weak self] (noti) in
            
            if let value = noti.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                let frame = value.cgRectValue
                self?.bottomConstraint.constant = frame.height + 8
                
                UIView.animate(withDuration: 0.3, animations: {
                    self?.view.layoutIfNeeded()
                    if let count = self?.comments.count, count > 0 {
                        self?.tableView.scrollToRow(at: IndexPath(item: count-1, section: 0), at: UITableViewScrollPosition.bottom, animated: true)
                    }
                })
            }
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name.UIKeyboardWillHide, object: nil, queue: OperationQueue.main) { [weak self] (noti) in
            self?.bottomConstraint.constant = 8
            self?.view.layoutIfNeeded()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        self.tabBarController?.tabBar.isHidden = false
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
            if let time = self.comments[indexPath.row].timestamp {
                view.labelTimestamp.text = time.toDayTime
            }
            return view
        }
        else {
            let view = tableView.dequeueReusableCell(withIdentifier: "DestinationMessageCell", for: indexPath) as! DestinationMessageCell
            view.labelName.text = destinationUserModel?.userName
            view.labelMessage.text = self.comments[indexPath.row].message
            view.labelMessage.numberOfLines = 0
            
            let url = URL(string: (self.destinationUserModel?.profileImageUrl)!)
            view.imageViewProfile.layer.cornerRadius = view.imageViewProfile.frame.width / 2
            view.imageViewProfile.clipsToBounds = true
            view.imageViewProfile.kf.setImage(with: url)
            
            if let time = self.comments[indexPath.row].timestamp {
                view.labelTimestamp.text = time.toDayTime
            }
            return view
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
}

extension Int {
    
    var toDayTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        let date = Date(timeIntervalSince1970: Double(self)/1000)
        return dateFormatter.string(from: date)
    }
    
}


