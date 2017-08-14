//
//  HomeViewController.swift
//  UU
//
//  Created by admin on 2017/3/14.
//  Copyright © 2017年 L. All rights reserved.
//

import UIKit
import CoreData
import AVOSCloud
import TZImagePickerController
import Kingfisher

class HomeViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,TZImagePickerControllerDelegate{

    
    
    @IBAction func myFriendButton(_ sender: UIButton) {
        friendLoad = true
    }
    
    @IBOutlet weak var UserName: UILabel!
    @IBOutlet weak var aboveView: UIView!//表层view
    @IBOutlet weak var badgeLabel: UILabel!
    
    @IBOutlet weak var labelTopLayoutConstrint: NSLayoutConstraint!
    @IBOutlet weak var labelLeadingLayoutConstrint: NSLayoutConstraint!
    @IBOutlet weak var labelTrailingLayoutConstrint: NSLayoutConstraint!
    @IBOutlet weak var labelBottomLayoutConstrint: NSLayoutConstraint!
//    @IBOutlet weak var labelTopLayoutConstrint: NSLayoutConstraint!
//    
//    @IBOutlet weak var labelLeadingLayoutConstrint: NSLayoutConstraint!
//    
//    @IBOutlet weak var labelTrailingLayoutConstrint: NSLayoutConstraint!
//    
//    @IBOutlet weak var labelBottomLayoutConstrint: NSLayoutConstraint!
    
    //@IBOutlet weak var labelTopLayoutConstrint: NSLayoutConstraint!
    //@IBOutlet weak var labelLeadingLayoutConstrint: NSLayoutConstraint!
   // @IBOutlet weak var labelTrailingLayoutConstrint: NSLayoutConstraint!
  
  //  @IBOutlet weak var labelBottomLayoutConstrint: NSLayoutConstraint!
    
//    @IBOutlet weak var labelTopLayoutConstrint: NSLayoutConstraint!
//    @IBOutlet weak var labelLeadingLayoutConstrint: NSLayoutConstraint!
//    @IBOutlet weak var labelTrailingLayoutConstrint: NSLayoutConstraint!
//    @IBOutlet weak var labelBottomLayoutConstrint: NSLayoutConstraint!
    
    @IBOutlet weak var goText: UILabel!
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var topView: UIView!

    
    //label约束
    var labelTopLayoutConstant: CGFloat!
    var labelLeadingLayoutConstant: CGFloat!
    var labelTrailingLayoutConstant: CGFloat!
    var labelBottomLayoutConstant: CGFloat!
    
    var viewFrameY:CGFloat!
    var viewFrameX:CGFloat!
    var buttomview:UIView!
    var cancelButton:UIButton!
    
    var swipeLeft:UISwipeGestureRecognizer!//左滑
    var swipeRinght:UISwipeGestureRecognizer!//右滑

    var flag = 0
    var re:Bool!
    var friendLoad = false
    var name = ""
    
    var imagecount = 4
    
    var headImage:UIButton!
    var headImageData:UIImage!
    var objectId:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.aboveView.frame.size = CGSize(width: width, height: height)
        self.topView.frame.size = self.aboveView.frame.size
        
