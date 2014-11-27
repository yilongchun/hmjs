//
//  MainViewController.m
//  hmjz
//
//  Created by yons on 14-10-23.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import "MainViewController.h"
#import "MKNetworkKit.h"
#import "Utils.h"
#import "YsdtViewController.h"
#import "BwhdViewController.h"
#import "GgtzViewController.h"
#import "ShezhiViewController.h"
#import "ChooseChildrenViewController.h"
#import "ChooseClassViewController.h"
#import "BjtzViewController.h"
#import "BwhdViewController.h"
#import "MyViewController.h"
#import "JYSlideSegmentController.h"
#import "GrdaViewController.h"
#import "KcbViewController.h"
#import "BbspViewController.h"
#import "UIImageView+AFNetworking.h"
#import "MBProgressHUD.h"
#import "ApplyViewController.h"
#import "MyTabbarController.h"

//两次提示的默认间隔
static const CGFloat kDefaultPlaySoundInterval = 3.0;

@interface MainViewController ()<MBProgressHUDDelegate,UIAlertViewDelegate>{
    MKNetworkEngine *engine;
    NSArray *typearr;//育儿资讯分类
    NSArray *kcbarr;//课程表
    NSArray *sparr;//食谱
    MBProgressHUD *HUD;
}

@property (strong, nonatomic)NSDate *lastPlaySoundDate;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    self.unreadlabel.layer.cornerRadius = self.unreadlabel.frame.size.height/2;
    self.unreadlabel.layer.masksToBounds = YES;
    
    //获取未读消息数，此时并没有把self注册为SDK的delegate，读取出的未读数是上次退出程序时的
    [self didUnreadMessagesCountChanged];
    //warning 把self注册为SDK的delegate
    [self registerNotifications];
    
    [[ApplyViewController shareController] loadDataSourceFromLocalDB];
//    _mainController = [[MainChatViewController alloc] init];
    _chatListController = [[ChatListViewController alloc] init];
    _chatListController.title = @"会话";
//    [_chatListController registerNotifications];
    
    [self setupUnreadMessageCount];
    
    
    //设置导航栏
    self.navigationController.delegate = self;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor, nil]];
    [self.navigationController setNavigationBarHidden:YES];
    
    
        
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    self.navigationItem.backBarButtonItem = backItem;
    backItem.title = @"返回";
    
    //初始化网络引擎
    engine = [[MKNetworkEngine alloc] initWithHostName:[Utils getHostname] customHeaderFields:nil];
    
    //添加加载等待条
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"加载中";
    [self.view addSubview:HUD];
    HUD.delegate = self;
    
    UITapGestureRecognizer *singleTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(grdaAction:)];
    [self.studentimg addGestureRecognizer:singleTap1];
    
    self.studentimg.layer.cornerRadius = self.studentimg.frame.size.height/2;
    self.studentimg.layer.masksToBounds = YES;
    [self.studentimg setContentMode:UIViewContentModeScaleAspectFill];
    [self.studentimg setClipsToBounds:YES];
    self.studentimg.layer.borderColor = [UIColor yellowColor].CGColor;
    self.studentimg.layer.borderWidth = 1.0f;
    self.studentimg.layer.shadowOffset = CGSizeMake(4.0, 4.0);
    self.studentimg.layer.shadowOpacity = 0.5;
    self.studentimg.layer.shadowRadius = 2.0;
    
    [self initData];
    
}

- (void)initData{
    [self loadData];//设置学生信息
    [self loadYezx];//加载育儿资讯分类
    [self loadKcb];//加载课程表
    [self loadBbsp];//加载食谱
    [self loadData2];
   
}

