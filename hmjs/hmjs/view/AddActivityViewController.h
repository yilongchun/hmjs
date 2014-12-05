//
//  AddActivityViewController.h
//  hmjs
//
//  Created by yons on 14-12-5.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddActivityViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *contentTextview;
@property (weak, nonatomic) IBOutlet UIButton *btn1;
@property (weak, nonatomic) IBOutlet UIButton *imagePickBtn;

- (IBAction)saveBtn:(id)sender;


@end
