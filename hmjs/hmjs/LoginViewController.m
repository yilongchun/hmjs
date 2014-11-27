//
//  LoginViewController.m
//  hmjz
//
//  Created by yons on 14-10-22.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import "LoginViewController.h"
#import "MBProgressHUD.h"
#import "MKNetworkKit.h"
#import "MainViewController.h"
#import "Utils.h"
#import "ChooseChildrenViewController.h"
#import "ChooseClassViewController.h"
#import "EMError.h"



@interface LoginViewController ()<MBProgressHUDDelegate,IChatManagerDelegate>{
    MBProgressHUD *HUD;
    MKNetworkEngine *engine;
    
}

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.delegate = self;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    }
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor, nil]];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    self.navigationItem.backBarButtonItem = backItem;
    backItem.title = @"返回";
    
    self.navigationController.delegate = self;
    
    // Do any additional setup after loading the view from its nib.
    //添加手势，点击输入框其他区域隐藏键盘
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGr.cancelsTouchesInView =NO;
    [self.view addGestureRecognizer:tapGr];
    //添加登陆事件
    self.loginBtn.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loginTag:)];
    [self.loginBtn addGestureRecognizer:singleTap];
    //添加加载等待条
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.delegate = self;
    
    engine = [[MKNetworkEngine alloc] initWithHostName:[Utils getHostname] customHeaderFields:nil];
    
    self.loginBtn.layer.cornerRadius = 5.0f;
    
    _mainController = [[MainViewController alloc] init];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *loginusername = [userDefaults objectForKey:@"loginusername"];
    NSString *loginpassword = [userDefaults objectForKey:@"loginpassword"];
    
    self.username.text = loginusername;
    self.password.text = loginpassword;
    
}
//登陆
-(void)loginTag:(UITapGestureRecognizer *) rapGr{
    
    if (self.username.text.length == 0) {
        [self alertMsg:@"请输入账号"];
        return;
    }else if (self.password.text.length == 0){
        [self alertMsg:@"请输入密码"];
        return;
    }
    
    
    [self viewTapped:rapGr];
    HUD.labelText = @"正在加载中";
    [HUD show:YES];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:self.username.text forKey:@"userId"];
    [dic setValue:self.password.text forKey:@"password"];
    
    MKNetworkOperation *op = [engine operationWithPath:@"/app/Plogin.do" params:dic httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {

        NSString *result = [operation responseString];
        NSError *error;
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (resultDict == nil) {
            NSLog(@"json parse failed \r\n");
        }
        
        NSNumber *success = [resultDict objectForKey:@"success"];
        NSString *msg = [resultDict objectForKey:@"msg"];

        if ([success boolValue]) {
            NSDictionary *data = [resultDict objectForKey:@"data"];
            NSString *userid = [data objectForKey:@"userid"];
            NSString *hxusercode = [data objectForKey:@"hxusercode"];
            NSString *hxpassword = [data objectForKey:@"hxpassword"];
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:userid forKey:@"userid"];

            [userDefaults setObject:self.username.text forKey:@"loginusername"];
            [userDefaults setObject:self.password.text forKey:@"loginpassword"];
            
            
            
            [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:hxusercode
                                                                password:hxpassword
                                                              completion:
             ^(NSDictionary *loginInfo, EMError *error) {
                 
                 if (loginInfo && !error) {
                     
//                     [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@YES];
                     [_mainController setupUnreadMessageCount];
                     
                 }else {
                     
                     switch (error.errorCode) {
                         case EMErrorServerNotReachable:
                             [self alertMsg:@"连接服务器失败!"];
                             NSLog(@"连接服务器失败!");
                             break;
                         case EMErrorServerAuthenticationFailure:
                             [self alertMsg:@"用户名或密码错误"];
                             NSLog(@"用户名或密码错误");
                             break;
                         case EMErrorServerTimeout:
                             [self alertMsg:@"连接服务器超时!"];
                             NSLog(@"连接服务器超时!");
                             break;
                         default:
                             [self alertMsg:@"登录失败"];
                             NSLog(@"登录失败");
                             break;
                     }
                 }
             } onQueue:nil];
            
            
            
            
            
            [self getParentInfo:userid];//获取家长信息
            
            
            }else{
            [HUD hide:YES];
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = msg;
            hud.margin = 10.f;
            hud.removeFromSuperViewOnHide = YES;
            [hud hide:YES afterDelay:1];
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        [HUD hide:YES];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"连接失败";
        hud.margin = 10.f;
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:YES afterDelay:2];
    }];
    [engine enqueueOperation:op];

}