//加载信息设置
- (void)loadData{
    //设置信息
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *student = [userDefaults objectForKey:@"student"];
    NSString *studentname = [student objectForKey:@"studnetname"];
    NSNumber *studentage = [student objectForKey:@"age"];
    NSString *flieid = [student objectForKey:@"flieid"];
    
    self.studentname.text = studentname;
    self.studentage.text = [NSString stringWithFormat:@"年龄：%@岁",studentage];
    
    //设置头像
    if ([Utils isBlankString:flieid]) {
        [self.studentimg setImage:[UIImage imageNamed:@"chatListCellHead.png"]];
    }else{
//        [self.studentimg setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/image/show.do?id=%@",[Utils getImageHostname],flieid]] placeholderImage:[UIImage imageNamed:@"nopicture.png"]];
        [self.studentimg setImageWithURL:[NSURL URLWithString:flieid] placeholderImage:[UIImage imageNamed:@"chatListCellHead.png"]];
    }
}
//家长列表
- (void)loadData2{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *class = [userDefaults objectForKey:@"class"];
    NSString *classid = [class objectForKey:@"classid"];
    [dic setValue:classid forKey:@"classId"];
    [dic setValue:@"1" forKey:@"page"];
    [dic setValue:@"10" forKey:@"rows"];
    
    MKNetworkOperation *op = [engine operationWithPath:@"/Parentfield/findPageList.do" params:dic httpMethod:@"GET"];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        //        NSLog(@"[operation responseData]-->>%@", [operation responseString]);
        NSString *result = [operation responseString];
        NSError *error;
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (resultDict == nil) {
            NSLog(@"json parse failed \r\n");
        }
        NSNumber *success = [resultDict objectForKey:@"success"];
        if ([success boolValue]) {
            NSDictionary *data = [resultDict objectForKey:@"data"];
            if (data != nil) {
                NSArray *arr = [data objectForKey:@"rows"];
                
                [userDefaults setObject:arr forKey:@"friendarr"];
            }
        }else{
            
            
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
    }];
    [engine enqueueOperation:op];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
//隐藏导航栏
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
    if ([viewController isKindOfClass:[MainViewController class]]) {
        [self.navigationController setNavigationBarHidden:YES];
    }
}

//选择宝宝
- (IBAction)chooseChildren:(UIButton *)sender {
    ChooseChildrenViewController *cc = [[ChooseChildrenViewController alloc] init];
    [self.navigationController pushViewController:cc animated:YES];
}
//选择班级
- (IBAction)chooseClass:(UIButton *)sender {
    
    ChooseClassViewController *cc = [[ChooseClassViewController alloc] init];
    [self.navigationController pushViewController:cc animated:YES];
}

- (void)grdaAction:(UITapGestureRecognizer *)sender{
    GrdaViewController *vc = [[GrdaViewController alloc] init];
    
    [self.navigationController pushViewController:vc animated:YES];
}

//设置
- (IBAction)setup:(UIButton *)sender {
    
    ShezhiViewController *sz = [[ShezhiViewController alloc] init];
    [self.navigationController pushViewController:sz animated:YES];
}
//园所动态
- (IBAction)ysdtAction:(UIButton *)sender {
    
    
    YsdtViewController *ysdt = [[YsdtViewController alloc] init];
    [self.navigationController pushViewController:ysdt animated:YES];
}
//班务活动
- (IBAction)bwhdAction:(UIButton *)sender {
    
    //    初始化第一个视图控制器
//    BwhdViewController *vc1 = [[BwhdViewController alloc] init];
//    vc1.tabBarItem =[[UITabBarItem alloc] initWithTitle:@"班务活动" image:[UIImage imageNamed:@"ic_bwrz_002.png"] tag:0];
//    
//    
//    //    初始化第二个视图控制器
//    BjtzViewController *vc2 = [[BjtzViewController alloc] init];
//    vc2.tabBarItem =[[UITabBarItem alloc] initWithTitle:@"班级通知" image:[UIImage imageNamed:@"ic_bwrz_003.png"] tag:1];
//
//    //    把导航控制器加入到数组
//    NSMutableArray *viewArr_ = [NSMutableArray arrayWithObjects:vc1,vc2, nil];
    
    
    MyTabbarController *tabBarCtl = [[MyTabbarController alloc] init];
    
    //    把视图数组放到tabbarcontroller 里面
//    UITabBarController *tabBarCtl = [[UITabBarController alloc] init];
//    [tabBarCtl.view setFrame:CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.height)];
//    tabBarCtl.title = @"班务活动";
//    tabBarCtl.viewControllers = viewArr_;
//    
//    tabBarCtl.selectedIndex = 0;
//    [[tabBarCtl tabBar] setSelectedImageTintColor:[UIColor colorWithRed:42/255.0 green:173/255.0 blue:128/255.0 alpha:1]];
    
    
    
    [self.navigationController pushViewController:tabBarCtl animated:YES];
    [self.navigationController setNavigationBarHidden:NO];
    
}

