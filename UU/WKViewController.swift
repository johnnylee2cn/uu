//
//  WKViewController.swift
//  UU
//
//  Created by admin on 2017/3/15.
//  Copyright © 2017年 L. All rights reserved.
//

import UIKit
import WebKit

class WKViewController: UIViewController {

    var link:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let UserDefault = UserDefaults.standard
        let objData = UserDefault.data(forKey: "url")
        //还原对象
        link = NSKeyedUnarchiver.unarchiveObject(with: objData!) as! String
 
        let wkWebView = WKWebView(frame: view.frame) //初始化
        wkWebView.autoresizingMask = [.flexibleHeight]
        view.addSubview(wkWebView)//载入视图
        //载入网址
        if let url = URL(string: link){
            let request = URLRequest(url: url)
            wkWebView.load(request)
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
