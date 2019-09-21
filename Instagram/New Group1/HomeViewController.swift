//
//  HomeViewController.swift
//  Instagram
//
//  Created by Raphael on 2019/08/17.
//  Copyright © 2019 takahashi. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    //postarrayの配列
    var postArray: [PostData] = []
    
    // DatabaseのobserveEventの登録状態を表す
    var observing = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // テーブルセルのタップを無効にする
        tableView.allowsSelection = false
        
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        
        // テーブル行の高さをAutoLayoutで自動調整する
        tableView.rowHeight = UITableView.automaticDimension
        
        // テーブル行の高さの概算値を設定しておく
        // 高さ概算値 = 「縦横比1:1のUIImageViewの高さ(=画面幅)」+「いいねボタン、キャプションラベル、その他余白の高さの合計概算(=100pt)」
        tableView.estimatedRowHeight = UIScreen.main.bounds.width + 100
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")
        
        if Auth.auth().currentUser != nil {
            if self.observing == false {
                // 要素が追加されたらpostArrayに追加してTableViewを再表示する
                let postsRef = Database.database().reference().child(Const.PostPath)
                postsRef.observe(.childAdded, with: { snapshot in
                    print("DEBUG_PRINT: .childAddedイベントが発生しました。")
                    
                    // PostDataクラスを生成して受け取ったデータを設定する
                    if let uid = Auth.auth().currentUser?.uid {
                        let postData = PostData(snapshot: snapshot, myId: uid)
                        self.postArray.insert(postData, at: 0)
                        
                        // TableViewを再表示する
                        self.tableView.reloadData()
                    }
                })
                // 要素が変更されたら該当のデータをpostArrayから一度削除した後に新しいデータを追加してTableViewを再表示する
                postsRef.observe(.childChanged, with: { snapshot in
                    print("DEBUG_PRINT: .childChangedイベントが発生しました。")
                    
                    if let uid = Auth.auth().currentUser?.uid {
                        // PostDataクラスを生成して受け取ったデータを設定する
                        let postData = PostData(snapshot: snapshot, myId: uid)
                        
                        // 保持している配列からidが同じものを探す
                        var index: Int = 0
                        for post in self.postArray {
                            if post.id == postData.id {
                                index = self.postArray.firstIndex(of: post)!
                                break
                            }
                        }
                        
                        // 差し替えるため一度削除する
                        self.postArray.remove(at: index)
                        
                        // 削除したところに更新済みのデータを追加する
                        self.postArray.insert(postData, at: index)
                        
                        // TableViewを再表示する
                        self.tableView.reloadData()
                    }
                })
                
                // DatabaseのobserveEventが上記コードにより登録されたため
                // trueとする
                observing = true
            }
        } else {
            if observing == true {
                // ログアウトを検出したら、一旦テーブルをクリアしてオブザーバーを削除する。
                // テーブルをクリアする
                postArray = []
                tableView.reloadData()
                // オブザーバーを削除する
                let postsRef = Database.database().reference().child(Const.PostPath)
                postsRef.removeAllObservers()
                
                // DatabaseのobserveEventが上記コードにより解除されたため
                // falseとする
                observing = false
            }
        }
    }
    //tableView(_:numberOfRowsInSection:)メソッド・・・配列の数を返します。
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
    //tableView(_ : cellForRowAt :)メソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // dequeueReusableCell(withIdentifier:for:)メソッド・・・セルを取得してPostDataを設定する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
        cell.setPostData(postArray[indexPath.row])
        
        //addTarget(_:action:for:)メソッド
        // PostTableViewCell内のボタンのlikeButtonを持ってきて使えるようにする
        cell.likeButton.addTarget(self, action:#selector(handleButton(_:forEvent:)), for: .touchUpInside)
        // PostTableViewCell内のボタンのlikeButtonを持ってきて使えるようにする
        cell.commentButton.addTarget(self, action:#selector(handleCommentButton(_:forEvent:)), for: .touchUpInside)
        
       
        return cell
    }
    
    
    
    // セル内のlikeボタンがタップされた時に呼ばれるメソッド
    @objc func handleButton(_ sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: likeボタンがタップされました。")
        
        // タップされた(ボタンのある)セルのインデックスを求める３点セット
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        // ＜配列からタップされたインデックスのデータを取り出す＞
        //postArrayをpostDataに代入
        let postData = postArray[indexPath!.row]
        
        // ＜Firebaseに保存するデータの準備＞
        //もし、現在の使用者のIDがnilじゃなかったら、uidに代入する
        if let uid = Auth.auth().currentUser?.uid {
            //もし、postDataのisLiked(すでにlikeしていた)であれば、
            if postData.isLiked {
                // ＜すでにいいねをしていた場合はいいねを解除するためIDを取り除く＞
                //-1をindexとする
                var index = -1
                
                //postDataのlikesを繰り返す
                for likeId in postData.likes {
                    //もし、likeIdがuidと等しければ、
                    if likeId == uid {
                        //index（−１）とはpstDataのlikesの最初のインデックスであるとし、  ＜削除するためにインデックスを保持しておく＞
                        index = postData.likes.firstIndex(of: likeId)!
                        //繰り返しを抜ける
                        break
                    }
                }
                //postDataのlikesのindexを削除する
                postData.likes.remove(at: index)//remove(at: 〇〇)…〇〇を削除する
            
            //でなければ(likeされてなければ)、post.Dataのlikesにuidをappend(追加)する
            } else {
                postData.likes.append(uid)
            }
            
            // 増えたlikesをFirebaseに保存する
            let postRef = Database.database().reference().child(Const.PostPath).child(postData.id!)
            //likes辞書
            let likes = ["likes": postData.likes]
            //Firebaseに辞書を保存する
            postRef.updateChildValues(likes)
            
        }
    }
    
    
    
     // セル内のcommentボタンがタップされた時に呼ばれるメソッド
    @objc func handleCommentButton(_ sender: UIButton, forEvent event: UIEvent){
        print("DEBUG_PRINT: コメントボタンがタップされました。")
        
        // タップされた(ボタンのある)セルのインデックスを求める３点セット
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]
        
//        /*オプショナルバインディング
//        もし、現在の使用者のIDがnilじゃなかったら、commentNameに代入する*/
//        if let commentNameId = Auth.auth().currentUser?.displayName{
//
//            //postDataのcommentNameにcommentNameIdをappend(追加)する
//            postData.commentName.append(commentNameId)
//
//
//            //postData.commentNameを繰り返す
//            for forCommentName in postData.commentName {
//            print(forCommentName)
//            }
//        }
        /*オプショナルバインディング
         もし、indexPathがnilじゃなかったら、indexPathに代入し、tableView.cellForRow(at: indexPath) as? PostTableViewCellがnilじゃなかったら、cellに代入し、現在の使用者の表示名がnilじゃなかったら、displayNameに代入し、cell.textField.textがnilじゃなかったら、textに代入する。*/
        if let indexPath = indexPath,
            //tableView(_ : cellForRowAt :)メソッド
            //指定されたインデックスパスにあるテーブルセル（PostTableViewCell）を返す
            let cell = tableView.cellForRow(at: indexPath) as? PostTableViewCell,
            //現在の使用者の表示名がnilじゃなかったら、displayNameに代入し、
            let displayName = Auth.auth().currentUser?.displayName,
            //cell.textField.textをtextと定義する
            let text = cell.textField.text  {
            
            
            //であれば、cell(PostTableViewCell)のtextFieldをプリントする
            print(cell.textField.text as Any)
            
            //であれば、postData.commentsにtextをappend(追加)する
            postData.comments.append("\(displayName): \(text)\n")
        
//            //postData.commentsを繰り返す
//            for forComments in postData.comments {
//            print(forComments)
//            }
        }
        
            // 増えたcommentsをFirebaseに保存する
            let postRef = Database.database().reference().child(Const.PostPath).child(postData.id!)
            //comments辞書
            let commentDictionary = ["comments": postData.comments]
            //Firebaseに辞書を保存する
            postRef.updateChildValues(commentDictionary)
            
        }
 
    
}
