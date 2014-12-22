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
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    // 禁用 iOS7 返回手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    
    UIImage *img1 = [UIImage imageNamed:@"xxjs.png"];
    UIImage *img1_h = [UIImage imageNamed:@"xxjs_high.png"];
    
    UIImage *img2 = [UIImage imageNamed:@"wdhd.png"];
    UIImage *img2_h = [UIImage imageNamed:@"wdhd_high.png"];
    
    UIImage *img3 = [UIImage imageNamed:@"xxgg.png"];
    UIImage *img3_h = [UIImage imageNamed:@"xxgg_high.png"];
    
    UIImage *img4 = [UIImage imageNamed:@"wdgg.png"];
    UIImage *img4_h = [UIImage imageNamed:@"wdgg_high.png"];
    
    UIImage *img5 = [UIImage imageNamed:@"xxhd.png"];
    UIImage *img5_h = [UIImage imageNamed:@"xxhd_high.png"];
    
    
    BwhdViewController *vc1 = [[BwhdViewController alloc] init];
    WdhdViewController *vc2 = [[WdhdViewController alloc] init];
    GgtzViewController *vc3 = [[GgtzViewController alloc] init];
    MyNoticeReviewViewController *vc4 = [[MyNoticeReviewViewController alloc] init];
    BwrzViewController *vc5 = [[BwrzViewController alloc] init];
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
        img1 = [img1 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        img1_h = [img1_h imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        img2 = [img2 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        img2_h = [img2_h imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        img3 = [img3 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        img3_h = [img3_h imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        img4 = [img4 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        img4_h = [img4_h imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        img5 = [img5 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        img5_h = [img5_h imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        UITabBarItem *item1 = [[UITabBarItem alloc] initWithTitle:@"班务活动" image:img1 selectedImage:img1_h];
        [item1 setTag:0];
        vc1.tabBarItem = item1;
        
        UITabBarItem *item2 = [[UITabBarItem alloc] initWithTitle:@"我的活动" image:img2 selectedImage:img2_h];
        [item2 setTag:1];
        vc2.tabBarItem = item2;
        
        UITabBarItem *item3 = [[UITabBarItem alloc] initWithTitle:@"公告通知" image:img3 selectedImage:img3_h];
        [item3 setTag:2];
        vc3.tabBarItem = item3;
        
        UITabBarItem *item4 = [[UITabBarItem alloc] initWithTitle:@"我的公告" image:img4 selectedImage:img4_h];
        [item4 setTag:3];
        vc4.tabBarItem = item4;
        
        UITabBarItem *item5 = [[UITabBarItem alloc] initWithTitle:@"班务日志" image:img5 selectedImage:img5_h];
        [item5 setTag:4];
        vc5.tabBarItem = item5;
    }else{
        UITabBarItem *item1 = [[UITabBarItem alloc] initWithTitle:@"班务活动" image:img1 tag:0];
        vc1.tabBarItem = item1;
        
        UITabBarItem *item2 = [[UITabBarItem alloc] initWithTitle:@"我的活动" image:img2 tag:1];
        vc2.tabBarItem = item2;
        
        UITabBarItem *item3 = [[UITabBarItem alloc] initWithTitle:@"公告通知" image:img3 tag:2];
        vc3.tabBarItem = item3;
        
        UITabBarItem *item4 = [[UITabBarItem alloc] initWithTitle:@"我的公告" image:img4 tag:3];
        vc4.tabBarItem = item4;
        
        UITabBarItem *item5 = [[UITabBarItem alloc] initWithTitle:@"班务日志" image:img5 tag:4];
        vc5.tabBarItem = item5;
    }
    
    
    //    把导航控制器加入到数组
    NSMutableArray *viewArr_ = [NSMutableArray arrayWithObjects:vc1,vc2,vc3,vc4,vc5, nil];
    
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
        [self.navigationItem setRightBarButtonItem:bwhdButtonItem];
    }else if (item.tag == 2){
        self.title = @"公告通知";
        [self.navigationItem setRightBarButtonItem:ggtzButtonItem];
    }else if (item.tag == 4){
        self.title = @"班务日志";
        [self.navigationItem setRightBarButtonItem:bwrzButtonItem];
    }else if (item.tag == 1){
        self.title = @"我的活动";
        [self.navigationItem setRightBarButtonItem:nil];
    }else if (item.tag == 3){
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
