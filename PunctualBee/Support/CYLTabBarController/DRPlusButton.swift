//
//  DRPlusButton.swift
//  PunctualBee
//
//  Created by xqzh on 16/8/9.
//  Copyright © 2016年 xqzh. All rights reserved.
//

import UIKit

class DRPlusButton: CYLPlusButton {
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.titleLabel!.textAlignment = NSTextAlignment.Center
    self.adjustsImageWhenHighlighted = false
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func layoutSubview() {
//     //控件大小,间距大小
//     //注意：一定要根据项目中的图片去调整下面的0.7和0.9，Demo之所以这么设置，因为demo中的 plusButton 的 icon 不是正方形。
//    let imageViewEdgeWidth   = self.bounds.size.width * 0.7;
//    let imageViewEdgeHeight  = imageViewEdgeWidth * 0.9;
//    
//    let centerOfView    = self.bounds.size.width * 0.5;
//    let labelLineHeight = self.titleLabel!.font.lineHeight;
//    let verticalMarginT = self.bounds.size.height - labelLineHeight - imageViewEdgeWidth;
//    let verticalMargin  = verticalMarginT / 2;
//    
//    // imageView 和 titleLabel 中心的 Y 值
//    let centerOfImageView  = verticalMargin + imageViewEdgeWidth * 0.5;
//    let centerOfTitleLabel = imageViewEdgeWidth  + verticalMargin * 2 + labelLineHeight * 0.5 + 5;
//    
//    //imageView position 位置
//    self.imageView!.bounds = CGRectMake(0, 0, imageViewEdgeWidth, imageViewEdgeHeight);
//    self.imageView!.center = CGPointMake(centerOfView, centerOfImageView);
//    
//    //title position 位置
//    self.titleLabel!.bounds = CGRectMake(0, 0, self.bounds.size.width, labelLineHeight);
//    self.titleLabel!.center = CGPointMake(centerOfView, centerOfTitleLabel);
//    
  }

}

var i = 0

extension DRPlusButton : CYLPlusButtonSubclassing {
 
  static func plusButton() -> AnyObject! {
    let button = DRPlusButton()
    let buttonImage = UIImage(named: "post_normal")
//    button.setImage(buttonImage, forState: UIControlState.Normal)
    button.setBackgroundImage(buttonImage, forState: UIControlState.Normal)
//    button.setTitle("发布", forState: UIControlState.Normal)
//    button.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
//    
//    button.setTitle("选中", forState: UIControlState.Selected)
//    button.setTitleColor(UIColor.blueColor(), forState: UIControlState.Selected)
//    
//    button.titleLabel!.font = UIFont.systemFontOfSize(9.5)
    button.sizeToFit()
    button.addTarget(self, action: #selector(DRPlusButton.clickPublish(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    
    
    return button;
  }
  
//  static func indexOfPlusButtonInTabBar() -> UInt {
//    return 1
//  }
//  
//  static func plusChildViewController() -> UIViewController! {
//    let st = STTableViewController(nibName: nil, bundle: nil)
//    return st
//  }
  
  static func multiplierOfTabBarHeight(tabBarHeight: CGFloat) -> CGFloat {
    return 0.5
  }
  
  static func constantOfPlusButtonCenterYOffsetForTabBarHeight(tabBarHeight: CGFloat) -> CGFloat {
    return -5
  }
  
  static func clickPublish(sender:UIButton) {
    print("clicked plus button")
    i += 1
    // 动画
    UIView.animateWithDuration(0.75, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
      sender.transform = CGAffineTransformRotate(sender.transform, CGFloat(M_PI_4))
      }, completion:{
        (Bool) -> Void in
        
    })
    
    let st       = STTableViewController(nibName: nil, bundle: nil)
    let tabBarVC = cyl_tabBarController() as CYLTabBarController
    let homeVC   = tabBarVC.childViewControllers[0] as! UINavigationController
    let vc       = homeVC.childViewControllers[0] as! ViewController
    if i % 2 != 0 {
      vc.reloadLineData() // 获取地铁信息
    }
    
    // st控制器可透明显示
    homeVC.modalPresentationStyle = .CurrentContext
    st.tableView.backgroundColor = UIColor.clearColor()
    
    // UIPresentationController自定义转场动画方式
    st.modalPresentationStyle = UIModalPresentationStyle.Custom
    st.transitioningDelegate = st
    
    // 关联STTableViewController与ViewController
    
    // block 与closure无缝衔接，实现传值
    st.block = {
      category in
      
      let loc = CLLocation(latitude: category.latitude, longitude: category.longitude)
      vc.setDestination(loc, name: category.name)
      
    } as myBlock
    
    // popover方式弹出
//    st.modalPresentationStyle = UIModalPresentationStyle.Popover
//    st.plusBtn = sender
//    st.presentationController!.delegate = st
//    st.preferredContentSize = CGSizeMake(UIScreen.mainScreen().bounds.width , 460); // 设置popover的大小
//    
//    let popover = st.popoverPresentationController
//    popover!.sourceRect = sender.bounds
//    popover!.sourceView = sender
//    popover!.permittedArrowDirections = .Down
//    popover!.delegate = st
//    popover!.passthroughViews = [sender]   // 指定view ，在popover弹出后，仍然可以与用户交互
//    popover!.backgroundColor = UIColor.clearColor()
    
    if i % 2 == 0 {
      tabBarVC.dismissViewControllerAnimated(true, completion: {
        
      })
      
    }
    else {
      tabBarVC.presentViewController(st, animated: true) {
      }
    }

    
  }
  
  
  
  
}