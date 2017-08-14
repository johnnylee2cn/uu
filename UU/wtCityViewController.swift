//
//  wtCityViewController.swift
//  UU
//
//  Created by admin on 2017/4/4.
//  Copyright © 2017年 L. All rights reserved.
//

import UIKit
import Alamofire

class wtCityViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource {

    let width:CGFloat = UIScreen.main.bounds.width/3
    var areaAddress:String! = nil
    var a:Bool = true
    @IBOutlet weak var areaPickerView: UIPickerView!
   
    @IBOutlet weak var cityTextField: UITextField!
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
        self.navigationController?.popToViewController((self.navigationController?.viewControllers[0])!, animated: true)
    }
    
    @IBAction func selecteArea(_ sender: UIBarButtonItem) {
        //获取选中的省
        let p = self.addressArray[provinceIndex]
        let province = p["state"]!
        
        //获取选中的市
        let c = p["cities"]![cityIndex] as! [String: AnyObject]
        let city = c["city"] as! String
        
        //获取选中的县（地区）
        var area = ""
        if (c["areas"] as! [String]).count > 0 {
            area = (c["areas"] as! [String])[areaIndex]
        }
        
        areaAddress = "\(province)\(city)\(area)"
        
        getLatitudeAndlongitude(cityName: areaAddress)
    }
    

    
    
    
    //所有地址数据集合
    var addressArray = [[String:AnyObject]]()
    
    //选择省的索引
    var provinceIndex = 0
    
    //选择市的索引
    var cityIndex = 0
    
    //选择地区的索引
    var areaIndex = 0
    
    var isY = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        areaPickerView.delegate = self
        areaPickerView.dataSource = self
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "po")
        //初始化数据
       let path = Bundle.main.path(forResource: "address", ofType: "plist")
       self.addressArray = NSArray(contentsOfFile: path!) as! Array
        
        
            }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        if isY == false{
        let line = lineView()
       
        line.frame = CGRect(x: self.cityTextField.frame.minX, y: self.cityTextField.frame.maxY + 55, width: self.cityTextField.frame.width, height: 2)
        self.view.addSubview(line)
        }
        
        self.isY = false
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
      
        switch component {
        case 0:
            return addressArray.count
        case 1:
           let province = addressArray[provinceIndex]
           return province["cities"]!.count
        default:
            let province = addressArray[provinceIndex]
            if let city = province["cities"]![cityIndex] as? [String:AnyObject]{
                                return city["areas"]!.count
            } else {
                
                return 0
            }
        }
     }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return width
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return self.addressArray[row]["state"] as? String
        }else if component == 1 {
            let province = self.addressArray[provinceIndex]
            let city = province["cities"]![row] as! [String: AnyObject]
            return city["city"] as? String
        }else {
            let province = self.addressArray[provinceIndex]
            let city = province["cities"]![cityIndex] as! [String: AnyObject]
            return city["areas"]![row] as? String
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //根据列、行索引判断需要改变数据的区域
        switch (component) {
        case 0:
            provinceIndex = row
            cityIndex = 0
            areaIndex = 0
            pickerView.reloadComponent(1)
            pickerView.reloadComponent(2)
            pickerView.selectRow(0, inComponent: 1, animated: false)
            pickerView.selectRow(0, inComponent: 2, animated: false)
        case 1:
            cityIndex = row
            areaIndex = 0
            pickerView.reloadComponent(2)
            pickerView.selectRow(0, inComponent: 2, animated: false)
        case 2:
            areaIndex = row
        default:
            break
        }
        let p = self.addressArray[provinceIndex]
        let provincee = p["state"]!
        
        //获取选中的市
        let c = p["cities"]![cityIndex] as! [String: AnyObject]
        let cityy = c["city"] as! String
        
        //获取选中的县（地区）
        var area = ""
        if (c["areas"] as! [String]).count > 0 {
            area = (c["areas"] as! [String])[areaIndex]
        }
        self.cityTextField.text = "\(provincee)\(cityy)\(area)"
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let lable=UILabel()
        lable.font = UIFont.systemFont(ofSize: 13)
        
        if component == 0 {
            lable.text = self.addressArray[row]["state"] as? String
        }else if component == 1 {
            let province = self.addressArray[provinceIndex]
            let city = province["cities"]![row] as! [String: AnyObject]
            lable.text = city["city"] as? String
        }else {
            let province = self.addressArray[provinceIndex]
            let city = province["cities"]![cityIndex] as! [String: AnyObject]
            lable.text = city["areas"]![row] as? String
        }

        return  lable
      }
    
    
    
    func getLatitudeAndlongitude(cityName:String){
        
        let url = "https://api.map.baidu.com/geocoder/v2/"
        let parame = ["address":"\(cityName)","output":"json","ak":"6imoN8a44I7y8kmuvxn2WDSo4UPDKdMH","mcode":"bloc.io.UU","callback":"showLocation"]
        Alamofire.request(url, method: .post, parameters: parame, encoding: URLEncoding.default, headers: nil)
            .responseJSON(completionHandler: { (response) in
                switch response.result{
                case .success(let json):
                    //print(json)
                    let dict = json as! Dictionary<String,AnyObject>
                    let result = (dict as AnyObject).value(forKey: "result")
                    let location = (result as AnyObject).value(forKey: "location")
                    let lat = (location as AnyObject).value!(forKey:"lat")
                    let x1 = lat!
                    //print(x1)
                    let lng = (location as AnyObject).value!(forKey:"lng")
                    let y1 = lng!
                    //print("--\(y1)--------------")
                    let defaults = UserDefaults.standard
                    let str = NSKeyedArchiver.archivedData(withRootObject: [x1,y1])
                    let ci = NSKeyedArchiver.archivedData(withRootObject: cityName)
                    defaults.set(str, forKey: "po")
                    defaults.set(ci, forKey: "ci")
                    self.navigationController?.popViewController(animated: true)
                    self.navigationController?.popToViewController((self.navigationController?.viewControllers[0])!, animated: true)
                case .failure(let error):
                    print(error)
                }
            })        
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
