//
//  massTrianPlanViewController.swift
//  UU
//
//  Created by admin on 2017/7/21.
//  Copyright © 2017年 L. All rights reserved.
//

import UIKit

class massTrianPlanViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var routeSearch:BMKRouteSearch! = BMKRouteSearch()
    var startPlanNode:BMKPlanNode! = BMKPlanNode()//出发点
    var endPlanNode:BMKPlanNode! = BMKPlanNode()//目的地
    var option:BMKMassTransitRoutePlanOption! = BMKMassTransitRoutePlanOption()//跨境交通
    var massTrainArray:[BMKMassTransitRouteLine]! = []
    var massTrainStepArray:[BMKMassTransitSubStep] = []
    var startName:String!
    var startCityName:String!
    var endName:String!
    var endCityName:String!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        routeSearch.delegate = self
        
        self.startPlanNode.name = startName
        self.startPlanNode.cityName = startCityName
        self.endPlanNode.name = endName
        self.endPlanNode.cityName = endCityName

        option.from = self.startPlanNode
        option.to = self.endPlanNode
        let flag = routeSearch.massTransitSearch(self.option)
        if flag{
            print("公交路线搜索成功")
        }else{
            print("公交路线搜索失败")
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension massTrianPlanViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return massTrainArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "massCell", for: indexPath) as! tarinTableViewCell
        let array = massTrainArray[indexPath.row]
        cell.startAddress.text = startCityName
        cell.endAddress.text = endCityName
        cell.timeLabel.text = ("\(array.duration.dates)天\(array.duration.hours)时\(array.duration.minutes)秒")
        cell.distanceLabel.text = ("\((array.distance)/100)km")
        cell.priceLabel.text = "\(array.price)元"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sb = UIStoryboard(name: "SecondTab", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "detailPlanView") as! detailMassPlanViewController
        vc.detailPlan = massTrainArray[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension massTrianPlanViewController:BMKRouteSearchDelegate{
    func onGetMassTransitRouteResult(_ searcher: BMKRouteSearch!, result: BMKMassTransitRouteResult!, errorCode error: BMKSearchErrorCode) {
        //成功获取结果
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

        if error == BMK_SEARCH_NO_ERROR{
        if let info = result.routes as? [BMKMassTransitRouteLine]{
            self.massTrainArray = info
            self.tableView.reloadData()
            for value in info{
                print(value.duration.dates)//路途天数
                print(value.duration.hours)//小时
                print(value.duration.minutes)//分钟
                
                
                print(value.title)
                print(value.price)//价格
                print(value.distance)//长度
                //   print(value.title.characters)
                print(value.starting.title)//起始
                print(value.terminal.title)//目的地
                if let steps = value.steps{
                    //方案
                    for step in (steps as? [BMKMassTransitStep])!{
                     
                        self.massTrainStepArray = (step.steps as? [BMKMassTransitSubStep])!
                        //  子方案
                        for stepValue in (step.steps as? [BMKMassTransitSubStep])!{
                            print(stepValue.instructions)
                            print(stepValue.stepType)
                            print(stepValue.vehicleInfo)
                            print(stepValue.entraceCoor)
                            print(stepValue.exitCoor)
                        }
                    }
                }
            }
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
        }
        
    }
}
