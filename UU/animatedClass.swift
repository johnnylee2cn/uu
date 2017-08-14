//
//  animatedClass.swift
//  UU
//
//  Created by admin on 2017/7/28.
//  Copyright © 2017年 L. All rights reserved.
//

import UIKit

class fadeAnimator: NSObject,UIViewControllerAnimatedTransitioning {
    let duration = 1.5
    
    //指定转场动画持续的时间
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TimeInterval(duration)
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //得到容器视图
        let containerView = transitionContext.containerView
        let key = UITransitionContextViewKey.to
        //目标视图
        let toView = transitionContext.view(forKey: key)!
        containerView.addSubview(toView)
        
        //为目标视图展现动画
        toView.alpha = 0.0
        UIView.animate(withDuration: TimeInterval(duration), animations: { 
            toView.alpha = 1.0
        }) { (_) in
            transitionContext.completeTransition(true)
        }
    }
    
}

class customAlert:UIView{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeAlert(text:String){
//        let alertView = UIView()
//                alertView.center = CGPoint(x:view.bounds.width/2, y: view.bounds.height/2)
//                alertView.frame.size = CGSize(width: 280, height: 160)
        
                let imageView = UIImageView(frame: CGRect(x: 10, y: 20, width: 120, height: 120))
                imageView.image = UIImage(named: "傻")
                self.addSubview(imageView)
        
                let textView = UITextView(frame: CGRect(x: 140, y: 20, width: 140, height: 90))
                textView.text = text
                textView.font = UIFont.systemFont(ofSize: 15)
                textView.backgroundColor = UIColor(red: 103/255, green: 131/255, blue: 188/255, alpha: 1)
                self.addSubview(textView)
        
                let button = UIButton(frame: CGRect(x: 150, y: 110, width: 120, height: 30))
                button.setTitle("确定", for: .normal)
                button.backgroundColor = UIColor(red: 102/255, green: 94/255, blue: 130/255, alpha: 1)
                button.tintColor = UIColor.black
                button.addTarget(self, action: #selector(closeView), for: .touchUpInside)
                self.addSubview(button)
    }
    
    func closeView(send:UIButton){
        send.superview?.removeFromSuperview()
    }
    
//    init(text:String,view:UIView) {
//        let alertView = UIView()
//        alertView.center = CGPoint(x:view.bounds.width/2, y: view.bounds.height/2)
//        alertView.frame.size = CGSize(width: 280, height: 160)
//        
//        let imageView = UIImageView(frame: CGRect(x: 20, y: 20, width: 120, height: 120))
//        imageView.image = UIImage(named: "傻")
//        alertView.addSubview(imageView)
//        
//        let label = UILabel(frame: CGRect(x: 140, y: 20, width: 140, height: 90))
//        label.font = UIFont.systemFont(ofSize: 15)
//        alertView.addSubview(label)
//        
//        let button = UIButton(frame: CGRect(x: 140, y: 90, width: 140, height: 30))
//        alertView.addSubview(button)
//    }
}
