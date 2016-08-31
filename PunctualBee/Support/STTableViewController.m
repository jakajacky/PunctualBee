//
//  STTableViewController.m
//  SvpplyTable
//
//  Created by Anonymous on 13-8-13.
//  Copyright (c) 2013年 Minqian Liu. All rights reserved.
//

#import "STTableViewController.h"
#import "STTableViewCell.h"
#import "UIColor+HexString.h"
#import "PunctualBee-Swift.h"

#define InitSelectedIndex @"0"

typedef enum
{
  STTableViewRowInsert,
  STTableViewRowDelete
}STTableViewRowAction;

@interface STTableViewController () 
{
  NSInteger _selectedCategorySection;
  NSMutableArray *_categories;
  NSMutableDictionary *_structure;
  NSMutableArray* _displayedChildren;
  CustomPresentationController *_cus;
}
@property (atomic, assign) NSInteger selectedCategorySection;

@property (nonatomic, strong) NSMutableArray *categories;
@property (nonatomic, strong) NSMutableDictionary *structure;
@property (nonatomic, strong) NSMutableArray* displayedChildren;



@end

@implementation STTableViewController


- (id)init {
  self = [super init];
  if (self) {
//    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width - 40, self.view.bounds.size.height - 100) style:UITableViewStylePlain];
//    [self.view addSubview:_tableView];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.categories = [[NSMutableArray alloc] init];
  self.structure = [[NSMutableDictionary alloc] init];
  self.displayedChildren = [[NSMutableArray alloc] init];
  
  self.tableView.dataSource = self;
  self.tableView.delegate = self;
  [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
//  [self.tableView setBackgroundColor:[UIColor whiteColor]];
//  [self.view setBackgroundColor:[UIColor clearColor]];

  [self loadDataFromLocalJSON];
  _selectedCategorySection = -1;
  [self.displayedChildren addObjectsFromArray:[((NSDictionary *)[self.structure objectForKey:@"0"]) objectForKey:@"forwardIndex"]];
  [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark popover 模式
// 0、return UIModalPresentationNone 表示在iPhone上的效果 和iPad一样，都是popover样式，否则，iPhone默认是普通的
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
  return UIModalPresentationNone;
}

// 1、关闭 点击非popover部分，popover dismiss的功能， 然后与popover的passthroughViews属性连用，可实现点击指定位置，dimiss popover
- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {
  return NO;
}

// 2、popover dismiss之后的回调
- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {
  NSLog(@"dismiss popover");
}

- (void)popoverPresentationController:(UIPopoverPresentationController *)popoverPresentationController willRepositionPopoverToRect:(inout CGRect *)rect inView:(inout UIView  * __nonnull * __nonnull)view {
  // 设置popover的位置
}

// 3、负责 弹出的视图 是否显示NavigationBar 当 0处 为UIModalPresentationNone时，不会回调这个方法
- (UIViewController *)presentationController:(UIPresentationController *)controller viewControllerForAdaptivePresentationStyle:(UIModalPresentationStyle)style
{
  UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller.presentedViewController];
  UIBarButtonItem *btnDone = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismiss)];
  nav.topViewController.navigationItem.rightBarButtonItem = btnDone;
  return nav;
}