- (void)loadYezx{
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *userid = [userDefaults objectForKey:@"userid"];
        [dic setValue:userid forKey:@"userid"];
    
        MKNetworkOperation *op = [engine operationWithPath:@"/MationType/findAllList.do" params:dic httpMethod:@"GET"];
        [op addCompletionHandler:^(MKNetworkOperation *operation) {

            NSString *result = [operation responseString];
            NSError *error;
            NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
            if (resultDict == nil) {
                NSLog(@"json parse failed \r\n");
            }
            NSNumber *success = [resultDict objectForKey:@"success"];
            if ([success boolValue]) {
                NSArray *data = [resultDict objectForKey:@"data"];
                if (data != nil) {
                    typearr = data;
                }
            }else{
    
    
            }
        }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
            NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        }];
        [engine enqueueOperation:op];
}

//育儿资讯
- (IBAction)yezxAction:(UIButton *)sender {
    
    NSMutableArray *vcs = [NSMutableArray array];
    for (int i = 0; i < [typearr count]; i++) {
        NSDictionary *type = [typearr objectAtIndex:i];
        
        MyViewController *vc = [[MyViewController alloc] init];
        vc.typeId = [type objectForKey:@"id"];
//        UIViewController *vc = [[UIViewController alloc] init];
        vc.title = [NSString stringWithFormat:@"%@", [type objectForKey:@"typename"]];
        [vcs addObject:vc];
    }
    
    JYSlideSegmentController *slideSegmentController = [[JYSlideSegmentController alloc] initWithViewControllers:vcs];
    slideSegmentController.title = @"育儿资讯";
    slideSegmentController.indicatorInsets = UIEdgeInsetsMake(0, 8, 8, 8);
    slideSegmentController.indicator.backgroundColor = [UIColor greenColor];
    
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController pushViewController:slideSegmentController animated:YES];
    
   
}

- (void)loadKcb{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *class = [userDefaults objectForKey:@"class"];
    NSString *classid = [class objectForKey:@"classid"];
    [dic setValue:classid forKey:@"classid"];
    
    MKNetworkOperation *op = [engine operationWithPath:@"/Schedule/findPbyid.do" params:dic httpMethod:@"GET"];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
//        NSLog(@"[operation responseData]-->>%@", [operation responseString]);
        NSString *result = [operation responseString];
        NSError *error;
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (resultDict == nil) {
            NSLog(@"json parse failed \r\n");
        }
        NSNumber *success = [resultDict objectForKey:@"success"];
        //            NSString *msg = [resultDict objectForKey:@"msg"];
        //        NSString *code = [resultDict objectForKey:@"code"];
        if ([success boolValue]) {
            NSArray *data = [resultDict objectForKey:@"data"];
            if (data != nil) {
                kcbarr = data;
            }
        }else{
            
            
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
    }];
    [engine enqueueOperation:op];
}
//课程表
- (IBAction)kcbAction:(UIButton *)sender {
    NSMutableArray *vcs = [NSMutableArray array];
    
    KcbViewController *vc1 = [[KcbViewController alloc] init];
    vc1.title = @"周一";
    vc1.dataSource = kcbarr;
    vc1.weekName = @"monday";
    [vcs addObject:vc1];
    KcbViewController *vc2 = [[KcbViewController alloc] init];
    vc2.title = @"周二";
    vc2.dataSource = kcbarr;
    vc2.weekName = @"tuesday";
    [vcs addObject:vc2];
    KcbViewController *vc3 = [[KcbViewController alloc] init];
    vc3.title = @"周三";
    vc3.dataSource = kcbarr;
    vc3.weekName = @"wednesday";
    [vcs addObject:vc3];
    KcbViewController *vc4 = [[KcbViewController alloc] init];
    vc4.title = @"周四";
    vc4.dataSource = kcbarr;
    vc4.weekName = @"thursday";
    [vcs addObject:vc4];
    KcbViewController *vc5 = [[KcbViewController alloc] init];
    vc5.title = @"周五";
    vc5.dataSource = kcbarr;
    vc5.weekName = @"friday";
    [vcs addObject:vc5];
    

    JYSlideSegmentController *slideSegmentController = [[JYSlideSegmentController alloc] initWithViewControllers:vcs];
    //设置背景图片
    UIImage *image = [UIImage imageNamed:@"ic_kcb_bg.png"];
    slideSegmentController.view.layer.contents = (id)image.CGImage;
    

    slideSegmentController.title = @"课程表";
    slideSegmentController.indicatorInsets = UIEdgeInsetsMake(0, 8, 8, 8);
    slideSegmentController.indicator.backgroundColor = [UIColor greenColor];
    
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController pushViewController:slideSegmentController animated:YES];
}

