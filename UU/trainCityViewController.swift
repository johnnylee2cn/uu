//
//  trainCityViewController.swift
//  UU
//
//  Created by admin on 2017/7/22.
//  Copyright © 2017年 L. All rights reserved.
//

import UIKit

class trainCityViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!

    var routeSearch:BMKRouteSearch! = BMKRouteSearch()
    var startPlanNode:BMKPlanNode! = BMKPlanNode()//出发点
    var endPlanNode:BMKPlanNode! = BMKPlanNode()//目的地
    var option:BMKTransitRoutePlanOption! = BMKTransitRoutePlanOption()//跨境交通
    var trainArray:[BMKTransitRouteLine]! = []
    var trainStepArray:[BMKTransitStep] = []
    var startName:String!
    var startCityName:String!
    var endName:String!
    var endCityName:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        routeSearch.delegate = self
        self.startPlanNode.name = "佛山"
        self.startPlanNode.cityName = "祖庙"
        self.endPlanNode.name = "广州"
        self.endPlanNode.cityName = "黄沙"
        option.from = startPlanNode
        option.to = endPlanNode
        option.city = "广州"
        
        let flag = routeSearch.transitSearch(self.option)
        
        if flag{
            print("公交路线搜索成功")
        }else{
            print("公交路线搜索失败")
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - tableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return trainArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityPlanCell", for: indexPath) as! trainCityTableViewCell
        let array = trainArray[indexPath.row]
        
        cell.startLabel.text = array.starting.title
        cell.endLabel.text = array.terminal.title
        cell.timeLabel.text = "\(array.duration.dates)天\(array.duration.hours)时\(array.duration.minutes)分"
        cell.distanceLabel.text = "\(array.distance/10)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sb = UIStoryboard(name: "SecondTab", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "detaiCityPlan") as! detailCityViewController
        vc.detailPlan = trainArray[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
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

extension trainCityViewController:BMKRouteSearchDelegate{
    func onGetTransitRouteResult(_ searcher: BMKRouteSearch!, result: BMKTransitRouteResult!, errorCode error: BMKSearchErrorCode) {
      //  print(result.routes.count)
        if error == BMK_SEARCH_NO_ERROR{
            // print(result.suggestAddrResult.startCityList.count)
            //print(result.routes.count)
            if let info = result.routes as? [BMKTransitRouteLine]{
                trainArray = info
                self.tableView.reloadData()
            }
            
        }else if error == BMK_SEARCH_AMBIGUOUS_KEYWORD{
            print("检索词有歧义")
        }else if error == BMK_SEARCH_AMBIGUOUS_ROURE_ADDR{
            print("检索地址有歧义")
        }else if error == BMK_SEARCH_NOT_SUPPORT_BUS{
            print("该城市不支持公交搜索")
        }else if error == BMK_SEARCH_NOT_SUPPORT_BUS_2CITY{
            print("该城市不支持跨城公交搜索")
        }else if error == BMK_SEARCH_RESULT_NOT_FOUND{
            print("没有找到检索结果")
        }else if error == BMK_SEARCH_PARAMETER_ERROR{
            print("参数错误")
        }else if error == BMK_SEARCH_ST_EN_TOO_NEAR{
            print("起始点太近")
            //        BMK_SEARCH_KEY_ERROR,///<key错误
            //        BMK_SEARCH_NETWOKR_ERROR,///网络连接错误
            //        BMK_SEARCH_NETWOKR_TIMEOUT,///网络连接超时
            //        BMK_SEARCH_PERMISSION_UNFINISHED,///还未完成鉴权，请在鉴权通过后重试
        }else if error == BMK_SEARCH_KEY_ERROR{
            print("key错误")
        }else if error == BMK_SEARCH_NETWOKR_ERROR{
            print("网络连接错误")
        }else if error == BMK_SEARCH_NETWOKR_TIMEOUT{
            print("网络连接超时")
        }else if error == BMK_SEARCH_PERMISSION_UNFINISHED{
            print("还未完成鉴权，请在鉴权通过后重试")
        }

    }
}
