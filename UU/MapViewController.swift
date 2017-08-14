//
//  MapViewController.swift
//  UU
//
// 地图的主界面
//  Created by admin on 2017/3/26.
//  Copyright © 2017年 L. All rights reserved.
//

import UIKit
import Alamofire
import FTIndicator

class MapViewController: UIViewController,UISearchBarDelegate,UITableViewDelegate {
    
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    
    let transportation:Array<String> = ["汽车","骑行","步行"]//导航提示的三种类型
    
    var mapView:BMKMapView!//加载地图的view
    //查询周边服务的view
    var aroundView:UIView!
    
    //地点
    lazy var search:BMKPoiSearch = {
        let search = BMKPoiSearch()
        search.delegate = self
        return search
    }()
    
    //路线规划
    lazy var routeSearch:BMKWalkingRoutePlanOption = {
        let search = BMKWalkingRoutePlanOption()
       // search.delegate = self
        return search
    }()
    
    var name:String!
    var searchBar:UISearchBar!
    var dataSouce:Array<String> = []
    var tab:UITableView!
    var x:Double! = nil
    var y:Double! = nil
    var findBool:Bool! = true
    var center:CLLocationCoordinate2D!
    var bmk:BMKRouteLine!
    
    var attractions = 0//初始景点个数
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        setmapView()
        setAroundView()
        lineButton()
        setSearchBar()
        getCoordinate()
        //foundAttractions()
        let data = NSKeyedArchiver.archivedData(withRootObject: "景点") as Data
        findOfData(data: data)
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
       mapView.viewWillAppear()
         self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        findStart()
        mapView.delegate = self
        search.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        mapView.viewWillDisappear()
        mapView.delegate = nil
        search.delegate = nil
        
    }
    
    //MARK: - 界面控件的设置
    
    //显示地图界面的view
    func setmapView(){
        mapView = BMKMapView()
        mapView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        mapView.isTrafficEnabled = true
        mapView.delegate = self
        
         self.view.addSubview(mapView)
    }
    
    //显示周边服务层的半透明view
    func setAroundView(){
        aroundView = UIView()
        aroundView.alpha = 0.7
        aroundView.backgroundColor = UIColor.black
        aroundView.frame = CGRect(x: 0, y: self.view.bounds.height/1.2, width: width, height: 50)
        aroundView.isUserInteractionEnabled = true
        let target = UITapGestureRecognizer(target: self, action: #selector(clickView))
        aroundView.addGestureRecognizer(target)
        mapView.addSubview(aroundView)
        mapView.addSubview(setLabel())
    }
    
    //显示字体：查询周边服务
    func setLabel() -> UILabel{
        let label = UILabel()
        label.frame = CGRect(x: 0, y: self.view.bounds.height/1.2, width: self.aroundView.bounds.width/3, height: self.aroundView.bounds.height)
        label.text = "查询周边服务"
        label.textColor = UIColor.white
        return label
    }
    
    //查询周边服务的view点击手势
    func clickView(){
        findBool = false
        let sb = UIStoryboard(name: "SecondTab", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "NMap")
        self.present(vc, animated: true, completion: nil)
    }
    
    // 查找路线
    func lineButton(){
        let button = UIButton()
        button.center = CGPoint(x: self.view.bounds.width/2, y: aroundView.frame.origin.y-35)
        button.frame.size = CGSize(width: 50, height: 30)
        button.setTitle("路线", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        button.setImage(UIImage(named:"箭头"), for: .normal)
        button.backgroundColor = UIColor(red: 36/255, green: 59/255, blue: 117/255, alpha: 0.7)
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(toSearchLine), for: .touchUpInside)
        self.mapView.addSubview(button)
    }
    
    //去搜索路径页面
    func toSearchLine(){
        let sb = UIStoryboard(name: "SecondTab", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "line") as! searchLineViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //  设置搜索框
    func setSearchBar(){
        searchBar = UISearchBar()
        searchBar.frame = CGRect(x: 0, y:0, width: width, height: 30)
        searchBar.placeholder = "请输入地名"
        searchBar.delegate = self
        self.navigationItem.titleView = searchBar
    }
    
    func getCoordinate(){
        //得到坐标
        let defaults = UserDefaults.standard
        let objectData = defaults.data(forKey: "point")
        let point = NSKeyedUnarchiver.unarchiveObject(with: objectData!) as! Array<Double>
        let point1 = point[0]
        let point2 = point[1]
        
        //设置坐标
        center = CLLocationCoordinate2D(latitude: point2, longitude: point1)
        center.latitude = point2
        center.longitude = point1
        
        //加上气泡
        let annotation = BMKPointAnnotation()
        annotation.title = "我的位置"
        annotation.coordinate = center
        mapView.addAnnotation(annotation)
        
        //设置中心点
        mapView.centerCoordinate = center
        
        
        //设置查询范围
        let span = BMKCoordinateSpanMake(0.011929035022411938, 0.0078062748817018246)
        let region = BMKCoordinateRegionMake(center, span)
        mapView.setRegion(region, animated: true)
        
        mapView.showMapScaleBar = true
        mapView.mapScaleBarPosition = CGPoint(x: 20, y: aroundView.frame.origin.y - 20)
    }
    
    //MARK: - 搜索框
    //搜索框进入搜索页面
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        findBool = false
        let sb = UIStoryboard(name: "SecondTab", bundle:nil)
        let vc = sb.instantiateViewController(withIdentifier: "search") as! SearViewController
        self.present(vc, animated: true, completion: nil)
        
                return false
    }
    
    //将上一次搜索结果清空
    func cleanAnnotation(mapview:BMKMapView){
        for value in mapview.annotations{
            let annotation = value as! BMKAnnotation
            if annotation.title!() != "我的位置"{
                mapview.removeAnnotation(annotation)
            }
        }
    }
    
    @IBAction func cancel(segue:UIStoryboardSegue) {
        
    }

    //得到用户名输入的中文地址
    func findStart(){
        if findBool == false{
        let defaults = UserDefaults.standard
        let labelData = defaults.data(forKey: "selectAddressName")

            if labelData != nil{
                findOfData(data: labelData!)
        }
        findBool = true
        }
    }
    
    //将中文地址转化为坐标
    func findOfData(data:Data){
        name = NSKeyedUnarchiver.unarchiveObject(with: data) as! String
        let span = BMKCoordinateSpanMake(0.011929035022411938, 0.0078062748817018246)//查找范围
        let region = BMKCoordinateRegionMake(center, span)//中心点和范围
        mapView.setRegion(region, animated: true)
        
        let option = BMKNearbySearchOption()
        option.pageIndex = 0
        option.pageCapacity = 20
        option.location = center
        option.keyword = name
        let flag = search.poiSearchNear(by: option)
        if flag{
            print("发送检索成功")
        }else{
            print("检索失败")
        }

    }
}