//加载食谱
- (void)loadBbsp{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *student = [userDefaults objectForKey:@"student"];
    NSString *studentid = [student objectForKey:@"studentid"];
    [dic setValue:studentid forKey:@"studentid"];
    
    MKNetworkOperation *op = [engine operationWithPath:@"/Pcookbook/findCookList.do" params:dic httpMethod:@"GET"];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        //        NSLog(@"[operation responseData]-->>%@", [operation responseString]);
        NSString *result = [operation responseString];
        NSError *error;
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (resultDict == nil) {
            NSLog(@"json parse failed \r\n");
        }
        NSNumber *success = [resultDict objectForKey:@"success"];
        if ([success boolValue]) {
            NSArray *data = [resultDict objectForKey:@"data"];
            if (data != nil) {
                sparr = data;
            }
        }else{
            
            
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
    }];
    [engine enqueueOperation:op];
}

//宝宝食谱
- (IBAction)bbspAction:(UIButton *)sender {
    
    NSMutableArray *vcs = [NSMutableArray array];
    
    for (int i = 0 ; i < [sparr count]; i++) {
        BbspViewController *vc = [[BbspViewController alloc] init];
        NSArray *data = [sparr objectAtIndex:i];
        vc.dataSource = data;
        NSDictionary *info = [data objectAtIndex:0];
        NSString *date = [info objectForKey:@"occurDate"];
        if (date.length > 5) {
            vc.title = [[info objectForKey:@"occurDate"] substringFromIndex:5];
        }
        [vcs addObject:vc];
    }
    
//    BbspViewController *vc1 = [[BbspViewController alloc] init];
//    vc1.title = @"11-03";
//    [vcs addObject:vc1];
//    BbspViewController *vc2 = [[BbspViewController alloc] init];
//    vc2.title = @"周二";
//    [vcs addObject:vc2];
//    BbspViewController *vc3 = [[BbspViewController alloc] init];
//    vc3.title = @"周三";
//    [vcs addObject:vc3];
//    BbspViewController *vc4 = [[BbspViewController alloc] init];
//    vc4.title = @"周四";
//    [vcs addObject:vc4];
//    BbspViewController *vc5 = [[BbspViewController alloc] init];
//    vc5.title = @"周五";
//    [vcs addObject:vc5];
    
    if (vcs.count > 0) {
        JYSlideSegmentController *slideSegmentController = [[JYSlideSegmentController alloc] initWithViewControllers:vcs];
        
        slideSegmentController.title = @"食谱";
        slideSegmentController.indicatorInsets = UIEdgeInsetsMake(0, 8, 8, 8);
        slideSegmentController.indicator.backgroundColor = [UIColor greenColor];
        
        [self.navigationController setNavigationBarHidden:NO];
        [self.navigationController pushViewController:slideSegmentController animated:YES];
    }else{
        //提示没有信息
        [self alertMsg:@"暂时没有食谱信息，请稍后再试"];
    }
    
}


//小纸条
- (IBAction)xztAction:(UIButton *)sender {
    
//    if (_mainController == nil) {
//        _mainController = [[MainChatViewController alloc] init];
//    }
    if (_chatListController == nil) {
        _chatListController = [[ChatListViewController alloc] init];
    }
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController pushViewController:_chatListController animated:YES];
}

//返回到该页面调用
- (void)viewDidAppear:(BOOL)animated{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *backflag = [userDefaults objectForKey:@"backflag"];
    if ([@"1" isEqualToString:backflag]) {//选择完班级和宝宝 返回重新加载
        [userDefaults removeObjectForKey:@"backflag"];
        [self loadData];//设置学生信息
        [self loadYezx];//加载育儿资讯分类
        [self loadBbsp];//加载食谱
        [self loadKcb];//加载课程表
    }
    NSString *loginflag = [userDefaults objectForKey:@"loginflag"];//如果是登陆则删除标识符
    if ([@"1" isEqualToString:loginflag]) {
        [userDefaults removeObjectForKey:@"loginflag"];
    }
    NSString *updateImgFlag = [userDefaults objectForKey:@"updateImgFlag"];//如果是修改头像返回则重新加载学生信息
    if ([@"1" isEqualToString:updateImgFlag]) {
        [userDefaults removeObjectForKey:@"updateImgFlag"];
        [self loadData];
    }
    [super viewDidAppear:animated];
}

//提示
- (void)alertMsg:(NSString *)msg{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = msg;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:1];
}


