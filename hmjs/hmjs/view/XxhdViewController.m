//
//  XxhdViewController.m
//  hmjz
//
//  Created by yons on 14-11-28.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import "XxhdViewController.h"
#import "GgtzTableViewCell.h"
#import "MBProgressHUD.h"
#import "MKNetworkKit.h"
#import "Utils.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "MyViewControllerCellDetail.h"
#import "SRRefreshView.h"


@interface XxhdViewController ()<MBProgressHUDDelegate,SRRefreshDelegate>{
    MBProgressHUD *HUD;
    MKNetworkEngine *engine;
    NSNumber *totalpage;
    NSNumber *page;
    NSNumber *rows;
}
@property (nonatomic, strong) SRRefreshView         *slimeView;

@end

@implementation XxhdViewController
@synthesize dataSource;
@synthesize mytableview;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    
    //初始化tableview
    CGRect cg = CGRectMake(0, 64, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-50-64);
    mytableview = [[UITableView alloc] initWithFrame:cg style:UITableViewStylePlain];
    mytableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    //    [mytableview setSeparatorColor:[UIColor colorWithRed:42/255.0 green:173/255.0 blue:128/255.0 alpha:1]];
    //    if ([mytableview respondsToSelector:@selector(setSeparatorInset:)]) {
    //        [mytableview setSeparatorInset:UIEdgeInsetsZero];
    //    }
    //    if ([mytableview respondsToSelector:@selector(setLayoutMargins:)]) {
    //        [mytableview setLayoutMargins:UIEdgeInsetsZero];
    //    }
    mytableview.dataSource = self;
    mytableview.delegate = self;
    [self.view addSubview:mytableview];
    
    [mytableview addSubview:self.slimeView];
    
    
    //添加加载等待条
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"加载中";
    [self.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
    
    engine = [[MKNetworkEngine alloc] initWithHostName:[Utils getHostname] customHeaderFields:nil];
    //    [engine useCache];
    
    self.dataSource = [[NSMutableArray alloc] init];
    
    
    //初始化数据
    [self loadData];
    
}

#pragma mark - getter

- (SRRefreshView *)slimeView
{
    if (!_slimeView) {
        _slimeView = [[SRRefreshView alloc] init];
        _slimeView.delegate = self;
        _slimeView.upInset = 0;
        _slimeView.slimeMissWhenGoingBack = YES;
        _slimeView.slime.bodyColor = [UIColor grayColor];
        _slimeView.slime.skinColor = [UIColor grayColor];
        _slimeView.slime.lineWith = 1;
        _slimeView.slime.shadowBlur = 4;
        _slimeView.slime.shadowColor = [UIColor grayColor];
        _slimeView.backgroundColor = [UIColor whiteColor];
    }
    
    return _slimeView;
}

//加载数据
- (void)loadData{
    
    page = [NSNumber numberWithInt:1];
    rows = [NSNumber numberWithInt:10];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *student = [userDefaults objectForKey:@"student"];
    NSString *schoolId = [student objectForKey:@"schoolid"];
    [dic setValue:schoolId forKey:@"schoolId"];
    [dic setValue:page forKey:@"page"];
    [dic setValue:rows forKey:@"rows"];
    //    [dic setValue:@"t_activity_title" forKey:@"type"];
    MKNetworkOperation *op = [engine operationWithPath:@"/pactivity/schoolfindPageList.do" params:dic httpMethod:@"GET"];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSLog(@"[operation responseData]-->>%@", [operation responseString]);
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
            NSDictionary *data = [resultDict objectForKey:@"data"];
            if (data != nil) {
                NSArray *arr = [data objectForKey:@"rows"];
                self.dataSource = [NSMutableArray arrayWithArray:arr];
                NSNumber *total = [data objectForKey:@"total"];
                if ([total intValue] % [rows intValue] == 0) {
                    totalpage = [NSNumber numberWithInt:[total intValue] / [rows intValue]];
                }else{
                    totalpage = [NSNumber numberWithInt:[total intValue] / [rows intValue] + 1];
                }
                [mytableview reloadData];
            }
        }else{
            [HUD hide:YES];
            [self alertMsg:msg];
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        [HUD hide:YES];
        [self alertMsg:[err localizedDescription]];
    }];
    [engine enqueueOperation:op];
}

