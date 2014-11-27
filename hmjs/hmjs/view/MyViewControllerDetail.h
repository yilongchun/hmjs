//
//  MyViewControllerDetail.h
//  hmjz
//  资讯详情 web显示
//  Created by yons on 14-10-30.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyViewControllerDetail : UIViewController
@property (weak, nonatomic) IBOutlet UIWebView *mywebview;

@property(nonatomic,copy) NSString *detailid;

@end
