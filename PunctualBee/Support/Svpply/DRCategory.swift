//
//  DRCategory.swift
//  PunctualBee
//
//  Created by xqzh on 16/8/8.
//  Copyright © 2016年 xqzh. All rights reserved.
//

import UIKit

class DRCategory: NSObject {

  var _name:NSString!
  var _URLString:NSString!
  var _colorHex:NSString!
  var _borderColorHex:NSString!
  
  override init() {
    super.init()
  }
  
  convenience init(json:AnyObject) {
    self.init()
    let jsonDict = json as! NSDictionary
    _name           = jsonDict.objectForKey("name") as! NSString
    _URLString      = jsonDict.objectForKey("url") as! NSString
    _colorHex       = jsonDict.objectForKey("text_color") as! NSString
    _borderColorHex = jsonDict.objectForKey("border_color") as! NSString
    
  }
  
}
