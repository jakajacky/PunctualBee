//
//  ViewController.swift
//  PunctualBee
//
//  Created by xqzh on 16/8/2.
//  Copyright © 2016年 xqzh. All rights reserved.
//

import UIKit
import AudioToolbox
import SwiftyJSON

let heightL:CGFloat = 37.0
var firstRotation   = 0

class ViewController: UIViewController {

  var _mapView: BMKMapView?              // 基本地图
  var _locService: BMKLocationService?   // 定位
  var _searchPOI: BMKPoiSearch?          // POI检索
  var _searchBusLine: BMKBusLineSearch?  // 公交信息检索
  var _searcherGeo:BMKGeoCodeSearch?     // 反向地理编码
  
  var _destination:CLLocation?           // 目的地坐标
  var _destinationName:NSString?         // 目的地名称
  var _coor:CLLocationCoordinate2D?   // 目的地地图标
  var _view:UILabel?
  
  var _lines:NSMutableArray?             // 存储线路
  
  var _dictionary:NSMutableDictionary!   // 线路字典
  
  var limitDistance   = 1000.0           // 限制提醒距离
  
  var st:STTableViewController! // 用于block传值
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "首页"
    self.automaticallyAdjustsScrollViewInsets = false
    
    // 1、基础地图
    initBaseMapView()
    // 初始化在育新
    setDestination(CLLocation(latitude: 40.066124304797285, longitude: 116.35399725884176), name: "育新")
    // 2、定位
    initLocationService()
    // 3、POI检索 ***（当本地不存在category.json的时候）
    // 根路径
    let rootPath = NSHomeDirectory() as NSString
    // documents路径
    let documentsPath = rootPath.stringByAppendingPathComponent("Documents") as NSString
    // 获取文本路径
    let filePath = documentsPath.stringByAppendingPathComponent("categories.json")
    let manager  = NSFileManager.defaultManager()
    if !manager.fileExistsAtPath(filePath) {
      for i in 1..<16 {
        if i != 3 && i != 11 && i != 12 {
          initPoiSearch(i)
        }
      }
    }
    
    // 5、线路数组
    _lines = NSMutableArray()
    
