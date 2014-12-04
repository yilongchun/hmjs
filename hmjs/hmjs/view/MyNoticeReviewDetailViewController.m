//
//  MyNoticeReviewDetailViewController.m
//  hmjs
//
//  Created by yons on 14-12-4.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import "MyNoticeReviewDetailViewController.h"
#import "MKNetworkKit.h"
#import "Utils.h"
#import "MBProgressHUD.h"

@interface MyNoticeReviewDetailViewController ()<MBProgressHUDDelegate>{
    MKNetworkEngine *engine;
    MBProgressHUD *HUD;
    
    NSString *detailid;
}


@end

@implementation MyNoticeReviewDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //初始化引擎
    engine = [[MKNetworkEngine alloc] initWithHostName:[Utils getHostname] customHeaderFields:nil];
    
    //添加加载等待条
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"加载中";
    [self.view addSubview:HUD];
    HUD.delegate = self;
    
    self.contentTextview.layer.borderColor = [UIColor colorWithRed:219/255.0 green:219/255.0 blue:219/255.0 alpha:1].CGColor;
    self.contentTextview.layer.borderWidth = 1.0;
    self.contentTextview.layer.cornerRadius = 5.0f;
//    _textView.delegate = self;
//    _textView.scrollEnabled = YES;
//    self.contentTextview.font = [UIFont fontWithName:@"Helvetica Neue" size:16.0];
//    _textView.returnKeyType = UIReturnKeyDefault;
    
    self.contentTextview.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    [self.contentTextview.layer setMasksToBounds:YES];
    
    self.view.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1];
    
    self.btn1.layer.cornerRadius = 5.0f;
    self.btn2.layer.cornerRadius = 5.0f;
    
    if (self.data != nil) {
        NSString *noticeTitle = [self.data objectForKey:@"noticeTitle"];
        NSString *noticeContent = [self.data objectForKey:@"noticeContent"];
        NSNumber *status = [self.data objectForKey:@"status"];
        self.titleLabel.text = noticeTitle;
        self.contentTextview.text = noticeContent;
        detailid = [self.data objectForKey:@"id"];
        if ([status intValue] == 2) {//待发布 隐藏按钮
            [self.btn1 setHidden:YES];
            [self.btn2 setHidden:YES];
        }
    }
    
    //添加手势，点击输入框其他区域隐藏键盘
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGr.cancelsTouchesInView =NO;
    [self.view addGestureRecognizer:tapGr];
}

//隐藏键盘
-(void)viewTapped:(UITapGestureRecognizer*)tapGr{
    [self.titleLabel resignFirstResponder];
    [self.contentTextview resignFirstResponder];
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

- (IBAction)delBtn:(id)sender {
    [self viewTapped:nil];

    [HUD show:YES];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userid = [userDefaults objectForKey:@"userid"];
    
    [dic setValue:userid forKey:@"userid"];
    [dic setValue:detailid forKey:@"noticeId"];
    
    MKNetworkOperation *op = [engine operationWithPath:@"/Notice/delete.do" params:dic httpMethod:@"POST"];
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
            [HUD hide:YES];
            self.titleLabel.text = @"";
            self.contentTextview.text = @"";
            [self okMsk:@"删除成功"];
            
            [self.navigationController popViewControllerAnimated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMyNoticeRevice" object:nil];
        }else{
            [HUD hide:YES];
            [self alertMsg:@"删除失败"];
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        [HUD hide:YES];
        
    }];
    [engine enqueueOperation:op];
    
    
}

- (IBAction)saveBtn:(id)sender {
    [self save:@"2"];
}

-(void)save:(NSString *)status{
    [self viewTapped:nil];
    if (self.titleLabel.text.length == 0) {
        [self alertMsg:@"请填写标题"];
    }else if(self.contentTextview.text.length == 0){
        [self alertMsg:@"请填写内容"];
    }else{
        [HUD show:YES];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *userid = [userDefaults objectForKey:@"userid"];
        
        [dic setValue:userid forKey:@"userid"];
        [dic setValue:detailid forKey:@"id"];
        [dic setValue:self.titleLabel.text forKey:@"noticetitle"];
        [dic setValue:self.contentTextview.text forKey:@"noticecontent"];
        
        MKNetworkOperation *op = [engine operationWithPath:@"/Notice/releasenotice.do" params:dic httpMethod:@"POST"];
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
                [HUD hide:YES];
                self.titleLabel.text = @"";
                self.contentTextview.text = @"";
                [self okMsk:@"发布成功"];
                
                [self.navigationController popViewControllerAnimated:YES];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMyNoticeRevice" object:nil];
            }else{
                [HUD hide:YES];
                [self alertMsg:@"发布失败"];
            }
        }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
            NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
            [HUD hide:YES];
            
        }];
        [engine enqueueOperation:op];
    }
}

//成功
- (void)okMsk:(NSString *)msg{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:hud];
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    hud.mode = MBProgressHUDModeCustomView;
    hud.delegate = self;
    hud.labelText = msg;
    [hud show:YES];
    [hud hide:YES afterDelay:1];
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
