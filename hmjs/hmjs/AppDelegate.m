//
//  AppDelegate.m
//  hmjz
//
//  Created by yons on 14-10-22.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "ApplyViewController.h"
#import "Utils.h"
#import "GuideViewController.h"
#import "IQKeyboardManager.h"
//#import "TempViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    

    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginStateChange:)
                                                 name:KNOTIFICATION_LOGINCHANGE
                                               object:nil];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:116/255.0 green:176/255.0 blue:64/255.0 alpha:1]];
    }
    
    
    //推送
    [self registerRemoteNotification];
//#warning SDK注册 APNS文件的名字, 需要与后台上传证书时的名字一一对应
    NSString *apnsCertName = nil;
#if DEBUG
    apnsCertName = APNSCERTNAME_DEVELOP;
    NSLog(@"开发推送证书");
#else
    apnsCertName = APNSCERTNAME_PRODUCTION;
    NSLog(@"正式推送证书");
#endif
    [[EaseMob sharedInstance] registerSDKWithAppKey:EASEMOB_APP_KEY apnsCertName:apnsCertName];
    
    
#if DEBUG
    [[EaseMob sharedInstance] enableUncaughtExceptionHandler];
#endif
    [[[EaseMob sharedInstance] chatManager] setIsAutoFetchBuddyList:YES];
    
    //以下一行代码的方法里实现了自动登录，异步登录，需要监听[didLoginWithInfo: error:]
    //demo中此监听方法在MainViewController中
    [[EaseMob sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    
    //注册为SDK的ChatManager的delegate (及时监听到申请和通知)
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];

    [MagicalRecord setupCoreDataStackWithStoreNamed:[NSString stringWithFormat:@"%@.sqlite", @"UIDemo"]];
    
//    [self loginStateChange:nil];
    
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    NSString *loginusername = [userDefaults objectForKey:@"loginusername"];
//    NSString *loginpassword = [userDefaults objectForKey:@"loginpassword"];
//    
//    
//    if (![Utils isBlankString:loginusername] && ![Utils isBlankString:loginpassword]) {
//        UINavigationController *vc = [[UINavigationController alloc] initWithRootViewController:[[MainViewController alloc] init]];
//        [vc setNavigationBarHidden:YES];
//        self.window.rootViewController = vc;
//    }else{
    
//    }
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"everLaunched"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"everLaunched"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunch"];
        NSLog(@"first launch第一次程序启动");
        //  [self.viewController setNsstilt:@"这是第一次启动"];
        
        
        GuideViewController *vc = [[GuideViewController alloc] init];
        self.window.rootViewController = vc;
        
        
        //== 这里开始你可以放入引导画面了! ==//
    }else {
        NSLog(@"second launch再次程序启动");
        //  [self.viewController setNsstilt:@"这是程序的N次启动"];
        LoginViewController *loginvc =  [[LoginViewController alloc] init];
        loginvc.logintype = @"login";
//        TempViewController *loginvc = [[TempViewController alloc] init];
        UINavigationController *vc = [[UINavigationController alloc] initWithRootViewController:loginvc];
        [vc setNavigationBarHidden:YES];
        self.window.rootViewController = vc;
    }
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//系统方法
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    //SDK调用
    [[EaseMob sharedInstance] application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

//系统方法
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    //SDK方法调用
//    [[EaseMob sharedInstance] application:application didFailToRegisterForRemoteNotificationsWithError:error];
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"注册推送失败"
//                                                    message:error.description
//                                                   delegate:nil
//                                          cancelButtonTitle:@"确定"
//                                          otherButtonTitles:nil];
//    [alert show];
}

//系统方法
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    //SDK方法调用
    [[EaseMob sharedInstance] application:application didReceiveRemoteNotification:userInfo];
}
//系统方法
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    //SDK方法调用
    [[EaseMob sharedInstance] application:application didReceiveLocalNotification:notification];
}


- (void)registerRemoteNotification{
    #if !TARGET_IPHONE_SIMULATOR
    UIApplication *application = [UIApplication sharedApplication];
    
    //iOS8 注册APNS
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
        [application registerForRemoteNotifications];
        UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
    }else{
        UIRemoteNotificationType notificationTypes = UIRemoteNotificationTypeBadge |
        UIRemoteNotificationTypeSound |
        UIRemoteNotificationTypeAlert;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:notificationTypes];
    }
    
    #endif
    
}

#pragma mark - push
- (void)didBindDeviceWithError:(EMError *)error
{
    if (error) {
        NSLog(@"消息推送与设备绑定失败");
    }
}

#pragma mark - private

