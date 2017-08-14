//
//  contactPeopleTableViewController.swift
//  UU
//
//  Created by admin on 2017/6/2.
//  Copyright © 2017年 L. All rights reserved.
//

import UIKit
import AVOSCloud
import CoreData

class contactPeopleTableViewController: UITableViewController,UISearchBarDelegate,UISearchResultsUpdating,reloadFriendList {

    var searchBar:UISearchBar!
    var name:String! = ""
    var friendName:String! = ""
    var objectId:String! = ""
    var sc:UISearchController!
    
    //搜索账户
    var searchAVObject:[AVObject] = []
    var searchVCResult:[AVObject] = []
    
    //好友列表
    var friendListAVObject:[AVObject] = []
    var searchFLResult:[AVObject] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getFriendListDataFromCloud()
        self.tableView.tableFooterView = UIView()
        getDataFromCloud()
        searchJump()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "好友请求", style: .plain, target: self, action: #selector(friendrequest))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func reloadToList(bool: Bool) {
        if bool == true{
             getFriendListDataFromCloud()
        }
    }
    
    //按条件查找数据
    func getBadgeCount(label:UILabel,friendName:String){
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest()
        fetchRequest.fetchLimit = 20
        fetchRequest.fetchOffset = 0
        
        let entity:NSEntityDescription = NSEntityDescription.entity(forEntityName: "ChatHistory", in: context)!
        fetchRequest.entity = entity
        
        let predicate = NSPredicate.init(format: "you = '\(name!)' and me = '\(friendName)' and readAlready = false", "")
        fetchRequest.predicate = predicate
        
        do {
            let result = try delegate.persistentContainer.viewContext.fetch(fetchRequest) as! [ChatHistory]
            print("count\(result.count)")
            if result.count != 0{
                label.isHidden = false
                label.text = "\(result.count)"
            }else{
                label.isHidden = true
                label.text = "9"
            }
        } catch  {
            print(error)
        }
        
    }

    
    //跳转好友请求
    func friendrequest(){
        let sb = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "friendRequest") as! addFriendNewsTableViewController
        vc.reloadDelege = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //搜索框
    func searchJump(){
        sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.dimsBackgroundDuringPresentation = false //搜索条背景不变暗
        sc.hidesNavigationBarDuringPresentation = false
        sc.searchBar.delegate = self
        tableView.tableHeaderView = sc.searchBar
        
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "searchView")
        self.present(vc, animated: true, completion: nil)
        return true
    }
    
    func getUserImage(userName:String,imageView:UIImageView){
        var headImageData = UIImage()
        let query = AVQuery(className: "UserInfo")
        query.whereKey("userName", equalTo: userName)
        query.findObjectsInBackground { (results, error) in
            OperationQueue.main.addOperation {
                if let result = results as? [AVObject]{
                    if let imgFile = result[0]["headImage"] as? AVFile{
                        imgFile.getDataInBackground({ (data, error) in
                            let imageData = NSKeyedUnarchiver.unarchiveObject(with: data!) as! UIImage
                            headImageData = imageData
                            imageView.image = headImageData
                        })
                    }else{
                        imageView.image = UIImage(named: "头")
                    }
                }
            }
        }
        
    }

    func searchFilter(text:String){
        searchVCResult = searchAVObject.filter({ (avobject) -> Bool in
        return (avobject["userName"] as! String).localizedCaseInsensitiveContains(text)
        })
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if var text = searchController.searchBar.text{
            text = text.trimmingCharacters(in: .whitespaces)
            searchFilter(text: text)
            tableView.reloadData()
        }
    }
    
    //搜寻好友数据
    func getDataFromCloud(){
        let query = AVQuery(className: "tripFriend")
        query.order(byDescending: "createdAt")
        
        query.findObjectsInBackground { (result, error) in
            if let results = result as? [AVObject]{
                self.searchAVObject = results
                OperationQueue.main.addOperation {
                    self.refreshControl?.endRefreshing()
                    self.tableView.reloadData()
                }
            }else{
                print(error ?? "未知错误")
            }
        }
    }
    
    //查找好友列表数据
    func getFriendListDataFromCloud(){
        let defaults = UserDefaults.standard
        let data = defaults.data(forKey: "name")
        name = NSKeyedUnarchiver.unarchiveObject(with: data!) as! String
        
        let query = AVQuery(className: "tripFriend")
        query.whereKey("userName", equalTo: name)
        query.order(byDescending: "createdAt")
        
        query.findObjectsInBackground { (result, error) in
            if let results = result as? [AVObject]{
                self.friendListAVObject = results
                OperationQueue.main.addOperation {
                    self.refreshControl?.endRefreshing()
                    self.tableView.reloadData()
                }
            }else{
                print(error ?? "未知错误")
            }
        }
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
        return friendListAVObject.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let array = friendListAVObject[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendList", for: indexPath) as! contactPeopleTableViewCell
       
        cell.friendNameLabel.text = array["friendName"] as? String
        
        getBadgeCount(label: cell.badgeLabel, friendName: (array["friendName"] as? String)!)
        getUserImage(userName: (array["friendName"] as? String)!, imageView: cell.headImage)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let array = friendListAVObject[indexPath.row]
        friendName = array["friendName"] as? String
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        updateData(FriendName: friendName)
    }
    
    //修改数据
    func updateData(FriendName:String){
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "ChatHistory")
        fetchRequest.fetchLimit = 20
        fetchRequest.fetchOffset = 0
        
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: "ChatHistory", in: context)
        fetchRequest.predicate = NSPredicate.init(format: "you = '\(name!)' and me = '\(FriendName)' and readAlready = false", "")
        do{
            
            let listData = try delegate.persistentContainer.viewContext.fetch(fetchRequest) as! [ChatHistory]
           
            for value in listData{
                value.readAlready = true
             }
            delegate.saveContext()
            self.tableView.reloadData()
        }catch{
            print("修改失败 ~ ~")
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chatView"{
            let dest = segue.destination as! chatViewController
            dest.youName = friendName
        }
    }
}
