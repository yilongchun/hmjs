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
#import "JsfcViewController.h"

@interface MyTabbarController ()

@end

@implementation MyTabbarController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImage *img1 = [UIImage imageNamed:@"xxjs.png"];
    UIImage *img1_h = [UIImage imageNamed:@"xxjs_high.png"];
    
    UIImage *img2 = [UIImage imageNamed:@"bjjs.png"];
    UIImage *img2_h = [UIImage imageNamed:@"bjjs_high.png"];
    
    UIImage *img3 = [UIImage imageNamed:@"jsfc"];
    UIImage *img3_h = [UIImage imageNamed:@"jsfc_high"];
    
    YqjsViewController *vc1 = [[YqjsViewController alloc] init];
    BjjsViewController *vc2 = [[BjjsViewController alloc] init];
    JsfcViewController *vc3 = [[JsfcViewController alloc] init];
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
        img1 = [img1 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        img1_h = [img1_h imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        img2 = [img2 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        img2_h = [img2_h imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        img3 = [img3 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        img3_h = [img3_h imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        UITabBarItem *item1 = [[UITabBarItem alloc] initWithTitle:@"学校介绍" image:img1 selectedImage:img1_h];
        [item1 setTag:0];
        vc1.tabBarItem = item1;
        
        UITabBarItem *item2 = [[UITabBarItem alloc] initWithTitle:@"班级介绍" image:img2 selectedImage:img2_h];
        [item2 setTag:1];
        vc2.tabBarItem = item2;
        
        UITabBarItem *item3 = [[UITabBarItem alloc] initWithTitle:@"教师风采" image:img3 selectedImage:img3_h];
        [item3 setTag:2];
        vc3.tabBarItem = item3;
        
    }else{
        UITabBarItem *item1 = [[UITabBarItem alloc] initWithTitle:@"学校介绍" image:img1 tag:0];
        vc1.tabBarItem = item1;
        UITabBarItem *item2 = [[UITabBarItem alloc] initWithTitle:@"班级介绍" image:img2 tag:1];
        vc2.tabBarItem = item2;
        UITabBarItem *item3 = [[UITabBarItem alloc] initWithTitle:@"教师风采" image:img3 tag:2];
        vc3.tabBarItem = item3;
    }
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
   
    
    //    把导航控制器加入到数组
    NSMutableArray *viewArr_ = [NSMutableArray arrayWithObjects:vc1,vc2,vc3, nil];
    
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
    }else if (item.tag == 2){
        self.title = @"教师风采";
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

//ios<6.0
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    NSLog(@"shouldAutorotateToInterfaceOrientation3");
    return NO;
}
//ios>6.0
- (BOOL)shouldAutorotate
{
    NSLog(@"shouldAutorotate3");
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    NSLog(@"supportedInterfaceOrientations3");
    return UIInterfaceOrientationMaskPortrait;//只支持这一个方向(正常的方向)
}

@end
