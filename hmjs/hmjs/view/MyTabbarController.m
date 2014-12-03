//
//  MyTabbarController.m
//  hmjz
//
//  Created by yons on 14-11-20.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import "MyTabbarController.h"
#import "YqjsViewController.h"
#import "BjjsViewController.h"


@interface MyTabbarController ()

@end

@implementation MyTabbarController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    //    初始化第一个视图控制器
    YqjsViewController *vc1 = [[YqjsViewController alloc] init];
    vc1.tabBarItem =[[UITabBarItem alloc] initWithTitle:@"学校介绍" image:[UIImage imageNamed:@"ic_bwrz_002.png"] tag:0];
    
    
    //    初始化第二个视图控制器
    BjjsViewController *vc2 = [[BjjsViewController alloc] init];
    vc2.tabBarItem =[[UITabBarItem alloc] initWithTitle:@"班级介绍" image:[UIImage imageNamed:@"ic_bwrz_001.png"] tag:1];
    
    //    把导航控制器加入到数组
    NSMutableArray *viewArr_ = [NSMutableArray arrayWithObjects:vc1,vc2, nil];
    
    self.title = @"学校介绍";
    self.viewControllers = viewArr_;
    
    self.selectedIndex = 0;
    [[self tabBar] setSelectedImageTintColor:[UIColor colorWithRed:42/255.0 green:173/255.0 blue:128/255.0 alpha:1]];
    
    
}

#pragma mark - UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if (item.tag == 0) {
        self.title = @"学校介绍";
    }else if (item.tag == 1){
        self.title = @"班级介绍";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
