//
//  searchLineViewController.swift
//  UU
//
//  Created by admin on 2017/7/16.
//  Copyright © 2017年 L. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

class searchLineViewController: UIViewController,passValueDelegate,naviViewBack {
    
    var searchStyle = "汽车"
    var mapView = BMKMapView()
    var search = AMapSearchAPI()
    var startPoint:AMapNaviPoint! = AMapNaviPoint()//导航开始坐标
    var endPoint:AMapNaviPoint! = AMapNaviPoint()//导航结束坐标
    var name = ""
    var routeHistory:SearchRouteLine!
    var objectData:[SearchRouteLine] = []
    var routeSearch:BMKRouteSearch! = BMKRouteSearch()
    var bus = BMKBusLineSearch()//检索单独公交路线
    var trainTableView = UITableView()
    var startPlanNode:BMKPlanNode! = BMKPlanNode()//出发点
    var endPlanNode:BMKPlanNode! = BMKPlanNode()//目的地
    var option:BMKMassTransitRoutePlanOption! = BMKMassTransitRoutePlanOption()//跨境交通
    var cityOption = BMKTransitRoutePlanOption()//查找市内公共交通
    var busOption = BMKBusLineSearchOption()//查找公交线路
    var massTrainArray:[BMKMassTransitSubStep] = []
    
    @IBOutlet weak var loadMapView: UIView!
    @IBOutlet weak var startPosition: UITextField!
    @IBOutlet weak var endPosition: UITextField!
    @IBOutlet weak var lineLabel: UILabel!
    @IBOutlet weak var historyTableView: UITableView!
    