- (void)dealloc{
    [self unregisterNotifications];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 99) {
        if (buttonIndex != [alertView cancelButtonIndex]) {
            [[EaseMob sharedInstance].chatManager asyncLogoffWithCompletion:^(NSDictionary *info, EMError *error) {
                [[ApplyViewController shareController] clear];
                [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
            } onQueue:nil];
        }
    }
    else if (alertView.tag == 100) {
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
    } else if (alertView.tag == 101) {
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
    }
}

#pragma mark - private

-(void)registerNotifications{
    [self unregisterNotifications];
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
}

-(void)unregisterNotifications{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}

//显示该界面 刷新未读消息数
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupUnreadMessageCount];
}


//设置未读消息数
- (void)setupUnreadMessageCount{
    NSArray *conversations = [[[EaseMob sharedInstance] chatManager] conversations];
    NSInteger unreadCount = 0;
    for (EMConversation *conversation in conversations) {
        unreadCount += conversation.unreadMessagesCount;
    }
    if (unreadCount > 0) {
        if (unreadCount < 9) {
            self.unreadlabel.font = [UIFont systemFontOfSize:13];
        }else if(unreadCount > 9 && unreadCount < 99){
            self.unreadlabel.font = [UIFont systemFontOfSize:12];
        }else{
            self.unreadlabel.font = [UIFont systemFontOfSize:10];
        }
        [self.unreadlabel setHidden:NO];
        self.unreadlabel.text = [NSString stringWithFormat:@"%ld",(long)unreadCount];
    }else{
        [self.unreadlabel setHidden:YES];
    }
    
    UIApplication *application = [UIApplication sharedApplication];
    [application setApplicationIconBadgeNumber:unreadCount];
}

#pragma mark - IChatMangerDelegate 消息变化
- (void)didUpdateConversationList:(NSArray *)conversationList
{
    [_chatListController refreshDataSource];
}
// 未读消息数量变化回调
-(void)didUnreadMessagesCountChanged
{
    [self setupUnreadMessageCount];
}
- (void)didFinishedReceiveOfflineMessages:(NSArray *)offlineMessages{
    [self setupUnreadMessageCount];
}
- (BOOL)needShowNotification:(NSString *)fromChatter
{
    BOOL ret = YES;
    NSArray *igGroupIds = [[EaseMob sharedInstance].chatManager ignoredGroupList];
    for (NSString *str in igGroupIds) {
        if ([str isEqualToString:fromChatter]) {
            ret = NO;
            break;
        }
    }
    
    if (ret) {
        EMPushNotificationOptions *options = [[EaseMob sharedInstance].chatManager pushNotificationOptions];
        
        do {
            if (options.noDisturbing) {
                NSDate *now = [NSDate date];
                NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute
                                                                               fromDate:now];
                
                NSInteger hour = [components hour];
                //        NSInteger minute= [components minute];
                
                NSUInteger startH = options.noDisturbingStartH;
                NSUInteger endH = options.noDisturbingEndH;
                if (startH>endH) {
                    endH += 24;
                }
                
                if (hour>=startH && hour<=endH) {
                    ret = NO;
                    break;
                }
            }
        } while (0);
    }
    
    return ret;
}
// 收到消息回调
-(void)didReceiveMessage:(EMMessage *)message
{
    BOOL needShowNotification = message.isGroup ? [self needShowNotification:message.conversation.chatter] : YES;
    if (needShowNotification) {
#if !TARGET_IPHONE_SIMULATOR
        [self playSoundAndVibration];
        
        BOOL isAppActivity = [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive;
        if (!isAppActivity) {
            [self showNotificationWithMessage:message];
        }else{
        }
        
#endif
    }
    [self setupUnreadMessageCount];
}

- (void)playSoundAndVibration{
    
    //如果距离上次响铃和震动时间太短, 则跳过响铃
    NSLog(@"%@, %@", [NSDate date], self.lastPlaySoundDate);
    NSTimeInterval timeInterval = [[NSDate date]
                                   timeIntervalSinceDate:self.lastPlaySoundDate];
    if (timeInterval < kDefaultPlaySoundInterval) {
        return;
    }
    //保存最后一次响铃时间
    self.lastPlaySoundDate = [NSDate date];
    
    // 收到消息时，播放音频
    [[EaseMob sharedInstance].deviceManager asyncPlayNewMessageSound];
    // 收到消息时，震动
    [[EaseMob sharedInstance].deviceManager asyncPlayVibration];
}

- (void)showNotificationWithMessage:(EMMessage *)message
{
    EMPushNotificationOptions *options = [[EaseMob sharedInstance].chatManager pushNotificationOptions];
    //发送本地推送
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate date]; //触发通知的时间
    
    if (options.displayStyle == ePushNotificationDisplayStyle_messageSummary) {
        id<IEMMessageBody> messageBody = [message.messageBodies firstObject];
        NSString *messageStr = nil;
        switch (messageBody.messageBodyType) {
            case eMessageBodyType_Text:
            {
                messageStr = ((EMTextMessageBody *)messageBody).text;
            }
                break;
            case eMessageBodyType_Image:
            {
                messageStr = @"[图片]";
            }
                break;
            case eMessageBodyType_Location:
            {
                messageStr = @"[位置]";
            }
                break;
            case eMessageBodyType_Voice:
            {
                messageStr = @"[音频]";
            }
                break;
            case eMessageBodyType_Video:{
                messageStr = @"[视频]";
            }
                break;
            default:
                break;
        }
        
        NSString *title = message.from;
        if (message.isGroup) {
            NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
            for (EMGroup *group in groupArray) {
                if ([group.groupId isEqualToString:message.conversation.chatter]) {
                    title = [NSString stringWithFormat:@"%@(%@)", message.groupSenderName, group.groupSubject];
                    break;
                }
            }
        }
        
        notification.alertBody = [NSString stringWithFormat:@"%@:%@", title, messageStr];
    }
    else{
        notification.alertBody = @"您有一条新消息";
    }
    
    //#warning 去掉注释会显示[本地]开头, 方便在开发中区分是否为本地推送
    //notification.alertBody = [[NSString alloc] initWithFormat:@"[本地]%@", notification.alertBody];
    
    notification.alertAction = @"打开";
    notification.timeZone = [NSTimeZone defaultTimeZone];
    //发送通知
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    //    UIApplication *application = [UIApplication sharedApplication];
    //    application.applicationIconBadgeNumber += 1;
}