extension MapViewController:BMKMapViewDelegate{
    //点击大头针
    func mapView(_ mapView: BMKMapView!, annotationViewForBubble view: BMKAnnotationView!) {
        let annotaiton = view.annotation
        print(">>>\(String(describing: annotaiton?.coordinate))\(String(describing: annotaiton?.title!()))\(String(describing: annotaiton?.subtitle!()))")
    }
    
    //区域改变
    func mapView(_ mapView: BMKMapView!, regionDidChangeAnimated animated: Bool) {
        print(mapView.region.center,mapView.region.span)//CLLocationCoordinate2D(latitude: 31.272873385065104, longitude: 121.61537568502136) BMKCoordinateSpan(latitudeDelta: 0.011921347023825746, longitudeDelta: 0.0078062748817018246)
    }
    
    func mapView(_ mapView: BMKMapView!, viewFor annotation: BMKAnnotation!) -> BMKAnnotationView! {
        if annotation.title!() == "我的位置"{
           let annotationView = BMKAnnotationView(annotation: annotation, reuseIdentifier: "annotation")
           
           annotationView?.backgroundColor = UIColor.blue
           annotationView?.annotation = annotation
           annotationView?.image = UIImage(named: "地图")
            
            return annotationView
        }
        return nil
    }
    
}

