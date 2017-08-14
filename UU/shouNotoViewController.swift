//
//  shouNotoViewController.swift
//  UU
//
//  Created by admin on 2017/7/6.
//  Copyright © 2017年 L. All rights reserved.
//

import UIKit
import AVOSCloud
import FTIndicator
import DGElasticPullToRefresh

class shouNotoViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,reload,dataToShowNoto {
   


   
    @IBOutlet weak var tableView: UITableView!
    @IBAction func eiditButton(_ sender: UIBarButtonItem) {
        setEdit()
    }
    
    var notoAVObject:[AVObject] = []
    var name = ""
    var atrText:NSAttributedString!
    var reload:Bool = false
    var activity = UIActivityIndicatorView()
    var barButton = UIBarButtonItem()
    var view1 = MyView()
    var array:[notoModel] = []
    let loadingView = DGElasticPullToRefreshLoadingViewCircle()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        loadingView.tintColor = UIColor(red: 78/255.0, green: 221/255.0, blue: 200/255.0, alpha: 1.0)
        tableView.dg_addPullToRefreshWithActionHandler({
            self.refreshData()
            self.tableView.dg_stopLoading()
        }, loadingView: loadingView)
        tableView.dg_setPullToRefreshFillColor(UIColor(red: 57/255.0, green: 67/255.0, blue: 89/255.0, alpha: 1.0))
        tableView.dg_setPullToRefreshBackgroundColor(tableView.backgroundColor!)

        
        nameSelect()
        editingBox()
        refreshData()
        setTableView()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //自定义protocol
    func successToCloud(bool: Bool) {
        
        var value = ""
        switch bool{
        case true:
           refreshData()
            value = "云端保存成功"
         case false:
            value = "云端保存失败"
        }
        
        FTIndicator.setIndicatorStyle(.light)
        FTIndicator.showNotification(with: UIImage(named:"勾"), title: "保存成功", message: "")
    }

    func dataMethod(model:[notoModel]){
        array = model
        print(array.count)
        self.tableView.reloadData()
        activity.stopAnimating()
    }
    
