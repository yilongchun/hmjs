//
//  MainViewController.h
//  hmjz
//  首页
//  Created by yons on 14-10-23.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainChatViewController.h"
#import "ChatListViewController.h"

@interface MainViewController : UIViewController<UINavigationControllerDelegate,IChatManagerDelegate>{
    BOOL loginSuccess;
}
- (IBAction)chooseChildren:(UIButton *)sender;
- (IBAction)chooseClass:(UIButton *)sender;
- (IBAction)setup:(UIButton *)sender;

- (IBAction)ysdtAction:(UIButton *)sender;
- (IBAction)bwhdAction:(UIButton *)sender;
- (IBAction)yezxAction:(UIButton *)sender;
- (IBAction)kcbAction:(UIButton *)sender;
- (IBAction)bbspAction:(UIButton *)sender;
- (IBAction)xztAction:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIImageView *studentimg;
@property (weak, nonatomic) IBOutlet UILabel *studentname;
@property (weak, nonatomic) IBOutlet UILabel *studentage;
@property (weak, nonatomic) IBOutlet UILabel *unreadlabel;



@property (nonatomic, copy) NSString *flag;


//@property (strong, nonatomic) MainChatViewController *mainController;
@property (strong, nonatomic) ChatListViewController *chatListController;

- (void)setupUnreadMessageCount;

@end
