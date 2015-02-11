//
//  AddXsydViewController.h
//  hmjs
//
//  Created by yons on 15-2-10.
//  Copyright (c) 2015年 yons. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddXsydViewController : UIViewController<UIActionSheetDelegate,UIAlertViewDelegate>

@property (nonatomic, strong) UITableView *mytableview;
@property (nonatomic, strong) NSDictionary *studentinfo;

@property (weak, nonatomic) IBOutlet UIButton *dateBtn;
@property (weak, nonatomic) IBOutlet UISegmentedControl *typeSeg;
@property (weak, nonatomic) IBOutlet UITextField *nameText;
@property (weak, nonatomic) IBOutlet UITextField *reasonText;
@property (weak, nonatomic) IBOutlet UITextView *remarkText;
@property (weak, nonatomic) IBOutlet UIButton *studentBtn;
@property (weak, nonatomic) IBOutlet UILabel *classnameLabel;

- (IBAction)chooseDate:(id)sender;
- (IBAction)chooseStudent:(id)sender;

@end
