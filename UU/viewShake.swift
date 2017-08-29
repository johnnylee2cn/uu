//
//  viewShake.swift
//  UU
//
//  Created by admin on 2017/8/21.
//  Copyright © 2017年 L. All rights reserved.
//

import UIKit

enum shakeDirection {
    case horizontal //水平抖动
    case vertical  //垂直抖动
}

extension UIView{
    /**
     扩展UIView增加抖动方法
     
     @param direction：抖动方向（默认是水平方向）
     @param times：抖动次数（默认5次）
     @param interval：每次抖动时间（默认0.1秒）
     @param delta：抖动偏移量（默认2）
     @param completion：抖动动画结束后的回调
     */
     func shake(direction:shakeDirection = .horizontal,times:Int = 5,interval:TimeInterval = 0.1,delta:Int = 2,completion:(() -> Void)? = nil){
        UIView.animate(withDuration: interval, animations: { 
            switch direction{
            case .horizontal:
                self.layer.setAffineTransform(CGAffineTransform(translationX: CGFloat(delta), y: 0))
                break
            case .vertical:
                self.layer.setAffineTransform(CGAffineTransform(translationX: 0, y: CGFloat(delta)))
                break
            }
        }) { (complete) in
            //如果当前是最后一次抖动，则还原
            if (times == 0){
                UIView.animate(withDuration: interval, animations: { 
                    self.layer.setAffineTransform(CGAffineTransform.identity)
                }, completion: { (complete) in
                    completion?()
                })
            }else{
                self.shake(direction: direction, times: times - 1, interval: interval, delta: delta * -1, completion: completion)
            }
        }
        
    }
}
