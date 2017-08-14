//
//  notoAPI.swift
//  UU
//
//  Created by admin on 2017/7/3.
//  Copyright © 2017年 L. All rights reserved.
//

import UIKit
import AVOSCloud
import Kingfisher
import SwiftyJSON

protocol dataToShowNoto {
    func dataMethod(model:[notoModel])
}

class notoAPI{
    var notoArray = [notoModel]()
    var delegate:dataToShowNoto?
    init(userName:String) {
 
        let query = AVQuery(className: "UserNoto")
        query.whereKey("userName", equalTo: userName)
        query.order(byDescending: "createdAt")
        query.limit = 10 //返回数量
        
        query.findObjectsInBackground { (result, error) in
            if let results = result as? [AVObject]{
                  for value in results{
                    let attributed = NSMutableAttributedString()
                    let textValue = (value["notoText"] as! String) + "\n\n"
                      let text = NSAttributedString(string: textValue)
                         attributed.append(text)
                    
                        if let imgFile = value["notoImage"] as? AVFile{
                            if let imgArray =  imgFile.getData(){
                                let imageArray = NSKeyedUnarchiver.unarchiveObject(with: imgArray) as! Array<Any>
                                for i in 0..<imageArray.count{
                                 let attachment = NSTextAttachment()
                                    
                                   attachment.image  = imageArray[i] as? UIImage
                                    
                                    // 图片之间留点空隙
                                    let text = NSAttributedString(string: " ")
                                    attributed.append(text)
                                    
                                   attachment.bounds = CGRect(x: 0, y: 0, width: 100.CGFloatValue, height: 100.CGFloatValue)
                                    attributed.append(NSAttributedString(attachment: attachment))
                                      }
                
                                    let model = notoModel(text: attributed, time: value["createdAt"] as! Date, object: value)
                                    self.notoArray.append(model)
                               

//                                    let notificationName = Notification.Name(rawValue: "noto")
//                                NotificationCenter.default.post(name: notificationName, object: nil, userInfo: ["value1":self.notoArray])

                            }
                      }
                        else{
                        let model = notoModel(text: attributed, time: value["createdAt"] as! Date, object: value)
                        self.notoArray.append(model)
//                            let notificationName = Notification.Name(rawValue: "noto")
//                    NotificationCenter.default.post(name: notificationName, object: nil, userInfo: ["value1":self.notoArray])
                    }
                    self.delegate?.dataMethod(model: self.notoArray)
                  }
                    }else{
                print(error ?? "未知错误")
            }
                }
        }
    
    
    
    
    
    
    
}

