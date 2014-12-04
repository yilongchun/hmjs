//
//  WdhdViewController.h
//  hmjs
//  我的活动
//  Created by yons on 14-12-3.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WdhdViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>


@property (nonatomic, strong) UITableView *mytableview;
@property (nonatomic, strong) NSMutableArray *dataSource;


@end
