//
//  AccountViewController.swift
//  swiftChatting
//
//  Created by KimSuyoung on 2018. 5. 6..
//  Copyright © 2018년 KimSuyoung. All rights reserved.
//

import UIKit
import Firebase

class AccountViewController: ViewController {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerBackgroundView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var floatingMenuTopConstraint: NSLayoutConstraint!
    
    var floatinMenuBase: CGFloat = 0.0
    var whiteMode = false
    var barStyle = UIStatusBarStyle.lightContent
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return barStyle
    }
    
    
    @IBAction func showAlert(_ sender: UIButton) {
        let alertController = UIAlertController(title: "상태 메세지", message: nil, preferredStyle: .alert)
        alertController.addTextField { (textfield) in
            textfield.placeholder = "상태메세지를 입력해주세요"
        }
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
            if let textfield = alertController.textFields?.first {
                let dic = [ "comment": textfield.text ]
                let uid = Auth.auth().currentUser?.uid
                Database.database().reference().child("users").child(uid!).updateChildValues(dic)
            }
        }))
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: { (aciton) in
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func signOut(_ sender: UIButton) {
        
        try! Auth.auth().signOut()
        
        let view = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.present(view, animated: true, completion: nil)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerBackgroundView.alpha = 0.0
        titleLabel.alpha = 0.0
        
        listTableView.contentInset = UIEdgeInsets(top: imageHeightConstraint.constant - headerView.bounds.height, left: 0, bottom: 0, right: 0)
        listTableView.scrollIndicatorInsets = listTableView.contentInset
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if floatinMenuBase == 0.0 {
            let ip = IndexPath(row: 1, section: 0)
            if let cell = listTableView.cellForRow(at: ip) {
                let frame = view.convert(cell.frame, to: view)
                floatinMenuBase = frame.origin.y + listTableView.contentInset.top
                floatingMenuTopConstraint.constant = floatinMenuBase
            }
        }
    }
    
    
}

extension AccountViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y
        
        let diff = y + 200
        floatingMenuTopConstraint.constant = floatinMenuBase - diff
        
        if y < -200 {
            imageHeightConstraint.constant = 300 + abs(diff)
        } else {
            imageHeightConstraint.constant = 300
        }
        
        if y >= 0 {
            if !whiteMode {
                whiteMode = true
                
                UIView.animate(withDuration: 0.3, delay: 0.0, options: .beginFromCurrentState, animations: {
                    [weak self] in
                    self?.headerBackgroundView.alpha = 1.0
                    self?.titleLabel.alpha = 1.0
                    }, completion: nil)
                
                barStyle = .default
                setNeedsStatusBarAppearanceUpdate()
            }
        } else {
            if whiteMode {
                whiteMode = false
                
                UIView.animate(withDuration: 0.3, delay: 0.0, options: .beginFromCurrentState, animations: {
                    [weak self] in
                    self?.headerBackgroundView.alpha = 0.0
                    self?.titleLabel.alpha = 0.0
                    }, completion: nil)
                
                barStyle = .lightContent
                setNeedsStatusBarAppearanceUpdate()
            }
        }
        
    }
    
}

extension AccountViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AccountTableViewCell") as! AccountTableViewCell
            cell.emailLabel.text = "rumex13@naver.com"
            cell.nameLabel.text = "네이버"
            
            let df = DateFormatter()
            df.dateFormat = "M월 d일(E)"
            cell.signUpDateLabel.text = df.string(for: Date())
            cell.commentLabel.text = "Hello, LINE"
            
            return cell
        default:
            return tableView.dequeueReusableCell(withIdentifier: "dummy")!
        }
    }
    
}

extension AccountViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 1:
            return 40
        case 2:
            return 1000
        default:
            return UITableViewAutomaticDimension
        }
    }
    
}

