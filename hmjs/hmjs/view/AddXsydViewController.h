//
//  AddXsydViewController.h
//  hmjs
//
//  Created by yons on 15-2-10.
//  Copyright (c) 2015年 yons. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddXsydViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *mytableview;
@property (nonatomic, strong) NSDictionary *info;

@end