        self.bgImage.frame.size = CGSize(width: width, height: height)
        self.aboveView.backgroundColor = UIColor.init(red: 65/245, green: 65/225, blue: 65/225, alpha: 1)
        getUserName()
        naviLeftButton()
        swipe2()
        cView()
        translucentView()
      //  getChatNewsCount()
        getUserImage()
            }
    
    override func viewWillAppear(_ animated: Bool) {
    
        if friendLoad == true{
         //   getChatNewsCount()
            friendLoad = false
        }
    }

    //MARK: - 主页面的view
    //主页面半透明view
    func translucentView(){
        topView.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 0.3)
       
    }
    
    //导航栏左侧按钮
    func naviLeftButton(){
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named:"侧滑导航"), style: .plain, target:self , action: #selector(swipeButton))
    }
    
    //MARK: - 主页面控件设置
    //聊天信息提示红点
    func slideLabel(sender:UIPanGestureRecognizer){
        //开始的状态
        if sender.state == .began{
            viewFrameY = sender.view?.frame.origin.y
            viewFrameX = sender.view?.frame.origin.x
            
        }else if sender.state == .changed{
            //当状态变化
            senderChange(sender:sender)
        }else if sender.state == .ended{
            UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
                () -> Void in
                self.badgeLabel.frame.origin.y = self.viewFrameY
                self.badgeLabel.frame.origin.x = self.viewFrameX
            }, completion: { (success) -> Void in
                if success {
                    self.senderEnd()
                }
            })
            return
        }
    }
    
    //状态改变
    func senderChange(sender:UIPanGestureRecognizer){
        let y1 = sender.translation(in: sender.view?.superview).y
        
        labelTopLayoutConstrint.constant = labelTopLayoutConstant + y1
        labelBottomLayoutConstrint.constant = labelBottomLayoutConstant - y1
        
        
        let x1 = sender.translation(in: sender.view?.superview).x
        labelLeadingLayoutConstrint.constant = labelLeadingLayoutConstant + x1
        labelTrailingLayoutConstrint.constant = labelTrailingLayoutConstant - x1
        

    }
    
    //滑动结束
    func senderEnd(){
        //回弹动画结束后恢复默认约束值
                    self.labelTopLayoutConstrint.constant = self.labelTopLayoutConstant
                    self.labelLeadingLayoutConstrint.constant = self.labelLeadingLayoutConstant
                    self.labelTrailingLayoutConstrint.constant = self.labelTrailingLayoutConstant
                    self.labelBottomLayoutConstrint.constant = self.labelBottomLayoutConstant
                    self.badgeLabel.isHidden = true
    }
    
    //设置badge状态
    func getChatNewsCount(){
        badgeLabel.layer.cornerRadius = 8
        badgeLabel.clipsToBounds = true
        badgeLabel.textAlignment = NSTextAlignment.center
        badgeLabel.isUserInteractionEnabled = true
        
        let tap = UIPanGestureRecognizer(target: self, action: #selector(slideLabel))
        badgeLabel.addGestureRecognizer(tap)
        labelTopLayoutConstant = labelTopLayoutConstrint.constant
        labelBottomLayoutConstant = labelBottomLayoutConstrint.constant
        labelLeadingLayoutConstant = labelLeadingLayoutConstrint.constant
        labelTrailingLayoutConstant = labelTrailingLayoutConstrint.constant
        getData()
    }

    //  未收到的消息数量
    func getData(){
    
        let appdelegata = UIApplication.shared.delegate as! AppDelegate
        let context = appdelegata.persistentContainer.viewContext
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest()
        fetchRequest.fetchLimit = 20
        fetchRequest.fetchOffset = 0
        
        let entity:NSEntityDescription = NSEntityDescription.entity(forEntityName: "ChatHistory", in: context)!
        fetchRequest.entity = entity
        
        let predicate = NSPredicate.init(format: "you = '\(name)' and readAlready = false", "")
        fetchRequest.predicate = predicate
        
        do {
            let result = try context.fetch(fetchRequest) as! [ChatHistory]
            self.tabBarItem.badgeValue = "\(result.count)"
            if result.count != 0{
                badgeLabel.isHidden = false
                badgeLabel.text = "\(result.count)"
            }else{
                badgeLabel.isHidden = true
            }
           
        } catch  {
            print(error)
        }

    }
    
    
    //滑动事件
    func swipe2() {
        swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(HomeViewController.swipe(_:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.aboveView.addGestureRecognizer(swipeLeft)
        
        swipeRinght = UISwipeGestureRecognizer(target: self, action: #selector(HomeViewController.swipe(_:)))
        swipeRinght.direction = UISwipeGestureRecognizerDirection.right
        self.aboveView.addGestureRecognizer(swipeRinght)
    }
    
    //监听的方法
    func swipe(_ recognizer:UISwipeGestureRecognizer) {
        if recognizer.direction == UISwipeGestureRecognizerDirection.left{
            swipeToRight()
        }else if recognizer.direction == UISwipeGestureRecognizerDirection.right{
            swipeToLeft()
        }
    }
    
    //导航栏左侧按钮事件
    func swipeButton(){
        if self.aboveView.center.x == width/2{
            swipeToLeft()
        }else{
            swipeToRight()
        }
    }

    //右滑动画
    func swipeToRight(){
        UIView.animate(withDuration: 0.5, animations: {
                if self.flag % 2 != 0{
                    self.aboveView.center.x = width/2
                    self.buttomview.frame.origin.x = -120
                    self.flag += 1
                }
            })
    }
    
    //左滑动画
    func swipeToLeft(){
        UIView.animate(withDuration: 0.5, animations: {
                if self.flag % 2 == 0{
                    self.aboveView.center.x = width/2+120
                    self.buttomview.frame.origin.x = 0
                    self.flag += 1
                }
            })
    }
    //侧栏view and 侧栏控件
    func cView() {
        buttomview = UIView()
        buttomview.frame = CGRect(x: -120, y: 0, width: 120, height: self.view.bounds.height)
        buttomview.backgroundColor = UIColor.gray
        
        setHeadImage()
        setCancel()
        setUserInfo()
        setUpdatePWD()
        
        
        buttomview.addSubview(cancelButton)
        
        
        self.view.addSubview(buttomview)
    }
    
    //设置头像
    func setHeadImage(){
    
        headImage = UIButton()
        headImage.frame = CGRect(x: 25, y: 30, width:50, height: 50)
        headImage.layer.cornerRadius = 25
        headImage.clipsToBounds = true
        headImage.setImage(UIImage(named:"头"), for: .normal)
        
        headImage.addTarget(self, action: #selector(selectHeadImage), for: .touchUpInside)
        headImage.backgroundColor = UIColor.white
        buttomview.addSubview(headImage)
    }
    
    //设置重新登录
    func setCancel(){
        cancelButton = UIButton()
        cancelButton.frame = CGRect(x: 20, y: 80, width: 70, height: 50)
        cancelButton.setTitle("重新登录", for: .normal)
        
        let image = UIImage(named: "退出-2")
        cancelButton.setImage(image, for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        cancelButton.addTarget(self, action: #selector(b), for: .touchUpInside)
    }
    
    //设置个人信息
    func setUserInfo(){
        let userButton = UIButton(frame: CGRect(x: 20, y: 110, width: 70, height: 50))
        let image2 = UIImage(named: "个人信息-3")
        userButton.setImage(image2, for: .normal)
        userButton.setTitle("个人信息", for: .normal)
        userButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        userButton.addTarget(self, action: #selector(userInfo), for: .touchUpInside)
        buttomview.addSubview(userButton)
    }
    
    //设置修改密码
    func setUpdatePWD(){
        
        let updatePwdButton = UIButton(frame: CGRect(x: 20, y: 140, width: 70, height: 50))
        let image3 = UIImage(named: "个人信息-3")
        updatePwdButton.setImage(image3, for: .normal)
        updatePwdButton.setTitle("修改密码", for: .normal)
        updatePwdButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        updatePwdButton.addTarget(self, action: #selector(updatePwd), for: .touchUpInside)
        buttomview.addSubview(updatePwdButton)
    }
    
    //使用userdefault得到登录名
    func getUserName() {
        let defaults = UserDefaults.standard
        let objectData = defaults.data(forKey: "name")
         self.name = NSKeyedUnarchiver.unarchiveObject(with: objectData!) as! String
        UserName.text = "『" + name + "』"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - 头像
    func getUserImage(){
        let query = AVQuery(className: "UserInfo")
        
        query.whereKey("userName", equalTo: name)
        query.findObjectsInBackground { (results, error) in
            OperationQueue.main.addOperation {
             if let result = results as? [AVObject]{
                for value in result{
                    self.objectId = value["objectId"] as? String
                    if let imgFile = value["headImage"] as? AVFile{
                         imgFile.getDataInBackground({ (data, error) in
                          let imageData = NSKeyedUnarchiver.unarchiveObject(with: (data)!) as! UIImage
                            //self.setHeadImage()
                            self.headImageData = imageData
                            self.headImage.setImage(self.headImageData, for: .normal)
                          
                     })
                  }

                }
                }
            }
        }
        
    }
    
    
    func selectHeadImage(){
        let actionSheet = UIAlertController(title: "添加图片", message: "", preferredStyle: .actionSheet)
        let image = UIAlertAction(title: "打开相册", style: .default) { (_) in
            self.openLibrary()
        }
        let camera = UIAlertAction(title: "打开相机", style: .default) { (_) in
            self.openCamera()
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        actionSheet.addAction(image)
        actionSheet.addAction(camera)
        actionSheet.addAction(cancel)
        
        present(actionSheet, animated: true, completion: nil)

    }
    
    //打开相册
    func openLibrary(){
        let photoBrowser = TZImagePickerController(maxImagesCount: 1, delegate: self)
        present(photoBrowser!, animated: true, completion: nil)
    }
    //打开相机
    func openCamera(){
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            return
        }
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.sourceType = .camera
        picker.delegate = self
    }
    
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool, infos: [[AnyHashable : Any]]!) {
        self.headImageData = photos[0]
        self.headImage.setImage(self.headImageData, for: .normal)
                let value = NSKeyedArchiver.archivedData(withRootObject: photos[0]) as NSData
                let imgFile = AVFile(name: name, data: value as Data)
                let object = AVObject(className: "UserInfo", objectId: objectId!)
        
                object.setObject(imgFile, forKey: "headImage")
                object.saveInBackground { (success, error) in
                    if success{
                        print("保存成功")
                    }else{
                        print(error ?? "未知原因")
                    }
                }

        
    }
    
    func tz_imagePickerControllerDidCancel(_ picker: TZImagePickerController!) {
        picker.dismiss(animated: true, completion: nil)
    }

    //MARK: - 跳转到各页面
    func b(){
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "loginView")
        self.present(vc, animated: true, completion: nil)
       
    }
    
    //修改密码的跳转
    func updatePwd()  {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "detailInfo")
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //个人信息
    func userInfo(){
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "Info")
    
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func deleteDefault(){
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "name")
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//       
//    }
   

}


