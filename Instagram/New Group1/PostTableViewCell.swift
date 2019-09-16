//
//  PostTableViewCell.swift
//  Instagram
//
//  Created by Raphael on 2019/08/21.
//  Copyright © 2019 takahashi. All rights reserved.
//

import UIKit
import DOFavoriteButton


class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userProfilePic: UIImageView!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel! 
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var commentName: UILabel!
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
    
    
    func setPostData(_ postData: PostData) {
        //キャプションは”postDataの名前：postDataのキャプション”
        self.captionLabel.text = "\(postData.name!) : \(postData.caption!)"
        //日付
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString = formatter.string(from: postData.date!)
        self.dateLabel.text = dateString
        //イメージはpostDataのイメージ
        self.postImageView.image = postData.image
        //いいねのカウント
        let likeNumber = postData.likes.count
        likeLabel.text = "\(likeNumber)"
        
        if postData.isLiked {
            //もし「いいね」を押せば「like_exist」を表示
            let buttonImage = UIImage(named: "like_exist")
            self.likeButton.setImage(buttonImage, for: .normal)
        } else {
            //でなければ「like_none」を表示
            let buttonImage = UIImage(named: "like_none")
            self.likeButton.setImage(buttonImage, for: .normal)
        }
        
        self.commentName.text = "\(postData.name!)"
        
        if postData.isComment {
            //もし「コメント」を押せば「入力文章」を表示
            commentLabel.text = textField.text
            
        } else {
            //でなければ「like_none」を表示
            print("なし")
            
        }
       
        }
        
    

    
    
    func textFieldShouldReturn(_textField:UITextField)->Bool{
        textField.resignFirstResponder()
        return true
    }
    
}

