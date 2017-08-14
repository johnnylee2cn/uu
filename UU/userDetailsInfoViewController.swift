//
//  userDetailsInfoViewController.swift
//  UU
//
//  Created by admin on 2017/5/7.
//  Copyright © 2017年 L. All rights reserved.
//

import UIKit
import AVOSCloud

class userDetailsInfoViewController: UIViewController {

    var clickButton:Array<UIButton>! = [] //添加文本框右侧按钮
    var objectID:String! = ""
    var AVOSCloudArray:Array<AVObject> = []//接受云数据
    var isY = true
    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var newPwd: UITextField!
    @IBOutlet weak var pwdProblem: UITextField!
    @IBOutlet weak var pwdProblemAnswer: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textDelegate()
        getUserName()
    }
    
    override func viewDidLayoutSubviews() {
        makeLine()
    }
    
    //MARK: - 控件
    //  文本框下面的横线
    func makeLine(){
        //if isY == false{
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
       // }
        
       // self.isY = false
    }
    
    //文本框设置代理
    func textDelegate(){
        userName.delegate = self
        pwdProblemAnswer.delegate = self
        newPwd.delegate = self
        
        newPwd.isEnabled = true
        pwdProblem.isEnabled = false
        pwdProblemAnswer.isEnabled = false
    }
    
    //文本库旁边放置修改按钮
    func addImageView(){

        for _ in 0..<3{
            let button:UIButton! = UIButton()
            button.setTitle("修改", for: .normal)
           
            button.setTitleColor(UIColor.darkGray, for: .normal)
            self.view.addSubview(button)
            clickButton.append(button)
        }
        click(height: userName.bounds.height, width:userName.bounds.width)
    }

    //修改按钮的size和点击事件
    func click(height:CGFloat,width:CGFloat){
        clickButton[0].frame = CGRect(x: width + self.pwdProblem.frame.origin.x, y: self.pwdProblem.frame.origin.y, width: 38, height: height)
        clickButton[0].addTarget(self, action: #selector(updatePP), for: .touchUpInside)
        
        clickButton[1].frame = CGRect(x: width + self.pwdProblemAnswer.frame.origin.x , y: self.pwdProblemAnswer.frame.origin.y, width: 38, height: height)
        clickButton[1].addTarget(self, action: #selector(updatePPA), for: .touchUpInside)
        
        clickButton[2].frame = CGRect(x: width + self.newPwd.frame.origin.x , y: self.newPwd.frame.origin.y, width: 38, height: height)
        clickButton[2].addTarget(self, action: #selector(updatePwd), for: .touchUpInside)

    }
    //按钮响应的事件
    func updatePP(){
        updateToCloud(user: "userPwdProblem", str: pwdProblem.text!, textFieldName: "密保问题")
    }
    
    func updatePPA(){
        updateToCloud(user: "pwdProblemAnswer", str: pwdProblemAnswer.text!, textFieldName: "密保回答")
    }
    
    func updatePwd(){
        updateToCloud(user: "userPwd", str: newPwd.text!, textFieldName: "密码")
    }
    
    //MARK: - 与云端交互
    //初始化时取到原先数据
    func getUserName(){
        let defaults = UserDefaults.standard
        let objectData = defaults.data(forKey: "name")
        let name = NSKeyedUnarchiver.unarchiveObject(with: objectData!) as! String
        userName.text = name
        
        let query = AVQuery(className: "UserInfo")
        query.whereKey("userName", equalTo: name)
        query.findObjectsInBackground({ (results, error) in
            if let rr = results as? [AVObject]{
                self.AVOSCloudArray = rr
                let problem = rr[0]["pwdProblem"] as! String
                self.pwdProblem.text = problem
            }
        })
    }

    
    //修改数据
    func updateToCloud(user:String,str:String,textFieldName:String){
        let sql = "update UserInfo set \(user) = '\(str)' where userName = '\(userName.text!)' and objectId = '\(objectID!)'"
        AVQuery.doCloudQueryInBackground(withCQL: sql, callback: { (result, error) in
            if error == nil{
            let actionMenu = UIAlertController(title: "提示", message: "\(user)修改成功", preferredStyle: .alert)
                let back = UIAlertAction(title: "返回", style: .cancel, handler: nil)
                actionMenu.addAction(back)
                self.present(actionMenu, animated: true, completion: nil)
            }
        })

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
extension userDetailsInfoViewController:UITextFieldDelegate{
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case pwdProblemAnswer:
            verificationAnswer()
        case newPwd:
            let pwd = AVOSCloudArray[0]["userPwd"] as! String
            if newPwd.text == pwd{
                pwdProblemAnswer.isEnabled = true
                pwdProblemAnswer.placeholder = "请输入答案"
            }
        
        default:break
            
        }
    }
    //验证回答
    func verificationAnswer(){
        let answer = AVOSCloudArray[0]["pwdProblemAnswer"] as! String
        objectID = AVOSCloudArray[0]["objectId"] as! String
        if pwdProblemAnswer.text == answer{
            pwdProblem.isEnabled = true
            addImageView()
        }else{
            let menu = UIAlertController(title: "提示", message: "回答错误", preferredStyle: .alert)
            let back = UIAlertAction(title: "确定", style: .cancel, handler: nil)
            menu.addAction(back)
            present(menu, animated: true, completion: nil)
        }

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
