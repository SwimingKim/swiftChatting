//
//  ViewController.swift
//  swiftChatting
//
//  Created by KimSuyoung on 2018. 5. 1..
//  Copyright © 2018년 KimSuyoung. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let subView = UIView(frame: view.frame)
        view.insertSubview(subView, at: 0)
        
        let tap = UITapGestureRecognizer()
        tap.delegate = self
        subView.addGestureRecognizer(tap)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
