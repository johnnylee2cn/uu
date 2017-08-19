//
//  LoginViewController.swift
//  UU
//
//  Created by admin on 2017/4/26.
//  Copyright © 2017年 L. All rights reserved.
//

import UIKit
import Alamofire
import AVOSCloud

class LoginViewController: UIViewController,UIViewControllerTransitioningDelegate {

    //保存云服务器的数据
    var login:[AVObject]!
    var x:Int? = nil
    let transition = fadeAnimator()
    
    @IBOutlet weak var loginOutlet: UIButton!//登录按钮
    @IBOutlet weak var topView: UIView!//半透明层
    @IBOutlet weak var tishi: UILabel!//提示label
    @IBOutlet weak var userName: UITextField!//昵称文本库
    @IBOutlet weak var userPassword: UITextField!//密码文本框
    //登录按钮点击事件
    @IBAction func userLogin(_ sender: UIButton) {
       getObjectFromCloud()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        networkStatusListener()
        
        //半透明层
        topView.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 0.5)
       
    
        
        //登录按钮点击时，按钮文字颜色变化
        loginOutlet.setTitleColor(UIColor(red: 123/255, green: 123/255, blue: 123/255, alpha: 0.8), for: .highlighted)
        userName.clearButtonMode = .whileEditing
        
        
        getPoint()
        
        
    }
    
    override func viewDidLayoutSubviews() {
        makeLine()
    }
    
    override func viewWillLayoutSubviews() {
        
    }

    override func viewWillAppear(_ animated: Bool) {
        //隐藏导航栏
        self.navigationController?.isNavigationBarHidden = true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return transition
    }
    
    
    func networkStatusListener(){
        //1.设置网络监听状态 2。获得网络Reachability对象
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged),name: ReachabilityChangedNotification,object: reachability)
        do{
            // 3、开启网络状态消息监听
            try reacha?.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
    }
    
    // 主动检测网络状态
    func reachabilityChanged(note: NSNotification) {
        
        let reachability = note.object as! Reachability // 准备获取网络连接信息
        
        if reachability.isReachable { // 判断网络连接状态
            print("网络连接：可用")
            if reachability.isReachableViaWiFi { // 判断网络连接类型
                print("连接类型：WiFi")
                DispatchQueue.main.async {
                    self.alert_noNetwrok(statu: "正在使用wifi")
                }
                // strServerInternetAddrss = getHostAddress_WLAN() // 获取主机IP地址 192.168.31.2 小米路由器
                // processClientSocket(strServerInternetAddrss)    // 初始化Socket并连接，还得恢复按钮可用
            } else {
                print("连接类型：移动网络")
                DispatchQueue.main.async {
                    self.alert_noNetwrok(statu: "正在使用数据流量")
                }
                // getHostAddrss_GPRS()  // 通过外网获取主机IP地址，并且初始化Socket并建立连接
            }
        } else {
            print("网络连接：不可用")
            DispatchQueue.main.async { // 不加这句导致界面还没初始化完成就打开警告框，这样不行
                self.alert_noNetwrok(statu: "网络连接已关闭") // 警告框，提示没有网络
            }
        }
    }
    
    // 警告框，提示没有连接网络 *********************
    func alert_noNetwrok(statu:String) -> Void {
        //获取当前用户浏览页面的控制器
        let window = UIApplication.shared.keyWindow
        let rootVC = window?.rootViewController
        var vc:UIViewController!
        
        guard rootVC != nil else {
            return
        }
        
        if rootVC?.presentedViewController != nil{
            vc = rootVC
        }
        
        if rootVC?.isKind(of: UINavigationController.self) == true{
            let nave = rootVC as! UINavigationController
            vc = nave.visibleViewController
        }
        
        if rootVC?.isKind(of: UITabBarController.self) == true{
            let tab = (rootVC as! UITabBarController).selectedViewController
            vc = tab
        }
        
        //获取到以后，加上提示框
        FTIndicator.setIndicatorStyle(.dark)
        FTIndicator.showNotification(withTitle: "", message: statu)
        
        //        let alert = UIAlertController(title: "系统提示", message: statu, preferredStyle: .alert)
        //        let cancelAction = UIAlertAction(title: "确定", style: .default, handler: nil)
        //        alert.addAction(cancelAction)
        //        vc.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - 画横线
    
    //昵称和密码下面的横线
    func makeLine(){
        
        if x != nil{
        let line = lineView()
        line.frame = CGRect(x: self.userName.frame.minX, y:self.userName.frame.maxY , width: self.userName.bounds.width, height: 2)
            
        let line2 = lineView()
        line2.frame = CGRect(x: self.userPassword.frame.minX, y:self.userPassword.frame.maxY , width: self.userPassword.bounds.width, height: 2)

         self.topView.addSubview(line)
         self.topView.addSubview(line2)
        }
        x = 0
     }
    
    //点击空白区域关闭键盘
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func close(segue:UIStoryboardSegue) {
    
    }
    
    //MARK: - 从云服务器下载数据
    func getObjectFromCloud(needUpdate:Bool = false){
        print(self.userName.frame.maxY)
        print(self.userPassword.frame.maxY)
       
        let query = AVQuery(className: "UserInfo")
        query.order(byDescending: "createdAt")

        query.findObjectsInBackground { (result, error) in
            if let results = result as?[AVObject]{
                self.login = results
                self.verificationLogin()
                
            }else{
                print(error ?? "未知错误")
            }
        }
    }
   
    //账号密码判断
    func verificationLogin(){
        for i in 0..<self.login.count{
            //账号密码做判断
            if self.userName.text == self.login[i]["userName"] as? String && self.userPassword.text == self.login[i]["userPwd"] as? String{
                //存储登录昵称
                let defaults = UserDefaults.standard
                let lableData = NSKeyedArchiver.archivedData(withRootObject: self.userName.text ?? "未显示")
                defaults.set(lableData, forKey: "name")
                
                //跳转
                let sb = UIStoryboard(name: "Main", bundle:nil)
                let vc = sb.instantiateViewController(withIdentifier: "tabbar")
                vc.transitioningDelegate = self
                self.present(vc, animated: true, completion: nil)
            }
        }
        self.tishi.text = "用户名或者密码错误"
    }
    
    //用百度api拿到地址坐标
    func getPoint() {
        
        var x1:Double!
        var y1:Double!
        
        Alamofire.request("https://api.map.baidu.com/location/ip?ak=6imoN8a44I7y8kmuvxn2WDSo4UPDKdMH&mcode=bloc.io.UU&coor=bd09ll").responseJSON { (response) in
            switch response.result{
            case .success(let json):
               
                let dict = json as! Dictionary<String,AnyObject>
                let locationInfo = (dict as AnyObject).value(forKey: "content")
                let location = (locationInfo as AnyObject).value(forKey: "address")
                
                //取坐标
                let point = (locationInfo as AnyObject).value(forKey:"point")
                let x = (point as AnyObject).value(forKey: "x")
                x1 = (x as! String).DoubleValue
                let y = (point as AnyObject).value(forKey: "y")
                y1 = (y as! String).DoubleValue
                
                //存储坐标
                let defaults = UserDefaults.standard
                let str = NSKeyedArchiver.archivedData(withRootObject: [x1,y1])
                defaults.set(str, forKey: "point")
                
                let str2 = NSKeyedArchiver.archivedData(withRootObject: location ?? "未显示" )
                defaults.set(str2, forKey: "city")
            
            case .failure(let error):
                print(error)
            }
        }
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

//线条类
class lineView:UIView{
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
        context?.setStrokeColor(red: 90/255, green: 110/255, blue: 168/255, alpha: 1 )
        context?.setAllowsAntialiasing(true)
        
        //x 100-120,y 100
        context?.setLineWidth(1)
        context?.move(to: CGPoint(x: 0, y: 0))
        context?.addLine(to: CGPoint(x: width, y: 0))
        context?.strokePath()
    }
}

