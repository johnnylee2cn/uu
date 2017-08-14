//
//  searchTFAPI.swift
//  UU
//
//  Created by admin on 2017/7/11.
//  Copyright © 2017年 L. All rights reserved.
//

import UIKit
import AVOSCloud

protocol dataToSearchTF {
    func dataMethod(model:[searchModel])
}

class searchTFAPI{
    var searchAVObject:[searchModel] = []
    var boolClick:Bool! = false
    var delegate:dataToSearchTF?
    
    init(userName:String,skip:Int){
    // MARK: - 和云数据交互
    
        let query = AVQuery(className: "searchTripInfo")
        query.order(byDescending: "createdAt")
        
        query.limit = 5 //最多返回wu条
        query.skip = 5 * skip //跳过多少条
        print(query.skip)
        
        query.findObjectsInBackground { (result, error) in
            if let results = result as? [AVObject]{
   
                for value in results{
                    let name = value["userName"] as? String
 
                    let title = value["articleTitle"] as? String

                    let id = value["objectId"] as? String
                    let bool = self.getLike(id: id!, name:userName )
                    
                    var address = ""
                    if value["userAddress"] != nil{
                        address = (value["userAddress"] as? String)!
                    }else{
                        address = "未设置"
                    }
                    
                    
                    let time = value["createdAt"] as? Date
                    let attributed = NSMutableAttributedString()
                    
                    //让图片单独起一行
                    let textValue = (value["articleText"] as? String)! + "\n\n"
                    let text = NSAttributedString(string: textValue)
                    attributed.append(text)
                    
                    if let imgFile = value["articleImage"] as? AVFile{
                      let url = URL(string: imgFile.url!)
                            if let imgArray = imgFile.getData(){
                              
                                    let image = NSKeyedUnarchiver.unarchiveObject(with: imgArray) as! Array<Any>
                                    for i in 0..<image.count{
                                        let attachment = NSTextAttachment()
                                        let imageView = UIImageView()
                                        imageView.kf.setImage(with: url)
                                        attachment.image = image[i] as? UIImage
                                       // 图片之间留点空隙
                                        let text = NSAttributedString(string: " ")
                                        attributed.append(text)
                                        
                                        attachment.bounds = CGRect(x: 0, y: 0, width: 100.CGFloatValue, height: 100.CGFloatValue)
                                        attributed.append(NSAttributedString(attachment: attachment))
                                    }
                                let model = searchModel(title: title!, userName: name!, address: address, text: attributed, time: time!, id: id!, isSelected: bool)
                                    self.searchAVObject.append(model)
                            }
                        
                    }else{
                        let model = searchModel(title: title!, userName: name!, address: address, text: attributed, time: time!, id: id!, isSelected: bool)
                        self.searchAVObject.append(model)
                    }
                    
                   
                    
                }
                 self.delegate?.dataMethod(model: self.searchAVObject)
            }else{
                print(error ?? "未知错误")
            }
        }
    
    }
    
    func getLike(id:String,name:String)->Bool{
        
      
             let query = AVQuery(className: "clickHeart")
            query.whereKey("searchTripID", equalTo: id)
            query.whereKey("clickName", equalTo: name)
            let array = query.findObjects()
            if array?.count == 1{
               return true
            }else{
                return false
        }
        
           
        
    
            
        

    }
}
