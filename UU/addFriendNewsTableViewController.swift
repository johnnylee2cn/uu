//
//  addFriendNewsTableViewController.swift
//  UU
//
//  Created by admin on 2017/6/4.
//  Copyright © 2017年 L. All rights reserved.
//

import UIKit
import AVOSCloud

protocol reloadFriendList {
    func reloadToList(bool:Bool)
}

class addFriendNewsTableViewController: UITableViewController {

    @IBAction func back(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var userName:String! = ""//自己的名字
    var friendName:String! = ""//对方的名字
    var addFriendsAVObject:[AVObject] = []
    var objectID = ""
    var reloadDelege:reloadFriendList!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserName()
        self.navigationController?.isNavigationBarHidden = false
        self.tableView.tableFooterView = UIView()
        getDataFromCloud()
    }
    
    func getDataFromCloud(){
        let query = AVQuery(className: "addFriends")
        print("username\(userName)")
        query.whereKey("addFriendName", equalTo: userName!)
        query.findObjectsInBackground { (result, error) in
            if let results = result as? [AVObject]{
                self.addFriendsAVObject = results
                
                OperationQueue.main.addOperation {
                    self.tableView.reloadData()
                }
            }
        }
    }

    func getUserName(){
    let defaults = UserDefaults.standard
    let data = defaults.data(forKey: "name")
    userName = NSKeyedUnarchiver.unarchiveObject(with: data!) as! String
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return addFriendsAVObject.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let array = addFriendsAVObject[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "addFriendCell", for: indexPath) as! addFriendNewsTableViewCell

        cell.otherName.text = array["userName"] as? String


        //初始化DateFormatter类
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        //设置样式
        dateFormatter.dateStyle = DateFormatter.Style.short
        let date = array["createdAt"] as! Date
        let dateString = dateFormatter.string(from: date)
        cell.addTime.text = dateString
        
        let read = array["newsReadAlready"] as! Bool
        if read == false{
            cell.backgroundColor = UIColor.darkGray
            cell.statusLabel.text = "未查看"
        }else{
            cell.backgroundColor = UIColor.white
            cell.statusLabel.text = "已查看"
            cell.isUserInteractionEnabled = false
        }
        
        self.objectID = array["objectId"] as! String
        self.friendName = array["userName"] as? String
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let array = addFriendsAVObject[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "addFriendCell", for: indexPath) as! addFriendNewsTableViewCell
        cell.otherName.text = array["userName"] as? String
       
        
        //初始化DateFormatter类
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        //设置样式
        dateFormatter.dateStyle = DateFormatter.Style.short
        let date = array["createdAt"] as! Date
        let dateString = dateFormatter.string(from: date)
        cell.addTime.text = dateString

        cell.backgroundColor = UIColor.white
        cell.statusLabel.text = "已查看"
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let array = addFriendsAVObject[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "addFriendCell", for: indexPath) as! addFriendNewsTableViewCell
        let agree = UITableViewRowAction(style: .normal, title: "同意") { (_, indexPath) in
            let cloudObject = AVObject(className: "tripFriend")
            cloudObject["userName"] = self.userName
            cloudObject["friendName"] = self.friendName
            
            cloudObject.saveInBackground({ (success, error) in
                if success{
                    self.addSuccess(id: (array["objectId"] as? String)!,label:cell.statusLabel,indexPath: indexPath)
                }else{
                    print(error ?? "未知错误")
                }
            })
            
            let object = AVObject(className: "tripFriend")
            object["friendName"] = self.userName
            object["userName"] = self.friendName
            object.saveInBackground({ (_, _) in
                
            })
        }
        
        let refuse = UITableViewRowAction(style: .destructive, title: "拒绝") { (_, indexPath) in
                self.updateRead(indexPath: indexPath, label: cell.statusLabel, id: (array["objectId"] as? String)!)
        }
        
        return [agree,refuse]
    }

    func addSuccess(id:String,label:UILabel,indexPath:IndexPath){
        let actionSheet = UIAlertController(title: "添加好友", message: "添加好友成功", preferredStyle: .alert)
        
        let back = UIAlertAction(title: "确定", style: .cancel, handler: { (_) in
            let todo = AVObject(className: "addFriends", objectId: id)
            todo.setObject(true, forKey: "newsReadAlready")
            todo.saveInBackground { (success, error) in
                if success{
                    print("修改成功")
                    self.reloadDelege.reloadToList(bool: true)
                    self.getDataFromCloud()
                }else{
                    print("修改失败")
                }
            }
            label.text = "已添加"
            self.tableView.cellForRow(at: indexPath)?.isEditing = false
        })
        actionSheet.addAction(back)
        self.present(actionSheet, animated: true, completion: nil)

    }
    
    func updateRead(indexPath:IndexPath,label:UILabel,id:String){
            tableView.cellForRow(at: indexPath)?.isEditing = false
            label.text = "已拒绝"
            let todo = AVObject(className: "addFriends", objectId: id)
            todo.setObject(true, forKey: "newsReadAlready")
            todo.saveInBackground { (success, error) in
                if success{
                    print("修改成功")
                    self.getDataFromCloud()
                }else{
                    print("修改失败")
                }
            }

    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
