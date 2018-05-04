//
//  ChatModel.swift
//  swiftChatting
//
//  Created by KimSuyoung on 2018. 5. 1..
//  Copyright © 2018년 KimSuyoung. All rights reserved.
//
import UIKit
import ObjectMapper
//import ObjectMapper

class ChatModel: NSObject {
    
    public var users: Dictionary<String, Bool> = [:] // 채팅방에 참여한 사람들
    public var comments: Dictionary<String, Comment> = [:] // 채팅방의 대화내용
//    required init?(map: Map) {
//
//    }
//    func mapping(map: Map) {
//        users <- map["user"]
//        comments <- map["comments"]
//    }
    
    public class Comment {
        public var uid: String?
        public var message: String?
//        public required init?(map: Map) {
//            
//        }
//        public mutating func mapping(map: Map) {
//            uid <- map["uid"]
//            message <- map["message"]
//        }
    }

}
