//
//  DRTableViewCell.swift
//  PunctualBee
//
//  Created by xqzh on 16/8/8.
//  Copyright © 2016年 xqzh. All rights reserved.
//

import UIKit

class DRTableViewCell: UITableViewCell {

  var _label:UILabel!
  var _color:UIColor!
  var _category:DRCategory!
  
  func setContent(content:DRCategory) -> Void {
    _category = content
    self.textLabel!.textAlignment = NSTextAlignment.Center
    self.textLabel!.textColor = UIColor.col
  }

}

extension UIColor {
  
  static func colorWithHexString(stringToConvert:NSString) -> UIColor {
    var cString = stringToConvert.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString as! NSString// 去掉前后空格换行符
    // String should be 6 or 8 characters
    if cString.length < 6 {
      return UIColor.redColor()
    }
    
    // strip 0X if it appears
    if cString.hasPrefix("0X") {
      cString = cString.substringFromIndex(2)
    }
    if cString.hasPrefix("#") {
      cString = cString.substringFromIndex(1)
    }
    if cString.length != 6 {
      return UIColor.redColor()
    }
    // Separate into r, g, b substrings
    var range = NSMakeRange(0, 2)
    let rString = cString.substringWithRange(range)
    
    range.location = 2
    let gString = cString.substringWithRange(range)
    
    range.location = 4
    let bString = cString.substringWithRange(range)
    
    // Scan values ..操蛋指针
    // 字符串形式的16进制 转UInt32
    let r,g,b:UnsafeMutablePointer<UInt32>
    let scannerR = NSScanner(string: rString)
    let scannerG = NSScanner(string: gString)
    let scannerB = NSScanner(string: bString)
    scannerR.scanHexInt(r)
    scannerG.scanHexInt(g)
    scannerB.scanHexInt(b)
    
    return UIColor(red: CGFloat(r.memory) / 255.0 , green: CGFloat(g.memory) / 255.0, blue: CGFloat(b.memory) / 255.0, alpha: 1)
  }
  
}
