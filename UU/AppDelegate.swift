
//
//  AppDelegate.swift
//  UU
//
//  Created by admin on 2017/3/14.
//  Copyright © 2017年 L. All rights reserved.
//

import UIKit
import CoreData
import AVOSCloud

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var bool:Bool! = true
    let manage = BMKMapManager()
    var locationManager = CLLocationManager()
    let APIKey = "21ac267e51062ee288ef1536db0c24bf"
    
    //qq登录
    var tencentAuth: TencentOAuth!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
 
        //qq登录初始化
        tencentAuth = TencentOAuth(appId: "1106056187", andDelegate: self)
        let defaults = UserDefaults.standard
        let data = defaults.data(forKey: "name")
        if data?.count != nil{
            
            //根视图
            self.window = UIWindow(frame: UIScreen.main.bounds)
            let sb = UIStoryboard(name: "Main", bundle:nil)
            let vc = sb.instantiateViewController(withIdentifier: "tabbar")
            
            self.window?.rootViewController = vc
            self.window?.makeKeyAndVisible()
        }else{
            //根视图
            self.window = UIWindow(frame: UIScreen.main.bounds)
            let sb = UIStoryboard(name: "Main", bundle:nil)
            let vc = sb.instantiateViewController(withIdentifier: "loginView")
            
            self.window?.rootViewController = vc
            self.window?.makeKeyAndVisible()
        }
                
        UINavigationBar.appearance().barTintColor = UIColor.init(red: 65/245, green: 65/225, blue: 65/225, alpha: 1)
        UINavigationBar.appearance().tintColor = UIColor.white
        
        //注册高德地图
        AMapServices.shared().apiKey = APIKey
        
        //注册百度地图
        let rst = manage.start("6imoN8a44I7y8kmuvxn2WDSo4UPDKdMH", generalDelegate: nil)
        if !rst{
            print("manage start fail")
        }
        
        //初始化导航SDK
        
        AVOSCloud.setApplicationId("HLky7P8bcA401DqkJ0fkUmTG-gzGzoHsz", clientKey: "PXtYSKP31BKSGUyKBuLOajOO")
        
               return true
        
    }
    
    //qq登录到代理方法
    func tencentDidLogin() {
        // 登录成功后要调用一下这个方法, 才能获取到个人信息
        self.tencentAuth.getUserInfo()
    }
    
    func tencentDidNotNetWork() {
        // 网络异常
    }
    
    func tencentDidNotLogin(_ cancelled: Bool) {
        
    }
    
    func getUserInfoResponse(_ response: APIResponse!) {
        // 获取个人信息
        if response.retCode == 0 {
            
            if let res = response.jsonResponse {
                
                if (self.tencentAuth.getUserOpenID()) != nil {
                    // 获取uid
                }
                
                if res["nickname"] != nil {
                    // 获取nickname
                    print(res["nickname"])
                }
                
                if res["gender"] != nil {
                    // 获取性别
                }
                
                if res["figureurl_qq_2"] != nil {
                    // 获取头像
                }
                
            }
        } else {
            // 获取授权信息异常
        }
    }
    

    
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        //qq登录
        let urlKey: String = options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String
        
        if urlKey == "5ps2yePh8OnvbgK1" {
            // QQ 的回调
            return  TencentOAuth.handleOpen(url)
        }

     return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "UU")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

