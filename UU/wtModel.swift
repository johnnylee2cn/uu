//
//  wtModel.swift
//  UU
//
//  Created by admin on 2017/4/19.
//  Copyright © 2017年 L. All rights reserved.
//

import UIKit

struct nowModel {
    var temperature:String!
    var addreess:String!
    var imageName:String!
    
    init(temperature:String,addreess:String,imageName:String) {
        self.temperature = temperature
        self.addreess = addreess
        self.imageName = imageName
    }
}
