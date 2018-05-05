//
//  ChatRoomsViewController.swift
//  swiftChatting
//
//  Created by KimSuyoung on 2018. 5. 5..
//  Copyright © 2018년 KimSuyoung. All rights reserved.
//

import UIKit
import Firebase

class ChatRoomsViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    var uid: String!
    var chatrooms: [ChatModel]! = []
    
    func getChatroomsList() {
        
        self.chatrooms.removeAll()
        
        Database.database().reference().child("chatrooms").queryOrdered(byChild: "users/"+uid).queryEqual(toValue: true).observeSingleEvent(of: .value, with: { (datasnapshot) in

            for item in datasnapshot.children.allObjects as! [DataSnapshot] {
                if let chatroomdic = item.value as? [String: AnyObject] {
                    let chatModel = ChatModel(JSON: chatroomdic)
                    self.chatrooms.append(chatModel!)
                }
            }
            print(self.chatrooms.count)
            self.tableView.reloadData()
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.uid = Auth.auth().currentUser?.uid
//        self.getChatroomsList()
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        viewDidLoad()
        self.getChatroomsList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension ChatRoomsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatrooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RowCell", for: indexPath) as! CustomCell
        
        var destinationUid: String?
        for item in chatrooms[indexPath.row].users {
            if item.key != self.uid {
                destinationUid = item.key
            }
        }
        Database.database().reference().child("users").child(destinationUid!).observeSingleEvent(of: .value, with: { (datasnapshot) in
            
            let userModel = UserModel()
            userModel.setValuesForKeys(datasnapshot.value as! [String: AnyObject])
            
            cell.labelTitle.text = userModel.userName
            let url = URL(string: userModel.profileImageUrl!)
            URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, err) in
                
                DispatchQueue.main.sync {
                    cell.imageview.image = UIImage(data: data!)
                    cell.imageview.layer.cornerRadius = cell.imageview.frame.width/2
                    cell.imageview.layer.masksToBounds = true
                }
            }).resume()
            
            let lastMessagkey = self.chatrooms[indexPath.row].comments.keys.sorted(){ $0 > $1 }
            cell.labelLastmessage.text = self.chatrooms[indexPath.row].comments[lastMessagkey[0]]?.message
        })
        return cell
    }
    
}

class CustomCell: UITableViewCell {
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelLastmessage: UILabel!
    @IBOutlet weak var imageview: UIImageView!
    
}