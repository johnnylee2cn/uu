//
//  SearchViewController.swift
//  UU
//
//  Created by admin on 2017/3/28.
//  Copyright © 2017年 L. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController,UISearchBarDelegate {

    var searchBar:UISearchBar!
    var BMKSearch = BMKPoiSearch()
    let tableView = UITableView()
    var dataSource:NSArray = []
    //var vView = UIView()
    @IBAction func rCancel(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "rMap", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // vView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        searchBar = UISearchBar()
        searchBar.frame = CGRect(x: 0, y:0, width: self.view.bounds.width, height: 30)
        searchBar.placeholder = "请输入地名"
        searchBar.delegate = self
        self.navigationItem.titleView = searchBar
        // Do any additional setup after loading the view.
        
        BMKSearch.delegate = self
     }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let defaults = UserDefaults.standard
        let objectData = defaults.data(forKey: "point")
        let point = NSKeyedUnarchiver.unarchiveObject(with: objectData!) as! Array<Double>
        let point1 = point[0]
        let point2 = point[1]
        print("point1:\(point1),point2:\(point2)")
        let option = BMKNearbySearchOption()
        option.location = CLLocationCoordinate2D(latitude: point2, longitude: point1)
        option.pageIndex = 0
        option.pageCapacity = 20
        option.keyword = searchBar.text
        
        let flag = BMKSearch.poiSearchNear(by: option)
        if flag{
                        print(" 搜索成功")
        }else{
            print(" 搜索失败")
        }
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
       
    
      
        return true
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

extension SearchViewController:BMKPoiSearchDelegate{
    func onGetPoiResult(_ searcher: BMKPoiSearch!, result poiResult: BMKPoiResult!, errorCode: BMKSearchErrorCode) {
        dataSource = poiResult.poiInfoList as NSArray!
      // print(poiResult.poiInfoList)
        tableView.frame = CGRect(x: 0, y: (self.navigationController?.navigationBar.bounds.height)! + 20, width: self.view.bounds.width, height: self.view.bounds.height)
        tableView .dataSource = self
        tableView.delegate = self
        self.tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "searchCell")
        self.view.addSubview(tableView)


    }
}

extension SearchViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(dataSource.count)
        let opi:BMKPoiInfo = dataSource[indexPath.row] as! BMKPoiInfo
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell")
        cell?.textLabel?.text = opi.name
        print(opi.name+">>>>")
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let defaults = UserDefaults.standard
        let cell:BMKPoiInfo = dataSource[indexPath.row] as! BMKPoiInfo
        let labelData = NSKeyedArchiver.archivedData(withRootObject:cell.name)
        defaults.set(labelData, forKey: "selectAddressName")
        

        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
