//
//  ChooseChildrenViewController.m
//  hmjz
//
//  Created by yons on 14-10-28.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import "ChooseChildrenViewController.h"
#import "ChildrenTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "Utils.h"
#import "MKNetworkKit.h"
#import "MainViewController.h"
#import "MBProgressHUD.h"
#import "ChooseClassViewController.h"

@interface ChooseChildrenViewController ()<MBProgressHUDDelegate>{
    NSInteger currentIndex;
    MBProgressHUD *HUD;
    MKNetworkEngine *engine;
}

@end

@implementation ChooseChildrenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"切换宝宝";
    self.mytableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.navigationController setNavigationBarHidden:NO];
    
    //添加加载等待条
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.delegate = self;
    HUD.labelText = @"正在加载中";
    
    engine = [[MKNetworkEngine alloc] initWithHostName:[Utils getHostname] customHeaderFields:nil];
    
    currentIndex = -1;
    [self loadData];
}

- (void)loadData{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *student = [userDefaults objectForKey:@"student"];
    NSString *studentid = [student objectForKey:@"studentid"];
    
    self.dataSource = [userDefaults objectForKey:@"students"];
    for (int i = 0 ; i < [self.dataSource count]; i++) {
        NSDictionary *data = [self.dataSource objectAtIndex:i];
        NSString *studentid2 = [data objectForKey:@"studentid"];
        if ([studentid isEqualToString:studentid2]) {
            currentIndex = i;
            break;
        }else{
            
        }
    }
    
    
    
    [self.mytableview reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"childrencell";
    ChildrenTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ChildrenTableViewCell" owner:self options:nil] lastObject];
//        [cell.layer setMasksToBounds:YES];
//        cell.layer.cornerRadius=5;
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSDictionary *data = [self.dataSource objectAtIndex:indexPath.row];
    NSString *studentname = [data objectForKey:@"studnetname"];
    NSNumber *studentsex = [data objectForKey:@"studentsex"];
    NSString *sex;
    if ([studentsex intValue]== 0) {
        sex = @"男";
    }else if ([studentsex intValue]== 1){
        sex = @"女";
    }
    NSString *fileid = [data objectForKey:@"flieid"];
    
    cell.namelabel.text = [NSString stringWithFormat:@"姓名：%@",studentname] ;
    cell.sexlabel.text = [NSString stringWithFormat:@"性别：%@",sex];
    
    if ([Utils isBlankString:fileid]) {
        [cell.img setImage:[UIImage imageNamed:@"chatListCellHead.png"]];
    }else{
//        [cell.img setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/image/show.do?id=%@",[Utils getImageHostname],fileid]] placeholderImage:[UIImage imageNamed:@"nopicture.png"]];
        [cell.img setImageWithURL:[NSURL URLWithString:fileid] placeholderImage:[UIImage imageNamed:@"chatListCellHead.png"]];
    }
    
    // 重用机制，如果选中的行正好要重用
    if (currentIndex == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // 取消前一个选中的，就是单选啦
    NSIndexPath *lastIndex = [NSIndexPath indexPathForRow:currentIndex inSection:0];
    UITableViewCell *lastCell = [tableView cellForRowAtIndexPath:lastIndex];
    lastCell.accessoryType = UITableViewCellAccessoryNone;
    
    // 选中操作
    UITableViewCell *cell = [tableView  cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    // 保存选中的
    currentIndex = indexPath.row;
    
    NSDictionary *data = [self.dataSource objectAtIndex:indexPath.row];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:data forKey:@"student"];//将默认的一个宝宝存入userdefaults
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSString *studentid = [data objectForKey:@"studentid"];//学生id
    
    [self getClassInfo:studentid];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

//根据学生id获取班级信息
- (void)getClassInfo:(NSString *)studentid{
    [HUD show:YES];
    
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
            if ([array count] == 1) {//只有一个班级默认选择
                NSDictionary *data = [array objectAtIndex:0];
                
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:data forKey:@"class"];//将班级存入userdefaults
                [userDefaults setObject:array forKey:@"classes"];//将所有班级存入userdefaults
                [userDefaults setObject:@"1" forKey:@"backflag"];//将状态存入userdefaults 返回首页时判断刷新
                MainViewController *mvc = [[MainViewController alloc] init];
                [HUD hide:YES];
                
                NSString *loginflag = [userDefaults objectForKey:@"loginflag"];
                if ([@"1" isEqualToString:loginflag]) {
                    [userDefaults removeObjectForKey:@"loginflag"];
                    [self.navigationController pushViewController:mvc animated:YES];
                    
                }else{
                    for (UIViewController *temp in self.navigationController.viewControllers) {
                        if ([temp isKindOfClass:[MainViewController class]]) {
                            [userDefaults setObject:@"1" forKey:@"backflag"];
                            [self.navigationController popToViewController:temp animated:YES];
                            break;
                        }
                    }
                }
//                [self.navigationController pushViewController:mvc animated:YES];
                
            }else if([array count] > 1){//有多个班级需要用户选择
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:array forKey:@"classes"];//将班级存入userdefaults
                ChooseClassViewController *vc = [[ChooseClassViewController alloc] init];
                [HUD hide:YES];
                [self.navigationController pushViewController:vc animated:YES];
                
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
