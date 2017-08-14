//
//  addressSelecteViewController.swift
//  UU
//
//  Created by admin on 2017/5/9.
//  Copyright © 2017年 L. All rights reserved.
//

import UIKit
protocol addressResult {
    func addressSelect(address:String)
}

class addressSelecteViewController: UIViewController {
    let width:CGFloat = UIScreen.main.bounds.width/3
    var isY = true
    
    @IBOutlet weak var addressTextfield: UITextField!
    @IBOutlet weak var addressPickerView: UIPickerView!
    
    //所有地址数据集合
    var addressArray = [[String:AnyObject]]()
    
    //选择省的索引
    var provinceIndex = 0
    
    //选择市的索引
    var cityIndex = 0
    
    //选择地区的索引
    var areaIndex = 0
    
    var delegate:addressResult?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = UIBarButtonItem(title: "保存", style: .plain, target: self, action: #selector(saveInfo))
        self.navigationItem.rightBarButtonItem = button
        
        addressPickerView.delegate = self
        addressPickerView.dataSource = self
        //初始化数据
        let path = Bundle.main.path(forResource: "address", ofType: "plist")
        self.addressArray = NSArray(contentsOfFile: path!) as! Array
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        if isY == false{
        let line = lineView()
        line.frame = CGRect(x: self.addressTextfield.frame.minX, y: self.addressTextfield.frame.maxY, width: self.addressTextfield.frame.width, height: 2)
        self.view.addSubview(line)
        }
        self.isY = false
    }
    
    func saveInfo(){
        delegate?.addressSelect(address: addressTextfield.text!)
        self.navigationController?.popToViewController((self.navigationController?.viewControllers[1])!, animated: true)
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
extension addressSelecteViewController:UIPickerViewDelegate,UIPickerViewDataSource{
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
        return 20
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
        associationData()
        
    }
    
    //改变字体大小
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
    
    //使滚动框和文本框数据联动
    func associationData(){
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
        self.addressTextfield.text = "\(provincee)\(cityy)\(area)"
    }

}
