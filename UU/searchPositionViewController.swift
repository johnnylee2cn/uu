//
//  searchPositionViewController.swift
//  UU
//
//  Created by admin on 2017/7/16.
//  Copyright © 2017年 L. All rights reserved.
//

import UIKit
import Alamofire
import FTIndicator

protocol passValueDelegate {
    func passValue(bool:Bool,value:String)
}

class searchPositionViewController: UIViewController,UISearchBarDelegate {

    var searchBar:UISearchBar!
    var BMKSearch = BMKPoiSearch()
    let tableView = UITableView()
    var dataSource:NSArray!
    var textName = ""
    var delegate:passValueDelegate?
  //  var searchVCResult:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar = UISearchBar()
        searchBar.frame = CGRect(x: 0, y:0, width: self.view.bounds.width, height: 30)
        searchBar.placeholder = "请输入地名"
        searchBar.delegate = self
        self.navigationItem.titleView = searchBar
         BMKSearch.delegate = self
        
                // Do any additional setup after loading the view.
        
       
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillDisappear(_ animated: Bool) {
       
    }
    
    //MARK: - 搜索方法
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //得到所在城市名
        let defaults2 = UserDefaults.standard
        let objectData2 = defaults2.data(forKey: "city")
        let city = NSKeyedUnarchiver.unarchiveObject(with: objectData2!) as! String
        
        let option = BMKCitySearchOption()
        option.city = city
        option.keyword = searchBar.text
        option.pageIndex = 0
        option.pageCapacity = 20
        
        
        let flag = BMKSearch.poiSearch(inCity: option)
        if flag{
            print(" 搜索成功")
        }else{
            print(" 搜索失败")
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

extension searchPositionViewController:BMKPoiSearchDelegate{
    func onGetPoiResult(_ searcher: BMKPoiSearch!, result poiResult: BMKPoiResult!, errorCode: BMKSearchErrorCode) {
        if errorCode == BMK_SEARCH_RESULT_NOT_FOUND{
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
        }else if errorCode == BMK_SEARCH_NO_ERROR{
            //数据源添加数据
        dataSource = poiResult.poiInfoList as NSArray!
            // print(poiResult.poiInfoList)
        tableView.frame = CGRect(x: 0, y: (self.navigationController?.navigationBar.bounds.height)! + 20, width: self.view.bounds.width, height: self.view.bounds.height)
        tableView .dataSource = self
        tableView.delegate = self
        self.tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "searchCell")
        self.view.addSubview(tableView)
        }
        
     }
}

extension searchPositionViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let opi:BMKPoiInfo = dataSource[indexPath.row] as! BMKPoiInfo
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell")
        cell?.textLabel?.text = opi.name
        print(opi.name+">>>>")
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let opi:BMKPoiInfo = dataSource[(tableView.indexPathForSelectedRow?.row)!] as! BMKPoiInfo
        //下一步写protocol
        if textName == "始"{
            delegate?.passValue(bool: true, value: opi.name)
        }else{
            delegate?.passValue(bool: false, value: opi.name)
        }
        self.navigationController?.popToViewController((self.navigationController?.viewControllers[1])!, animated: true)
    }
}

