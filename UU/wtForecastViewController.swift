//
//  wtForecastViewController.swift
//  UU
//
//  Created by admin on 2017/4/4.
//  Copyright © 2017年 L. All rights reserved.
//

import UIKit
import Alamofire
import SnapKit

class wtForecastViewController: UIViewController,UIScrollViewDelegate {
    
    var scrollView:UIScrollView!
    var swipeLeft:UISwipeGestureRecognizer!
    var swipeRight:UISwipeGestureRecognizer!
    var wtScrollView:UIScrollView!
    var imageView:UIImageView!
    var image:UIImageView!
    var imageName:String!
    var slidView:UIView!
    var tpLabel:UILabel! //气温
    var tplabel2:UILabel!//天气
    var label:UILabel!
    var label2:UILabel! = nil
    var temperature:Any!
    var skycon:Any!
    var count = 0
    var a:Bool = false
    var scroll = true
    var slid = true
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "po")

        bgScrollView()
        bgImageView()
      
       
        getWeather()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        wtScrollView.isHidden = false
        let defaults = UserDefaults.standard
        let objectData = defaults.data(forKey: "po")
        if objectData?.count != nil{
            getWeather()
        }
    }
    
    //MARK: - UI
    //生成背景图片 
    //生成页面滑动view
    func bgScrollView() {
        automaticallyAdjustsScrollViewInsets = false
        scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.frame = self.view.bounds
        scrollView.backgroundColor = UIColor.white
        scrollView.contentSize = CGSize(width: self.view.bounds.width, height: self.view.bounds.height)
//        scrollView.snp.makeConstraints { (make) in
//            make.left.equalTo(0)
//            make.right.equalTo(0)
//            make.top.equalTo(0)
//            make.bottom.equalTo(0)
//        }
        self.view.addSubview(scrollView)
        
    }
    func bgImageView(){
        //背景图片
        imageView = UIImageView()
        imageView.frame = self.view.bounds
        imageView.backgroundColor = UIColor.red
        imageView.image = UIImage(named: "57514aee2cf61_1024")
        self.scrollView.addSubview(imageView)
    }
    
    //MARKL - 生成24小时天气滑动view
    func getWTScrollView(){
        wtScrollView = UIScrollView()
        wtScrollView.frame = CGRect(x: 0+(self.count*width.IntValue).CGFloatValue, y: self.view.bounds.height/3, width: self.view.bounds.width, height: 100)
        wtScrollView.backgroundColor = UIColor.clear
        wtScrollView.contentSize = CGSize(width: self.view.bounds.width*8, height: 100)
        self.scrollView.addSubview(wtScrollView)
    }
    //24小时背景图片
    func makeImageInWTScrollView(imageName:String,image_x:CGFloat,wtScrollview:UIScrollView){
        let image = UIImageView()
        image.frame = CGRect(x: image_x, y: 30, width: 40, height: 40)
        image.image = UIImage(named: imageName)
        wtScrollview.addSubview(image)
    }
    
    
    
    //MARK: - UI功能
   
        //
    
    //MARK: - 数据
    
    //得到数据
    func getWeather(){
        let defaults = UserDefaults.standard
        let objectData = defaults.data(forKey: "po")
       
        //当值为nil，说明为自选地点.else有自选地点
        if objectData?.count == nil{
            whenCountIsNil()
        }else{
            whenCountIsNotNil()
          
        }
 }
    
    //当userdefault数值为0
    func whenCountIsNil(){
        let topView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
            topView.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 0.3)
            self.scrollView.addSubview(topView)
            getWTScrollView()
            let defaults = UserDefaults.standard
            let objectData = defaults.data(forKey: "point")
            let point = NSKeyedUnarchiver.unarchiveObject(with: objectData!) as! Array<Double>
            let point1 = point[0]
            let point2 = point[1]
            let defaults2 = UserDefaults.standard
            let objectData2 = defaults2.data(forKey: "city")
            let city = NSKeyedUnarchiver.unarchiveObject(with: objectData2!) as! String
            self.getAll(x:point2 , y:point1 ,cityName: city, wtScrollview: wtScrollView)
    }
    
    func whenCountIsNotNil(){
        
        let defaults = UserDefaults.standard
        let objectData = defaults.data(forKey: "po")
        let point = NSKeyedUnarchiver.unarchiveObject(with: objectData!) as! Array<Double>
        
        count = 1//当count = 1,第二页生成的view依此为参照
        secondeViewBGImage()//第二页背景图
        secondClearView()//第二页半透明层
        
       // getWTScrollView()//第二页24小时滑动栏
        
        //将大滑动栏内容宽度设为两个view
        scrollView.contentSize = CGSize(width: self.view.bounds.width+(count*width.IntValue).CGFloatValue, height: self.view.bounds.height)
       
        //第一页添加指示小箭头
        if slid == true{
            //在第一个页面添加滑动小箭头
            leftSlid()
            slid = false
        }
        
        //城市名称
        let point1 = point[0]
        let point2 = point[1]
        let defaults2 = UserDefaults.standard
        let objectData2 = defaults2.data(forKey: "ci")
        let city = NSKeyedUnarchiver.unarchiveObject(with: objectData2!) as! String
        getAll(x: point1, y: point2,cityName: city, wtScrollview: secondTwentyFour())
    }
    
    //第二页背景图片
    func secondeViewBGImage(){
        image = UIImageView()
        image.frame = CGRect(x: self.view.frame.maxX, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        image.backgroundColor = UIColor.red
        image.image = UIImage(named: "57514aee2cf61_1024")
        self.scrollView.addSubview(image)

    }
    
    //第二页半透明层
    func secondClearView(){
        let topView = UIView(frame: CGRect(x: width, y: 0, width: width, height: height))
        topView.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 0.3)
        self.scrollView.addSubview(topView)
    }
    
    //第二页24小时滑动栏
    func secondTwentyFour() ->UIScrollView{
        let tScrollView:UIScrollView = UIScrollView()
        tScrollView.frame = CGRect(x: width, y: self.view.bounds.height/3, width: self.view.bounds.width, height: 100)
        tScrollView.isPagingEnabled = true
        tScrollView.contentSize =  CGSize(width: self.view.bounds.width*7, height: 100)
        tScrollView.backgroundColor = UIColor.clear
        self.scrollView.addSubview(tScrollView)
        return tScrollView
    }
    
    
    //添加箭头
    func leftSlid(){
        
        let slidView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        let imageView = UIImageView(frame: CGRect(x: 300, y: 300, width: 50, height: 50))
        
        imageView.image = UIImage(named: "手势")
        slidView.addSubview(imageView)
     
        self.scrollView.addSubview(slidView)
        
        UIView.animate(withDuration:  3) {
           imageView.frame = CGRect(x: 250, y: 300, width: 50, height: 50)
            
             DispatchQueue.main.asyncAfter(deadline: .now()+3, execute: {
                slidView.removeFromSuperview()
            })
        }
    }
    
    //获取天气所有值
    func getAll(x:Double,y:Double,cityName:String,wtScrollview:UIScrollView){
        getCityName(cityName: cityName)
        getNowTemp()
        Thread.detachNewThread {
            wtAPI.init(x: x, y: y )//wpi获取坐标
        //得到数据的通知
        let notificationName = Notification.Name(rawValue: "通知")
        NotificationCenter.default.addObserver(self,
                                               selector:#selector(self.downloadImage(notification:)),
                                               name: notificationName, object: nil)

        }
                tweentyFour(x: x, y: y, wtScrollview: wtScrollview)
        }
    
    //得到地点名称
    func getCityName(cityName:String){
        self.tpLabel = UILabel()
        self.tpLabel.font = UIFont.systemFont(ofSize: 17)
        self.tpLabel.frame = CGRect(x: 0+(count*width.IntValue).CGFloatValue, y: 80, width: width, height: 30)
        self.tpLabel.backgroundColor = UIColor.clear
        self.tpLabel.text = cityName
        self.tpLabel.textColor = UIColor.white
        self.tpLabel.textAlignment = NSTextAlignment.center//文字居中
        self.scrollView.addSubview(self.tpLabel)
    }
    
    //得到实时天气
    func getNowTemp(){
        self.tplabel2 = UILabel()
        self.tplabel2.font = UIFont.systemFont(ofSize: 32)
        self.tplabel2.frame = CGRect(x: 0+(self.count*width.IntValue).CGFloatValue, y: 140, width: width, height: 30)
        self.tplabel2.textAlignment = NSTextAlignment.center//文字居中
        self.tplabel2.backgroundColor = UIColor.clear
        self.tplabel2.textColor = UIColor.orange
    }
    
    //通知后的事件.得到数据
    func downloadImage(notification: Notification) {
        let userInfo = notification.userInfo as! [String: AnyObject]
        let value1 = userInfo["value1"] as! [nowModel]
        self.tplabel2.text = value1[0].temperature!
        self.imageName = value1[0].imageName!
        self.scrollView.addSubview(tplabel2)
        let defaults = UserDefaults.standard
        let objectData = defaults.data(forKey: "po")
        
        if objectData?.count == nil{
            imageView.image = UIImage(named: imageName)
        }else{
            image.image = UIImage(named: imageName)
        }
       
    }
    
    func tweentyFour(x:Double,y:Double,wtScrollview:UIScrollView){
        Alamofire.request("https://api.caiyunapp.com/v2/X4cLQaUeRJwtJQe4/\(y),\(x)/forecast.json")
            .responseJSON { (response) in
                switch response.result{
                
                case .success(let json):
                    let dict = json as! Dictionary<String,AnyObject>
                    
                    //未来24小时
                    self.successGetTweentyFourTemp(dict: dict, wtScrollview: wtScrollview)
                    //  未来五天
                    self.dayAfterFiveDaytemp(dict: dict)
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    //如果成功，得到未来24小时天气状况
    func successGetTweentyFourTemp(dict:Dictionary<String,AnyObject>,wtScrollview:UIScrollView){
        let result = (dict as AnyObject).value(forKey: "result")
        //未来24小时
        let hourly = (result as AnyObject).value!(forKey:"hourly")
        //
        let skycon = (hourly as AnyObject).value!(forKey:"skycon") as! Array<Dictionary<String,String>>
        for i in 0..<skycon.count{
            //时间
            let datetime = (skycon[i] as AnyObject).value!(forKey:"datetime") as! String
            let value = (skycon[i] as AnyObject).value!(forKey:"value") as! String
            let dt = datetime.components(separatedBy: " ")
            //24小时温度
            self.label = UILabel()
            self.label.frame = CGRect(x: 0+i*70+self.count, y: 0, width: 500, height: 20)
            self.label.textColor = UIColor.black
            self.label.font = UIFont.systemFont(ofSize: 15)
            self.label.text = dt[1]
            wtScrollview.addSubview(self.label)
            
            //24小时天气概况
            self.label2 = UILabel()
            self.label2.frame = CGRect(x: self.label.frame.origin.x, y: 80, width: 500, height: 20)
            self.label2.textColor = UIColor.black
            self.label2.font = UIFont.systemFont(ofSize:15)
            
            self.labelAndImage(wtScrollview: wtScrollview, value: value)
        }
    }
    
    //24小时天气概况label 和图片
        func labelAndImage(wtScrollview:UIScrollView,value:String) {
        switch value{
            case "CLEAR_NIGHT":
                self.label2.text = "晴夜"
                self.makeImageInWTScrollView(imageName: "clearNightIcon",image_x: self.label.frame.origin.x, wtScrollview: wtScrollview)
                wtScrollview.addSubview(self.label2)
            case "CLEAR_DAY":
                self.makeImageInWTScrollView(imageName: "clearDayIcon",image_x: self.label.frame.origin.x, wtScrollview: wtScrollview)
                self.label2.text = "晴天"
                wtScrollview.addSubview(self.label2)
            case "PARTLY_CLOUDY_DAY":
                self.label2.text = "多云"
                self.makeImageInWTScrollView(imageName: "partlyDayIcon",image_x: self.label.frame.origin.x, wtScrollview: wtScrollview)
                wtScrollview.addSubview(self.label2)
            case "PARTLY_CLOUDY_NIGHT":
                self.label2.text = "多云"
                self.makeImageInWTScrollView(imageName: "partlyDayIcon",image_x: self.label.frame.origin.x, wtScrollview: wtScrollview)
                wtScrollview.addSubview(self.label2)
            case "CLOUDY":
                self.label2.text = "阴"
                self.makeImageInWTScrollView(imageName: "cloudyDayIcon",image_x: self.label.frame.origin.x, wtScrollview: wtScrollview)
                wtScrollview.addSubview(self.label2)
            case "Rain":
                self.label2.text = "雨"
                self.makeImageInWTScrollView(imageName: "rainDayIcon",image_x: self.label.frame.origin.x, wtScrollview: wtScrollview)
                wtScrollview.addSubview(self.label2)
            case "SNOW":
                self.label2.text = "雪"
                self.makeImageInWTScrollView(imageName: "snowDayIcon",image_x: self.label.frame.origin.x, wtScrollview: wtScrollview)
                wtScrollview.addSubview(self.label2)
            case "WIND":
                self.label2.text = "风"
                wtScrollview.addSubview(self.label2)
            case "FOG":
                self.label2.text = "雾"
                wtScrollview.addSubview(self.label2)
            default:
                self.label2.text = "天气概况：\(value)"
            }
        }

    //未来五天平均气温
    func dayAfterFiveDaytemp(dict:Dictionary<String,AnyObject>){
        let result = (dict as AnyObject).value(forKey: "result")
        let daily = (result as AnyObject).value(forKey:"daily")
        let tempForFiveDay = (daily as AnyObject).value(forKey:"temperature")
        let skykon = (daily as AnyObject).value(forKey:"skycon")//未来五天天气
        let valueFive = (skykon as AnyObject).value(forKey:"value") as! Array<String>
        let date = (tempForFiveDay as AnyObject).value(forKey:"date") as! Array<String>//日期
        let max = (tempForFiveDay as AnyObject).value(forKey:"max") as! Array<CGFloat>//最大温度
        let min = (tempForFiveDay as AnyObject).value(forKey:"min") as! Array<CGFloat>//最低温度
        self.future(date: date, valueToFive: valueFive, maxToFive: max, minToFive: min)
    }
    
    //未来五天天气
    func future(date:Array<String>,valueToFive:Array<String>,maxToFive:Array<CGFloat>,minToFive:Array<CGFloat>){
        
        for i in 0..<5{
            let dateLabel = UILabel()
            dateLabel.frame = CGRect(x: Int(0+(self.count*width.IntValue).CGFloatValue), y: self.wtScrollView.frame.maxY.IntValue+i*45, width: 200, height: 20)
            dateLabel.backgroundColor = UIColor.clear
            dateLabel.font = UIFont.systemFont(ofSize: 15)
            dateLabel.text = date[i]
            let dateLabel2 = UILabel()
            dateLabel2.frame = CGRect(x: Int(self.view.bounds.width-100)+self.count*width.IntValue, y: self.wtScrollView.frame.maxY.IntValue+i*45, width: 100, height: 20)
            dateLabel2.backgroundColor = UIColor.clear
            dateLabel2.text = "\(minToFive[i]) ~ \(maxToFive[i])"
            dateLabel2.font = UIFont.systemFont(ofSize: 15)
            let imageView = UIImageView()
            imageView.frame = CGRect(x: Int(self.view.bounds.width/2)+self.count*width.IntValue, y: self.wtScrollView.frame.maxY.IntValue+i*45, width: 30, height: 30)
            imageView.backgroundColor = UIColor.clear
            switch valueToFive[i]{
            case "CLEAR_NIGHT":
                imageView.image = UIImage(named: "clearNightIcon")
                self.scrollView.addSubview(imageView)
            case "CLEAR_DAY":
                imageView.image = UIImage(named: "clearDayIcon")
                self.scrollView.addSubview(imageView)
            case "PARTLY_CLOUDY_DAY":
                imageView.image = UIImage(named: "partlyDayIcon")
                self.scrollView.addSubview(imageView)
            case "PARTLY_CLOUDY_NIGHT":
                imageView.image = UIImage(named: "partlyDayIcon")
                self.scrollView.addSubview(imageView)
            case "CLOUDY":
                imageView.image = UIImage(named: "cloudyDayIcon")
                self.scrollView.addSubview(imageView)
            case "RAIN":
                imageView.image = UIImage(named: "rainDayIcon")
                self.scrollView.addSubview(imageView)
            case "SNOW":
                imageView.image = UIImage(named: "snowDayIcon")
                self.scrollView.addSubview(imageView)
            case "WIND":
                imageView.image = UIImage(named: "snowDayIcon")
                self.scrollView.addSubview(imageView)
            case "FOG":
                imageView.image = UIImage(named: "snowDayIcon")
                self.scrollView.addSubview(imageView)
            default:
                imageView.image = UIImage(named: "snowDayIcon")
                self.scrollView.addSubview(imageView)
            }

            scrollView.addSubview(dateLabel)
            scrollView.addSubview(dateLabel2)
            
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
