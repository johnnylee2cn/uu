//
//  forgetPwdViewController.swift
//  UU
//
//  Created by admin on 2017/5/7.
//  Copyright © 2017年 L. All rights reserved.
//

import UIKit
import AVOSCloud
import SnapKit

class forgetPwdViewController: UIViewController {
    var buttonBarRight:UIBarButtonItem!
    var objectID:String!
    var imgArray:Array<UIImageView>! = []
    var value:Array<AVObject> = []
    var isY = true
    @IBOutlet weak var userName: UITextField!//用户名
    @IBOutlet weak var newPwd: UITextField!//新密码
    @IBOutlet weak var confirm: UITextField!//确认密码
    @IBOutlet weak var pwdProblem: UITextField!//密保问题
    @IBOutlet weak var pwdProblemAnswer: UITextField!//密保回答

    
     
    override func viewDidLoad() {
        super.viewDidLoad()
        //不隐藏导航栏
        self.navigationController?.isNavigationBarHidden = false
        
        
        
        //添加导航栏右侧修改按钮
        buttonBarRight = UIBarButtonItem(title: "修改", style: .plain, target: self, action: #selector(saveUserInfo))
        self.navigationItem.rightBarButtonItem = buttonBarRight
        
        textFieldDelegate()
        userName.placeholder = "请先输入用户名"
        addImageView()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        self.confirm.frame.size = self.userName.frame.size
        makeLine()
        
//        self.confirm.snp.makeConstraints { (make) in
//            make.bottom.equalTo(-(height/2.9))
//        }
//            self.confirm.updateConstraintsIfNeeded()
//        
    }
    
    //MARK: - 文本框的设置
    
    //设置文本框代理
    func textFieldDelegate(){
        userName.delegate = self
        pwdProblemAnswer.delegate = self
        newPwd.delegate = self
        confirm.delegate = self
        newPwd.isEnabled = false
        confirm.isEnabled = false
        pwdProblemAnswer.isEnabled = false

        
    }
    
    // 文本框的按钮
    func makeLine(){
       // if isY == false{
        let line = lineView()
        line.frame = CGRect(x: self.userName.frame.minX, y: self.userName.frame.maxY, width: self.userName.bounds.width, height: 2)
        self.view.addSubview(line)
        
        let line2 = lineView()
        line2.frame = CGRect(x: self.pwdProblem.frame.minX, y: self.pwdProblem.frame.maxY, width: self.pwdProblem.bounds.width, height: 2)
        self.view.addSubview(line2)
        
        let line3 = lineView()
        line3.frame = CGRect(x: self.pwdProblemAnswer.frame.minX, y: self.pwdProblemAnswer.frame.maxY, width: self.pwdProblemAnswer.bounds.width, height: 2)
        self.view.addSubview(line3)
        
        let line4 = lineView()
        line4.frame = CGRect(x: self.newPwd.frame.minX, y: self.newPwd.frame.maxY, width: self.newPwd.bounds.width, height: 2)
        self.view.addSubview(line4)
        
        let line5 = lineView()
        line5.frame = CGRect(x: self.confirm.frame.minX, y: self.confirm.frame.maxY, width: self.confirm.bounds.width, height: 2)
        self.view.addSubview(line5)
       // }
        //self.isY = false
    }
    
    //文本框右侧添加提示图片
    func addImageView(){
    
        let height = userName.bounds.height
        let width = userName.bounds.width
        var count = 0
        
        while count < 3{
            let imgView:UIImageView! = UIImageView()
            self.view.addSubview(imgView)
            imgArray.append(imgView)
            count = count + 1
        }
        imageViewSize(width: width, height: height)
    }
    
    //图片frame
    func imageViewSize(width:CGFloat,height:CGFloat){
        
        imgArray[0].frame = CGRect(x: width + self.pwdProblemAnswer.frame.origin.x, y: self.pwdProblemAnswer.frame.origin.y, width: 38, height: height)
        imgArray[1].frame = CGRect(x: width + self.newPwd.frame.origin.x , y: self.newPwd.frame.origin.y, width: 38, height: height)
        imgArray[2].frame = CGRect(x: width + self.confirm.frame.origin.x , y: self.confirm.frame.origin.y, width: 38, height: height)
    }
    
    //修改云端数据
    func saveUserInfo(){
        if confirm.text != "" && confirm.text == newPwd.text{
            let sql = "update UserInfo set userPwd = '\(confirm.text!)' where userName = '\(userName.text!)' and objectId = '\(objectID!)'"
            AVQuery.doCloudQueryInBackground(withCQL: sql, callback: { (result, error) in
                if error == nil{
                    self.successToCloud()
 
                }
            })
        }
    }

    func successToCloud(){
        let menu = UIAlertController(title: "修改成功", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "确定", style: .default) { (_) in
            self.navigationController?.popToRootViewController(animated: true)
        }
        menu.addAction(action)
        present(menu, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension forgetPwdViewController:UITextFieldDelegate{
       func textFieldDidEndEditing(_ textField: UITextField) {
        
        switch textField {
        case userName:
            let name = userName.text!
            let result = AVQuery.doCloudQuery(withCQL: "select count(*) from UserInfo where userName = '\(name)' ")
            //判断用户名是否注册
            if result?.count == 0{
                notRegistered()
            }else{
                getProblem(name:name)
            }
            //判断回答是否正确
        case pwdProblemAnswer:
            answerVerification()
            
        case newPwd:
            //判断密码框是否输入
            if newPwd.text == ""{
                
                self.imgArray[1].image = UIImage(named: "叉-2")
                
            }else{
                self.imgArray[1].image = UIImage(named: "勾")
                
            }
            //判断确认密码是否与密码一致
        case confirm:
            let width = textField.bounds.width
            let height = textField.bounds.height
            samePWD(width:width,height:height)
        default:break
        }
     }
    
     //未注册提示
    func notRegistered(){
        let actionSheet = UIAlertController(title: "提示", message: "用户名未注册", preferredStyle: .alert)
                let action = UIAlertAction(title: "确定", style: .cancel, handler: nil)
                actionSheet.addAction(action)
                self.present(actionSheet, animated: true, completion: nil)
    }
    
    //通过用户名得到密保问题
    func getProblem(name:String){
       
        let query = AVQuery(className: "UserInfo")
        query.whereKey("userName", equalTo: name)
        query.findObjectsInBackground({ (results, error) in
            if let rr = results as? [AVObject]{
                self.value = rr
                let problem = self.value[0]["pwdProblem"] as! String
                
                self.pwdProblem.text = problem
                self.pwdProblem.isEnabled = false
                self.pwdProblemAnswer.isEnabled = true
            }else{
                print(error ?? "未知错误")
            }
        })

    }
    
    //验证回答
    func answerVerification(){
        let problem = value[0]["pwdProblemAnswer"] as! String
        self.objectID = value[0]["objectId"] as! String
        if self.pwdProblemAnswer.text == problem{
            self.imgArray[0].image = UIImage(named: "勾")
            self.newPwd.isEnabled = true
            self.confirm.isEnabled = true
            self.newPwd.placeholder = "请输入密码"
            self.confirm.placeholder = "请再次输入密码"
            
        }else{
            self.imgArray[0].image = UIImage(named: "叉-2")
            return
        }

    }
    
    //验证两次密码是否一致
    func samePWD(width:CGFloat,height:CGFloat){
        
            let imgView:UIImageView! = UIImageView()
            imgView.frame = CGRect(x: width + confirm.frame.origin.x , y: newPwd.frame.origin.y, width: 38, height: height)
            
            if confirm.text == newPwd.text{
                self.imgArray[2].image = UIImage(named: "勾")
                
            }else{
                self.imgArray[2].image = UIImage(named: "叉-2")
                
            }

    }

    //点击空白区域关闭键盘
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