#pragma mark - IChatManagerDelegate 登陆回调（主要用于监听自动登录是否成功）
- (void)didLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error
{
    if (error) {
        /*NSString *hintText = @"";
         if (error.errorCode != EMErrorServerMaxRetryCountExceeded) {
         if (![[[EaseMob sharedInstance] chatManager] isAutoLoginEnabled]) {
         hintText = @"你的账号登录失败，请重新登陆";
         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
         message:hintText
         delegate:self
         cancelButtonTitle:@"确定"
         otherButtonTitles:nil,
         nil];
         alertView.tag = 99;
         [alertView show];
         }
         } else {
         hintText = @"已达到最大登陆重试次数，请重新登陆";
         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
         message:hintText
         delegate:self
         cancelButtonTitle:@"确定"
         otherButtonTitles:nil,
         nil];
         alertView.tag = 99;
         [alertView show];
         }*/
        NSString *hintText = @"你的账号登录失败，正在重试中... \n点击 '登出' 按钮跳转到登录页面 \n点击 '继续等待' 按钮等待重连成功";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:hintText
                                                           delegate:self
                                                  cancelButtonTitle:@"继续等待"
                                                  otherButtonTitles:@"登出",
                                  nil];
        alertView.tag = 99;
        [alertView show];
    }
}

#pragma mark - IChatManagerDelegate 登录状态变化

- (void)didLoginFromOtherDevice
{
    [[EaseMob sharedInstance].chatManager asyncLogoffWithCompletion:^(NSDictionary *info, EMError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"你的账号已在其他地方登录"
                                                           delegate:self
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil,
                                  nil];
        alertView.tag = 100;
        [alertView show];
    } onQueue:nil];
}

- (void)didRemovedFromServer {
    [[EaseMob sharedInstance].chatManager asyncLogoffWithCompletion:^(NSDictionary *info, EMError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"你的账号已被从服务器端移除"
                                                           delegate:self
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil,
                                  nil];
        alertView.tag = 101;
        [alertView show];
    } onQueue:nil];
}

- (void)didConnectionStateChanged:(EMConnectionState)connectionState
{
    [_chatListController networkChanged:connectionState];
}

#pragma mark -

- (void)willAutoReconnect{
    [self hideHud];
    [self showHudInView:self.view hint:@"正在重连中..."];
}

- (void)didAutoReconnectFinishedWithError:(NSError *)error{
    [self hideHud];
    if (error) {
        [self showHint:@"重连失败，稍候将继续重连"];
    }else{
        [self showHint:@"重连成功！"];
    }
}


@end
