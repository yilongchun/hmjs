//
//  AddXsydViewController.m
//  hmjs
//
//  Created by yons on 15-2-10.
//  Copyright (c) 2015年 yons. All rights reserved.
//

#import "AddXsydViewController.h"
#import "MKNetworkKit.h"
#import "Utils.h"
#import "MBProgressHUD.h"
#import "ChooseStudentViewController.h"

@interface AddXsydViewController ()<MBProgressHUDDelegate>{
    MBProgressHUD *HUD;
    MKNetworkEngine *engine;
    UIDatePicker *datePicker;
    ChooseStudentViewController *vc;
}

@end

@implementation AddXsydViewController
@synthesize mytableview;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"学生异动管理";
    self.dateBtn.layer.borderColor = [UIColor colorWithRed:194/255.0 green:194/255.0 blue:194/255.0 alpha:1].CGColor;
    self.dateBtn.layer.borderWidth = 0.4f;
    self.dateBtn.layer.cornerRadius = 5.0f;
    [self.dateBtn setBackgroundImage:[[UIImage imageNamed:@"grayBg.png"]stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
    
    self.studentBtn.layer.borderColor = [UIColor colorWithRed:194/255.0 green:194/255.0 blue:194/255.0 alpha:1].CGColor;
    self.studentBtn.layer.borderWidth = 0.4f;
    self.studentBtn.layer.cornerRadius = 5.0f;
    [self.studentBtn setBackgroundImage:[[UIImage imageNamed:@"grayBg.png"]stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
    
    [self.typeSeg addTarget:self action:@selector(changeType:) forControlEvents:UIControlEventValueChanged];
    
    
    self.remarkText.layer.borderColor = [UIColor colorWithRed:194/255.0 green:194/255.0 blue:194/255.0 alpha:1].CGColor;
    self.remarkText.layer.borderWidth = 0.4f;
    self.remarkText.layer.cornerRadius = 5.0f;
    
    [self.remarkText setFrame:CGRectMake(self.remarkText.frame.origin.x, self.remarkText.frame.origin.y, [UIScreen mainScreen].bounds.size.width-8-58, self.remarkText.frame.size.height)];
    
    CGRect rect = self.nameText.frame;
    rect.size.height = 40;
    self.nameText.frame = rect;
    
    rect = self.reasonText.frame;
    rect.size.height = 40;
    self.reasonText.frame = rect;
    
    rect = self.typeSeg.frame;
    rect.size.height = 35;
    self.typeSeg.frame = rect;
    
    UIBarButtonItem *buttonItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
    [self.navigationItem setRightBarButtonItem:buttonItem1];
    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *class= [userDefaults objectForKey:@"class"];
    NSString *classname = [class objectForKey:@"className"];
    self.classnameLabel.text = classname;
    
    datePicker = [ [ UIDatePicker alloc] initWithFrame:CGRectMake(0, 15, 0, 0)];
    datePicker.datePickerMode = UIDatePickerModeDate;
    [datePicker setMaximumDate:[NSDate date]];
    self.typeSeg.selectedSegmentIndex = 0;
    //添加加载等待条
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"加载中...";
    [self.view addSubview:HUD];
    HUD.delegate = self;
    
    engine = [[MKNetworkEngine alloc] initWithHostName:[Utils getHostname] customHeaderFields:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(chooseStudentEnd:)
                                                 name:@"chooseStudentEnd"
                                               object:nil];
    
//    //初始化tableview
//    CGRect cg;
//    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
//        cg = CGRectMake(0, 64, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-64);
//        self.automaticallyAdjustsScrollViewInsets = NO;
//    }else{
//        cg = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-64);
//    }
//    mytableview = [[UITableView alloc] initWithFrame:cg style:UITableViewStylePlain];
//    mytableview.dataSource = self;
//    mytableview.delegate = self;
//    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
//    [mytableview setTableFooterView:v];
//    if ([mytableview respondsToSelector:@selector(setSeparatorInset:)]) {
//        [mytableview setSeparatorInset:UIEdgeInsetsZero];
//    }
//    if ([mytableview respondsToSelector:@selector(setLayoutMargins:)]) {
//        [mytableview setLayoutMargins:UIEdgeInsetsZero];
//    }
//    [self.view addSubview:mytableview];
}

//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return 6;
//}
//
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    
//    static NSString *cellIdentifier = @"cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//    if (!cell) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];;
//    }
//    
//    switch (indexPath.row) {
//        case 0:
//        {
//            cell.textLabel.text = @"日期";
//            cell.detailTextLabel.text = @"请选择";
//            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        }
//            break;
//        case 1:
//        {
//            cell.textLabel.text = @"班级";
//            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//            NSDictionary *class= [userDefaults objectForKey:@"class"];
//            NSString *classname = [class objectForKey:@"className"];
//            cell.detailTextLabel.text = classname;
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        }
//            break;
//        case 2:
//        {
//            cell.textLabel.text = @"姓名";
//            cell.detailTextLabel.text = @"未填写";
//            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        }
//            break;
//        case 3:
//        {
//            cell.textLabel.text = @"类型";
//            cell.detailTextLabel.text = @"请选择";
//            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        }
//            break;
//        case 4:
//        {
//            cell.textLabel.text = @"原因";
//            cell.detailTextLabel.text = @"未填写";
//            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//            [cell.detailTextLabel sizeToFit];
//            cell.detailTextLabel.numberOfLines = 0;
//            cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
//            [cell.detailTextLabel setTextAlignment:NSTextAlignmentLeft];
//        }
//            break;
//        case 5:
//        {
//            cell.textLabel.text = @"备注";
//            cell.detailTextLabel.text = @"未填写";
//            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//            [cell.detailTextLabel sizeToFit];
//            cell.detailTextLabel.numberOfLines = 0;
//            cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
//            [cell.detailTextLabel setTextAlignment:NSTextAlignmentLeft];
//        }
//            break;
//        default:
//            break;
//    }
//    
//    return cell;
//    
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    float width = [UIScreen mainScreen].bounds.size.width;
//    CGSize size = CGSizeMake(width-100,CGFLOAT_MAX);
//    if (indexPath.row == 4) {
//        CGSize labelsize = [@"未填写" sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
//        if (labelsize.height+20 < 44) {
//            return 44;
//        }else{
//            return labelsize.height+20;
//        }
//    }
//    return 44;
//
//}
//
//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
//    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
//        [cell setSeparatorInset:UIEdgeInsetsZero];
//    }
//    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
//        [cell setLayoutMargins:UIEdgeInsetsZero];
//    }
//}
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)save{
    
    if ([self.dateBtn.titleLabel.text isEqualToString:@"请选择日期"]) {
        [self alertMsg:@"请选择日期"];
        return;
    }
    if (self.typeSeg.selectedSegmentIndex == 0) {
        if (!self.studentinfo) {
            [self alertMsg:@"请选择学生"];
            return;
        }
    }else if (self.typeSeg.selectedSegmentIndex == 1){
        if ([Utils isBlankString:self.nameText.text]) {
            [self alertMsg:@"请填写学生姓名"];
            return;
        }
    }
    
    
    NSMutableString *content = [NSMutableString string];
    if (self.typeSeg.selectedSegmentIndex == 0) {
        [content appendFormat:@"%@ ",self.dateBtn.titleLabel.text];
        if (self.typeSeg.selectedSegmentIndex == 0) {
            NSString *studentname = [self.studentinfo objectForKey:@"studentname"];
            [content appendFormat:@"%@ ",studentname];
        }else if (self.typeSeg.selectedSegmentIndex == 1){
            [content appendFormat:@"%@ ",self.nameText.text];
        }
        [content appendFormat:@"从 %@ ",self.classnameLabel.text];
        [content appendFormat:@"转出"];
    }else if(self.typeSeg.selectedSegmentIndex == 1){
        [content appendFormat:@"%@ ",self.dateBtn.titleLabel.text];
        if (self.typeSeg.selectedSegmentIndex == 0) {
            NSString *studentname = [self.studentinfo objectForKey:@"studentname"];
            [content appendFormat:@"%@ ",studentname];
        }else if (self.typeSeg.selectedSegmentIndex == 1){
            [content appendFormat:@"%@ ",self.nameText.text];
        }
        [content appendFormat:@"转入 "];
        [content appendFormat:@"%@",self.classnameLabel.text];
    }
    
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认信息吗?"
                                                                       message:content
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                                  style:UIAlertActionStyleDestructive
                                                handler:^(UIAlertAction *action) {
                                                    NSLog(@"确定");
                                                    [self saveToServer];
                                                }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                                  style:UIAlertActionStyleCancel
                                                handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确认信息吗?" message:content delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        NSLog(@"确认");
        [self saveToServer];
    }
}