    // 6、线路字典
    _dictionary = NSMutableDictionary()
    
  }
  
  func initBaseMapView() {
    _mapView = BMKMapView(frame:
      CGRect(x: 0, y: 64, width: self.view.frame.width, height: self.view.frame.height - 113))
    _mapView!.baseIndoorMapEnabled = true
    _mapView!.showsUserLocation    = true
    _mapView!.showMapScaleBar      = true
    _mapView!.delegate             = self
    self.view.addSubview(_mapView!)
    
    // 用于显示距离
    _view = UILabel(frame: CGRectMake(10, 70, self.view.frame.width - 20, heightL))
    _view!.backgroundColor = UIColor.grayColor()
    _view!.alpha = 0.35
    _view!.textAlignment = NSTextAlignment.Center
    _view!.text = "--m"
    _view!.font = UIFont.systemFontOfSize(12)
    _view!.textColor = UIColor.whiteColor()
    _view!.layer.cornerRadius = heightL / 2
    _view!.layer.masksToBounds = true
    self.view.addSubview(_view!)
  }
  
  func initLocationService() {
    //初始化BMKLocationService
    _locService = BMKLocationService()
    _locService!.delegate = self
    _locService!.allowsBackgroundLocationUpdates = true
    _locService!.pausesLocationUpdatesAutomatically = false
    //启动LocationService
    _locService!.startUserLocationService()
    
    // 注册通知
    let notice = NSNotificationCenter.defaultCenter()
    notice.addObserver(self, selector: #selector(restartLocationService), name: "restartLocationService", object: nil)
    
    
    
  }
  
  // 重新定位
  func restartLocationService() {
//    _locService!.stopUserLocationService()
//    _locService = BMKLocationService()
//    _locService?.delegate = self
    _locService!.startUserLocationService()
    _locService!.allowsBackgroundLocationUpdates = true
    _locService!.pausesLocationUpdatesAutomatically = false
//    initLocationService()
  }
  
  func initPoiSearch(keyword:NSInteger) {
    _searchPOI = BMKPoiSearch()
    _searchPOI!.delegate = self
    let poiSearchOption = BMKCitySearchOption()
    poiSearchOption.city = "北京市"
    poiSearchOption.keyword = "地铁\(keyword)号线"
    poiSearchOption.pageCapacity = 10000
    poiSearchOption.pageIndex = 0
    let poiflag = _searchPOI!.poiSearchInCity(poiSearchOption)
    if poiflag {
      print("poi检索发送成功")
    }
    else {
      print("poi检索发送失败")
    }
  }
  
  func initBusLineSearch(busLineUid:NSString) {
    //初始化检索对象
    _searchBusLine = BMKBusLineSearch()
    _searchBusLine!.delegate = self;
    //发起检索
    let buslineSearchOption = BMKBusLineSearchOption()
    buslineSearchOption.city = "北京";
    buslineSearchOption.busLineUid = busLineUid as String;
    let busLineflag = _searchBusLine!.busLineSearch(buslineSearchOption)
    
    if(busLineflag)
    {
      NSLog("busline检索发送成功");
    }
    else
    {
      NSLog("busline检索发送失败");
    }
  }
  
  func setDestination(location:CLLocation, name:NSString) {
    _destination     = location
    _destinationName = name
    
    // 设置限制提醒距离
    limitDistance = 1000
    
    // 添加一个PointAnnotation
    let annotation = BMKPointAnnotation()
    
    _coor = CLLocationCoordinate2D()
    if _mapView!.annotations.count == 0 {
      _coor!.latitude  = _destination!.coordinate.latitude
      _coor!.longitude = _destination!.coordinate.longitude
      annotation.coordinate = _coor!;
      annotation.title = "\(_destinationName!)"
      _mapView?.addAnnotation(annotation)
    }
    else {
      let anno = _mapView!.annotations[0] as! BMKPointAnnotation
      if anno.coordinate.latitude == _destination!.coordinate.latitude && anno.coordinate.longitude == _destination!.coordinate.longitude {
        _coor!.latitude  = _destination!.coordinate.latitude
        _coor!.longitude = _destination!.coordinate.longitude
        annotation.coordinate = _coor!;
        annotation.title = "\(_destinationName!)"
      }
      else {
        _mapView!.removeAnnotation(anno)
        
        _coor!.latitude  = _destination!.coordinate.latitude
        _coor!.longitude = _destination!.coordinate.longitude
        annotation.coordinate = _coor!;
        annotation.title = "\(_destinationName!)"
        _mapView?.addAnnotation(annotation)
      }
    }
    
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    _mapView?.viewWillAppear()
    _mapView?.delegate = self // 此处记得不用的时候需要置nil，否则影响内存的释放
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    _mapView?.viewWillDisappear()
    _mapView?.delegate       = nil // 不用时，置nil
    _locService?.delegate    = nil
    _searchBusLine?.delegate = nil
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

}

extension ViewController:
BMKMapViewDelegate, BMKLocationServiceDelegate, BMKBusLineSearchDelegate, BMKPoiSearchDelegate, CLLocationManagerDelegate, BMKGeoCodeSearchDelegate {
  
  func mapViewDidFinishLoading(mapView: BMKMapView!) {
    _mapView!.compassPosition = CGPointMake(10,5) // 设置指南针位置
  }
  
  // BMKMapViewDelegate
  func mapview(mapView: BMKMapView!, baseIndoorMapWithIn flag: Bool, baseIndoorMapInfo info: BMKBaseIndoorMapInfo!) {
    if flag {
      print("室内")
    }
    else {
      print("室外")
    }
  }
  
  // BMKLocationServiceDelegate
  // location change
  func didUpdateBMKUserLocation(userLocation: BMKUserLocation!) {
  
    _mapView?.updateLocationData(userLocation)
    
    
    // 是否到达指定位置
    let currentLoc     = BMKMapPointForCoordinate(userLocation.location.coordinate);
    let destinationLoc = BMKMapPointForCoordinate(_coor!);
    let distance = BMKMetersBetweenMapPoints(currentLoc,destinationLoc)
    let distanceStr = NSString(format: "%.0f", distance)
//    print("-------\(currentLoc)-\(_coor)------")
    _view?.text = "距离\(_destinationName!) \(distanceStr) m"
    
    if distance < limitDistance {
      AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
      AudioServicesPlaySystemSound(1150)
      
      // 3.调用通知
      if UIApplication.sharedApplication().applicationState == UIApplicationState.Background {
        if UIApplication.sharedApplication().applicationIconBadgeNumber == 0 {
          let queue = dispatch_queue_create("queue", DISPATCH_QUEUE_SERIAL)
          dispatch_sync(queue, { 
            // 1.创建本地通知
            let localNote = UILocalNotification()
            // 2.设置本地通知的内容
            // 2.1.设置通知发出的时间
            localNote.fireDate = NSDate.init(timeIntervalSinceNow: 0.0)
            // 2.2.设置通知的内容
            localNote.alertBody = "即将到达-\(self._destinationName!),请提前做好准备!";
            // 2.3.设置滑块的文字（锁屏状态下：滑动来“关闭提醒”）
            localNote.alertAction = "关闭提醒";
            // 2.4.决定alertAction是否生效
            localNote.hasAction = true;
            // 2.5.设置点击通知的启动图片
            localNote.alertLaunchImage = "123";
            // 2.6.设置alertTitle
            localNote.alertTitle = "Punctual通知:";
            // 2.7.设置有通知时的音效
            localNote.soundName = "buyao.wav";
            // 2.8.设置应用程序图标右上角的数字
            //        if UIApplication.sharedApplication().applicationState != .Active {
            let badge =  UIApplication.sharedApplication().applicationIconBadgeNumber;
            localNote.applicationIconBadgeNumber = badge + 1;
            //        }
            if UIApplication.sharedApplication().applicationState != .Active {
            }
            else {
              localNote.applicationIconBadgeNumber = 0
              UIApplication.sharedApplication().applicationIconBadgeNumber = 0
            }
            
            // 2.9.设置额外信息
            localNote.userInfo = ["type":1]
            localNote.category = "closeNotiCate"
            UIApplication.sharedApplication().scheduleLocalNotification(localNote)
          })
          
        }
    }
    }
  }
  
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//    print("------+++-------")
  }
  
  // BMKPoiSearchDelegate
  func onGetPoiResult(searcher: BMKPoiSearch!, result poiResult: BMKPoiResult!, errorCode: BMKSearchErrorCode) {
    
    for info:BMKPoiInfo in poiResult.poiInfoList as! [BMKPoiInfo] {
      if info.epoitype == 4 {
//        print("地铁：\(info.name)：\(info.uid)")
        let line = LineModel(poiInfo: info)
        _lines!.addObject(line)
      }
    }
    _lines!.removeLastObject()
    _searchPOI = nil
    
    if _lines!.count == 12 {
      // lines排序
      _lines!.sortUsingComparator({
        
        (s1:AnyObject!,s2:AnyObject!)->NSComparisonResult in
        let line1=s1 as! LineModel
        let line2=s2 as! LineModel
        
        let lineS1  = line1.name.componentsSeparatedByString("铁")[1]
        let lineStr1 = lineS1.componentsSeparatedByString("号")[0] as NSString
        
        let lineS2  = line2.name.componentsSeparatedByString("铁")[1]
        let lineStr2 = lineS2.componentsSeparatedByString("号")[0] as NSString
        
        if lineStr1.intValue <= lineStr2.intValue {
          return NSComparisonResult.OrderedAscending
        }
        
        return NSComparisonResult.OrderedDescending
      })
      
      // 查地铁站
      for line in _lines! {
        let l:LineModel = line as! LineModel
//        print(l.name!)
        // 4、地铁线路信息
        initBusLineSearch(l.uid)
        
      }
    }
  }
  
  // BMKBusLineSearchDelegate
  func onGetBusDetailResult(searcher: BMKBusLineSearch!, result busLineResult: BMKBusLineResult!, errorCode error: BMKSearchErrorCode) {
    if (error == BMK_SEARCH_NO_ERROR) {
      
      //在此处理正常结果
      // 整合Line 的站点信息
      let stations = NSMutableArray()
      for station:BMKBusStation in busLineResult.busStations as! [BMKBusStation] {
//        print("\(busLineResult.busLineName)：\(station.title)")
        let lineStation = StationModel(busStation: station, lineuid: busLineResult.uid, linename: busLineResult.busLineName)
        stations.addObject(lineStation)
      }
      // 找到该站所属的地铁线
      for (_, obj) in _lines!.enumerate() {
        let line:LineModel = obj as! LineModel
        if busLineResult.uid.compare(line.uid as String) == NSComparisonResult.OrderedSame {
          line.children = NSArray(array: stations)
        }
      }
    
    }
    else {
      NSLog("抱歉，未找到结果");
    }
  }
  
  /**
   *点中底图标注后会回调此接口
   *@param mapview 地图View
   *@param mapPoi 标注点信息
   */
  func mapView(mapView: BMKMapView!, onClickedMapPoi mapPoi: BMKMapPoi!) {
    print("\(mapPoi.text)")
    
    // 地图单击 选点
    let location = CLLocation(latitude: mapPoi.pt.latitude, longitude: mapPoi.pt.longitude)
    setDestination(location, name: mapPoi.text)
  }
  
  /**
   *点中底图空白处会回调此接口
   *@param mapview 地图View
   *@param coordinate 空白处坐标点的经纬度
   */
  func mapView(mapView: BMKMapView!, onClickedMapBlank coordinate: CLLocationCoordinate2D) {
   
  }
  
  // 监听mapView的一些状态变化
  func mapStatusDidChanged(mapView: BMKMapView!) {
    let status = mapView.getMapStatus()
//    print(status.fRotation)
    if status.fRotation > 2 && status.fRotation < 358 {
    
      if firstRotation == 0 {
        UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
          self._view!.frame = CGRectMake(10, 70, heightL, heightL)
          
        }) { (stop:Bool) in
          if stop {
            self._view!.font = UIFont.systemFontOfSize(0)
          }
        }
        
        firstRotation = 1
      }
    
    }
    else {
    
      dispatch_after(2, dispatch_get_main_queue(), {
        UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
          self._view!.frame = CGRectMake(10, 70, self.view.frame.width - 20, heightL)
          
        }) { (stop:Bool) in
          if stop {
            self._view!.font = UIFont.systemFontOfSize(12)
          }
        }
        firstRotation = 0
      })
      
    }
  }
  
  // plusButton点击时触发
  func reloadLineData() {
    
    // 根路径
    let rootPath = NSHomeDirectory() as NSString
    // documents路径
    let documentsPath = rootPath.stringByAppendingPathComponent("Documents") as NSString
    // 获取文本路径
    let filePath = documentsPath.stringByAppendingPathComponent("categories.json")
    let manager  = NSFileManager.defaultManager()
    if !manager.fileExistsAtPath(filePath) {
    
      dispatch_async(dispatch_queue_create("concurrent", DISPATCH_QUEUE_CONCURRENT)) {
        // 生成json字典
        // 1、meta
        let meta = ["status": 200,
                    "msg"   : "OK",
                    "time"  : "1335541016"
        ]
        
        self._dictionary.setValue(meta, forKey: "meta")
        
        // 2、生成lines数组
        let lineArray = NSMutableArray()
        for (_, obj) in self._lines!.enumerate() {
          let line:LineModel = obj as! LineModel
          let lineDic = line.dictionaryWithLine(line)
          lineArray.addObject(lineDic)
        }
        
        // 3、生成categories
        let categories = NSMutableArray()
        let categoriesDic = ["name":"All Lines",
                             "url":"www",
                             "text_color":"#000000",
                             "border_color":"#000000",
                             "children":lineArray
        ]
        categories.addObject(categoriesDic)
        
        // 4、生成response
        let response = ["categories":categories]
        
        // 5、生成字典
        self._dictionary.setValue(response, forKey: "response")
  //      print("\(self._dictionary)")
        
        // 6、生成json
        let json = JSON(self._dictionary)
        
        // 7、写入文件
        // 根路径
        let rootPath = NSHomeDirectory() as NSString
        // documents路径
        let documentsPath = rootPath.stringByAppendingPathComponent("Documents") as NSString
        // 获取文本路径
        let filePath = documentsPath.stringByAppendingPathComponent("categories.json")
        // 写入
        do {
          try json.rawString()!.writeToFile(filePath, atomically: true, encoding: NSUTF8StringEncoding)
        } catch {
          print("存储json失败")
        }
      }
    }
  }
  
  // 设置大头针图片， 没有自定义泡泡，以后再说
  func mapView(mapView: BMKMapView!, viewForAnnotation annotation: BMKAnnotation!) -> BMKAnnotationView! {
    let annotationView = BMKAnnotationView(annotation: annotation, reuseIdentifier: "ano")
    annotationView.image = UIImage(named: "Pin-.png")
    annotationView.centerOffset = CGPointMake(0, -10)
    return annotationView
  }
  
//  // 长按 选点
//  func mapview(mapView: BMKMapView!, onLongClick coordinate: CLLocationCoordinate2D) {
//    
//    // 反向地理编码
//    _searcherGeo = BMKGeoCodeSearch()
//    _searcherGeo!.delegate = self
//    let reverseGeoCodeSearchOption = BMKReverseGeoCodeOption()
//    reverseGeoCodeSearchOption.reverseGeoPoint = coordinate
//    let flag = _searcherGeo!.reverseGeoCode(reverseGeoCodeSearchOption)
//    if(flag)
//    {
//      NSLog("反geo检索发送成功");
//    }
//    else
//    {
//      NSLog("反geo检索发送失败");
//    }
//    
//    
//    
//  }
//  
//  // 反向地理编码 结果
//  func onGetReverseGeoCodeResult(searcher: BMKGeoCodeSearch!, result: BMKReverseGeoCodeResult!, errorCode error: BMKSearchErrorCode) {
//    if (error == BMK_SEARCH_NO_ERROR) {
//            print("\(result.address)--\(result.addressDetail)--\((result.poiList[0] as! BMKPoiInfo).name)")
//        }
//        else {
//            NSLog("抱歉，未找到结果");
//        }
//    
//  }
  
  
}