-(void)loginStateChange:(NSNotification *)notification
{
    UINavigationController *nav = nil;
    
    BOOL isAutoLogin = [[[EaseMob sharedInstance] chatManager] isAutoLoginEnabled];
    BOOL loginSuccess = [notification.object boolValue];
    
    
    
    
//    if (isAutoLogin || loginSuccess) {
//        
//        [[ApplyViewController shareController] loadDataSourceFromLocalDB];
//        if (_mainController == nil) {
//            _mainController = [[MainChatViewController alloc] init];
//            nav = [[UINavigationController alloc] initWithRootViewController:_mainController];
//        }else{
//            nav  = _mainController.navigationController;
//        }
//        NSLog(@"环信登陆成功");
//        
//        
//    }else{
//        LoginViewController *loginController = [[LoginViewController alloc] init];
//        nav = [[UINavigationController alloc] initWithRootViewController:loginController];
//        NSLog(@"环信未登陆");
//    }
    if (isAutoLogin || loginSuccess) {
        NSLog(@"已登陆");
        NSString *ver = [[EaseMob sharedInstance] sdkVersion];
        NSLog(@"%@",ver);
        
//        [[ApplyViewController shareController] loadDataSourceFromLocalDB];
//        if (_mainController == nil) {
//            _mainController = [[MainChatViewController alloc] init];
//            nav = [[UINavigationController alloc] initWithRootViewController:_mainController];
//        }else{
//            nav  = _mainController.navigationController;
//        }
    }else{
//        _mainController = nil;
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults removeObjectForKey:@"loginusername"];
        [userDefaults removeObjectForKey:@"loginpassword"];
        
        LoginViewController *loginController = [[LoginViewController alloc] init];
        nav = [[UINavigationController alloc] initWithRootViewController:loginController];
        self.window.rootViewController = nav;
        [nav setNavigationBarHidden:YES];
    }

    
    

}

#pragma mark - IChatManagerDelegate 好友变化

//- (void)didReceiveBuddyRequest:(NSString *)username
//                       message:(NSString *)message
//{
//    if (!username) {
//        return;
//    }
//    if (!message) {
//        message = [NSString stringWithFormat:@"%@ 添加你为好友", username];
//    }
//    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{@"title":username, @"username":username, @"applyMessage":message, @"applyStyle":[NSNumber numberWithInteger:ApplyStyleFriend]}];
//    [[ApplyViewController shareController] addNewApply:dic];
//    if (_mainController) {
//        [_mainController setupUntreatedApplyCount];
//    }
//}

#pragma mark - IChatManagerDelegate 群组变化

//- (void)didReceiveGroupInvitationFrom:(NSString *)groupId
//                              inviter:(NSString *)username
//                              message:(NSString *)message
//{
//    if (!groupId || !username) {
//        return;
//    }
//    
//    NSString *groupName = groupId;
//    if (!message || message.length == 0) {
//        message = [NSString stringWithFormat:@"%@ 邀请你加入群组\'%@\'", username, groupName];
//    }
//    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{@"title":groupName, @"groupId":groupId, @"username":username, @"applyMessage":message, @"applyStyle":[NSNumber numberWithInteger:ApplyStyleGroupInvitation]}];
//    [[ApplyViewController shareController] addNewApply:dic];
//    if (_mainController) {
//        [_mainController setupUntreatedApplyCount];
//    }
//}

//接收到入群申请
//- (void)didReceiveApplyToJoinGroup:(NSString *)groupId
//                         groupname:(NSString *)groupname
//                     applyUsername:(NSString *)username
//                            reason:(NSString *)reason
//                             error:(EMError *)error
//{
//    if (!groupId || !username) {
//        return;
//    }
//    
//    if (!reason || reason.length == 0) {
//        reason = [NSString stringWithFormat:@"%@ 申请加入群组\'%@\'", username, groupname];
//    }
//    else{
//        reason = [NSString stringWithFormat:@"%@ 申请加入群组\'%@\'：%@", username, groupname, reason];
//    }
//    
//    if (error) {
//        NSString *message = [NSString stringWithFormat:@"发送申请失败:%@\n原因：%@", reason, error.description];
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alertView show];
//    }
//    else{
//        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{@"title":groupname, @"groupId":groupId, @"username":username, @"groupname":groupname, @"applyMessage":reason, @"applyStyle":[NSNumber numberWithInteger:ApplyStyleJoinGroup]}];
//        [[ApplyViewController shareController] addNewApply:dic];
//        if (_mainController) {
//            [_mainController setupUntreatedApplyCount];
//        }
//    }
//}

//- (void)didReceiveRejectApplyToJoinGroupFrom:(NSString *)fromId
//                                   groupname:(NSString *)groupname
//                                      reason:(NSString *)reason
//{
//    if (!reason || reason.length == 0) {
//        reason = [NSString stringWithFormat:@"被拒绝加入群组\'%@\'", groupname];
//    }
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"申请提示" message:reason delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//    [alertView show];
//}

//- (void)group:(EMGroup *)group didLeave:(EMGroupLeaveReason)reason error:(EMError *)error
//{
//    NSString *tmpStr = group.groupSubject;
//    NSString *str;
//    if (!tmpStr || tmpStr.length == 0) {
//        NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
//        for (EMGroup *obj in groupArray) {
//            if ([obj.groupId isEqualToString:group.groupId]) {
//                tmpStr = obj.groupSubject;
//                break;
//            }
//        }
//    }
//    
//    if (reason == eGroupLeaveReason_BeRemoved) {
//        str = [NSString stringWithFormat:@"你被从群组\'%@\'中踢出", tmpStr];
//    }
//    if (str.length > 0) {
//        TTAlertNoTitle(str);
//    }
//}


@end
