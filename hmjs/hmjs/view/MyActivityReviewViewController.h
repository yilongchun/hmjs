//
//  MyActivityReviewViewController.h
//  hmjs
//
//  Created by yons on 14-12-4.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyActivityReviewViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *mytableview;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic,copy) NSString *detailid;
@property (nonatomic,copy) NSString *title;

@end
