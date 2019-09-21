//
//  PostTableViewCell.swift
//  Instagram
//
//  Created by Raphael on 2019/08/21.
//  Copyright © 2019 takahashi. All rights reserved.
//

import UIKit
import DOFavoriteButton


class PostTableViewCell: UITableViewCell{
    
    @IBOutlet weak var userProfilePic: UIImageView!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel! 
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var commentLabel: UILabel!
    
    @IBOutlet weak var likeButton: DOFavoriteButton!
    @IBOutlet weak var commentButton: DOFavoriteButton!
    
    
    var postArray: [PostData] = []
    
 

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
//各部品にPostDataのデータを表示させる
    func setPostData(_ postData: PostData) {
        
        //captionLabelに表示するのは"postDataのname"と"postDataのcaption"である
        self.captionLabel.text = "\(postData.name!) : \(postData.caption!)"
        
        //日付
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString = formatter.string(from: postData.date!)
        self.dateLabel.text = dateString
        
        //postImageViewに表示するのはpostDataのimageである
        self.postImageView.image = postData.image
        
        //いいねのカウント
        //postData.likesをlikeNumberに代入する
        let likeNumber = postData.likes.count
        //likeLabelに表示するのはlikeNumberである
        likeLabel.text = "\(likeNumber)"
        
        //もし、すでにlikeされていたら、
        if postData.isLiked {
            //「like_exist」を表示
            let buttonImage = UIImage(named: "like_exist")
            self.likeButton.setImage(buttonImage, for: .normal)
        } else {
            //でなければ「like_none」を表示
            let buttonImage = UIImage(named: "like_none")
            self.likeButton.setImage(buttonImage, for: .normal)
        }
        
        //allCommentは最初は空である
        var allComment = ""
        
        //postData.commentsの中から要素をひとつずつ取り出すのを繰り返す、というのがcomment
        for comment in postData.comments{
        //comment + comment = allCommentである
        allComment += comment
        //commentLabelに表示するのはallComment（commentを足していったもの）である
        self.commentLabel.text = allComment

        }
       
        }
        
    

//    textField.delegate = self
//
//    func textFieldShouldReturn(_textField:UITextField)->Bool{
//        textField.resignFirstResponder()
//        return true
//    }


}
