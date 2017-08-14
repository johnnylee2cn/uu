//
//  searchFriendsTableViewController.swift
//  UU
//
//  Created by admin on 2017/6/13.
//  Copyright © 2017年 L. All rights reserved.
//

import UIKit
import AVOSCloud

class searchFriendsTableViewController: UITableViewController,UISearchBarDelegate {

    var searchBar:UISearchBar!
    var resultsObject:[AVObject]! = []
    var name:String! = ""
    var count = 0
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        getName()
        self.tableView.tableFooterView = UIView()
        makeSearchView()
        searchBar.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getName(){
        let defaults = UserDefaults.standard
        let str = defaults.data(forKey: "name")
        name = NSKeyedUnarchiver.unarchiveObject(with: str!) as! String
    }
    
    func getSearchResultsData(){
        let query = AVQuery(className: "UserInfo")
        query.whereKey("userName", equalTo: searchBar.text)
        
        query.findObjectsInBackground { (result, error) in
            if let results = result as? [AVObject]{
                self.resultsObject = results
                OperationQueue.main.addOperation {
                    self.tableView.reloadData()
                }
            }else{
            let menu = UIAlertController(title: "查找好友", message: "没有找到此用户", preferredStyle: .alert)
            let back = UIAlertAction(title: "确定", style: .default, handler: nil)
            menu.addAction(back)
            self.present(menu, animated: true, completion: nil)
        }
    }
        
        
    }
    
    func makeSearchView(){
        searchBar = UISearchBar()
        self.searchBar.frame = CGRect(x: 0, y: 0, width: 250, height: 30)
        self.searchBar.placeholder = "查找好友"
       // searchBar.delegate = self
        self.tableView.tableHeaderView = searchBar
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        getSearchResultsData()
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        getSearchResultsData()
        return true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        getSearchResultsData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return resultsObject.count
    }

   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let value = resultsObject[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchFCell", for: indexPath) as! searchFriendsTableViewCell

       cell.friendNameLabel.text = value["userName"] as? String

        return cell
    }
   
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let sql = "select count(*) from tripFriend where friendName = '\(searchBar.text!)' and userName = '\(name!)'"
        let result = AVQuery.doCloudQuery(withCQL: sql)
        let addFriends = UITableViewRowAction(style: .normal, title: "添加") { (
            _, indexPath) in
            let actionSheet = UIAlertController(title: "添加好友", message: "确认添加对方为好友？", preferredStyle: .alert)
            let yes = UIAlertAction(title: "确定", style: .default) { (_) in
                
                if self.name == self.searchBar.text{
                    let actionMenu = UIAlertController(title: "提示", message:"用户不可以添加自己为好友" , preferredStyle: .alert)
                    let back = UIAlertAction(title: "返回", style: .cancel, handler: nil)
                    actionMenu.addAction(back)
                    self.present(actionMenu, animated: true, completion: nil)
                }else if result?.count != 0{
                    let actionMenu = UIAlertController(title: "提示", message:"该用户已是您的好友" , preferredStyle: .alert)
                    let back = UIAlertAction(title: "返回", style: .cancel, handler: nil)
                    actionMenu.addAction(back)
                    self.present(actionMenu, animated: true, completion: nil)

                }else{
                    let cloudObject = AVObject(className: "addFriends")
                    cloudObject["userName"] = self.name
                    cloudObject["addFriendName"] = self.searchBar.text
                    cloudObject.saveInBackground({ (succeed, error) in
                        if succeed{
                            print("保存成功")
                            let actionMenu = UIAlertController(title: "好友请求", message:"已发送好友请求" , preferredStyle: .alert)
                            let back = UIAlertAction(title: "确定", style: .cancel, handler: nil)
                            actionMenu.addAction(back)
                            self.present(actionMenu, animated: true, completion: nil)
                        }else{
                            print("保存失败")
                        }
                    })
                }
            
        }
            let back = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            
            actionSheet.addAction(yes)
            actionSheet.addAction(back)
            
            self.present(actionSheet, animated: true, completion: nil)

        }
        
        return [addFriends]
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
