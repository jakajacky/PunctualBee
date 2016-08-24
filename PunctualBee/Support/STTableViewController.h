//
//  STTableViewController.h
//  SvpplyTable
//
//  Created by Anonymous on 13-8-13.
//  Copyright (c) 2013年 Minqian Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STCategory.h"

typedef void(^myBlock)(STCategory *category);

@interface STTableViewController : UITableViewController
<
  UITableViewDataSource,
  UITableViewDelegate,
  UIPopoverPresentationControllerDelegate,
  UIAdaptivePresentationControllerDelegate,
  UIViewControllerTransitioningDelegate
>

@property (nonatomic, copy)   myBlock block;
@property (nonatomic, strong) UIButton *plusBtn;


@end