    @IBAction func backbutton(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func changePosotion(_ sender: UIButton) {
        let sStr = startPosition.text
        let eStr = endPosition.text
        
        startPosition.text = eStr
        endPosition.text = sStr
    }
    
    @IBAction func driveButton(_ sender: UIButton) {
     lineLabel.frame.origin = CGPoint(x: sender.frame.minX, y: sender.frame.origin.y + 26)
        self.searchStyle = "汽车"
    }
    
    
    @IBAction func busButton(_ sender: UIButton) {
        lineLabel.frame.origin = CGPoint(x: sender.frame.minX, y: sender.frame.origin.y + 26)
        self.searchStyle = "公交"
    }
    
   
    @IBAction func walkButton(_ sender: UIButton) {
        lineLabel.frame.origin = CGPoint(x: sender.frame.minX, y: sender.frame.origin.y + 26)
        self.searchStyle = "步行"
    }
   
    @IBAction func rideButton(_ sender: UIButton) {
        lineLabel.frame.origin = CGPoint(x: sender.frame.minX, y: sender.frame.origin.y + 26)
        self.searchStyle = "骑行"
    }
    
    @IBAction func trainButton(_ sender: UIButton) {
        lineLabel.frame.origin = CGPoint(x: sender.frame.minX, y: sender.frame.origin.y + 26)
        self.searchStyle = "火车"
    }
    
    
    @IBAction func coachButton(_ sender: UIButton) {
        lineLabel.frame.origin = CGPoint(x: sender.frame.minX, y: sender.frame.origin.y + 26)
    }
    
    @IBAction func searchButton(_ sender: UIButton) {
        self.startPosition.resignFirstResponder()
        self.endPosition.resignFirstResponder()
        if startPosition.text != "输入终点" && endPosition.text != "输入终点"{
        if self.searchStyle == "火车"{
            
            let sb = UIStoryboard(name: "SecondTab", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "massTrain") as! massTrianPlanViewController
            vc.startName = "衡阳"
            vc.startCityName = "晶珠广场"
            vc.endName = "广州"
            vc.endCityName = "广州火车站"
            self.navigationController?.pushViewController(vc, animated: true)
        }else if self.searchStyle == "公交"{
            let sb = UIStoryboard(name: "SecondTab", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "cityPlan") as! trainCityViewController
//            vc.startName = "佛山"
//            vc.startCityName = "祖庙"
//            vc.endName = "广州"
//            vc.endCityName = "广州火车站"
            self.navigationController?.pushViewController(vc, animated: true)
         }else if self.searchStyle == "汽车"{
        
        if startPosition.text == "我的位置"{
            //得到坐标
            getCoordinate(pointPosition: startPoint)

            positionAPI.init(cityName: endPosition.text!, bool: false)
        }else if endPosition.text == "我的位置"{
            //得到坐标
            getCoordinate(pointPosition: endPoint)
            positionAPI.init(cityName: startPosition.text!, bool: true)
        }else{
            positionAPI.init(cityName: startPosition.text!, bool: true)
            positionAPI.init(cityName: endPosition.text!, bool: false)
            
        }
        }
        }else{
            let alertView = customAlert()
            alertView.center = CGPoint(x: 20, y: self.view.bounds.height/2-50)
            alertView.frame.size = CGSize(width: 280, height: 160)
            alertView.backgroundColor = UIColor(red: 103/255, green: 131/255, blue: 188/255, alpha: 1)
            alertView.makeAlert(text: "起始点或终点不能为空")
            self.view.addSubview(alertView)
//            let menu = UIAlertController(title: "提示", message: "起始地或目的地不能为空", preferredStyle: .alert)
//            let childAlert = UIAlertAction(title: "确认", style: .cancel, handler: nil)
//            menu.addAction(childAlert)
//            present(menu, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserName()
        search?.delegate = self
        endPosition.delegate = self
        startPosition.delegate = self
        historyTableView.delegate = self
        historyTableView.dataSource = self
        routeSearch.delegate = self
        notification()
        getDataFromCore()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.view.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func passValue(bool: Bool, value: String) {
        if bool == true{
            startPosition.text = value
        }else{
            endPosition.text = value
        }
        self.view.endEditing(true)
      }
    
    func reloadView(bool: Bool) {
        if bool == true{
            self.view.endEditing(true)
            getDataFromCore()
        }
    }
    
    //数据通知
    func notification(){
        let notificationName = Notification.Name(rawValue: "position")
        NotificationCenter.default.addObserver(self,
                                               selector:#selector(getPosition(notification:)),
                                               name: notificationName, object: nil)
    }
    
    func getPosition(notification: Notification) {
        let userInfo = notification.userInfo as! [String:AnyObject]
        let value = userInfo["value1"] as! pointModel
        if value.startBool == true{
            self.startPoint.latitude = value.latitude
            self.startPoint.longitude = value.longitude
            
            if endPosition.text == "我的位置"{
               
            toNaviView(style: searchStyle)
            }
        }else{
            self.endPoint.latitude = value.latitude
            self.endPoint.longitude = value.longitude
         
            toNaviView(style: searchStyle)
            
        }
    }
    
    //去导航页
    func toNaviView(style:String){
            let sb = UIStoryboard(name: "SecondTab", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "naviVC") as! naviViewController
            vc.startLatitude = self.startPoint.latitude
            vc.startCoordinate = self.startPoint.longitude
            vc.endLatitude = self.endPoint.latitude
            vc.endCoordinate = self.endPoint.longitude
            vc.naviWay = style
            vc.fromLine = true
            saveSearchHistory(style: searchStyle)
            self.navigationController?.pushViewController(vc, animated: true)
    }

        //我的位置
    func getCoordinate(pointPosition:AMapNaviPoint){
        //得到坐标
        let defaults = UserDefaults.standard
        let objectData = defaults.data(forKey: "point")
        let point = NSKeyedUnarchiver.unarchiveObject(with: objectData!) as! Array<Double>
        let point1 = point[0]
        let point2 = point[1]
        pointPosition.latitude = CGFloat(point2)
        pointPosition.longitude = CGFloat(point1)
    }

    //把搜索记录保存到coredata
    func saveSearchHistory(style:String){
        let delegate = UIApplication.shared.delegate as! AppDelegate
        routeHistory = SearchRouteLine(context:delegate.persistentContainer.viewContext)
        routeHistory.startLatitude = Float(startPoint.latitude)
        routeHistory.startLongitude = Float(startPoint.longitude)
        routeHistory.endLatitude = Float(endPoint.latitude)
        routeHistory.endLongitude = Float(endPoint.longitude)
        routeHistory.startName = startPosition.text
        routeHistory.endName = endPosition.text
        routeHistory.searchStyle = style
        routeHistory.userName = name
        routeHistory.addTime = Date() as NSDate
        delegate.saveContext()
    }
    
    //从coreData拿搜索数据
    func getDataFromCore(){
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
      
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest()
        fetchRequest.fetchLimit = 20
        fetchRequest.fetchOffset = 0
        
        let entity:NSEntityDescription = NSEntityDescription.entity(forEntityName: "SearchRouteLine", in: context)!
        fetchRequest.entity = entity
      
        let predicate = NSPredicate.init(format: "userName = %@ ", name)
        
        fetchRequest.predicate = predicate
        
        
        do {
            objectData = try appDelegate.persistentContainer.viewContext.fetch(fetchRequest) as! [SearchRouteLine]
            self.historyTableView.reloadData()
        } catch  {
            print(error)
        }

    }
    
    
    func getUserName(){
        let defaults = UserDefaults.standard
        let data = defaults.data(forKey: "name")
        name = NSKeyedUnarchiver.unarchiveObject(with: data!) as! String
        
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}

extension searchLineViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objectData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let value = objectData[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "routeLineCell", for: indexPath) as! routeLineTableViewCell
        cell.startAddress.text = value.startName
        cell.endAddress.text = value.endName
        cell.startLatitude = CGFloat(value.startLatitude)
        cell.startlongitude = CGFloat(value.startLongitude)
        cell.endLatitude = CGFloat(value.endLatitude)
        cell.endLongitude = CGFloat(value.endLongitude)
        cell.style = value.searchStyle
        cell.searchStyle.text = value.searchStyle
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let value = objectData[indexPath.row]
    
        if value.searchStyle == "汽车"{
            self.cellPointToNavi(style: "汽车", sLatitude: CGFloat(value.startLatitude), sLongitude: CGFloat(value.startLongitude), eLatitude: CGFloat(value.endLatitude), eLongitude: CGFloat(value.endLongitude))
        }else if value.searchStyle == "骑行"{
            self.cellPointToNavi(style: "骑行", sLatitude: CGFloat(value.startLatitude), sLongitude: CGFloat(value.startLongitude), eLatitude: CGFloat(value.endLatitude), eLongitude: CGFloat(value.endLongitude))
        }else if value.searchStyle == "步行"{
            self.cellPointToNavi(style: "步行", sLatitude: CGFloat(value.startLatitude), sLongitude: CGFloat(value.startLongitude), eLatitude: CGFloat(value.endLatitude), eLongitude: CGFloat(value.endLongitude))
        }
    }
    
    //点击cell历史记录，去往导航
    func cellPointToNavi(style:String,sLatitude:CGFloat,sLongitude:CGFloat,eLatitude:CGFloat,eLongitude:CGFloat){
        let sb = UIStoryboard(name: "SecondTab", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "naviVC") as! naviViewController
        vc.startLatitude = sLatitude
        vc.startCoordinate = sLongitude
        vc.endLatitude = eLatitude
        vc.endCoordinate = eLongitude
        vc.naviWay = style
        vc.fromLine = true
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension searchLineViewController:BMKRouteSearchDelegate{
    //        BMK_SEARCH_NO_ERROR = 0,///<检索结果正常返回
    //        BMK_SEARCH_AMBIGUOUS_KEYWORD,///<检索词有岐义
    //        BMK_SEARCH_AMBIGUOUS_ROURE_ADDR,///<检索地址有岐义
    //        BMK_SEARCH_NOT_SUPPORT_BUS,///<该城市不支持公交搜索
    //        BMK_SEARCH_NOT_SUPPORT_BUS_2CITY,///<不支持跨城市公交
    //        BMK_SEARCH_RESULT_NOT_FOUND,///<没有找到检索结果
    //        BMK_SEARCH_ST_EN_TOO_NEAR,///<起终点太近
    //        BMK_SEARCH_KEY_ERROR,///<key错误
    //        BMK_SEARCH_NETWOKR_ERROR,///网络连接错误
    //        BMK_SEARCH_NETWOKR_TIMEOUT,///网络连接超时
    //        BMK_SEARCH_PERMISSION_UNFINISHED,///还未完成鉴权，请在鉴权通过后重试
    //        BMK_SEARCH_INDOOR_ID_ERROR,///室内图ID错误
    //        BMK_SEARCH_FLOOR_ERROR,///室内图检索楼层错误
    //        BMK_SEARCH_INDOOR_ROUTE_NO_IN_BUILDING,///起终点不在支持室内路线的室内图内
    //        BMK_SEARCH_INDOOR_ROUTE_NO_IN_SAME_BUILDING,///起终点不在同一个室内
    //        BMK_SEARCH_PARAMETER_ERROR,///参数错误
    

    
    func onGetTransitRouteResult(_ searcher: BMKRouteSearch!, result: BMKTransitRouteResult!, errorCode error: BMKSearchErrorCode) {
       
       
       

    }
 }

extension searchLineViewController:AMapSearchDelegate{

}

extension searchLineViewController:UITextFieldDelegate{
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        var textName = ""
        if textField == startPosition{
            textName = "始"
        }else{
            textName = "尾"
        }
        let sb = UIStoryboard(name: "SecondTab", bundle:nil)
        let vc = sb.instantiateViewController(withIdentifier: "searchPosition") as! searchPositionViewController
        vc.textName = textName
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
        return false
    }
}

