//
//  BjtzDetailViewController.h
//  hmjz
//  班级通知详情
//  Created by yons on 14-10-31.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"

@interface BjtzDetailViewController : UIViewController<HPGrowingTextViewDelegate>{
    UIView *containerView;
    HPGrowingTextView *textView;
}
@property (weak, nonatomic) IBOutlet UITableView *mytableview;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic,copy) NSString *title;

-(void)resignTextView;
@end
