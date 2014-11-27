//
//  MyViewController.m
//  hmjz
//
//  Created by yons on 14-10-30.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import "MyViewController.h"
#import"MKNetworkKit.h"
#import "MBProgressHUD.h"
#import "GgtzTableViewCell.h"
#import "Utils.h"
#import "UIImageView+AFNetworking.h"
#import "MyViewControllerDetail.h"

@interface MyViewController ()<MBProgressHUDDelegate>{
    MBProgressHUD *HUD;
    MKNetworkEngine *engine;
    NSNumber *totalpage;
    NSNumber *page;
    NSNumber *rows;
}


@end

@implementation MyViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    page = [NSNumber numberWithInt:1];
    rows = [NSNumber numberWithInt:4];
    
    //初始化tableview
    CGRect cg = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    self.mytableview = [[UITableView alloc] initWithFrame:cg style:UITableViewStylePlain];
    self.mytableview.separatorStyle = UITableViewCellSeparatorStyleNone;
//    [self.mytableview setSeparatorColor:[UIColor colorWithRed:42/255.0 green:173/255.0 blue:128/255.0 alpha:1]];
//    if ([self.mytableview respondsToSelector:@selector(setSeparatorInset:)]) {
//        [self.mytableview setSeparatorInset:UIEdgeInsetsZero];
//    }
//    if ([self.mytableview respondsToSelector:@selector(setLayoutMargins:)]) {
//        [self.mytableview setLayoutMargins:UIEdgeInsetsZero];
//    }
    self.mytableview.dataSource = self;
    self.mytableview.delegate = self;
    [self.view addSubview:self.mytableview];
    
    //添加加载等待条
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"加载中";
    [self.view addSubview:HUD];
    HUD.delegate = self;
    
    engine = [[MKNetworkEngine alloc] initWithHostName:[Utils getHostname] customHeaderFields:nil];
    
    //初始化数据
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//加载数据
- (void)loadData{
    [HUD show:YES];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userid = [userDefaults objectForKey:@"userid"];
    
    [dic setValue:userid forKey:@"userid"];
    [dic setValue:page forKey:@"page"];
    [dic setValue:rows forKey:@"rows"];
    [dic setValue:[NSNumber numberWithInt:0] forKey:@"isdel"];
    [dic setValue:self.typeId forKey:@"typeid"];
    
    MKNetworkOperation *op = [engine operationWithPath:@"/Mation/findPageList.do" params:dic httpMethod:@"GET"];
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
                self.dataSource = [NSMutableArray arrayWithArray:arr];
                [self.mytableview reloadData];
                NSNumber *total = [data objectForKey:@"total"];
                if ([total intValue] % [rows intValue] == 0) {
                    totalpage = [NSNumber numberWithInt:[total intValue] / [rows intValue]];
                }else{
                    totalpage = [NSNumber numberWithInt:[total intValue] / [rows intValue] + 1];
                }
            }
            [HUD hide:YES];
        }else{
            [HUD hide:YES];
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        [HUD hide:YES];
        
    }];
    [engine enqueueOperation:op];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ggtzcell";
    GgtzTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"GgtzTableViewCell" owner:self options:nil] lastObject];
    }
    
    NSDictionary *info = [self.dataSource objectAtIndex:indexPath.row];
    NSString *tntitle = [info objectForKey:@"title"];
    NSString *tncontent = [info objectForKey:@"digest"];
    NSString *fileid = [info objectForKey:@"fileid"];
    cell.gtitle.text = tntitle;
    cell.gdispcription.text = tncontent;
    cell.gdispcription.numberOfLines = 2;// 不可少Label属性之一
    cell.gdispcription.lineBreakMode = NSLineBreakByCharWrapping;// 不可少Label属性之二
    
    if ([Utils isBlankString:fileid]) {
        [cell.imageview setImage:[UIImage imageNamed:@"nopicture.png"]];
    }else{
//        [cell.imageview setImageFromURL:[NSURL URLWithString:fileid] placeHolderImage:nil usingEngine:engine animation:YES];
        
        [cell.imageview setImageWithURL:[NSURL URLWithString:fileid] placeholderImage:nil];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 75;
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
//    if ([self.dataSource count] == indexPath.row) {
//        if (page == totalpage) {
//            
//        }else{
//            [HUD show:YES];
//            [self loadMore];
//        }
//        
//    }else{
//        NSDictionary *info = [self.dataSource objectAtIndex:indexPath.row];
//        NSString *tnid = [info objectForKey:@"tnid"];
//        GgxqViewController *ggxq = [[GgxqViewController alloc]init];
//        ggxq.title = @"公告详情";
//        ggxq.tnid = tnid;
//        [self.navigationController pushViewController:ggxq animated:YES];
//    }
    NSDictionary *data = [self.dataSource objectAtIndex:indexPath.row];
    NSString *detailid = [data objectForKey:@"id"];
    
    MyViewControllerDetail *detail = [[MyViewControllerDetail alloc] init];
    detail.detailid = detailid;
    [self.navigationController pushViewController:detail animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // 禁用 iOS7 返回手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // 开启
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
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
