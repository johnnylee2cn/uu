//
//  positionModel.swift
//  UU
//
//  Created by admin on 2017/7/17.
//  Copyright © 2017年 L. All rights reserved.
//

import UIKit
import Alamofire

class pointModel{
    var latitude:CGFloat!
    var longitude:CGFloat!
    var startBool:Bool!
    init(latitude:CGFloat,longitude:CGFloat,startBool:Bool) {
        self.latitude = latitude
        self.longitude = longitude
        self.startBool = startBool
    }
}

class positionAPI{
    init(cityName:String,bool:Bool) {
        let url = "https://api.map.baidu.com/geocoder/v2/"
        let parame = ["address":"\(cityName)","output":"json","ak":"6imoN8a44I7y8kmuvxn2WDSo4UPDKdMH","mcode":"bloc.io.UU","callback":"showLocation"]
        Alamofire.request(url, method: .post, parameters: parame, encoding: URLEncoding.default, headers: nil)
            .responseJSON(completionHandler: { (response) in
                OperationQueue.main.addOperation {
                    switch response.result{
                    case .success(let json):
                        let dict = json as! Dictionary<String,AnyObject>
                        let result = (dict as AnyObject).value(forKey: "result")
                        let location = (result as AnyObject).value(forKey: "location")
                        let lat = (location as AnyObject).value!(forKey:"lat")
                        let x1 = lat!
                        let lng = (location as AnyObject).value!(forKey:"lng")
                        let y1 = lng!
                      let point = pointModel(latitude: x1 as! CGFloat, longitude: y1 as! CGFloat, startBool: bool)
                        let notificationName = Notification.Name(rawValue: "position")
                        NotificationCenter.default.post(name: notificationName, object: nil, userInfo: ["value1":point])
                    case .failure(let error):
                        print(error)
                    }
                }
            })
    }
}
