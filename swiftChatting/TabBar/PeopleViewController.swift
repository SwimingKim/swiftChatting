//
//  MainViewController.swift
//  swiftChatting
//
//  Created by KimSuyoung on 2018. 5. 1..
//  Copyright © 2018년 KimSuyoung. All rights reserved.
//

import UIKit
import SnapKit
import Firebase

class PeopleViewController: UIViewController {
    
    var array = [UserModel]()
    var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PeopleViewTableCell.self, forCellReuseIdentifier: "Cell")
        tableView.rowHeight = 70
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(view).offset(20)
            make.bottom.left.right.equalTo(view)
        }
        
        Database.database().reference().child("users").observe(.value, with: {
            [unowned self] (snapshot) in
            self.array.removeAll()
            
            let myUid = Auth.auth().currentUser?.uid

            for child in snapshot.children{
                let fchild = child as! DataSnapshot
                let userModel = UserModel()

                userModel.setValuesForKeys(fchild.value as! [String : Any])
                
                if userModel.uid == myUid {
                    continue
                }
                
                self.array.append(userModel)
            }

            DispatchQueue.main.async {
                self.tableView.reloadData();
            }
        })

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension PeopleViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PeopleViewTableCell
        
        let imageview = cell.imageview!
        imageview.snp.makeConstraints { (make) in
            make.centerY.equalTo(cell)
            make.left.equalTo(cell).offset(10)
            make.height.width.equalTo(50)
        }
        
        let url = URL(string: array[indexPath.row].profileImageUrl!)
        imageview.layer.cornerRadius = 50/2
        imageview.clipsToBounds = true
        imageview.kf.setImage(with: url)
        
        let label = cell.label!
        label.snp.makeConstraints { (make) in
            make.centerY.equalTo(cell)
            make.left.equalTo(imageview.snp.right).offset(20)
        }
        label.text = array[indexPath.row].userName
        
        let label_comment = cell.label_comment!
        label_comment.snp.makeConstraints { (make) in
            make.right.equalTo(cell).offset(-20)
            make.centerY.equalTo(cell)
        }
        if let comment = array[indexPath.row].comment {
            label_comment.text = comment
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let view = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController
        view?.destinationUid = self.array[indexPath.row].uid
        navigationController?.pushViewController(view!, animated: true)
    }
    
}

class PeopleViewTableCell: UITableViewCell {
    
    var imageview: UIImageView! = UIImageView()
    var label: UILabel! = UILabel()
    var label_comment: UILabel! = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier )
        self.addSubview(imageview)
        self.addSubview(label)
        self.addSubview(label_comment)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
