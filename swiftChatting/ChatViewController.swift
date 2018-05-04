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
    
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var textFieldMessage: UITextField!
    var uid: String?
    var chatRoomUid: String?
    
    public var destinationUid: String? // 나중에 내가 채팅할 대상 uid
    
    @objc func createRoom() {
        let createRoomInfo: Dictionary<String, Any> = [
            "users" : [
                uid!: true,
                destinationUid!: true
            ]
        ]
        
        if (chatRoomUid == nil) {
            Database.database().reference().child("chatrooms").childByAutoId().setValue(createRoomInfo)
        } else {
            let value: Dictionary<String, Any> = [
                "comments": [
                    "uid": uid,
                    "message": textFieldMessage.text
                ]
            ]
            Database.database().reference().child("chatrooms").child(chatRoomUid!).child("comments").childByAutoId().setValue(value)
            
        }
    }
    
    @objc func checkChatRoom() {
        
        Database.database().reference().child("chatrooms").queryOrdered(byChild: "users/"+uid!).queryEqual(toValue: true).observeSingleEvent(of: .value, with: { (datasnapshot) in
            for item in datasnapshot.children.allObjects as! [DataSnapshot] {
                
//                if let chatRoomdic = item.value as? [String: AnyObject] {
//                    let chatModel = ChatModel(JSON: chatRoomdic)
//                    if ChatModel.user[self.destinationUid] {
//                        self.chatRoomdic = item.key
//                    }
//                }
//                self.chatRoomUid = item.key
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uid = Auth.auth().currentUser?.uid
        sendButton.addTarget(self, action: #selector(createRoom), for: .touchUpInside)
        checkChatRoom()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
