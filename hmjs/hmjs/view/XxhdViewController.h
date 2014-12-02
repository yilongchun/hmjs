//
//  XxhdViewController.h
//  hmjz
//
//  Created by yons on 14-11-28.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XxhdViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>


@property (nonatomic, strong) UITableView *mytableview;
@property (nonatomic, strong) NSMutableArray *dataSource;


@end
