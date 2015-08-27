//
//  MyNoticeReviewDetailViewController.h
//  hmjs
//
//  Created by yons on 14-12-4.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELCImagePickerHeader.h"

@interface MyNoticeReviewDetailViewController : UIViewController<ELCImagePickerControllerDelegate, UINavigationControllerDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate>

//@property (weak, nonatomic) IBOutlet UITextField *titleLabel;
//@property (weak, nonatomic) IBOutlet UITextView *contentTextview;
@property (nonatomic, strong) NSDictionary *data;
//@property (weak, nonatomic) IBOutlet UIButton *btn1;
//@property (weak, nonatomic) IBOutlet UIButton *btn2;
//@property (weak, nonatomic) IBOutlet UILabel *title1;
//@property (weak, nonatomic) IBOutlet UILabel *title2;
//- (IBAction)delBtn:(id)sender;
//- (IBAction)saveBtn:(id)sender;

@property (nonatomic, strong) NSMutableArray *chosenImages;
@property (weak, nonatomic) IBOutlet UITextField *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *contentTextview;
@property (weak, nonatomic) IBOutlet UIButton *imagePickBtn;
@property (weak, nonatomic) IBOutlet UIScrollView *myscrollview;

- (IBAction)launchController;

@end
