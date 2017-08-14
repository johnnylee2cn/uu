//
//  userInfoTableViewController.swift
//  UU
//
//  Created by admin on 2017/5/7.
//  Copyright © 2017年 L. All rights reserved.
//

import UIKit
import AVOSCloud

class userInfoTableViewController: UITableViewController,ageResult,addressResult {

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userSex: UILabel!
    @IBOutlet weak var userAge: UITextField!
    @IBOutlet weak var userAddress: UITextField!
    @IBOutlet weak var userNumber: UITextField!
    
    var name:String = ""
     var objectID:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserName()
        Thread.detachNewThread {
            self.getDataFromCloud()
        }
        
        
        self.tableView.tableFooterView = UIView()
        
        let rightButton = UIBarButtonItem(title: "保存", style: .plain, target: self, action: #selector(saveInfo))
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    //取得用户名
    func getUserName(){
        
        let defaults = UserDefaults.standard
        let str = defaults.data(forKey: "name")
        name = NSKeyedUnarchiver.unarchiveObject(with: str!) as! String
        userName.text = name
    }
    
    //年龄选择代理
    func ageSelect(age: String) {
        self.userAge.text = age
    }
    //地址选择代理
    func addressSelect(address: String) {
        self.userAddress.text = address
    }
    
    
    //MARK: - 与云端的交互
    //从云端拿数据
    func getDataFromCloud(){
        let result = AVQuery.doCloudQuery(withCQL: "select count(*) from userDetailInfo where userName = '\(name)' ")
        //如果查询没有结果，说明用户未填写过信息，需要创立一条，否则修改
        if result?.count == 1{
            let query = AVQuery(className: "userDetailInfo")
            query.whereKey("userName", equalTo: name)
            query.findObjectsInBackground({ (results, error) in
                if let rr = results as? [AVObject]{
                    self.userAge.text = rr[0]["userAge"] as? String
                    self.userSex.text = rr[0]["userSex"] as? String
                    self.userAddress.text = rr[0]["userAddress"] as? String
                    self.userNumber.text = rr[0]["userNumber"] as? String
                }
            })
        }
    }

    
    //保存数据到云端
    func saveInfo(){
        let result = AVQuery.doCloudQuery(withCQL: "select count(*) from userDetailInfo where userName = '\(name)' ")
        //如果查询没有结果，说明用户未填写过信息，需要创立一条，否则修改
        if result?.count != 1{
           makeDataToCloud()
        }else{
            updateDataForCloud()
        }
    }
    
    //创建数据
    func makeDataToCloud(){
        let objects = AVObject(className: "userDetailInfo")
        objects["userName"] = name
        objects["userSex"] = userSex.text
        objects["userAge"] = userAge.text
        objects["userAddress"] = userAddress.text
        objects["userNumber"] = userNumber.text
        objects.saveInBackground({ (success, error) in
            if success{
                print("保存云端成功")
                self.successToCloud()
            }else{
                print(error ?? "未知错误")
            }
        })
    }
    
    //修改数据
    func updateDataForCloud(){
       
        let query = AVQuery(className: "userDetailInfo")
        query.whereKey("userName", equalTo: name)
        query.findObjectsInBackground({ (results, error) in
            if let rr = results as? [AVObject]{
                self.objectID = rr[0]["objectId"] as! String
                self.updateData()
            }
        })

    }
    
    func updateData(){
        let sql = "update userDetailInfo set userSex = '\(self.userSex.text!)',userAge = '\(self.userAge.text!)',userAddress = '\(self.userAddress.text!)',userNumber = '\(self.userNumber.text!)' where userName = '\(self.name)' and objectId = '\(objectID)'"
                AVQuery.doCloudQueryInBackground(withCQL: sql, callback: { (result, error) in
                    if error == nil{
                        self.successToCloud()
                        print("修改成功")
                    }
                })
    }
    
    //保存成功提示
    func successToCloud(){
        let menu = UIAlertController(title: "提示", message: "", preferredStyle: .alert)
        let success = UIAlertAction(title: "保存成功", style: .cancel, handler: nil)
        menu.addAction(success)
        present(menu, animated: true, completion: nil)
    }
    //单元格点击事件
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0{
            if indexPath.row == 1{
        
                let actionSheet = UIAlertController(title: "选择", message: " ", preferredStyle: .actionSheet)
                let action = UIAlertAction(title: "男", style: .default, handler: { (_) in
                    self.userSex.text = "男"
                 actionSheet.dismiss(animated: true, completion: nil)
                })
                let action2 = UIAlertAction(title: "女", style: .default, handler: { (_) in
                    self.userSex.text = "女"
                    actionSheet.dismiss(animated: true, completion: nil)
                })
                actionSheet.addAction(action)
                actionSheet.addAction(action2)
                present(actionSheet, animated: true, completion: nil)
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAge"{
            let dest = segue.destination as! ageSelecteViewController
            dest.delegate = self
        }
         if segue.identifier == "toAddress"{
            let dest = segue.destination as! addressSelecteViewController
            dest.delegate = self
        }
    }
 }
