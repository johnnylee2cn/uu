//
//  searchTFModel.swift
//  UU
//
//  Created by admin on 2017/7/11.
//  Copyright © 2017年 L. All rights reserved.
//

import UIKit

class searchModel{
    var title:String
    var userName:String
    var address:String
    var text:NSMutableAttributedString
    var id:String
    var time:Date
    var isSelected:Bool
    
    
    init(title:String,userName:String,address:String,text:NSMutableAttributedString,time:Date,id:String,isSelected:Bool) {
        self.title = title
        self.userName = userName
        self.address = address
        self.text = text
        self.time = time
        self.id = id
        self.isSelected = isSelected
    }
}
