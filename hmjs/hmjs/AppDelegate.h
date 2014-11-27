//
//  AppDelegate.h
//  hmjz
//
//  Created by yons on 14-10-22.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EaseMob.h"
#import "MainChatViewController.h"
#import "ChatListViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,IChatManagerDelegate>

@property (strong, nonatomic) UIWindow *window;

//@property (strong, nonatomic) MainChatViewController *mainController;
//@property (strong, nonatomic) ChatListViewController *chatListController;


@end

