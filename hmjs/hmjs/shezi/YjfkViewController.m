//
//  YjfkViewController.m
//  hmjz
//
//  Created by yons on 14-11-5.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import "YjfkViewController.h"
#import "MKNetworkKit.h"
#import "Utils.h"
#import "MBProgressHUD.h"

@interface YjfkViewController ()<MBProgressHUDDelegate>{
    MKNetworkEngine *engine;
    MBProgressHUD *HUD;
}

@end

@implementation YjfkViewController
@synthesize textView = _textView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"意见反馈";
    //初始化引擎
    engine = [[MKNetworkEngine alloc] initWithHostName:[Utils getHostname] customHeaderFields:nil];
    
    //设置导航栏右侧按钮
    UIImage* image= [UIImage imageNamed:@"ic_sz_002.png"];
    CGRect frame= CGRectMake(0, 0, 20, 20);
    UIButton* someButton= [[UIButton alloc] initWithFrame:frame];
    [someButton addTarget:self action:@selector(feecback) forControlEvents:UIControlEventTouchUpInside];
    [someButton setBackgroundImage:image forState:UIControlStateNormal];
    [someButton setShowsTouchWhenHighlighted:NO];
    UIBarButtonItem *someBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:someButton];
    [self.navigationItem setRightBarButtonItem:someBarButtonItem];
    
    //初始化文本域
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(10.0, 80.0, [[UIScreen mainScreen] bounds].size.width-20, 200.0)];
    _textView.layer.backgroundColor = [[UIColor clearColor] CGColor];
    _textView.layer.borderColor = [UIColor colorWithRed:42/255.0 green:173/255.0 blue:128/255.0 alpha:1].CGColor;
    _textView.layer.borderWidth = 1.0;
    _textView.layer.cornerRadius = 8.0f;
    _textView.delegate = self;
    _textView.scrollEnabled = YES;
    _textView.font = [UIFont fontWithName:@"Helvetica Neue" size:16.0];
    _textView.returnKeyType = UIReturnKeyDefault;
    
    _textView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    _textView.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1];
    [_textView.layer setMasksToBounds:YES];
    [self.view addSubview:_textView];
    
    //添加加载等待条
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"提交中";
    [self.view addSubview:HUD];
    HUD.delegate = self;
    
}

- (void)textViewDidChangeSelection:(UITextView *)textView

{
//    NSRange range;
//    range.location = 0;
//    range.length = 0;
//    _textView.selectedRange = range;
}


- (void)feecback{
    [_textView resignFirstResponder];
    if (_textView.text.length == 0) {
        [self alertMsg:@"请填写内容"];
    }else{
        [HUD show:YES];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *userid = [userDefaults objectForKey:@"userid"];
        
        [dic setValue:userid forKey:@"userid"];
        [dic setValue:_textView.text forKey:@"feedbackcontent"];
        
        MKNetworkOperation *op = [engine operationWithPath:@"/Feedback/savafback.do" params:dic httpMethod:@"POST"];
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
                [self okMsk:@"提交成功"];
                _textView.text = @"";
            }else{
                [HUD hide:YES];
                [self alertMsg:@"提交失败"];
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

@end
