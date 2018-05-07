//
//  PeopleViewTableCell.swift
//  swiftChatting
//
//  Created by KimSuyoung on 2018. 5. 8..
//  Copyright © 2018년 KimSuyoung. All rights reserved.
//

import UIKit

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
