//
//  TFriendViewController.swift
//  UU
//
//  Created by admin on 2017/6/2.
//  Copyright © 2017年 L. All rights reserved.
//

import UIKit

class TFriendViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.tabBarController?.hidesBottomBarWhenPushed = true
        self.tabBarController?.tabBar.isHidden = true
        
        let barButton = UIBarButtonItem(title: "好友请求", style: .plain, target: self, action: #selector(addFriendNews))
        self.navigationItem.rightBarButtonItem = barButton
        
        let backButton = UIBarButtonItem(title: "返回", style: .plain, target: self, action: #selector(tabbarBack))
        self.navigationItem.leftBarButtonItem = backButton
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tabbarBack(){
        self.tabBarController?.hidesBottomBarWhenPushed = false
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.popViewController(animated: true)
        self.navigationController?.popToViewController((self.navigationController?.viewControllers[0])!, animated: true)
    }
    
    //跳转好友添加界面
    func addFriendNews(){
        
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "addNews")
        self.present(vc, animated: true, completion: nil)
    }

}