    //设置tableVIew
    func setTableView(){
    //表格在编辑状态下允许多选
        self.tableView?.allowsMultipleSelectionDuringEditing = true
        self.tableView.tableFooterView = UIView()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        //预计行高
        self.tableView.estimatedRowHeight = 200
    
      //  self.tableView.refreshControl = UIRefreshControl()
        //self.tableView.refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }
    
    //编辑框
    func editingBox(){
        view1 = MyView(frame: CGRect(x: 220, y:(self.navigationController?.navigationBar.bounds.height)! + 30 , width: 50, height: 61))
        
        let deleteButton = UIButton(frame: CGRect(x: 0, y: 10, width: 50, height: 25))
        deleteButton.setTitle("删除", for:.normal )
        deleteButton.backgroundColor = UIColor(red:237/255, green: 212/255, blue: 179/255, alpha: 0.8)

        deleteButton.setTitleColor(UIColor.black, for: .normal)
        deleteButton.setTitleColor(UIColor.red, for: .highlighted)
        deleteButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        deleteButton.addTarget(self, action: #selector(deleteCellData), for: .touchUpInside)
        
        let toDetailButton = UIButton(frame: CGRect(x: 0, y: 36, width: 50, height: 25))
        toDetailButton.backgroundColor = UIColor(red:237/255, green: 212/255, blue: 179/255, alpha: 0.8)
        toDetailButton.setTitle("翻页", for: .normal)
        toDetailButton.setTitleColor(UIColor.black, for: .normal)
        toDetailButton.setTitleColor(UIColor.red, for: .highlighted)
        toDetailButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        toDetailButton.addTarget(self, action: #selector(toDetail), for: .touchUpInside)

        
        view1.isHidden = true
        view1.addSubview(deleteButton)
        view1.addSubview(toDetailButton)
        self.view.addSubview(view1)

    }
    
    //进入编辑状态
    func setEdit(){
        switch view1.isHidden {
        case true:
            self.tableView.setEditing(true, animated: true)
            view1.isHidden = false
        default:
            self.tableView.setEditing(false, animated: true)
            view1.isHidden = true
        }
        
    }
    
    //删除数据
    func deleteCellData(){
        
        
        
        if let selectedItems = tableView!.indexPathsForSelectedRows {
            for indexPath in selectedItems {
                
                //if selectedItems.count != 1{
                    let value =  self.array[indexPath.row]
                    let objectId = value.object["objectId"]
                    let query = AVObject(className: "UserNoto", objectId: objectId as! String)
                    query.delete()
                array.remove(at: indexPath.row)
                tableView.reloadData()
            }

            self.refreshData()
            dropOutEditing()
         }
        let menu = UIAlertController(title: "未选中", message: "", preferredStyle: .alert)
        let back = UIAlertAction(title: "确认", style: .cancel, handler: nil)
        menu.addAction(back)
        present(menu, animated: true, completion: nil)
        
    }
    
    func toDetail(){
    let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "notoCard") as! notoCardViewController
        vc.model = array
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func dropOutEditing(){
        //退出编辑状态
            self.tableView!.setEditing(false, animated:true)
            view1.isHidden = true
            let menu = UIAlertController(title: "删除成功", message: "", preferredStyle: .alert)
            let back = UIAlertAction(title: "确认", style: .cancel, handler: nil)
            menu.addAction(back)
            present(menu, animated: true, completion: nil)

    }
    
    //刷新的方法
    func refreshData(){
        Thread.detachNewThread {
            notoAPI.init(userName: self.name).delegate = self
        }
        
    }
    
    //数据通知
    func notification(){
        let notificationName = Notification.Name(rawValue: "noto")
        NotificationCenter.default.addObserver(self,
                                               selector:#selector(downloadImage(notification:)),
                                               name: notificationName, object: nil)
    }
    
    func downloadImage(notification: Notification) {
        let userInfo = notification.userInfo as! [String:AnyObject]
        let value = userInfo["value1"] as! [notoModel]
        array = value
        print(array.count)
        self.tableView.reloadData()
        activity.stopAnimating()
    }
    
    //得到用户名
    func nameSelect(){
        let defaults = UserDefaults.standard
        let objects = defaults.data(forKey: "name")
        name = NSKeyedUnarchiver.unarchiveObject(with: objects!) as!String
    }
    
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
     func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return array.count
        
    }
    

     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(indexPath.row)
        let cell = tableView.dequeueReusableCell(withIdentifier: "notoCell", for: indexPath) as! showNotoTableViewCell
        let cellnoto = array[indexPath.row]
        
        cell.showLabel.attributedText = cellnoto.text
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        //设置样式
        dateFormatter.dateStyle = DateFormatter.Style.short
        let date = cellnoto.time
        let dateString = dateFormatter.string(from: date!)
        cell.dataLabel.text = dateString
        return cell
    }

     func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let shareMenu = UITableViewRowAction(style: .normal, title: "分享") { (_, indexPath) in
            let actionSheet = UIAlertController(title: "分享到", message: "", preferredStyle: .actionSheet)
            let qq = UIAlertAction(title: "QQ", style: .default, handler: { (_) in
                
            })
            actionSheet.addAction(qq)
            self.present(actionSheet, animated: true, completion: nil)
        }
        
        return [shareMenu]
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toAddNoto"{
            let dest = segue.destination as! NotoBookViewController
            dest.delegate = self
        }

    }
   

}

class MyView:UIView{
    override init(frame: CGRect) {
        super.init(frame: frame)
        //把背景色设为透明
        self.backgroundColor = UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: 0.1)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.8 )
        context?.setAllowsAntialiasing(true)
        
        //x 100-120,y 100
        context?.setLineWidth(1)
        context?.move(to: CGPoint(x: 0, y: 10))
        context?.addLine(to: CGPoint(x: 20, y: 10))
        context?.strokePath()
        
        //x 120 - 130 y 100 - 90
        context?.setLineWidth(1)
        context?.move(to: CGPoint(x: 20, y: 10))
        context?.addLine(to: CGPoint(x: 30, y: 0))
        context?.strokePath()
        
        //x 130 -140 y:90 - 100
        context?.setLineWidth(1)
        context?.move(to: CGPoint(x: 30, y: 0))
        context?.addLine(to: CGPoint(x: 40, y: 10))
        context?.strokePath()
        
        context?.setLineWidth(1)
        context?.move(to: CGPoint(x: 40, y: 10))
        context?.addLine(to: CGPoint(x: 50, y: 10))
        context?.strokePath()
        
        context?.setLineWidth(1)
        context?.move(to: CGPoint(x: 0, y: 10))
        context?.addLine(to: CGPoint(x: 0, y: 61))
        context?.strokePath()
        
        context?.setLineWidth(1)
        context?.move(to: CGPoint(x: 0, y: 61))
        context?.addLine(to: CGPoint(x: 50, y: 61))
        context?.strokePath()
        
        context?.setLineWidth(1)
        context?.move(to: CGPoint(x: 50, y: 61))
        context?.addLine(to: CGPoint(x: 50, y: 10))
        context?.strokePath()
    }
}
