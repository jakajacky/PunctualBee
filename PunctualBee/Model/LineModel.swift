//
//  LineModel.swift
//  PunctualBee
//
//  Created by xqzh on 16/8/5.
//  Copyright © 2016年 xqzh. All rights reserved.
//

import UIKit
import Foundation

class LineModel: NSObject {

  var uid:NSString!
  var name:NSString!
  var children:NSArray!
  var text_color:NSString!
  var border_color:NSString!
  
  override init() {
    super.init()
  }
  
  convenience init(dictionary:NSDictionary) {
    self.init()
    uid!          = dictionary["uid"] as! NSString
    name!         = dictionary["name"] as! NSString
    children!     = dictionary["children"] as! NSArray
    text_color!   = dictionary["text_color"] as! NSString
    border_color! = dictionary["border_color"] as! NSString
  }
  
  convenience init(poiInfo:BMKPoiInfo) {
    self.init()
    //uid
    uid          = NSString(string:poiInfo.uid)
    //name
    let sub = poiInfo.name.componentsSeparatedByString("线")[0] as String
    name         = sub.stringByAppendingString("线")
    
    //children
    children     = ["A","B"]
    
    //color
    let lineS  = name.componentsSeparatedByString("铁")[1]
    let lineStr = lineS.componentsSeparatedByString("号")[0]
    switch lineStr {
    case "1":
      text_color   = "#FF7FF0"
      border_color = "#E8DCE4"
      
    case "2":
      text_color   = "#0000FF"
      border_color = "#E8DCE4"
      
    case "4":
      text_color   = "#56B2BD"
      border_color = "#DDF0F2"
      
    case "5":
      text_color   = "#8E236B"
      border_color = "#E8DCE4"
      
    case "6":
      text_color   = "#007FFF"
      border_color = "#E8DCE4"
      
    case "7":
      text_color   = "#FF2400"
      border_color = "#E8DCE4"
      
    case "8":
      text_color   = "#215E21"
      border_color = "#E8DCE4"
      
    case "9":
      text_color   = "#6ABC8B"
      border_color = "#E1F2E8"
      
    case "10":
      text_color   = "#36779D"
      border_color = "#D7E4EB"
      
    case "13":
      text_color   = "#CFB53B"
      border_color = "#E8DCE4"
      
    case "14":
      text_color   = "#BC8F8F"
      border_color = "#E8DCE4"
      
    case "15":
      text_color   = "#8A4E77"
      border_color = "#E8DCE4"
      
    default: break
      
    }
    
  }
  
  
  func dictionaryWithLine(line:LineModel) -> NSDictionary {
    let dic = NSMutableDictionary()
    dic.setValue(line.uid, forKey: "uid")
    dic.setValue(line.name, forKey: "name")
    dic.setValue(line.text_color, forKey: "text_color")
    dic.setValue(line.border_color, forKey: "border_color")
    
    // children转换
    let stations = NSMutableArray()
    for (_, obj) in line.children.enumerate() {
      if obj.isKindOfClass(StationModel) {
        let station = obj as! StationModel
        stations.addObject(station.dictionaryWithStation(station))
      }
      
    }
    dic.setValue(stations, forKey: "children")
    
    return dic
  }

  
}
