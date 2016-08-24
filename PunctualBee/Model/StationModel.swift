//
//  StationModel.swift
//  PunctualBee
//
//  Created by xqzh on 16/8/5.
//  Copyright © 2016年 xqzh. All rights reserved.
//

import UIKit

class StationModel: NSObject {

  var uid:NSString!
  var lineUid:NSString!
  var lineName:NSString!
  var title:NSString!
  var longitude:CLLocationDegrees!
  var latitude:CLLocationDegrees!
  var text_color:NSString!
  var border_color:NSString!
  
  override init() {
    super.init()
  }
  
  convenience init(busStation:BMKBusStation, lineuid:NSString, linename:NSString) {
    self.init()
    uid       = busStation.uid
    lineUid   = lineuid
    lineName  = linename
    title     = busStation.title
    latitude  = busStation.location.latitude
    longitude = busStation.location.longitude
        
    let lineS  = lineName.componentsSeparatedByString("铁")[1]
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
  
  func dictionaryWithStation(station:StationModel) -> NSDictionary {
    let dic = NSMutableDictionary()
    dic.setValue(station.uid, forKey: "uid")
    dic.setValue(station.lineUid, forKey: "lineUid")
    dic.setValue(station.lineName, forKey: "lineName")
    dic.setValue(station.title, forKey: "name")
    dic.setValue(station.latitude, forKey: "latitude")
    dic.setValue(station.longitude, forKey: "longitude")
    dic.setValue(station.text_color, forKey: "text_color")
    dic.setValue(station.border_color, forKey: "border_color")

    return dic
  }
  
}