-(void)saveToServer{
    [HUD show:YES];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *class = [userDefaults objectForKey:@"class"];
    NSString *userid = [userDefaults objectForKey:@"userid"];
    

    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    [dic setValue:userid forKey:@"userid"];
    [dic setValue:[class objectForKey:@"id"] forKey:@"classid"];
    if (self.typeSeg.selectedSegmentIndex == 1) {//转入
        [dic setValue:[NSNumber numberWithInt:0] forKey:@"type"];
        [dic setValue:self.nameText.text forKey:@"studentid"];
    }else if (self.typeSeg.selectedSegmentIndex == 0) {//转出
        [dic setValue:[NSNumber numberWithInt:1] forKey:@"type"];
        NSString *studentid = [self.studentinfo objectForKey:@"studentid"];
        [dic setValue:studentid forKey:@"studentid"];
    }
    [dic setValue:self.reasonText.text forKey:@"detail"];
    [dic setValue:self.dateBtn.titleLabel.text forKey:@"occurdate"];
    [dic setValue:self.remarkText.text forKey:@"bak"];//备注
   
    
    
    MKNetworkOperation *op = [engine operationWithPath:@"/schooltransfer/save.do" params:dic httpMethod:@"POST"];
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
            [HUD hide:YES];
            [self okMsk:msg];
            [self performSelector:@selector(backAndReload) withObject:nil afterDelay:1.0f];
        }else{
            [HUD hide:YES];
            [self alertMsg:msg];
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        [HUD hide:YES];
        [self alertMsg:@"连接服务器失败"];
    }];
    [engine enqueueOperation:op];
}