- (void)loadMore{
    
    if ([page intValue]< [totalpage intValue]) {
        page = [NSNumber numberWithInt:[page intValue] +1];
    }
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *student = [userDefaults objectForKey:@"student"];
    NSString *schoolId = [student objectForKey:@"schoolid"];
    [dic setValue:schoolId forKey:@"schoolId"];
    [dic setValue:page forKey:@"page"];
    [dic setValue:rows forKey:@"rows"];
    //    [dic setValue:@"t_activity_title" forKey:@"type"];
    MKNetworkOperation *op = [engine operationWithPath:@"/pactivity/schoolfindPageList.do" params:dic httpMethod:@"GET"];
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
            [HUD hide:YES];
            NSDictionary *data = [resultDict objectForKey:@"data"];
            if (data != nil) {
                NSArray *arr = [data objectForKey:@"rows"];
                [self.dataSource addObjectsFromArray:arr];
                NSNumber *total = [data objectForKey:@"total"];
                if ([total intValue] % [rows intValue] == 0) {
                    totalpage = [NSNumber numberWithInt:[total intValue] / [rows intValue]];
                }else{
                    totalpage = [NSNumber numberWithInt:[total intValue] / [rows intValue] + 1];
                }
                [mytableview reloadData];
            }
        }else{
            [HUD hide:YES];
            [self alertMsg:msg];
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        [HUD hide:YES];
        [self alertMsg:[err localizedDescription]];
    }];
    [engine enqueueOperation:op];
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
    [hud hide:YES afterDelay:1.5];
}


//提示
- (void)alertMsg:(NSString *)msg{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = msg;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:1.5];
}


#pragma mark - UITableViewDatasource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (page != totalpage && [self.dataSource count] != 0) {
        return [[self dataSource] count] + 1;
    }else{
        return [[self dataSource] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.dataSource count] == indexPath.row) {
        static NSString *cellIdentifier = @"morecell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.textLabel.text = @"点击加载更多";
        }
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        return cell;
        
    }else{
        static NSString *cellIdentifier = @"ggtzcell";
        GgtzTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"GgtzTableViewCell" owner:self options:nil] lastObject];
        }
        NSDictionary *info = [self.dataSource objectAtIndex:indexPath.row];
        NSString *tntitle = [info objectForKey:@"activityTitle"];
        NSString *teacherfileid = [info objectForKey:@"teacherfileid"];
        NSString *tncontent = [info objectForKey:@"activityDigest"];
        NSNumber *noticecount = [info objectForKey:@"count"];
        NSString *tncreatedate = [info objectForKey:@"createDate"];
        NSString *source = [info objectForKey:@"teachername"];
        cell.gtitle.text = tntitle;
        
        if ([Utils isBlankString:teacherfileid]) {
            [cell.imageview setImage:[UIImage imageNamed:@"nopicture.png"]];
        }else{
            //            [cell.imageview setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/image/show.do?id=%@",[Utils getImageHostname],teacherfileid]] placeholderImage:[UIImage imageNamed:@"nopicture.png"]];
            [cell.imageview setImageWithURL:[NSURL URLWithString:teacherfileid] placeholderImage:[UIImage imageNamed:@"nopicture.png"]];
        }
        cell.gdispcription.text = tncontent;
        cell.gdispcription.numberOfLines = 2;// 不可少Label属性之一
        cell.gdispcription.lineBreakMode = NSLineBreakByCharWrapping;// 不可少Label属性之二
        //[cell.gdispcription sizeToFit];
        cell.gpinglun.text = [NSString stringWithFormat:@"评论(%@)",noticecount];
        cell.gdate.text = tncreatedate;
        cell.gsource.text = [NSString stringWithFormat:@"来自:%@",source];
        return cell;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.dataSource count] == indexPath.row) {
        return 44;
    }else{
        return 100;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
    //        [cell setSeparatorInset:UIEdgeInsetsZero];
    //    }
    //    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
    //        [cell setLayoutMargins:UIEdgeInsetsZero];
    //    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.dataSource count] == indexPath.row) {
        if (page == totalpage) {
            
        }else{
            [HUD show:YES];
            [self loadMore];
        }
        
    }else{
        NSDictionary *data = [self.dataSource objectAtIndex:indexPath.row];
        NSString *detailid = [data objectForKey:@"id"];
        MyViewControllerCellDetail *detail = [[MyViewControllerCellDetail alloc] init];
        detail.detailid = detailid;
        detail.title = @"活动详情";
        [self.navigationController pushViewController:detail animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - scrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_slimeView scrollViewDidScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_slimeView scrollViewDidEndDraging];
}

#pragma mark - slimeRefresh delegate
//刷新消息列表
- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView
{
    
    [self loadData];
    [_slimeView endRefresh];
}

@end
