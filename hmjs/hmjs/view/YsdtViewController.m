//
//  YsdtViewController.m
//  hmjz
//
//  Created by yons on 14-10-23.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import "YsdtViewController.h"
#import "YqjsViewController.h"
#import "GgtzViewController.h"
#import "BjjsViewController.h"

@interface YsdtViewController ()
@end

@implementation YsdtViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    // Do any additional setup after loading the view from its nib.
    [self.navigationController setNavigationBarHidden:NO];
    
    YqjsViewController *yqjs = [[YqjsViewController alloc] init];
    yqjs.title = @"园情介绍";
    BjjsViewController *bjjs = [[BjjsViewController alloc] init];
    bjjs.title = @"班级介绍";
    GgtzViewController *ggtz = [[GgtzViewController alloc] init];
    ggtz.title = @"公告通知";
    [self setViewControllers:[NSArray arrayWithObjects:yqjs, bjjs, ggtz, nil]];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