//登陆之后根据userid获取家长信息
- (void)getParentInfo:(NSString *)userid{
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:userid forKey:@"userid"];
    
    MKNetworkOperation *op = [engine operationWithPath:@"/Parent/findbyid.do" params:dic httpMethod:@"GET"];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
//        NSLog(@"[operation responseData]-->>%@", [operation responseString]);
        NSString *result = [operation responseString];
        NSError *error;
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (resultDict == nil) {
            NSLog(@"json parse failed \r\n");
        }
        
        NSNumber *success = [resultDict objectForKey:@"success"];
        NSString *msg = [resultDict objectForKey:@"msg"];
        
        if ([success boolValue]) {
            NSArray *array = [resultDict objectForKey:@"data"];
            if ([array count] > 0) {
                NSDictionary *data = [array objectAtIndex:0];
                NSString *parentid = [data objectForKey:@"id"];
                //NSString *parentname = [data objectForKey:@"parentname"];
                [self getChildrenInfo:parentid];//获取宝宝信息
            }else{
                
            }
        }else{
            [HUD hide:YES];
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = msg;
            hud.margin = 10.f;
            hud.removeFromSuperViewOnHide = YES;
            [hud hide:YES afterDelay:1];
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        [HUD hide:YES];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"连接失败";
        hud.margin = 10.f;
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:YES afterDelay:2];
    }];
    [engine enqueueOperation:op];
}

//根据家长id获取宝宝信息
- (void)getChildrenInfo:(NSString *)parentid{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:parentid forKey:@"parentid"];
    
    MKNetworkOperation *op = [engine operationWithPath:@"/Puser/findbyid.do" params:dic httpMethod:@"GET"];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
//        NSLog(@"[operation responseData]-->>%@", [operation responseString]);
        NSString *result = [operation responseString];
        NSError *error;
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (resultDict == nil) {
            NSLog(@"json parse failed \r\n");
        }
        
        NSNumber *success = [resultDict objectForKey:@"success"];
        NSString *msg = [resultDict objectForKey:@"msg"];
        
        if ([success boolValue]) {
            NSArray *array = [resultDict objectForKey:@"data"];
            if ([array count] == 1) {//只有一个宝宝默认选择
                NSDictionary *data = [array objectAtIndex:0];
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:data forKey:@"student"];//将默认的一个宝宝存入userdefaults
                
                [userDefaults setObject:array forKey:@"students"];
                
                NSString *studentid = [data objectForKey:@"studentid"];//学生id
                [self getClassInfo:studentid];//获取班级信息
                
            }else if([array count] > 1){//有多个宝宝需要用户选择
                
//                NSDictionary *data = [array objectAtIndex:0];
//                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//                [userDefaults setObject:data forKey:@"student"];//将默认的一个宝宝存入userdefaults
//                NSString *studentid = [data objectForKey:@"studentid"];//学生id
//                [self getClassInfo:studentid];//获取班级信息
                
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:array forKey:@"students"];//将多个宝宝存入userdefaults
                
                NSDictionary *student = [userDefaults objectForKey:@"student"];//从用户之前的设置读取已经选择的宝宝
                NSString *tempstudentid = [student objectForKey:@"studentid"];//取得学生id
                
                BOOL studentflag = false;
                
                for (int i = 0 ; i < [array count]; i++) {
                    NSDictionary *data = [array objectAtIndex:i];
                    NSString *studentid = [data objectForKey:@"studentid"];
                    if ([studentid isEqualToString:tempstudentid]) {
                        studentflag = true;//如果相等 说明之前已经选择过宝宝
                        break;
                    }
                }
                if (studentflag) {//如果选择过宝宝 直接读取班级信息
                    
                    [self getClassInfo:tempstudentid];//加载班级信息
                    
                }else{//如果没有选择过 跳转切换宝宝界面
                    ChooseChildrenViewController *vc = [[ChooseChildrenViewController alloc] init];//跳转 需要用户选择宝宝
                    [userDefaults setObject:@"1" forKey:@"loginflag"];
                    [self.navigationController pushViewController:vc animated:YES];
                    [HUD hide:YES];
                }
                
            }
        }else{
            [HUD hide:YES];
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = msg;
            hud.margin = 10.f;
            hud.removeFromSuperViewOnHide = YES;
            [hud hide:YES afterDelay:1];
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        [HUD hide:YES];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"连接失败";
        hud.margin = 10.f;
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:YES afterDelay:2];
    }];
    [engine enqueueOperation:op];
}
//根据学生id获取班级信息
- (void)getClassInfo:(NSString *)studentid{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:studentid forKey:@"studentid"];
    
    MKNetworkOperation *op = [engine operationWithPath:@"/Pclass/findbyid.do" params:dic httpMethod:@"GET"];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
