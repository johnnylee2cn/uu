//
//  registeredViewController.swift
//  UU
//
//  Created by admin on 2017/3/14.
//  Copyright © 2017年 L. All rights reserved.
//

import UIKit
import CoreData
import AVOSCloud

class registeredViewController: UIViewController {

    var login:UsersLoginInfo!
    var imageViewArray:Array<UIImageView>! = []
    var isY:Bool = true
    
    @IBOutlet weak var prompt: UILabel!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var pwdtwice: UITextField!
    @IBOutlet weak var pwd: UITextField!
    @IBOutlet weak var pwdProblem: UITextField!
    @IBOutlet weak var pwdProblemAnswer: UITextField!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //添加一个导航栏右侧注册按钮
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "注册", style: .plain, target: self, action: #selector(saveToCloud))
        
        imageView()
        textEidting()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        madeLine()
    }
    
    //文本框下面的线条
    func madeLine(){
        
       // if isY == false{
        let line = lineView()
        line.frame = CGRect(x: self.name.frame.minX, y: self.name.frame.maxY, width: self.name.bounds.width, height: 2)
        self.view.addSubview(line)
        
        let line2 = lineView()
        line2.frame = CGRect(x: self.pwd.frame.minX, y: self.pwd.frame.maxY, width: self.name.bounds.width, height: 2)
        self.view.addSubview(line2)
        
        let line3 = lineView()
        line3.frame = CGRect(x: self.pwdtwice.frame.minX, y: self.pwdtwice.frame.maxY, width: self.name.bounds.width, height: 2)
        self.view.addSubview(line3)
        
        let line4 = lineView()
        line4.frame = CGRect(x: self.pwdProblem.frame.minX, y: self.pwdProblem.frame.maxY, width: self.name.bounds.width, height: 2)
        self.view.addSubview(line4)
        
        let line5 = lineView()
        line5.frame = CGRect(x: self.pwdProblemAnswer.frame.minX, y: self.pwdProblemAnswer.frame.maxY, width: self.name.bounds.width, height: 2)
        self.view.addSubview(line5)
        //}
      //  self.isY = false
    }
    
    
    
    //每个文本框右侧放一个图片框
    func imageView(){
        let textFieldwidth = name.bounds.width
        let textFieldheight = name.bounds.height
        var count = 0
        while count < 5{
            let imageView:UIImageView = UIImageView()
            imageViewArray.append(imageView)
            self.view.addSubview(imageView)
            count = count + 1
        }
        imageViewFrame(width: textFieldwidth, height: textFieldheight)
        
    }
    
    //图片框的位置
    func imageViewFrame(width:CGFloat,height:CGFloat){
    //图片框的位置
        imageViewArray[0].frame = CGRect(x: name.frame.origin.x+3+width,  y: name.frame.origin.y , width: 38, height: height)
        imageViewArray[1].frame = CGRect(x: pwd.frame.origin.x+3+width,  y: pwd.frame.origin.y , width: 38, height: height)
        imageViewArray[2].frame = CGRect(x: pwdtwice.frame.origin.x+3+width,  y: pwdtwice.frame.origin.y , width: 38, height: height)
        imageViewArray[3].frame = CGRect(x: pwdProblem.frame.origin.x+3+width,  y: pwdProblem.frame.origin.y , width: 38, height: height)
        imageViewArray[4].frame = CGRect(x: pwdProblemAnswer.frame.origin.x+3+width,  y: pwdProblemAnswer.frame.origin.y , width:38, height: height)
    }

    //设置文本框代理
    func textEidting(){
        name.delegate = self
        pwd.delegate = self
        pwdtwice.delegate = self
        pwdProblem.delegate = self
        pwdProblemAnswer.delegate = self
    }

    //MARK: - 跟云服务器交互
    
    func saveToCloud(){
        let query = AVQuery(className: "UserInfo")
        query.whereKey("userName", equalTo: name.text ?? "")
        let result =  query.findObjects()
        
        // 结果判断，如果！=1说明用户名未注册
        if result?.count == 0 && pwd.text == pwdtwice.text{
            saveData()
        }else{
            prompt.text = "用户名已被用或者两次密码输入不正确"
        }
    }
    
    //保存数据步骤
    func saveData(){
        let cloudObject = AVObject(className: "UserInfo")
        cloudObject["userName"] = name.text
        cloudObject["userPwd"] = pwd.text
        cloudObject["pwdProblem"] = pwdProblem.text
        cloudObject["pwdProblemAnswer"] = pwdProblemAnswer.text
        let headImage = UIImage(named: "头")
        let data = NSKeyedArchiver.archivedData(withRootObject: headImage ?? "") as NSData
        let file = AVFile(name: name.text, data: data as Data)
        cloudObject["headImage"] = file
        cloudObject.saveInBackground { (succeed, error) in
            if succeed{
                print("保存云端成功")
                self.successToCloud()
            }else{
                print(error ?? "未知错误")
            }
        }

    }
    
    //保存成功提示
    func successToCloud(){
        let menu = UIAlertController(title: "注册成功", message: "", preferredStyle: .alert)
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

extension registeredViewController:UITextFieldDelegate{
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //判断文本框是否为空，两次密码是否相同
        if textField.text == ""{
            for value in imageViewArray{
                if value.frame.origin.y == textField.frame.origin.y{
                    value.image = UIImage(named: "叉-2")
                }
            }
        }else if textField == pwdtwice && pwdtwice.text != pwd.text{
            for value in imageViewArray{
                if value.frame.origin.y == textField.frame.origin.y{
                    value.image = UIImage(named: "叉-2")
                }
            }
        }else if textField == pwd && pwd.text == pwdtwice.text{
            for value in imageViewArray{
                if value.frame.origin.y == textField.frame.origin.y||value.frame.origin.y == pwdtwice.frame.origin.y{
                    value.image = UIImage(named: "勾")
                }
            }
        }else{
            for value in imageViewArray{
                if value.frame.origin.y == textField.frame.origin.y{
                    value.image = UIImage(named: "勾")
                }
            }
        }
    }
    
    //点击空白区域，关闭键盘
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
