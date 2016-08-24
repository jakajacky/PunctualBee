//
//  AppDelegate.swift
//  PunctualBee
//
//  Created by xqzh on 16/8/2.
//  Copyright © 2016年 xqzh. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, BMKGeneralDelegate, CLLocationManagerDelegate {

  var window: UIWindow?
  var bgTask:UIBackgroundTaskIdentifier!
  
  var _mapManager:BMKMapManager?
  
  var _locSys: CLLocationManager?        // 系统定位，用于无限后台，以便持续定位

  var tabBarController: CYLTabBarController!

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    
    _mapManager = BMKMapManager()
    // 如果要关注网络及授权验证事件，请设定generalDelegate参数
    let ret = _mapManager?.start("26v9WqUA1pBbukeQxpTo8GBUGBldr7yw", generalDelegate: self)
    if ret == false {
      NSLog("manager start failed!")
      let alert = UIAlertView(title: "Tips", message: "manager start failed!", delegate: self, cancelButtonTitle: "确定")
      alert.show()
    }
    
    DRPlusButton.registerPlusButton()
    
    
    let sysOS = UIDevice.currentDevice().systemVersion as NSString
    if sysOS.doubleValue >= 8.0 && sysOS.doubleValue <= 10.0 {
      
      let category = getCategoryOnIOS8()
    
      let set = NSSet(array: [category])
      let settings = UIUserNotificationSettings(forTypes: [.Sound, .Alert, .Badge], categories: set as? Set<UIUserNotificationCategory>)
      
      
      application.registerUserNotificationSettings(settings)
    
    }
    else if sysOS.doubleValue >= 10.0 { // iOS 10 的兼容
//      UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
//        granted, error in
//        if granted {
//          // 用户允许进行通知
//        }
//      }
    }
    else { // 兼容 iOS 7
      
    }
    
    return true
  }
  
  func onGetPermissionState(iError: Int32) {
    if iError == 0 {
      print("权鉴成功")
      self.setupViewControllers()
      self.window!.rootViewController = self.tabBarController
      self.window!.makeKeyAndVisible()
    }
    else {
      print("权鉴失败")
    }
  }

  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(application: UIApplication) {
    print("进入后台---持续定位")
    
    let application = UIApplication.sharedApplication()
    let shouldRestartLoc = application.setKeepAliveTimeout(600, handler: {
      self.backgroundHandler()
    })
    
    if shouldRestartLoc {
      print("backgrouding accepted")
    }
    else {
     backgroundHandler()
    }
    
  }
  
  func backgroundHandler() {
    
    let application = UIApplication.sharedApplication()
    bgTask = application.beginBackgroundTaskWithExpirationHandler {
//      application.endBackgroundTask(self.bgTask)
      if(self.bgTask != UIBackgroundTaskInvalid){
        self.bgTask = UIBackgroundTaskInvalid;
      }
//      self.bgTask = UIBackgroundTaskInvalid
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
      //
      // 初始化系统CLLocationManager
//      self._locSys = CLLocationManager()
//      self._locSys!.delegate = self
//      self._locSys!.pausesLocationUpdatesAutomatically = false
//      self._locSys!.allowsBackgroundLocationUpdates    = true
//      self._locSys!.startUpdatingLocation()
      while (true) {
        let noticeCenter = NSNotificationCenter.defaultCenter()
        noticeCenter.postNotificationName("restartLocationService", object: self, userInfo: nil)
        print("剩余时间：\(application.backgroundTimeRemaining)")
        // 初始化系统CLLocationManager
        //    _locSys = CLLocationManager()
        //    _locSys!.delegate = self
        //    _locSys!.pausesLocationUpdatesAutomatically = false
        //    _locSys!.allowsBackgroundLocationUpdates    = true
        //    _locSys!.startUpdatingLocation()
        sleep(5)
      }
    }
  }

  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
//    _locSys!.stopUpdatingHeading()
    UIApplication.sharedApplication().applicationIconBadgeNumber = 0
  }


  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }

  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    print("++++++++++++")
  }
  
  func setupViewControllers() {
  
    let firstVC = ViewController()
    let navigationVC = UINavigationController(rootViewController: firstVC)
    
    let secondVC = UIViewController()
    secondVC.view.backgroundColor = UIColor.whiteColor()
    let navigationVC1 = UINavigationController(rootViewController: secondVC)
    
    let tabBar = UITabBar.appearance() as UITabBar
    tabBar.backgroundImage = UIImage()
    tabBar.backgroundColor = UIColor.whiteColor()
    tabBar.shadowImage     = UIImage(named: "tapbar_top_line")
    
    // tabbar 属性
    let dict1 = [
      CYLTabBarItemTitle : "首页",
      CYLTabBarItemImage : "mycity_normal",
      CYLTabBarItemSelectedImage : "mycity_highlight",
      ]
    let dict2 = [
      CYLTabBarItemTitle : "我的",
      CYLTabBarItemImage : "account_normal",
      CYLTabBarItemSelectedImage : "account_highlight",
      ]
    
    let tabBarController = CYLTabBarController(viewControllers: [navigationVC, navigationVC1], tabBarItemsAttributes: [dict1, dict2])
    self.tabBarController = tabBarController;
    
  }

  func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
    
    let badge = application.applicationIconBadgeNumber;
    print("收到本地通知\(badge)")
    
  }
  
  func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
    if identifier == "closeNotiAction" {
      print("这里应该关闭到站提醒")
      
      let homeVC   = self.tabBarController.childViewControllers[0] as! UINavigationController
      let vc       = homeVC.childViewControllers[0] as! ViewController
      vc.limitDistance = -1000.0
    }
    completionHandler()
  }
  
  // 定义本地通知的交互action
  func getCategoryOnIOS8() -> UIUserNotificationCategory {
    let action = UIMutableUserNotificationAction()
    action.title       = "关闭提醒"
    action.identifier  = "closeNotiAction"
    action.destructive = true
    action.activationMode = .Background
    
    let category = UIMutableUserNotificationCategory()
    category.identifier = "closeNotiCate"
    category.setActions([action], forContext: .Default)
    
    return category
  }
  
}