//        NSLog(@"[operation responseData]-->>%@", [operation responseString]);
        NSString *result = [operation responseString];
        NSError *error;
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (resultDict == nil) {
            NSLog(@"json parse failed \r\n");
        }
        
        NSNumber *success = [resultDict objectForKey:@"success"];
        NSString *msg = [resultDict objectForKey:@"msg"];
        
        if ([success boolValue]) {
            NSArray *array = [resultDict objectForKey:@"data"];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            if ([array count] == 1) {//只有一个班级默认选择
                NSDictionary *data = [array objectAtIndex:0];
                
                
                [userDefaults setObject:data forKey:@"class"];//讲班级存入userdefaults
                [userDefaults setObject:array forKey:@"classes"];
                if (_mainController == nil) {
                    _mainController = [[MainViewController alloc] init];
                }
                [userDefaults setObject:@"1" forKey:@"loginflag"];
                [self.navigationController pushViewController:_mainController animated:YES];
                [HUD hide:YES];
            }else if([array count] > 1){//有多个班级需要用户选择
                [userDefaults setObject:array forKey:@"classes"];//将多个班级存入userdefaults
                
                NSDictionary *class = [userDefaults objectForKey:@"class"];//从用户之前的设置读取已经选择的班级
                NSString *tempclassid = [class objectForKey:@"classid"];//取得班级id
                
                BOOL classflag = false;
                for (int i = 0 ; i < [array count]; i++) {
                    NSDictionary *data = [array objectAtIndex:i];
                    NSString *classid = [data objectForKey:@"classid"];
                    if ([classid isEqualToString:tempclassid]) {
                        classflag = true;//如果相等 说明之前已经选择过班级
                        break;
                    }
                }
                if (classflag) {//如果选择过班级 直接进入首页
                    if (_mainController == nil) {
                        _mainController = [[MainViewController alloc] init];;
                    }
                    
                    [self.navigationController pushViewController:_mainController animated:YES];
                    
                }else{//如果没有选择过 跳转选择班级界面
                    ChooseClassViewController *vc = [[ChooseClassViewController alloc] init];//跳转 需要用户选择班级
                    [self.navigationController pushViewController:vc animated:YES];
                }
                [HUD hide:YES];
            }
            
        }else{
            [HUD hide:YES];
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = msg;
            hud.margin = 10.f;
            hud.removeFromSuperViewOnHide = YES;
            [hud hide:YES afterDelay:1];
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        [HUD hide:YES];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"连接失败";
        hud.margin = 10.f;
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:YES afterDelay:2];
    }];
    [engine enqueueOperation:op];
}

//隐藏键盘
-(void)viewTapped:(UITapGestureRecognizer*)tapGr{
    [self.username resignFirstResponder];
    [self.password resignFirstResponder];
    [self moveView:0];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if ([viewController isKindOfClass:[LoginViewController class]]) {
        [self.navigationController setNavigationBarHidden:YES];
    }
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

#pragma mark - 输入框代理
-(void)textFieldDidBeginEditing:(UITextField *)textField{   //开始编辑时，整体上移
    if(textField.tag == 0){
        if(self.view.frame.origin.y == 0){
            [self moveView:-60];
        }
        
    }else if(textField.tag == 1){
        if(self.view.frame.origin.y == -60){
            [self moveView:-60];
        }else if(self.view.frame.origin.y == 0){
            [self moveView:-120];
        }
    }
}

#pragma mark - 键盘回车
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag==0) {
        [self.password becomeFirstResponder];
    }
    if (textField.tag==1) {
        [self viewTapped:nil];
    }
    return YES;
}
//界面根据键盘的显示和隐藏上下移动
-(void)moveView:(float)move{
    NSTimeInterval animationDuration = 1.0f;
    CGRect frame = self.view.frame;
    if(move == 0){
        frame.origin.y =0;
    }else{
        frame.origin.y +=move;//view的X轴上移
    }
    [UIView beginAnimations:@"ResizeView" context:nil];
    self.view.frame = frame;
    [UIView setAnimationDuration:animationDuration];
    self.view.frame = frame;
    [UIView commitAnimations];//设置调整界面的动画效果
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

@end
