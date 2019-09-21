//
//  PostData.swift
//  Instagram
//
//  Created by Raphael on 2019/08/21.
//  Copyright © 2019 takahashi. All rights reserved.
//

import UIKit
import Firebase

class PostData: NSObject {
    var id: String?
    var image: UIImage?
    var imageString: String?
    var name: String?
    var caption: String?
    var date: Date?
    
    var likes: [String] = []
    //likeをされている
    var isLiked: Bool = false
    
    //var commentName : [String] = []
    var comments : [String] = []
    

    
    init(snapshot: DataSnapshot, myId: String) {
        self.id = snapshot.key
        
        let valueDictionary = snapshot.value as! [String: Any]
        
        imageString = valueDictionary["image"] as? String

        image = UIImage(data: Data(base64Encoded: imageString!, options: .ignoreUnknownCharacters)!)
        
       
        
        self.name = valueDictionary["name"] as? String
        
        
        self.caption = valueDictionary["caption"] as? String
        
        let time = valueDictionary["time"] as? String
        
        self.date = Date(timeIntervalSinceReferenceDate: TimeInterval(time!)!)
        
        //もし、valieDictionary["likes"]as? [String]がnilじゃなかったら、likesに代入する
        if let likes = valueDictionary["likes"] as? [String] {
            self.likes = likes
        }
        //self.likesを繰り返すことをlikeIdとする
        for likeId in self.likes {
            //もし、likeIDがmyIDと等しい時、
            if likeId == myId {
                //likeがすでにされている(=true)という事になる
                self.isLiked = true
                //であれば、繰り返しを抜ける
                break
            }
        }
        
//        //もし、valieDictionary["commentName"]as? [String]がnilじゃなかったら、commentNameに代入する
//        if let commentName = valueDictionary["commentName"] as? [String]{
//            self.commentName = commentName
//        }
        
        
        //もし、valieDictionary["comments"]as? [String]がnilじゃなかったら、commentsに代入する
        if let comments = valueDictionary["comments"] as? [String] {
            self.comments = comments
        }
    
    }
}