#pragma mark -
#pragma mark 下面三个方法，是用于UIPresentationController自定义转场动画的
- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
  _cus = [[CustomPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
  _cus.st = self;
  return _cus;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
  if (presented == self) {
    return [[CustomPresentationAnimationController alloc] initWithIsPresenting:true];
  }
  else {
    return nil;
  }
  
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
  if (dismissed == self) {
    return [[CustomPresentationAnimationController alloc] initWithIsPresenting:false];
  }
  else {
    return nil;
  }
}


- (void)dismiss {
  [self dismissViewControllerAnimated:YES completion:^{
    
  }];
}



#pragma mark - UITableView Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.displayedChildren.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"Cell";
  STTableViewCell *cell = (STTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  
  if (cell == nil)
  {
    cell = [[STTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
  }

  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  
  NSInteger index = [self getCategoryIndexFrom:indexPath.row];
  
  STCategory *category = ((STCategory *)[self.categories objectAtIndex:index]);
 
  cell = [self setCell:cell content:category indexRow:indexPath.row];
  
  return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [self setArraysWithSelected:indexPath.row];
}

#pragma mark - Animation Methods

- (void)setArraysWithSelected:(NSInteger)index
{
  NSMutableArray *indexPathInsert = [[NSMutableArray alloc] init];
  
  NSInteger categoryIndex = [self getCategoryIndexFrom:index];
  
  NSInteger currentIndex = -1, movedIndex = -1;
  
  [self.tableView beginUpdates];
  
  if (index == 0 && categoryIndex == 0)
  {
    currentIndex = _selectedCategorySection;
    
    _selectedCategorySection = -1;
    
    [self tableViewBased:currentIndex from:UITableViewRowAnimationTop to:UITableViewRowAnimationFade action:STTableViewRowDelete];
    
    
    NSInteger rootIndex = [self getCategoryIndexFrom:1];
    
    [self.displayedChildren removeAllObjects];
    [self.displayedChildren addObjectsFromArray:[((NSDictionary *)[self.structure objectForKey:@"0"]) objectForKey:@"forwardIndex"]];
    
    movedIndex = [self.displayedChildren indexOfObject:[NSString stringWithFormat:@"%d", rootIndex]];
    if (currentIndex != movedIndex) movedIndex = 0;

    [self tableViewBased:movedIndex from:UITableViewRowAnimationBottom to:UITableViewRowAnimationTop action:STTableViewRowInsert];
    
  }
  else
  {
    if (_selectedCategorySection == index)
    {
      STCategory *c = ((STCategory *)[self.categories objectAtIndex:[self getCategoryIndexFrom:_selectedCategorySection]]);
      NSLog(@"---%@===%f", c.name, c.latitude);
      // 选择新的 目的地
      _block(c);
      
      [self.tableView endUpdates];
      return;
    }
    else
    {
      NSDictionary *categoriesDict =  [self.structure objectForKey:[NSString stringWithFormat:@"%d",categoryIndex]];
      NSArray *forwardCategoryArray = [categoriesDict objectForKey:@"forwardIndex"];
      
      if (_selectedCategorySection == -1)
      {
        _selectedCategorySection = 1;
        
        currentIndex = index;
        [self tableViewBased:currentIndex from:UITableViewRowAnimationBottom to:UITableViewRowAnimationFade action:STTableViewRowDelete];
        
        [self.displayedChildren removeAllObjects];
        [self.displayedChildren addObject:@"0"];
        [self.displayedChildren addObject:[NSString stringWithFormat:@"%d", categoryIndex]];
        
        if (forwardCategoryArray && forwardCategoryArray.count > 0)  [self.displayedChildren addObjectsFromArray:forwardCategoryArray];
        
        movedIndex = _selectedCategorySection;
        
        [self tableViewBased:movedIndex from:UITableViewRowAnimationFade to:UITableViewRowAnimationFade action:STTableViewRowInsert];
        
      }
      else
      {
        NSRange range;
        currentIndex = _selectedCategorySection;
        
        if (!categoriesDict[@"forwardIndex"]) {
          [_cus oneAnimation]; // tip 动画
        }
        
        if (index < _selectedCategorySection)
        {
          range = NSMakeRange(index, self.displayedChildren.count - index);
          _selectedCategorySection = index;
        }
        else
        {
          range = NSMakeRange(_selectedCategorySection + 1, self.displayedChildren.count - _selectedCategorySection - 1);
          [indexPathInsert addObject:[self getIndexPath:_selectedCategorySection]];
          _selectedCategorySection += 1;
        }
        
        [self tableview:self.tableView baseIndexPath:[self getIndexPath:currentIndex] fromIndexPath:[self getIndexPath:range.location] animation:UITableViewRowAnimationNone toIndexPath:[self getIndexPath:range.location + range.length - 1] animation:UITableViewRowAnimationNone tableViewAction:STTableViewRowDelete];
        
        [self.displayedChildren removeObjectsInRange:range];
        
        [self.displayedChildren addObject:[NSString stringWithFormat:@"%d",categoryIndex]];
        
        if (forwardCategoryArray && forwardCategoryArray.count > 0)
        {
          [indexPathInsert addObjectsFromArray:[self indexPathArray:self.displayedChildren.count end:self.displayedChildren.count + forwardCategoryArray.count -1]];
          [self.displayedChildren addObjectsFromArray:forwardCategoryArray];
        }
        movedIndex = _selectedCategorySection;
        [self.tableView insertRowsAtIndexPaths:indexPathInsert withRowAnimation:UITableViewRowAnimationFade];
      }
    }
  }
  if (movedIndex > -1)
  {
    [self.tableView moveRowAtIndexPath:[self getIndexPath:currentIndex] toIndexPath:[self getIndexPath:movedIndex]];
    STCategory *cate = ((STCategory *)[self.categories objectAtIndex:[self getCategoryIndexFrom:movedIndex]]);
    [self setCell:(STTableViewCell *)[self.tableView cellForRowAtIndexPath:[self getIndexPath:currentIndex]] content:cate indexRow:movedIndex];
  }
  
  [self.tableView endUpdates];
  
}

- (void)tableViewBased:(NSInteger)base from:(UITableViewRowAnimation)from to:(UITableViewRowAnimation)to action:(STTableViewRowAction)action
{
  [self tableview:self.tableView baseIndexPath:[self getIndexPath:base] fromIndexPath:[self getIndexPath:0] animation:from toIndexPath:[self getIndexPath:self.displayedChildren.count - 1] animation:to tableViewAction:action];
}

- (void)tableview:(UITableView *)tableView baseIndexPath:(NSIndexPath *)baseIndexPath fromIndexPath:(NSIndexPath *)fromIndexPath animation:(UITableViewRowAnimation)baseTofromAnimation toIndexPath:(NSIndexPath *)toIndexPath animation:(UITableViewRowAnimation)baseTotoAnimation tableViewAction:(STTableViewRowAction)action
{
  NSMutableArray *array = [[NSMutableArray alloc]init];
  array = [self indexPathArray:fromIndexPath.row end:baseIndexPath.row - 1];
  [self tableView:tableView action:action indexPathArray:array animation:baseTofromAnimation];
  array = [self indexPathArray:baseIndexPath.row + 1 end:toIndexPath.row];
  [self tableView:tableView action:action indexPathArray:array animation:baseTotoAnimation];
}

- (void)tableView:(UITableView *)tableView action:(STTableViewRowAction)action indexPathArray:(NSArray *)indexPathArray animation:(UITableViewRowAnimation)animation
{
  if (STTableViewRowInsert == action )
  {
    [tableView insertRowsAtIndexPaths:indexPathArray withRowAnimation:animation];
  }
  else if (STTableViewRowDelete == action)
  {
    [tableView deleteRowsAtIndexPaths:indexPathArray withRowAnimation:animation];
  }
}

#pragma mark - Private Methods

- (STTableViewCell *)setCell:(STTableViewCell *)cell content:(STCategory *)category indexRow:(NSInteger)indexRow
{
  [cell setContent:category];
  
  if (_selectedCategorySection < 0 )
  {
    cell.textLabel.textColor = [UIColor whiteColor];
    [cell.contentView setBackgroundColor:[UIColor colorWithHexString:category.colorHex]];
  }
  else
  {
    if (indexRow < _selectedCategorySection)
    {
      cell.textLabel.textColor = [UIColor grayColor];
    }
    else if (indexRow == _selectedCategorySection)
    {
      cell.textLabel.textColor = [UIColor whiteColor];
      [cell.contentView setBackgroundColor:[UIColor colorWithHexString:category.colorHex]];
    }
  }
  return cell;
}

- (NSInteger) getCategoryIndexFrom:(NSInteger )index
{
  if (self.displayedChildren && self.displayedChildren.count > 0 && index >=0 && index < self.displayedChildren.count)
  {
    return [((NSString *)[self.displayedChildren objectAtIndex:index]) integerValue];
  }
  return 0;
}

- (NSMutableArray *)indexPathArray:(NSInteger)begin end:(NSInteger)end
{
  NSMutableArray *indexPathArray = [[NSMutableArray alloc]init];
  for (NSInteger i = begin; i <= end; i++) {
    [indexPathArray addObject:[self getIndexPath:i]];
  }
  return indexPathArray;
}

- (NSIndexPath *)getIndexPath:(NSInteger)row
{
  return [NSIndexPath indexPathForRow:row inSection:0];
}

#pragma mark - Load Data Methods

- (void) loadDataFromLocalJSON
{
  NSString *jsonPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
  NSString *filePath = [NSString stringWithFormat:@"%@/%@", jsonPath, @"categories.json"];
  NSData *jsonData = [[NSData alloc] initWithContentsOfFile:filePath];
  NSError *error = nil;
  if (jsonData == nil) {
    return;
  }
  NSDictionary * jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
  [self parseJSON:[[[jsonDict objectForKey:@"response"] objectForKey:@"categories"] objectAtIndex:0] backIndex:-1];
}

- (NSInteger)parseJSON:(NSDictionary*)jsonDict backIndex:(NSInteger)backIndex
{
  
  NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
  
  STCategory *category = [[STCategory alloc]initWithJSON:jsonDict];
  
  NSInteger currentIndex = [self.categories count];
  [self.categories addObject:category];
  
  NSMutableArray *array = [[NSMutableArray alloc] init];
  NSMutableArray *jsonArray = [jsonDict objectForKey:@"children"];
  
  if (jsonArray && jsonArray.count > 0) {
    for (NSDictionary *jsonCategoryDict in jsonArray) {
      [array addObject: [NSString stringWithFormat:@"%d", [self parseJSON:jsonCategoryDict backIndex:currentIndex]]];
    }
  }
  
  [dict setObject:[NSString stringWithFormat:@"%d", backIndex] forKey:@"backIndex"];
  if (array && array.count > 0) {
    [dict setObject:array forKey:@"forwardIndex"];
  }
  
  [self.structure setObject:dict forKey:[NSString stringWithFormat:@"%d",currentIndex]];
  
  return currentIndex;
}

@end
