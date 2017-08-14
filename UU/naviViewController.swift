//
//  naviViewController.swift
//  UU
//
//  Created by admin on 2017/7/17.
//  Copyright © 2017年 L. All rights reserved.
//

import UIKit
protocol naviViewBack {
    func reloadView(bool:Bool)
}

class naviViewController: UIViewController {

    //导航自驾
    var driveView = AMapNaviDriveView()
    var driveManager: AMapNaviDriveManager!
    //导航步行
    var walkView = AMapNaviWalkView()
    var walknaviManager:AMapNaviWalkManager! = nil
    //导航骑行
    var rideView:AMapNaviRideView!
    var rideManager:AMapNaviRideManager!
    var naviButtonView:UIView!
    
    var startLatitude:CGFloat!
    var endLatitude:CGFloat!
    var endCoordinate:CGFloat!
    var startCoordinate:CGFloat!
    
    var startPoint:AMapNaviPoint!//导航开始坐标
    var endPoint:AMapNaviPoint!//导航结束坐标
    var fromLine:Bool!
    var naviWay:String!
    
    var delegate:naviViewBack?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true

        switch naviWay {
        case "汽车":
            self.navigationController?.isNavigationBarHidden = true
        self.startPoint = AMapNaviPoint.location(withLatitude: startLatitude, longitude:startCoordinate)
        self.endPoint = AMapNaviPoint.location(withLatitude: endLatitude, longitude: endCoordinate )
        whenDriver()
        case "步行":
            self.navigationController?.isNavigationBarHidden = true
        self.startPoint = AMapNaviPoint.location(withLatitude:startLatitude , longitude:startCoordinate )
        self.endPoint = AMapNaviPoint.location(withLatitude: endLatitude, longitude:endCoordinate )
        whenWalk()
        case "骑行":
            self.navigationController?.isNavigationBarHidden = true
        self.startPoint = AMapNaviPoint.location(withLatitude: startLatitude, longitude:startCoordinate )
        self.endPoint = AMapNaviPoint.location(withLatitude: endLatitude, longitude: endCoordinate)
        whenRide()
        default:
            break
        }
    
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
         self.tabBarController?.tabBar.isHidden = false
    }
    
    
    
    func whenDriver(){
    
        driveView = AMapNaviDriveView(frame: view.bounds)
        driveView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        driveView.delegate = self
        driveView.showCompass = true
        
        view.addSubview(driveView)
        driveManager = AMapNaviDriveManager()
        driveManager.delegate = self
        
        driveManager.allowsBackgroundLocationUpdates = true
        driveManager.pausesLocationUpdatesAutomatically = false
        
        //将driveView添加为导航数据的Representative，使其可以接收到导航诱导数据
        driveManager.addDataRepresentative(driveView)
        calculateRoute()
        
    }
    
    func whenWalk(){
       
        walkView = AMapNaviWalkView(frame: view.bounds)
        walkView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        walkView.delegate = self
       
        view.addSubview(walkView)
        
        walknaviManager = AMapNaviWalkManager()
        walknaviManager.delegate = self
        walknaviManager.allowsBackgroundLocationUpdates = true
        walknaviManager.pausesLocationUpdatesAutomatically = false
        walknaviManager.addDataRepresentative(walkView)
        walknaviManager.calculateWalkRoute(withStart: [startPoint], end: [endPoint])
    }
    
    func whenRide(){
        
        rideView = AMapNaviRideView(frame: view.bounds)
        rideView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        rideView.delegate = self
        
        view.addSubview(rideView)
        
        rideManager = AMapNaviRideManager()
        rideManager.delegate = self
        rideManager.allowsBackgroundLocationUpdates = true
        rideManager.pausesLocationUpdatesAutomatically = true
        rideManager.addDataRepresentative(rideView)
        
        
        rideManager.calculateRideRoute(withStart: startPoint, end: endPoint)
    }

    func calculateRoute() {
        //进行路径规划
        driveManager.calculateDriveRoute(withStart: [startPoint],
                                         end: [endPoint],
                                         wayPoints: nil,
                                         drivingStrategy: .singleDefault)
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

extension naviViewController:AMapNaviDriveViewDelegate,AMapNaviDriveManagerDelegate{
    
    func driveViewCloseButtonClicked(_ driveView: AMapNaviDriveView) {
        //driveView.delegate = nil
        //driveManager.delegate = self
        
        self.driveManager.stopNavi()
        driveManager.removeDataRepresentative(driveView)
        self.driveView.removeFromSuperview()
        if fromLine == false{
        self.navigationController?.popToViewController((self.navigationController?.viewControllers[0])!, animated: true)
        }else{
            delegate?.reloadView(bool: true)
        self.navigationController?.popToViewController((self.navigationController?.viewControllers[1])!, animated: true)
            
        }
    }
    
    
    func driveManager(onCalculateRouteSuccess driveManager: AMapNaviDriveManager) {
        NSLog("CalculateRouteSuccess")
        
        //算路成功后进行模拟导航
        let actionMenu = UIAlertController(title:"提示" , message:"请选择导航方式" , preferredStyle: .alert)
        let simulation = UIAlertAction(title: "模拟导航", style: .default) { (_) in
            driveManager.startEmulatorNavi()
        }
        let gps = UIAlertAction(title: "实时导航", style: .default) { (_) in
            driveManager.startGPSNavi()
        }
        actionMenu.addAction(simulation)
        actionMenu.addAction(gps)
        present(actionMenu, animated: true, completion: nil)
        // self.navigationController?.isNavigationBarHidden = false
    }
}

extension naviViewController:AMapNaviWalkViewDelegate,AMapNaviWalkManagerDelegate{
    func walkViewCloseButtonClicked(_ walkView: AMapNaviWalkView) {
        self.walknaviManager.stopNavi()
        self.walknaviManager.removeDataRepresentative(walkView)
        self.walkView.removeFromSuperview()
        if fromLine == false{
            self.navigationController?.popToViewController((self.navigationController?.viewControllers[0])!, animated: true)
        }else{
            delegate?.reloadView(bool: true)
            self.navigationController?.popToViewController((self.navigationController?.viewControllers[1])!, animated: true)
        }
    }
    
    func walkManager(onCalculateRouteSuccess walkManager: AMapNaviWalkManager) {
        //算路成功后进行模拟导航
        let actionMenu = UIAlertController(title:"提示" , message:"请选择导航方式" , preferredStyle: .alert)
        let simulation = UIAlertAction(title: "模拟导航", style: .default) { (_) in
            walkManager.startEmulatorNavi()
        }
        let gps = UIAlertAction(title: "实时导航", style: .default) { (_) in
            walkManager.startGPSNavi()
        }
        actionMenu.addAction(simulation)
        actionMenu.addAction(gps)
        present(actionMenu, animated: true, completion: nil)
    }
}

extension naviViewController:AMapNaviRideViewDelegate,AMapNaviRideManagerDelegate{
    func rideViewCloseButtonClicked(_ rideView: AMapNaviRideView) {
        self.rideManager.stopNavi()
        self.rideManager.removeDataRepresentative(rideView)
        self.rideView.removeFromSuperview()
        if fromLine == false{
            self.navigationController?.popToViewController((self.navigationController?.viewControllers[0])!, animated: true)
        }else{
            delegate?.reloadView(bool: true)
            self.navigationController?.popToViewController((self.navigationController?.viewControllers[1])!, animated: true)
        }
    }
    
    func rideManager(onCalculateRouteSuccess rideManager: AMapNaviRideManager) {
        //算路成功后进行模拟导航
        let actionMenu = UIAlertController(title:"提示" , message:"请选择导航方式" , preferredStyle: .alert)
        let simulation = UIAlertAction(title: "模拟导航", style: .default) { (_) in
            rideManager.startEmulatorNavi()
        }
        let gps = UIAlertAction(title: "实时导航", style: .default) { (_) in
            rideManager.startGPSNavi()
        }
        actionMenu.addAction(simulation)
        actionMenu.addAction(gps)
        present(actionMenu, animated: true, completion: nil)
    }
    
}

