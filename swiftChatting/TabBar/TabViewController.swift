//
//  TabViewController.swift
//  swiftChatting
//
//  Created by KimSuyoung on 2018. 5. 8..
//  Copyright © 2018년 KimSuyoung. All rights reserved.
//

import UIKit

class TabViewController: UITabBarController {

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        tabBar.frame = CGRect(x: 0, y: 50, width: tabBar.frame.size.width, height: tabBar.frame.size.height)
    }

}
