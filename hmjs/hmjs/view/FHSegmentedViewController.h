//
//  KPSegmentedViewController.h
//  KPKuaiPai
//  工具类 分段选择切换界面
//  Created by Johnny iDay on 13-12-14.
//  Copyright (c) 2013年 Johnny iDay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FHSegmentedViewController : UIViewController

@property(nonatomic, assign) UIViewController *selectedViewController;
@property(nonatomic, strong) IBOutlet UISegmentedControl *segmentedControl;
@property(nonatomic, assign) NSInteger selectedViewControllerIndex;

- (void)setViewControllers:(NSArray *)viewControllers;
- (void)setViewControllers:(NSArray *)viewControllers titles:(NSArray *)titles;
- (void)pushViewController:(UIViewController *)viewController;
- (void)pushViewController:(UIViewController *)viewController title:(NSString *)title;

@end