extension MapViewController:BMKPoiSearchDelegate{
    func onGetPoiResult(_ searcher: BMKPoiSearch!, result poiResult: BMKPoiResult!, errorCode: BMKSearchErrorCode) {
        if errorCode == BMK_SEARCH_NO_ERROR {
            print("周边检索成功")
            cleanAnnotation(mapview: self.mapView)
                        
            let poiInfos = poiResult.poiInfoList as! [BMKPoiInfo]
            FTIndicator.setIndicatorStyle(.light)
            FTIndicator.showNotification(with: UIImage(named:"景点"), title: "加载了附近\(poiInfos.count)个景点", message: "")
            for poiInfo in poiInfos {
                dataSouce.append(poiInfo.name)
                //print(poiInfo.name, poiInfo.address)
    
                //加大头针
                let annotation = BMKPointAnnotation()
                annotation.coordinate = poiInfo.pt//CLLocationCoordinate2D
                annotation.title = poiInfo.name
                
                annotation.subtitle = poiInfo.address
                mapView?.addAnnotation(annotation)
            }
        }else if errorCode == BMK_SEARCH_RESULT_NOT_FOUND{
            FTIndicator.setIndicatorStyle(.light)
            FTIndicator.showNotification(withTitle: "未搜索到结果", message: "")
        }else if errorCode == BMK_SEARCH_AMBIGUOUS_KEYWORD{
            FTIndicator.setIndicatorStyle(.light)
            FTIndicator.showNotification(withTitle: "检索词有歧义", message: "")
        }else if errorCode == BMK_SEARCH_AMBIGUOUS_ROURE_ADDR{
            FTIndicator.setIndicatorStyle(.light)
            FTIndicator.showNotification(withTitle: "检索地址有歧义", message: "")
        }else if errorCode == BMK_SEARCH_AMBIGUOUS_ROURE_ADDR{
            FTIndicator.setIndicatorStyle(.light)
            FTIndicator.showNotification(withTitle: "该城市不支持公交搜索", message: "")
        }else if errorCode == BMK_SEARCH_NOT_SUPPORT_BUS_2CITY{
            FTIndicator.setIndicatorStyle(.light)
            FTIndicator.showNotification(withTitle: "该城市不支持跨城公交搜索", message: "")
        }else if errorCode == BMK_SEARCH_ST_EN_TOO_NEAR{
            FTIndicator.setIndicatorStyle(.light)
            FTIndicator.showNotification(withTitle: "起终点太近", message: "")
        }else if errorCode == BMK_SEARCH_KEY_ERROR{
            FTIndicator.setIndicatorStyle(.light)
            FTIndicator.showNotification(withTitle: "key错误", message: "")
        }else if errorCode == BMK_SEARCH_NETWOKR_ERROR{
            FTIndicator.setIndicatorStyle(.light)
            FTIndicator.showNotification(withTitle: "网络连接错误", message: "")
        }else if errorCode == BMK_SEARCH_NETWOKR_TIMEOUT{
            FTIndicator.setIndicatorStyle(.light)
            FTIndicator.showNotification(withTitle: "网络连接超时", message: "")
        }else if errorCode == BMK_SEARCH_PARAMETER_ERROR{
            FTIndicator.setIndicatorStyle(.light)
            FTIndicator.showNotification(withTitle: "参数错误", message: "")
        }else {
            print("周边检索失败")
        }
        print(name)
    }
    
    
    
    func mapView(_ mapView: BMKMapView!, didSelect view: BMKAnnotationView!) {
        if view.annotation.title!() != "我的位置"{
            let actionMenu = UIAlertController(title: "提示", message: "请选择交通工具", preferredStyle: .alert)
            let drive = UIAlertAction(title: "汽车", style: .default, handler: { (_) in
                self.pushToNavi(naviWay: "汽车", latitude: CGFloat(view.annotation.coordinate.latitude), longitude: CGFloat(view.annotation.coordinate.longitude))
                
                
            })
            
            let walker = UIAlertAction(title: "步行", style: .default, handler: { (_) in
                self.pushToNavi(naviWay: "步行", latitude: CGFloat(view.annotation.coordinate.latitude), longitude: CGFloat(view.annotation.coordinate.longitude))
            })
            
            let bicycle = UIAlertAction(title: "骑行", style: .default, handler: { (_) in
               self.pushToNavi(naviWay: "骑行", latitude: CGFloat(view.annotation.coordinate.latitude), longitude: CGFloat(view.annotation.coordinate.longitude))
            })
            
            let back = UIAlertAction(title: "返回", style: .cancel, handler: nil)
            actionMenu.addAction(drive)
            actionMenu.addAction(back)
            actionMenu.addAction(walker)
            actionMenu.addAction(bicycle)
            present(actionMenu, animated: true, completion: nil)
        }
    }
    
    func pushToNavi(naviWay:String,latitude:CGFloat,longitude:CGFloat){
        let sb = UIStoryboard(name: "SecondTab", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "naviVC") as! naviViewController
        vc.startLatitude = CGFloat(self.center.latitude)
        vc.endLatitude = latitude
        vc.endCoordinate = longitude
        vc.startCoordinate = CGFloat(self.center.longitude)
        vc.naviWay = naviWay
        vc.fromLine = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension MapViewController:BMKRouteSearchDelegate{
    func onGetWalkingRouteResult(_ searcher: BMKRouteSearch!, result: BMKWalkingRouteResult!, errorCode error: BMKSearchErrorCode) {
        print("aaaaa")
    }
}


