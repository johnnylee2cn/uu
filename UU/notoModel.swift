//
//  notoModel.swift
//  UU
//
//  Created by admin on 2017/7/3.
//  Copyright © 2017年 L. All rights reserved.
//

import UIKit
import AVOSCloud

struct notoModel{
    var text:NSMutableAttributedString!
    var time:Date!
    var object:AVObject!
    init(text:NSMutableAttributedString,time:Date,object:AVObject) {
        self.text = text
        self.time = time
        self.object = object
    }
}