-(void)changeType:(UISegmentedControl *)control{
    if (control.selectedSegmentIndex == 0) {//转入
        [self.nameText setHidden:YES];
        self.nameText.userInteractionEnabled = NO;
        [self.studentBtn setHidden:NO];
        self.studentBtn.userInteractionEnabled = YES;
    }else if(control.selectedSegmentIndex == 1){//转出
        [self.nameText setHidden:NO];
        self.nameText.userInteractionEnabled = YES;
        [self.studentBtn setHidden:YES];
        self.studentBtn.userInteractionEnabled = NO;
    }
}

-(void)backAndReload{
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadXsyd" object:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)chooseDate:(id)sender {
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1){
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                       message:@"请选择日期\n\n\n\n\n\n\n\n\n\n"// change UIAlertController height
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                                  style:UIAlertActionStyleDestructive
                                                handler:^(UIAlertAction *action) {
                                                    NSDate *date = datePicker.date;
                                                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                                    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                                                    NSString *destDateString = [dateFormatter stringFromDate:date];
                                                    [self.dateBtn setTitle:destDateString forState:UIControlStateNormal];
                                                }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                                  style:UIAlertActionStyleCancel
                                                handler:^(UIAlertAction *action) {
                                                    
                                                }]];
        
        
        //Make a frame for the picker & then create the picker
        CGRect pickerFrame = CGRectMake(12, 15, self.view.frame.size.width-24-20, 216);
        datePicker.frame = pickerFrame;
        [alert.view addSubview:datePicker];
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"请选择日期\n\n\n\n\n\n\n\n\n\n\n\n"
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消"
                                                   destructiveButtonTitle:@"确定"
                                                        otherButtonTitles:nil, nil];
        actionSheet.tag = 2;
        [actionSheet addSubview:datePicker];
        [actionSheet showInView:self.view];
    }
}

- (IBAction)chooseStudent:(id)sender {
    if(vc == nil){
        vc = [[ChooseStudentViewController alloc] init];
    }
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)chooseStudentEnd:(NSNotification*) notification{
    NSLog(@"%@",[notification object]);
    self.studentinfo = [notification object];
    if (self.studentinfo) {
        NSString *studentname = [self.studentinfo objectForKey:@"studentname"];
        [self.studentBtn setTitle:studentname forState:UIControlStateNormal];
    }
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        if (actionSheet.tag == 2){
            NSDate *date = datePicker.date;
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            NSString *destDateString = [dateFormatter stringFromDate:date];
            [self.dateBtn setTitle:destDateString forState:UIControlStateNormal];
        }
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
    [hud hide:YES afterDelay:1.0];
}

//提示
- (void)alertMsg:(NSString *)msg{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = msg;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:1.0];
}
@end
