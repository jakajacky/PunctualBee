//
//  DRSvpplyViewController.swift
//  PunctualBee
//
//  Created by xqzh on 16/8/8.
//  Copyright © 2016年 xqzh. All rights reserved.
//

import UIKit
import SwiftyJSON

let InitSelectedIndex = "0"

enum DRSvpplyViewRowAction {
  case DRSvpplyViewRowInsert
  case DRSvpplyViewRowDelete
}

class DRSvpplyViewController: UITableViewController {

  var _selectedCategorySection:NSInteger!
  var _categories:NSMutableArray!
  var _structure:NSMutableDictionary!
  var _displayedChildren:NSMutableArray!
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
      // init
      _categories        = NSMutableArray()
      _structure         = NSMutableDictionary()
      _displayedChildren = NSMutableArray()
      
//      self.tableView = UITableView(frame: self.view.bounds)
//      self.tableView.dataSource = self
//      self.tableView.delegate =self
      self.tableView.separatorStyle  = UITableViewCellSeparatorStyle.None
      self.tableView.backgroundColor = UIColor.blackColor()
      
      self.loadDataFromLocalJSON()
      _selectedCategorySection = -1
      _displayedChildren.addObjectsFromArray([_structure.objectForKey("0")!.objectForKey("forwardIndex")!])
      self.tableView.reloadData()
      
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return _displayedChildren.count
    }

  
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> DRTableViewCell {
      var cell = tableView.dequeueReusableCellWithIdentifier("DR", forIndexPath: indexPath) as? DRTableViewCell
      
      if cell == nil {
        cell = DRTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "DR")
      }
      
      cell!.selectionStyle = UITableViewCellSelectionStyle.None
      let index = self.getCategoryIndexFrom(indexPath.row)
      
      let category = _categories.objectAtIndex(index) as! DRCategory
      cell! = self.setCell(cell!, content: category, indexRow: indexPath.row)
      
      return cell!
    }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    self.seta
  }
  

  func setCell(cell:DRTableViewCell, content:DRCategory, indexRow:NSInteger) -> DRTableViewCell {
    cell.setContent(content)
    
    if _selectedCategorySection < 0 {
      cell.textLabel!.textColor = UIColor.whiteColor()
      cell.contentView.backgroundColor! = UIColor.colorWithHexString(content._colorHex)
    }
    else {
      if indexRow < _selectedCategorySection {
        cell.textLabel!.textColor = UIColor.grayColor()
      }
      else if indexRow == _selectedCategorySection {
        cell.textLabel!.textColor = UIColor.whiteColor()
        cell.contentView.backgroundColor! = UIColor.colorWithHexString(content._colorHex)
      }
    }
    return cell
  }
  
  func getCategoryIndexFrom(index:NSInteger) -> NSInteger {
    if _displayedChildren != nil && _displayedChildren.count > 0 && index >= 0 && index < _displayedChildren.count {
      return _displayedChildren.objectAtIndex(index).integerValue
    }
    return 0
  }
  
  // Load Data Methods
  func loadDataFromLocalJSON() {
    let jsonPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentationDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first! as NSString
    
    let filePath = jsonPath.stringByAppendingPathComponent("categories.json")
    let jsonData = NSData(contentsOfFile: filePath)
    
    let error:NSErrorPointer
    
//    let json    = JSON(data: jsonData!, options: NSJSONReadingOptions(), error: error)
    let jsonDic:NSDictionary?
    
    do {
      jsonDic = try NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions()) as? NSDictionary
    } catch {
      
    }
    
    let dicResponse   = jsonDic!.objectForKey("response") as! NSDictionary
    let dicCategories = dicResponse.objectForKey("categories") as! NSArray
    let line          = dicCategories.objectAtIndex(0) as! NSDictionary
    
    self.parseJSON(line, backIndex: -1)
  }
  
  func parseJSON(jsonDict:NSDictionary, backIndex:NSInteger) -> NSInteger {
    let dict = NSMutableDictionary()
    
    let category = DRCategory(json: jsonDict)
    
    let currentIndex = self._categories.count
    self._categories.addObject(category)
    
    let array = NSMutableArray()
    let jsonArray = jsonDict.objectForKey("children") as? NSArray
    
    if (jsonArray != nil && jsonArray!.count > 0) {
      for jsonCategoryDict in jsonArray! {
        array.addObject("\(self.parseJSON(jsonCategoryDict as! NSDictionary, backIndex: currentIndex))")
        
      }
    }
    
    dict.setObject("\(backIndex)", forKey: "backIndex")
    
    if (array.count > 0) {
      dict.setObject(array, forKey: "forwardIndex")
    }
    
    self._structure.setObject(dict, forKey: "\(currentIndex)")
    
    
    return currentIndex;
  }
  
  // Animation Methods
  func setArraysWithSelected(index:NSInteger) -> Void {
    let indexPathInsert = NSMutableArray()
    let categoryIndex   = self.getCategoryIndexFrom(index)
    let currentIndex    = -1, movedIndex = -1
    self.tableView.beginUpdates()
    
//    if index == 0 && categoryIndex == 0 {
//      currentIndex = _selectedCategorySection
//      _selectedCategorySection = -1
//      self.tableViewbase
//    }
  }

}
