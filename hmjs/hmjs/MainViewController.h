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
#import "GroupListViewController.h"
#import "SMPageControl.h"

@interface MainViewController : UIViewController<UINavigationControllerDelegate,IChatManagerDelegate,UIScrollViewDelegate>{
    BOOL loginSuccess;
}

- (IBAction)chooseClass:(UIButton *)sender;
- (IBAction)setup:(UIButton *)sender;

- (IBAction)bwglAction:(UIButton *)sender;
- (IBAction)ysdtAction:(UIButton *)sender;
- (IBAction)xsspAction:(UIButton *)sender;
- (IBAction)yezxAction:(UIButton *)sender;
- (IBAction)kcbAction:(UIButton *)sender;
- (IBAction)xztAction:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIImageView *teacherimg;
@property (weak, nonatomic) IBOutlet UILabel *teachername;

@property (nonatomic, copy) NSString *flag;
@property (nonatomic, strong) NSMutableArray *menus;


//@property (strong, nonatomic) MainChatViewController *mainController;
@property (strong, nonatomic) ChatListViewController *chatListController;
@property (strong, nonatomic) GroupListViewController *groupController;

- (void)setupUnreadMessageCount;

@end
