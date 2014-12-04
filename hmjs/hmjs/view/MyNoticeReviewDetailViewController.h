//
//  MyNoticeReviewDetailViewController.h
//  hmjs
//
//  Created by yons on 14-12-4.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyNoticeReviewDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *contentTextview;
@property (nonatomic, strong) NSDictionary *data;
@property (weak, nonatomic) IBOutlet UIButton *btn1;
@property (weak, nonatomic) IBOutlet UIButton *btn2;
- (IBAction)delBtn:(id)sender;
- (IBAction)saveBtn:(id)sender;

@end
