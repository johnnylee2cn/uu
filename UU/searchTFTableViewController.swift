//
//  searchTFTableViewController.swift
//  UU
//
//  Created by admin on 2017/5/16.
//  Copyright © 2017年 L. All rights reserved.
//

import UIKit
import AVOSCloud
import FTIndicator
import Kingfisher
import DGElasticPullToRefresh
import MJRefresh


 class searchTFTableViewController: UITableViewController,UISearchResultsUpdating,reloadView ,reloadComment,UISearchBarDelegate,dataToSearchTF{

    var searchVCResult:[searchModel] = []
    var array:[searchModel] = []
    var name:String = ""
    var friendName:String! = ""
    var objectIDArray:Array<String> = []
    var sc:UISearchController!
    var searchBar:UISearchBar!
    var reload = false
    var myView = MyView()
    var indexPathRow = 0
    var commentCount = 0
    let loadingView = DGElasticPullToRefreshLoadingViewCircle()//下拉刷新动画
    let footer = MJRefreshAutoNormalFooter()
    var likeModel:Array<Int> = []//点赞数量
    var skip = 0
    var activity = UIActivityIndicatorView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        loadingView.tintColor = UIColor(red: 78/255.0, green: 221/255.0, blue: 200/255.0, alpha: 1.0)
        loadingView.startAnimating()
        
        tableView.dg_addPullToRefreshWithActionHandler({
            //逻辑代码
            self.refreshData()
            self.tableView.dg_stopLoading()
        }, loadingView: loadingView)
        
        //颜色
        tableView.dg_setPullToRefreshFillColor(UIColor(red: 57/255.0, green: 67/255.0, blue: 89/255.0, alpha: 1.0))
        tableView.dg_setPullToRefreshBackgroundColor(tableView.backgroundColor!)
        
        getUserName()
         self.refreshData()
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "ojID")
        getSearchView()
        
       
        tableView.isScrollEnabled = true
        setTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
       
        sc.searchBar.isHidden = false
        
        if sc.isActive{
            navigationController?.setNavigationBarHidden(true, animated: false)
        }
        else {
            navigationController?.isNavigationBarHidden = false
        }
    }
    

    
    //隐藏状态栏
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .default
    }
    
   
    
   
    //设置tableVIew
    func setTableView(){
        //表格在编辑状态下允许多选
        self.tableView?.allowsMultipleSelectionDuringEditing = true
        self.tableView.tableFooterView = UIView()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        //预计行高
        self.tableView.estimatedRowHeight = 200
        footer.setRefreshingTarget(self, refreshingAction: #selector(refreshData))
        //是否自动加载
        footer.isAutomaticallyRefresh = false
        footer.stateLabel.textColor = UIColor.blue
        self.tableView.mj_footer = footer
        
    }

   
    // MARK: - 自设protocol
    func reload(bool: Bool) {
        if bool == true{
            refreshData()
            FTIndicator.setIndicatorStyle(.light)
            FTIndicator.showNotification(with: UIImage(named:"勾"), title: "保存成功", message: "")
        }
    }
    
    func reloadMainView(bool: Bool) {
        if bool == true{
            refreshData()
        }
    }
    
   func dataMethod(model: [searchModel]) {
        array = array + model
    if model.count == 0{
        footer.setTitle("没有更多数据", for: .idle)
    }
        self.tableView.reloadData()
        self.tableView.mj_footer.endRefreshing()
    }
    
    // MARK: - UISearchResultsUpdating && UISearchBarDelegate 
    func getSearchView(){
            sc = UISearchController(searchResultsController: nil)
            sc.searchResultsUpdater = self
            sc.dimsBackgroundDuringPresentation = false
            //搜索条背景不变暗
            sc.hidesNavigationBarDuringPresentation = false
            sc.searchBar.delegate = self
            sc.searchBar.backgroundColor = UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: 1)
            tableView.tableHeaderView = sc.searchBar
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        navigationController?.isNavigationBarHidden = false
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        navigationController?.isNavigationBarHidden = true
        return true
    }

    func searchFilter(text:String){
        searchVCResult = array.filter({ (model) -> Bool in
            return (model.title).localizedCaseInsensitiveContains(text)  || (model.userName).localizedCaseInsensitiveContains(text)
        })
    }
        
    func updateSearchResults(for searchController: UISearchController) {
        if var text = searchController.searchBar.text{
            text = text.trimmingCharacters(in: .whitespaces)
            searchFilter(text: text)
            tableView.reloadData()
        }
    }
    
    //得到评论数量
    func selectCommentCount(id:String,button:UIButton){
        DispatchQueue.global().async {
             let sql = "select count(*) from tripComments where tripID = '\(id)'"
        let result = AVQuery.doCloudQuery(withCQL: sql)
            DispatchQueue.main.async {
                button.setTitle("\(Int((result?.count)!))", for: .normal)
            }
        }
    }
    
    
    //得到头像
    func getUserImage(name:String,imageView:UIImageView){
        
        DispatchQueue.global().async {
        var headImageData = UIImage()
        let query = AVQuery(className: "UserInfo")
        query.whereKey("userName", equalTo: name)
        query.findObjectsInBackground { (results, error) in
           
                if let result = results as? [AVObject]{
                    if let imgFile = result[0]["headImage"] as? AVFile{
                      imgFile.getDataInBackground({ (data, error) in
                        DispatchQueue.main.async {
                            let imageData = NSKeyedUnarchiver.unarchiveObject(with: data!) as! UIImage
                            headImageData = imageData
                            imageView.image = headImageData
                        }
                        
                      })
                    }else{
                       imageView.image = UIImage(named: "头")
                    }
                }
            }
        }
    }
    
    //初始页面时得到点赞数量,和评论人数
    func getLikeCount(id:String,button:UIButton,indexPathRow:Int,textView:UITextView){
        DispatchQueue.global().async {
            let sql = "select * from clickHeart where searchTripID = '\(id)'"
            let result = AVQuery.doCloudQuery(withCQL: sql)
            let results = result?.results
            DispatchQueue.main.async {
                var likeName = ""
                 button.setTitle("\(Int((results?.count)!))", for: .normal)
                
                for value in (results! as? [AVObject])!{
                    likeName = likeName + (value["clickName"] as? String)! + ","
                }
                textView.text = likeName + "觉得很赞"
            }
       }
    }

    //点赞
    func addLikePeople(id:String,button:UIButton){
        let object = AVObject(className: "clickHeart")
        object["clickName"] = name
        object["searchTripID"] = id
        object.saveInBackground { (success, error) in
            if success{
            print("点赞成功")
                let str = button.titleLabel?.text
                let count = Int(str!)! + 1
                button.setTitle("\(count)", for: .normal)
            }else{
            print(error ?? "未知错误")
            }
        }
    }
    
    //取消赞
    func deleteLike(id:String,button:UIButton){
        let query = AVQuery(className: "clickHeart")
        query.whereKey("clickName", equalTo: name)
        query.whereKey("searchTripID", equalTo: id)
        query.deleteAllInBackground { (success, error) in
            if success{
                print("删除成功")
                let str = button.titleLabel?.text
                let count = Int(str!)! - 1
                button.setTitle("\(count)", for: .normal)
            }else{
                print(error ?? "未知错误")
            }
        }
    }
    
    // MARK: - Table view data source

        
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return sc.isActive ? searchVCResult.count : array.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
      let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! searchTFTableViewCell
        let count = sc.isActive ? searchVCResult.count : array.count
        let value =  sc.isActive ? searchVCResult[indexPath.row] : array[indexPath.row]
        
        //取得id
        let id = value.id
       
        //，得到评论数量
        self.selectCommentCount(id: id, button: cell.commentButton)
        //点赞数量
        cell.heartButton.tag = indexPath.row
        self.getLikeCount(id: id, button: cell.heartButton,indexPathRow: indexPath.row, textView: cell.likeView)
        if value.isSelected == true{
            cell.heartButton.setImage(UIImage(named:"爱心"), for: .normal)
        }else{
            cell.heartButton.setImage(UIImage(named:"爱心-2"), for: .normal)
        }
       
        cell.commentButton.tag = indexPath.row
        cell.commentButton.addTarget(self, action: #selector(touchUp), for: .touchUpInside)
        
        //地址
        let address = value.address
        cell.userAdress.setTitle(address, for: .normal)
        //用户名
        cell.nameLabel.text = value.userName
        
        
        cell.headImage.tag = 1000000
        
        getTime(label: cell.timeLabel, date: value.time )//时间
        getUserImage(name: (value.userName), imageView: cell.headImage)//头像
        infoButton(button: cell.infoButton)//个人信息
        
        detailButton(button: cell.detailButton,count:indexPath.row)
        
        //标题
        cell.titleLabel.text = value.title + "           第\(indexPath.row+1)行"
        //文本
        cell.labeltext.attributedText = value.text
        
        //动画
        let tap = UITapGestureRecognizer(target: self, action: #selector(heartAnimation))
        cell.heartButton.isUserInteractionEnabled = true
        cell.heartButton.addGestureRecognizer(tap)
        cell.heartButton.tag = indexPath.row
        
        if indexPath.row == count - 1{
           //self.activity.stopAnimating()
            
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    //MARK: - 杂乱的方法
    //爱心按钮的动画
    func heartAnimation(tap:UITapGestureRecognizer){
        let image = UIImage(named: "爱心-2")
        let image2 = UIImage(named:"爱心")
        let button = (tap.view) as? UIButton
        let index = tap.view?.tag
        let value =  sc.isActive ? searchVCResult[index!] : array[index!]
        if button?.imageView?.image == image{
            button?.setImage(image2, for: .normal)
            addLikePeople(id: value.id, button: button!)
        }else{
            button?.setImage(image, for: .normal)
            deleteLike(id: value.id, button: button!)
        }

        
        let heart = DMHeartFlyView(frame: CGRect(x: 0, y: 0, width: 40.0, height: 40.0))
        heart.center = CGPoint(x: (tap.view?.frame.origin.x)!, y: (tap.view?.frame.origin.y)!)
        tap.view?.superview?.addSubview(heart)
        heart.animate(in: tap.view?.superview)
      
    }
    
    

    //评论按钮点击事件
    func touchUp(send:UIButton){
       
        let defaults = UserDefaults.standard
        let id = sc.isActive ? searchVCResult[send.tag].id : array[send.tag].id
        let str = NSKeyedArchiver.archivedData(withRootObject: id )
        print(id)
        defaults.set(str, forKey: "ojID")
    }
    
    
    //得到时间
    func getTime(label:UILabel,date:Date){
    //将date转化为string
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateStyle = DateFormatter.Style.short
        let date = date
        let dateString = dateFormatter.string(from: date)
        label.text = dateString
    }
    
    //个人信息按钮
    func infoButton(button:UIButton){
        let tap = UITapGestureRecognizer(target: self, action: #selector(nameLabelClick(sender:)))
        button.isUserInteractionEnabled = true
        button.addGestureRecognizer(tap)

    }
    
    //详情页面
    func detailButton(button:UIButton,count:Int){
        button.isUserInteractionEnabled = true
        let target = UITapGestureRecognizer(target: self, action: #selector(toDetailView))
        button.tag = count
        button.addGestureRecognizer(target)
    }
    
        
    // MARK : -下拉菜单控件时间
    
    //去详情页
    func toDetailView(sender:UIGestureRecognizer){
        let count = sender.view?.tag
        let data = sc.isActive ? searchVCResult[count!] : array[count!]
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "searchDetail") as! searchDetailViewController
        let imageView = (sender.view?.superview?.superview?.viewWithTag(1000000))! as! UIImageView
        vc.image = imageView.image
        vc.detailDataSource = data
        sc.searchBar.isHidden = true
        navigationController?.isNavigationBarHidden = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //弹出用户信息框
    func nameLabelClick(sender:UIGestureRecognizer){
        let infoView = (sender.view?.superview?.superview)
        let view = infoView?.viewWithTag(20)!
        if view?.isHidden == true{
        view?.isHidden = false
        
        let label = infoView?.viewWithTag(13) as! UILabel
        self.friendName = label.text
        let addButton = infoView?.viewWithTag(16) as! UIButton
        addButton.addTarget(self, action: #selector(addLYFriend), for: .touchUpInside)
            
        label.text = (infoView?.viewWithTag(2) as! UILabel).text
        }else{
        view?.isHidden = true
        }
    }
    
    //添加好友
    func addLYFriend(){
        let actionSheet = UIAlertController(title: "添加好友", message: "确认添加对方为好友？", preferredStyle: .alert)
        let yes = UIAlertAction(title: "确定", style: .default) { (_) in
            if self.name == self.friendName{
                let actionMenu = UIAlertController(title: "提示", message:"用户不可以添加自己为好友" , preferredStyle: .alert)
                let back = UIAlertAction(title: "返回", style: .cancel, handler: nil)
                actionMenu.addAction(back)
                self.present(actionMenu, animated: true, completion: nil)
            }else{
                self.addFriend()
        }
    }
        let back = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        actionSheet.addAction(yes)
        actionSheet.addAction(back)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
        //发送好友请求
    func addFriend(){
        let cloudObject = AVObject(className: "addFriends")
            cloudObject["userName"] = self.name
            cloudObject["addFriendName"] = self.friendName
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
    
    
    //收起键盘
    func AddToolBar() -> UIToolbar {
        let toolBar:UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 35))
        toolBar.backgroundColor = UIColor.gray
        let spaceBtn = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let barBtn = UIBarButtonItem(title: "完成", style: .plain, target: self, action: #selector(doneNum))
        toolBar.items = [spaceBtn, barBtn]
        return toolBar
    }
    
    func doneNum() {
        self.sc.searchBar.endEditing(false)
    }

    //更新
    func refreshData(){
        Thread.detachNewThread {
            searchTFAPI.init(userName: self.name, skip: self.skip).delegate = self
        self.skip += 1
        }
        
    }
    
    //得到用户名
    func getUserName(){
        let defaults = UserDefaults.standard
        let objects = defaults.data(forKey: "name")
        name = NSKeyedUnarchiver.unarchiveObject(with: objects!) as!String
    }
   
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "detiaiID"{
            let arrayDetail = sc.isActive ? searchVCResult[tableView.indexPathForSelectedRow!.row] : array[tableView.indexPathForSelectedRow!.row]
            let dest = segue.destination as! searchDetailViewController
            dest.detailDataSource = arrayDetail
        }
        if segue.identifier == "addTripInfo"{
            let dest = segue.destination as! addTripInfoViewController
            dest.delegate = self
        }
        if segue.identifier == "toComment"{
            let dest = segue.destination as! commentViewController
            dest.commentDelegate = self
           
            sc.searchBar.isHidden = true
            navigationController?.isNavigationBarHidden = false
        }
    }
}
