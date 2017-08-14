//
//  wtAPI.swift
//  UU
//
//  Created by admin on 2017/4/20.
//  Copyright © 2017年 L. All rights reserved.
//

import UIKit
import Alamofire

class wtAPI{
    
    var albums = [nowModel]()
    
    init(x:Double,y:Double){
        
        var temp:String!
        var imageName:String!
      
        Alamofire.request("https://api.caiyunapp.com/v2/X4cLQaUeRJwtJQe4/\(y),\(x)/realtime.json")
            .responseJSON { (respons) in
                switch respons.result{
                case .success(let json):
                    let dict =  json as! Dictionary<String,AnyObject>
                    let weatherInfo = (dict as AnyObject).value(forKey: "result")
                    let skycon = (weatherInfo as AnyObject).value(forKey: "skycon")
                    let temp2 = (weatherInfo as AnyObject).value(forKey: "temperature")
                    switch skycon! as! String{
                    case "CLEAR_NIGHT":
                        imageName = "clearNight"
                        temp = "晴夜|\(String(describing: temp2!))"
                    case "CLEAR_DAY":
                       imageName =  "clearDay"
                        temp = "晴天|\(String(describing: temp2!))"
                    case "PARTLY_CLOUDY_DAY":
                        imageName =  "cloudyDay"
                        temp = "多云|\(String(describing: temp2!))"
                    case "PARTLY_CLOUDY_NIGHT":
                        imageName =  "cloudyDay"
                        temp = "多云|\(String(describing: temp2!))"
                    case "CLOUDY":
                        imageName =  "cloudyDay"
                        temp = "阴|\(String(describing: temp2!))"
                    case "RAIN":
                        imageName =  "cloudyDay"
                        temp = "雨|\(String(describing: temp2!))"
                    case "SNOW":
                        temp = "雪|\(String(describing: temp2!))"
                    case "WIND":
                        temp = "风|\(String(describing: temp2!))"
                    case "FOG":
                        temp = "雾|\(String(describing: temp2!))"
                    default:break
                    }
                    let model = nowModel(temperature: temp, addreess: "商户", imageName: imageName)
                self.albums.append(model )
                    let notificationName = Notification.Name(rawValue: "通知")
                    NotificationCenter.default.post(name: notificationName, object: nil, userInfo: ["value1":self.albums])
                 

                 //   self.reload()
                case .failure(let error):
                    print(error)
                }
                                
        }
    }
}
