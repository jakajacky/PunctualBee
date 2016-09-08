//
//  MineViewController.swift
//  PunctualBee
//
//  Created by xqzh on 16/8/26.
//  Copyright © 2016年 xqzh. All rights reserved.
//

import UIKit

class MineViewController: UIViewController {

  var table:UITableView!
  
  var offlineMap:BMKOfflineMap!   // 离线地图服务
  
  var record:BMKOLSearchRecord!   // 离线地图信息
  
  override func viewDidLoad() {
      super.viewDidLoad()
    self.title = "我的"
    initTableView()
    initOfflineMap()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }
  
  func initTableView() {
    self.table = UITableView(frame: self.view.bounds, style: .Grouped)
    self.table.delegate   = self
    self.table.dataSource = self
    self.view.addSubview(self.table)
  }
  
  func initOfflineMap() {
    offlineMap = BMKOfflineMap()
    offlineMap.delegate = self
  }

}

extension MineViewController:UITableViewDelegate, UITableViewDataSource, BMKOfflineMapDelegate {
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 1 {
      return 1
    }
    return 2
  }
  
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 10
  }
  
  func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 1
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var cell = table.dequeueReusableCellWithIdentifier("cell")
    if cell == nil {
      cell = UITableViewCell(style: .Value1, reuseIdentifier: "cell")
    }
    
    let records = offlineMap.searchCity("北京") as NSArray
    let oneRecord = records.objectAtIndex(0) as! BMKOLSearchRecord
    record = oneRecord
    
    switch indexPath.row {
    case 0:
      if indexPath.section == 0 {
        cell!.textLabel!.text = "离线地图"
        
        // 根路径
        let rootPath = NSHomeDirectory() as NSString
        // documents路径
        let documentsPath = rootPath.stringByAppendingPathComponent("Documents/vmp") as NSString
        // 获取文本路径
        let filePath = documentsPath.stringByAppendingPathComponent("beijing_131.dat")
        let manager  = NSFileManager.defaultManager()
        if manager.fileExistsAtPath(filePath) {
          cell!.detailTextLabel?.text = "已下载"
        }
        else {
          cell!.detailTextLabel?.text = NSString(format: "大约%.1fM", CGFloat(record.size) / 1024.0 / 1024.0) as String
        }
      }
      else {
        cell!.textLabel!.text = "关于"
      }
    case 1:
      if indexPath.section == 0 {
        cell!.textLabel!.text = "清理缓存"
      }
    default: break
    }
    return cell!
    
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if indexPath.row == 0 && indexPath.section == 0 {
      offlineMap.start(record.cityID)
    }
    else if indexPath.row == 1 && indexPath.section == 0 {
      offlineMap.remove(record.cityID)
      tableView.reloadData()
    }
    else {
      let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
      let about = storyBoard.instantiateViewControllerWithIdentifier("about")
      
      
      self.navigationController?.pushViewController(about, animated: true)
    }
    
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
  
  // BMKOfflineMapDelegate
  func onGetOfflineMapState(type: Int32, withState state: Int32) {
    if type == Int32(TYPE_OFFLINE_UPDATE) {
      //id为state的城市正在下载或更新，start后会毁掉此类型
      if let updateInfo = offlineMap .getUpdateInfo(state) {
        print("城市名：\(updateInfo.cityName)，下载比例：\(updateInfo.ratio)")

        let cell  = table.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))! as UITableViewCell
        let size  = CGFloat(updateInfo.size) / 1024.0 / 1024.0
        var total = CGFloat(updateInfo.size) / CGFloat(updateInfo.ratio) * CGFloat(100) / 1024.0 / 1024.0
        if updateInfo.ratio == 0 {
          total = 0.0
        }
        let downloadProgress = NSString(format: "%.1fM\\%.1fM", size, total)
        cell.detailTextLabel?.text = downloadProgress as String
        
        if updateInfo.ratio == 100 {
          cell.detailTextLabel?.text = "已下载"
        }
      }
      
      return
    }
    
    
    if type == Int32(TYPE_OFFLINE_NEWVER) {
      //id为state的state城市有新版本,可调用update接口进行更新
      if let updateInfo = offlineMap .getUpdateInfo(state) {
        print("是否有更新\(updateInfo.update)")
      }
      return
    }
    
    //正在解压第state个离线包，导入时会回调此类型
    if type == Int32(TYPE_OFFLINE_UNZIP) {
      return
    }
    
    //检测到state个离线包，开始导入时会回调此类型
    if type == Int32(TYPE_OFFLINE_ZIPCNT) {
      print("检测到%d个离线包",state);
      if state == 0 {
        showImportMessage(state)
      }
    }
    
    //有state个错误包，导入完成后会回调此类型
    if type == Int32(TYPE_OFFLINE_ERRZIP) {
      print("有%d个离线包导入错误",state);
    }
    
    //导入成功state个离线包，导入成功后会回调此类型
    if type == Int32(TYPE_OFFLINE_UNZIPFINISH) {
      print("成功导入%d个离线包",state);
      showImportMessage(state)
    }
  }
  
  func showImportMessage(count: Int32) {
    let alertView = UIAlertController(title: "导入离线地图", message: "成功导入离线地图包个数:\(count)", preferredStyle: .Alert)
    let okaction = UIAlertAction(title: "确定", style: UIAlertActionStyle.Default, handler: nil)
    alertView.addAction(okaction)
    self.presentViewController(alertView, animated: true, completion: nil)
  }
  
}
