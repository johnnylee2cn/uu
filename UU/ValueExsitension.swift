//
//  ValueExsitension.swift
//  UU
//
//  Created by admin on 2017/3/17.
//  Copyright © 2017年 L. All rights reserved.
//

import Foundation
import UIKit

extension UInt32{
    
    var FloatValue:Float{
        return Float(self)
    }
    
    
}

extension Int{
    var CGFloatValue:CGFloat{
        return CGFloat(self)
    }
}

extension CGFloat{
    var IntValue:Int{
        return Int(self)
    }
}

extension String{
    var  DoubleValue:Double{
        return Double(self)!
    }
}
