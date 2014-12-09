//
//  BbxxTarbarViewController.m
//  hmjz
//
//  Created by yons on 14-11-28.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import "BbxxTarbarViewController.h"
#import "BwhdViewController.h"
#import "GgtzViewController.h"
#import "BwrzViewController.h"
#import "WdhdViewController.h"
#import "MyNoticeReviewViewController.h"
#import "AddNoticeViewController.h"
#import "AddActivityViewController.h"
#import "AddBwrzViewController.h"

@interface BbxxTarbarViewController (){
    UIBarButtonItem *bwhdButtonItem;
    UIBarButtonItem *ggtzButtonItem;
    UIBarButtonItem *bwrzButtonItem;
}

@end

@implementation BbxxTarbarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO ;
    
    //    初始化第一个视图控制器
    BwhdViewController *vc1 = [[BwhdViewController alloc] init];
    UITabBarItem *item1 = [[UITabBarItem alloc] initWithTitle:@"班务活动" image:[[UIImage imageNamed:@"xxjs.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"xxjs_high.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [item1 setTag:0];
    vc1.tabBarItem = item1;
    
    WdhdViewController *vc4 = [[WdhdViewController alloc] init];
    UITabBarItem *item4 = [[UITabBarItem alloc] initWithTitle:@"我的活动" image:[[UIImage imageNamed:@"wdhd.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"wdhd_high.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [item4 setTag:3];
    vc4.tabBarItem = item4;
    
    //    初始化第二个视图控制器
    GgtzViewController *vc2 = [[GgtzViewController alloc] init];
    UITabBarItem *item2 = [[UITabBarItem alloc] initWithTitle:@"公告通知" image:[[UIImage imageNamed:@"xxgg.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"xxgg_high.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [item2 setTag:1];
    vc2.tabBarItem = item2;
    
    MyNoticeReviewViewController *vc5 = [[MyNoticeReviewViewController alloc] init];
    UITabBarItem *item5 = [[UITabBarItem alloc] initWithTitle:@"我的公告" image:[[UIImage imageNamed:@"wdgg.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"wdgg_high.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [item5 setTag:4];
    vc5.tabBarItem = item5;
    
    //    初始化第三个视图控制器
    BwrzViewController *vc3 = [[BwrzViewController alloc] init];
    UITabBarItem *item3 = [[UITabBarItem alloc] initWithTitle:@"班务日志" image:[[UIImage imageNamed:@"xxhd.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"xxhd_high.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [item3 setTag:2];
    vc3.tabBarItem = item3;
    
    //    把导航控制器加入到数组
    NSMutableArray *viewArr_ = [NSMutableArray arrayWithObjects:vc1,vc4,vc2,vc5,vc3, nil];
    
    self.title = @"班务活动";
    self.viewControllers = viewArr_;
    self.selectedIndex = 0;
    [[self tabBar] setSelectedImageTintColor:[UIColor colorWithRed:42/255.0 green:173/255.0 blue:128/255.0 alpha:1]];
    
    //设置导航栏右侧按钮
    UIImage* image= [UIImage imageNamed:@"ic_bwgg_011.png"];
    CGRect frame= CGRectMake(0, 0, 30, 30);
    UIButton* someButton= [[UIButton alloc] initWithFrame:frame];
    [someButton addTarget:self action:@selector(action1) forControlEvents:UIControlEventTouchUpInside];
    [someButton setBackgroundImage:image forState:UIControlStateNormal];
    [someButton setShowsTouchWhenHighlighted:NO];
    bwhdButtonItem = [[UIBarButtonItem alloc] initWithCustomView:someButton];
    
    UIButton* someButton2= [[UIButton alloc] initWithFrame:frame];
    [someButton2 addTarget:self action:@selector(action2) forControlEvents:UIControlEventTouchUpInside];
    [someButton2 setBackgroundImage:image forState:UIControlStateNormal];
    [someButton2 setShowsTouchWhenHighlighted:NO];
    ggtzButtonItem = [[UIBarButtonItem alloc] initWithCustomView:someButton2];
    
    UIButton* someButton3= [[UIButton alloc] initWithFrame:frame];
    [someButton3 addTarget:self action:@selector(action3) forControlEvents:UIControlEventTouchUpInside];
    [someButton3 setBackgroundImage:image forState:UIControlStateNormal];
    [someButton3 setShowsTouchWhenHighlighted:NO];
    bwrzButtonItem = [[UIBarButtonItem alloc] initWithCustomView:someButton3];
    [self.navigationItem setRightBarButtonItem:bwhdButtonItem];

    
}

#pragma mark - UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if (item.tag == 0) {
        self.title = @"班务活动";
        //设置导航栏右侧按钮
        [self.navigationItem setRightBarButtonItem:bwhdButtonItem];
    }else if (item.tag == 1){
        self.title = @"公告通知";
        [self.navigationItem setRightBarButtonItem:ggtzButtonItem];
    }else if (item.tag == 2){
        self.title = @"班务日志";
        [self.navigationItem setRightBarButtonItem:bwrzButtonItem];
    }else if (item.tag == 3){
        self.title = @"我的活动";
        [self.navigationItem setRightBarButtonItem:nil];
    }else if (item.tag == 4){
        self.title = @"我的公告";
        [self.navigationItem setRightBarButtonItem:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)action1{//添加班务活动
    AddActivityViewController *vc = [[AddActivityViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)action2{//添加公告通知
    AddNoticeViewController *vc = [[AddNoticeViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)action3{//添加班务日志
    AddBwrzViewController *vc = [[AddBwrzViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
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
