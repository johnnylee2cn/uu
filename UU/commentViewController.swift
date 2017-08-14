//
//  commentViewController.swift
//  UU
//
//  Created by admin on 2017/5/17.
//  Copyright © 2017年 L. All rights reserved.
//

import UIKit
import AVOSCloud

protocol reloadComment {
    func reloadMainView(bool:Bool)
}

class commentViewController: UIViewController {

    @IBOutlet weak var commentTableView: UITableView!
    var commentView:UIView!
    var textView:UITextView!
    var textField:UITextField!
    var button:UIButton!
    var commentDic:Dictionary<String,String>! = [:]
    var commentArray:Array<String>! = []
    var nameArray:Array<String>! = []
    var name:String! = ""
    var str:String! = ""
    var objectID:String!
    var commentsAVCloud:[AVObject] = []
    var refreshControl:UIRefreshControl!
    var commentToName:String! = ""
    var commentDelegate:reloadComment?
    let screenWidth = UIScreen.main.bounds.width
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //  键盘的通知
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(_notification:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(_notification:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)

        //使用userdefault接受值
        let defaults = UserDefaults.standard
        let data = defaults.data(forKey: "ojID")
        objectID = NSKeyedUnarchiver.unarchiveObject(with: data!) as! String

        print(objectID)
        setCommentTableView()
        setCommentView()
        setTextView()
        setSendButton()
        
        getDataFromCloud()
        self.refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK: - 设置view
    func setCommentTableView(){
        commentTableView.tableFooterView = UIView()
        commentTableView.delegate = self
        commentTableView.dataSource = self
        commentTableView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(closeResign))
        commentTableView.addGestureRecognizer(tap)
        
        commentTableView.estimatedRowHeight = 200
        commentTableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func setCommentView(){
        commentView = UIView(frame:CGRect(x: 0,y: self.view.frame.size.height - 106,width: screenWidth,height: 56))
        commentView.backgroundColor = UIColor.lightGray
        commentView.alpha=0.9
        self.view.addSubview(commentView)
    }
    
    func setTextView(){
        textView = UITextView()
        textView.frame = CGRect(x: 7,y: 10,width: screenWidth - 95,height: 36)
        textView.textColor = UIColor.black
        textView.font = UIFont.boldSystemFont(ofSize: 12)
        textView.layer.cornerRadius = 10.0
        textView.returnKeyType = UIReturnKeyType.send
        textView.backgroundColor = UIColor.darkGray
        commentView.addSubview(textView)
    }
    
    func setSendButton(){
        button = UIButton()
        button.setImage(UIImage(named:"发送-2"), for: .normal)
        button.setTitle("", for: .normal)
        button.frame = CGRect(x: screenWidth - 80,y: 10,width: 72,height: 36)
        button.layer.cornerRadius = 6.0
        button.addTarget(self, action: #selector(send), for: .touchUpInside)
        commentView.addSubview(button)

    }
    
    //MARK: - 与云数据交互
    //保存评论
     func saveDataToCloud(){
        let cloudObject = AVObject(className: "tripComments")
        cloudObject["commentName"] = name
        cloudObject["tripID"] = objectID
        cloudObject["tripComment"] = textView.text
        cloudObject.saveInBackground { (success, error) in
            if success{
                print("保存云端成功")
                self.commentDelegate?.reloadMainView(bool: true)
                self.getDataFromCloud()
            }else{
                print("保存失败")
            }
        }
    }
    
    //得到原有评论
    func getDataFromCloud(needUpdate:Bool = false){
        print(objectID)
        let query = AVQuery(className: "tripComments")
        query.whereKey("tripID", equalTo: objectID)
        query.order(byDescending: "createdAt")
        query.findObjectsInBackground { (results, error) in
            if let result = results{
                self.commentsAVCloud = result as! [AVObject]
                OperationQueue.main.addOperation {
                    self.commentTableView.reloadData()
                }
            }
        }
    }
    
    //得到用户头像
    func getUserImage(name:String,imageView:UIImageView){
        var headImageData = UIImage()
        let query = AVQuery(className: "UserInfo")
        query.whereKey("userName", equalTo: name)
        query.findObjectsInBackground { (results, error) in
            OperationQueue.main.addOperation {
                if let result = results as? [AVObject]{
                    if let imgFile = result[0]["headImage"] as? AVFile{
                        
                        imgFile.getDataInBackground({ (data, error) in
                            let imageData = NSKeyedUnarchiver.unarchiveObject(with: data!) as! UIImage
                            headImageData = imageData
                            imageView.image = headImageData
                        })
                    }
                }
            }
        }
        
    }

    //刷新页面
    func refreshData(){
        getDataFromCloud()
    }

    
    //MARK: - 键盘的设置
    //键盘的出现
    func keyBoardWillShow(_notification: Notification){
        //获取userInfo
        let kbInfo = _notification.userInfo
        //获取键盘的size
        let kbRect = (kbInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        //键盘的y偏移量
        let changeY = kbRect.origin.y - self.view.bounds.height
        //键盘弹出的时间
        let duration = kbInfo?[UIKeyboardAnimationDurationUserInfoKey] as!Double
   
        //界面偏移动画
        UIView.animate(withDuration: duration) {
           self.view.frame.origin.y = changeY+50
        }
    }
    
    //键盘的隐藏
    func keyBoardWillHide(_notification: Notification){
        
        let kbInfo = _notification.userInfo
        let duration = kbInfo?[UIKeyboardAnimationDurationUserInfoKey] as!Double
        
        UIView.animate(withDuration: duration) {
            self.view.frame.origin.y = 0
        }
    }

    func closeResign(){
        textView.resignFirstResponder()
    }
    
    //发送按钮的方法
    func send(){
        let defaults = UserDefaults.standard
        let objectData = defaults.data(forKey: "name")
        name = NSKeyedUnarchiver.unarchiveObject(with: objectData!) as! String
        
        nameArray.append(name)
        commentArray.append(textView.text!)
        commentTableView.delegate = self
        commentTableView.dataSource = self
        
        saveDataToCloud()
        textView.text = ""
    }
    
       
    
    //得到评论的对象
    func replay(sender:UIButton){
       let array = commentsAVCloud[sender.tag]
         str = array["commentName"] as! String
         textView.text = "回复评论"+str+":  "
    }
}

extension commentViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentsAVCloud.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let array = commentsAVCloud[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "comment", for: indexPath) as! commentTableViewCell
        
        cell.replyButton.tag = indexPath.row
        cell.replyButton.addTarget(self, action: #selector(replay), for: .touchUpInside)
        cell.userNameLabel.text = array["commentName"] as? String
        cell.commentLabel.text = array["tripComment"] as? String
        
        getUserImage(name: (array["commentName"] as? String)!, imageView: cell.headImage)
        
        
        cell.timeLable.text = getTime(date: array["createdAt"] as! Date)
        return cell
    }
    
    func getTime(date:Date) -> String{
    //初始化DateFormatter类
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        //设置样式
        dateFormatter.dateStyle = DateFormatter.Style.short
        let date = date
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}
