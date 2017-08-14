//
//  chatViewController.swift
//  UU
//
//  Created by admin on 2017/6/5.
//  Copyright © 2017年 L. All rights reserved.
//

import UIKit
import CoreData
import AVOSCloud

class chatViewController: UIViewController,ChatDataSource,UITextFieldDelegate{

    var name = ""
    var youName = ""
    var chatArrayAVObject:[AVObject] = []
    var Chats:NSMutableArray!
    var tableView:TableView!
    var me:UserInfo!
    var you:UserInfo!
    var txtMsg:UITextField!
    var chat:[ChatHistory] = []
    var addChat:ChatHistory!
    var messageArray:[MessageItem] = []
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = true
print("youname\(youName)")
        getName()
        getDataFromCoreData()
   
        
       
        txtMsg = UITextField()
        txtMsg.delegate = self

        setupChatTable()
        setupSendPanel()
        
        self.title = youName
        
    }
    
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
        print("changey\(changeY)")
        //界面偏移动画
        UIView.animate(withDuration: duration) {
          
            self.view.frame.origin.y = changeY
            
        }
    }
    

    //键盘的隐藏
    func keyBoardWillHide(_notification: Notification){
        
        let kbInfo = _notification.userInfo
        
        /*
         *
         let kbRect = (userInfo![UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
         *
         swift2.3正常，swift3.0取值为nil
         */
        
        let duration = kbInfo?[UIKeyboardAnimationDurationUserInfoKey] as!Double
        
        UIView.animate(withDuration: duration) {
            // self.commentView.frame.origin.y = -150
            self.view.frame.origin.y = 0
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       // self.view.endEditing(true)
    }
    
//    // 关闭键盘
//    func closeKeyBoard(){
//        print("====================")
//        txtMsg.resignFirstResponder()
//    }
    
    //从云端获取数据
    func getDataFromCloud(){
        let query = AVQuery(className: "tripFriend")
        query.whereKey("userName", equalTo: name)
        query.order(byDescending: "createdAt")
        query.findObjectsInBackground { (result, error) in
            if let results = result as? [AVObject]{
                print(results.count)
                self.chatArrayAVObject = results
                OperationQueue.main.addOperation {
                    //self.refreshControl?.endRefreshing()
                   // self.tableView.reloadData()
                }
            }else{
                print(error ?? "未知错误")
            }
        }
    }
    
    //  从coredata读取数据
    func getDataFromCoreData(){
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest()
        fetchRequest.fetchLimit = 20
        fetchRequest.fetchOffset = 0
        
        let entity:NSEntityDescription = NSEntityDescription.entity(forEntityName: "ChatHistory", in: context)!
        fetchRequest.entity = entity
        let currentDate = Date()
        print(currentDate)
        let predicate = NSPredicate.init(format: "you = %@ and me = %@  or you = %@ and me = %@ ", name,youName,youName,name)
        fetchRequest.predicate = predicate
        
        do {
           chat = try appDelegate.persistentContainer.viewContext.fetch(fetchRequest) as! [ChatHistory]
        } catch  {
            print(error)
        }
     
        print(chat.count)
    }
    
    func getName(){
        let defaults = UserDefaults.standard
        let data = defaults.data(forKey: "name")
        name = NSKeyedUnarchiver.unarchiveObject(with: data!) as! String
    }
    
    //输入框设置
    func setupSendPanel()
    {
        let screenWidth = UIScreen.main.bounds.width
        let sendView = UIView(frame:CGRect(x: 0,y: self.view.frame.size.height - 56,width: screenWidth,height: 56))
        
        sendView.backgroundColor=UIColor.lightGray
        sendView.alpha=0.9
        
        txtMsg = UITextField(frame:CGRect(x: 7,y: 10,width: screenWidth - 95,height: 36))
        txtMsg.backgroundColor = UIColor.white
        txtMsg.textColor=UIColor.black
        txtMsg.font=UIFont.boldSystemFont(ofSize: 12)
        txtMsg.layer.cornerRadius = 10.0
        txtMsg.returnKeyType = UIReturnKeyType.send
        
        //Set the delegate so you can respond to user input
        txtMsg.delegate = self
        sendView.addSubview(txtMsg)
        self.view.addSubview(sendView)
        
        let sendButton = UIButton(frame:CGRect(x: screenWidth - 80,y: 10,width: 72,height: 36))
        sendButton.backgroundColor=UIColor(red: 0x37/255, green: 0xba/255, blue: 0x46/255, alpha: 1)
        sendButton.addTarget(self, action:#selector(chatViewController.sendMessage) ,
                             for:UIControlEvents.touchUpInside)
        sendButton.layer.cornerRadius=6.0
        sendButton.setTitle("发送", for:UIControlState())
        sendView.addSubview(sendButton)
    }
    
    func textFieldShouldReturn(_ textField:UITextField) -> Bool
    {
        sendMessage()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        UIView.animate(withDuration: 0.4, animations: {
            // self.commentView.frame.origin.y = -150
            //self.view.frame.origin.y = -250
            NotificationCenter.default.addObserver(self, selector: #selector(self.keyBoardWillShow(_notification:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.keyBoardWillHide(_notification:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
           
        })
        return true
    }
    
    //发送消息的方法
    func sendMessage()
    {
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        addChat = ChatHistory(context: appdelegate.persistentContainer.viewContext)
        addChat.chatText = txtMsg.text
        addChat.me = name
        addChat.you = youName
        addChat.readAlready = false
        addChat.chatTime = Date() as NSDate
        appdelegate.saveContext()
        
    
        let sender = txtMsg
        let thisChat =  MessageItem(body:sender!.text! as NSString, user:me, date:Date(), mtype:ChatType.mine)
        
        Chats.add(thisChat)
        
        self.tableView.chatDataSource = self
        self.tableView.reloadData()
       
        //makeLabel(textView: txtMsg, labelView: thisChat.view)
        sender?.resignFirstResponder()
        
        sender?.text = ""
        
    }
    
    func makeLabel(textView:UITextField,labelView:UIView){
        let label = UILabel(frame: CGRect(x: (textView.superview?.frame.minX)!, y: (textView.superview?.frame.minY)!+10, width: textView.bounds.width, height: textView.bounds.height))
        self.view.addSubview(label)
        label.text = textView.text
     //   label.backgroundColor = UIColor.blue
        
        UIView.animate(withDuration: 5) { 
            label.frame = CGRect(x: self.tableView.frame.maxY, y: self.tableView.frame.maxY, width: textView.bounds.width, height: textView.bounds.height)
        }
//        let centerX = view.bounds.size.width/2
//        print(textView.frame.origin.x)
//        print(textView.frame.origin.y)
//        let boundingRect:CGRect =  CGRect(x:textView.superview!.frame.minX, y:textView.superview!.frame.minY, width:150,height: 150)
//        
//        let orbit = CAKeyframeAnimation(keyPath:"position")
//        orbit.duration = 5
//        orbit.path = CGPath(ellipseIn: boundingRect,transform: nil)
//        orbit.calculationMode = kCAAnimationPaced
//        label.layer.add(orbit,forKey:"Move")
//        label.layer.position = label.frame.origin
        
    }
    
    func setupChatTable()
    {
    
        self.tableView = TableView(frame:CGRect(x: 0, y: 20, width: self.view.frame.size.width, height: self.view.frame.size.height - 76), style: .plain)
        
        //创建一个重用的单元格
        self.tableView!.register(chatTableViewCell.self, forCellReuseIdentifier: "ChatCell")
    
        me = UserInfo(name:name )
        you  = UserInfo(name:youName)
        
        if chat.count != 0{
        for value in chat{
            var message:Any!
            if value.me == name{
             message = MessageItem(body: value.chatText! as NSString, user: me, date: value.chatTime! as Date, mtype: .mine)
            }else{
            message = MessageItem(body: value.chatText! as NSString, user: you, date: value.chatTime! as Date, mtype: .someone)
            }
            messageArray.append(message as! MessageItem)
            Chats = NSMutableArray()
            Chats.addObjects(from: self.messageArray)
            
            //set the chatDataSource
            self.tableView.chatDataSource = self
            
            //call the reloadData, this is actually calling your override method
            self.tableView.reloadData()
            
            
        }
        }else{
            
        let zero =  MessageItem(body:"我们已经是好友了，来打个招呼吧！", user:me,  date:Date(timeIntervalSinceNow:-90096400), mtype:.mine)
            Chats = NSMutableArray()
        
        Chats.addObjects(from: [zero])
        }
        
        //set the chatDataSource
        self.tableView.chatDataSource = self
        
        //call the reloadData, this is actually calling your override method
        self.tableView.reloadData()
        self.view.addSubview(self.tableView)
            }
    
    func rowsForChatTable(_ tableView:TableView) -> Int
    {
        return self.Chats.count
    }
    
    func chatTableView(_ tableView:TableView, dataForRow row:Int) -> MessageItem
    {
        return Chats[row] as! MessageItem
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//extension chatViewController:UITableViewDelegate,UITableViewDataSource{
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return chatArrayAVObject.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let array = chatArrayAVObject[indexPath.row]
//        let cell = tableView.dequeueReusableCell(withIdentifier: "chat", for: indexPath) as! chatTableViewCell
//        let userName = array["userName"] as! String
//        let friendName = array["friendName"] as! String
//        let namelabel = UILabel()
//        var chatLabel = UILabel()
//        if userName == name{
//            namelabel.frame = CGRect(x: 280, y: 20, width: 30, height: 20)
//            namelabel.text = name
//            namelabel.backgroundColor = UIColor.blue
//            
//            chatLabel.frame = CGRect(x: 50, y: 20, width: 200, height: 20)
//            if indexPath.row == 0{
//            chatLabel.text = "消息let cell tableView.dequeueReusableCell withIdentifier chat, for: indexPath chatTableViewCell"
//            }else{
//            chatLabel.text = "消息"
//            }
//            chatLabel.numberOfLines = 0
//            chatLabel.backgroundColor = UIColor.red
//            labelLayout(label: chatLabel)
//            cell.addSubview(namelabel)
//            cell.addSubview(chatLabel)
//        }
//        
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 200
//    }
//}


