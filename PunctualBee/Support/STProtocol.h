//
//  STProtocol.h
//  PunctualBee
//
//  Created by xqzh on 16/8/10.
//  Copyright © 2016年 xqzh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "STCategory.h"

@interface STProtocol : NSObject <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) UITableView *tableView;

- (id)initWithTable:(UITableView *)table;

@end
