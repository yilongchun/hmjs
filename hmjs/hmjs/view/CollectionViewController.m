//
//  CollectionViewController.m
//  hmxx
//
//  Created by yons on 15-1-20.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "CollectionViewController.h"
#import "CollectionCell.h"
#import "MKNetworkKit.h"
#import "Utils.h"
#import "MBProgressHUD.h"
#import "SRRefreshView.h"
#import "UIImageView+AFNetworking.h"
#import "CwjDetailViewController.h"
#import "SVPullToRefresh.h"

@interface CollectionViewController ()<MBProgressHUDDelegate,SRRefreshDelegate>{
    MBProgressHUD *HUD;
    MKNetworkEngine *engine;
    NSNumber *totalpage;
//    NSNumber *page;
//    NSNumber *rows;
    
    NSString *userid;
    NSString *classid;
    int sort;
//    UIActivityIndicatorView *tempactivity;
}
//@property (nonatomic, strong) SRRefreshView *slimeView;
@end

@implementation CollectionViewController
@synthesize mycollectionview;
@synthesize dataSource;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    mycollectionview.delegate = self;
//    mycollectionview.dataSource = self;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadData)
                                                 name:@"reloadCwj"
                                               object:nil];
    
//    [mycollectionview addSubview:self.slimeView];
    [mycollectionview registerClass:[CollectionCell class] forCellWithReuseIdentifier:@"CollectionCell"];
    mycollectionview.alwaysBounceVertical = YES;
    //添加加载等待条
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"加载中...";
    [self.view addSubview:HUD];
    HUD.delegate = self;
    
    engine = [[MKNetworkEngine alloc] initWithHostName:[Utils getHostname] customHeaderFields:nil];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    userid = [userDefaults objectForKey:@"userid"];
    NSDictionary *class = [userDefaults objectForKey:@"class"];
    classid = [class objectForKey:@"id"];
    dataSource = [[NSMutableArray alloc] init];
    
    __weak CollectionViewController *weakSelf = self;
    
    [mycollectionview addPullToRefreshWithActionHandler:^{
        [weakSelf insertRowAtTop];
    }];
    // setup infinite scrolling
//    [mycollectionview addInfiniteScrollingWithActionHandler:^{
//        [weakSelf insertRowAtBottom];
//    }];
    //初始化数据
    [mycollectionview triggerPullToRefresh];
}

//#pragma mark - getter
//- (SRRefreshView *)slimeView
//{
//    if (!_slimeView) {
//        _slimeView = [[SRRefreshView alloc] init];
//        _slimeView.delegate = self;
//        _slimeView.upInset = 0;
//        _slimeView.slimeMissWhenGoingBack = YES;
//        _slimeView.slime.bodyColor = [UIColor grayColor];
//        _slimeView.slime.skinColor = [UIColor grayColor];
//        _slimeView.slime.lineWith = 1;
//        _slimeView.slime.shadowBlur = 4;
//        _slimeView.slime.shadowColor = [UIColor grayColor];
//        _slimeView.backgroundColor = [UIColor whiteColor];
//    }
//    
//    return _slimeView;
//}

- (void)insertRowAtTop {
    
    int64_t delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self loadData];
    });
}

//- (void)insertRowAtBottom {
//    NSLog(@"insertRowAtBottom");
//    int64_t delayInSeconds = 0.5;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        if ([page intValue] < [totalpage intValue]) {NSLog(@"1");
//            page = [NSNumber numberWithInt:[page intValue] +1];
//        
//            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
//            [dic setValue:self.examinetype forKey:@"examinetype"];
//            [dic setValue:classid forKey:@"classid"];
//            [dic setValue:userid forKey:@"userid"];
//            [dic setValue:page forKey:@"page"];
//            [dic setValue:rows forKey:@"rows"];
//            MKNetworkOperation *op = [engine operationWithPath:@"/examine/findPageList.do" params:dic httpMethod:@"GET"];
//            [op addCompletionHandler:^(MKNetworkOperation *operation) {
//                NSString *result = [operation responseString];
//                NSError *error;
//                NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
//                if (resultDict == nil) {
//                    NSLog(@"json parse failed \r\n");
//                }
//                NSNumber *success = [resultDict objectForKey:@"success"];
//                NSString *msg = [resultDict objectForKey:@"msg"];
//                if ([success boolValue]) {
//                    NSDictionary *data = [resultDict objectForKey:@"data"];
//                    if (data != nil) {
//                        NSArray *arr = [data objectForKey:@"rows"];
//                        
//                        NSNumber *total = [data objectForKey:@"total"];
//                        if ([total intValue] % [rows intValue] == 0) {
//                            totalpage = [NSNumber numberWithInt:[total intValue] / [rows intValue]];
//                        }else{
//                            totalpage = [NSNumber numberWithInt:[total intValue] / [rows intValue] + 1];
//                        }
//                        
//                        NSMutableArray *indexPathArr = [NSMutableArray array];
//                        for (int i = 0; i < arr.count; i++) {
//                            [dataSource addObject:[arr objectAtIndex:i]];
//                            NSIndexPath *indexpath = [NSIndexPath indexPathForRow:dataSource.count-1 inSection:0];
//                            [indexPathArr addObject:indexpath];
//                        }
//                        [mycollectionview insertItemsAtIndexPaths:indexPathArr];
//                    }
//                    [mycollectionview.infiniteScrollingView stopAnimating];
//                    
//                    if ([page intValue] == [totalpage intValue]) {
//                        [self performSelector:@selector(showsInfiniteScrolling) withObject:nil afterDelay:0.5];
//                    }
//                    
//                }else{
//                    [mycollectionview.infiniteScrollingView stopAnimating];
//                    [self alertMsg:msg];
//                }
//            }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
//                NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
//                [mycollectionview.infiniteScrollingView stopAnimating];
//                [self alertMsg:@"连接服务器失败"];
//            }];
//            [engine enqueueOperation:op];
//        }else{NSLog(@"2");
//            [self showsInfiniteScrolling];
//        }
//    });
//}

//-(void)showsInfiniteScrolling{NSLog(@"3");
//    if (mycollectionview.showsInfiniteScrolling) {NSLog(@"4");
//        mycollectionview.showsInfiniteScrolling = NO;
//    }
//}

//加载数据
- (void)loadData{
//    [HUD show:YES];
//    page = [NSNumber numberWithInt:1];
//    rows = [NSNumber numberWithInt:12];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:self.examinetype forKey:@"examinetype"];
    [dic setValue:classid forKey:@"classid"];
    [dic setValue:userid forKey:@"userid"];
//    [dic setValue:page forKey:@"page"];
//    [dic setValue:rows forKey:@"rows"];
    MKNetworkOperation *op = [engine operationWithPath:@"/examine/findPageList.do" params:dic httpMethod:@"GET"];
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
            if (data != nil) {
                NSArray *arr = [data objectForKey:@"list"];
                self.dataSource = [NSMutableArray arrayWithArray:arr];
                
                
                
                NSDictionary *map = [data objectForKey:@"examineMap"];
                NSNumber *okcount = [map objectForKey:@"okcount"];
                NSNumber *qqcount = [map objectForKey:@"qqcount"];
                NSNumber *yccount = [map objectForKey:@"yccount"];
                
                self.label1.text = [NSString stringWithFormat:@"正常%d人",[okcount intValue]];
                self.label2.text = [NSString stringWithFormat:@"异常%d人",[yccount intValue]];
                self.label3.text = [NSString stringWithFormat:@"缺勤%d人",[qqcount intValue]];
//                NSNumber *total = [data objectForKey:@"total"];
//                if ([total intValue] % [rows intValue] == 0) {
//                    totalpage = [NSNumber numberWithInt:[total intValue] / [rows intValue]];
//                }else{
//                    totalpage = [NSNumber numberWithInt:[total intValue] / [rows intValue] + 1];
//                }
                
                for (int i = 0; i < arr.count; i++) {
                    NSDictionary *info = [arr objectAtIndex:i];
                    NSNumber *sortNum = [info objectForKey:@"sort"];
                    if ([sortNum intValue] != 999) {
                        int temp = [sortNum intValue];
                        if (temp > sort) {
                            sort = temp;
                        }
                    }
                }
                
                
            }
            [mycollectionview.pullToRefreshView stopAnimating];
            [mycollectionview reloadData];
//            if (!mycollectionview.showsInfiniteScrolling) {NSLog(@"5");
//                mycollectionview.showsInfiniteScrolling = YES;
//            }
//            [HUD hide:YES];
        }else{
//            [HUD hide:YES];
            [mycollectionview.pullToRefreshView stopAnimating];
            [self alertMsg:msg];
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
//        [HUD hide:YES];
        [mycollectionview.pullToRefreshView stopAnimating];
//        if (mycollectionview.showsInfiniteScrolling) {NSLog(@"6");
//            mycollectionview.showsInfiniteScrolling = NO;
//        }
        [self alertMsg:@"连接服务器失败"];
    }];
    [engine enqueueOperation:op];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- UICollectionViewDataSource
//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.dataSource count];
}
//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CollectionCell";
    CollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    NSDictionary *info = [dataSource objectAtIndex:indexPath.row];
    NSString *fileid = [info objectForKey:@"fileid"];
    
    NSString *situationtype = [info objectForKey:@"situationtype"];
    if (situationtype) {
        [cell.label1 setHidden:NO];
        if ([situationtype isEqualToString:@"1"]) {
            [cell.label1 setText:@"正常"];
            [cell.label1 setBackgroundColor:[UIColor colorWithRed:116/255.0 green:176/255.0 blue:64/255.0 alpha:1]];
        }else if ([situationtype isEqualToString:@"2"]) {
            [cell.label1 setText:@"缺勤"];
            [cell.label1 setBackgroundColor:[UIColor colorWithRed:130/255.0 green:115/255.0 blue:8/255.0 alpha:1]];
        }else if ([situationtype isEqualToString:@"3"]) {
            [cell.label1 setText:@"异常"];
            [cell.label1 setBackgroundColor:[UIColor colorWithRed:76/255.0 green:28/255.0 blue:12/255.0 alpha:1]];
        }else{
            [cell.label1 setHidden:YES];
        }
    }else{
        [cell.label1 setHidden:YES];
    }
    
    NSString *studentName = [info objectForKey:@"studentName"];
    cell.username.text = studentName;
    
    
    if ([Utils isBlankString:fileid]) {
        [cell.myimageview setImage:[UIImage imageNamed:@"nopicture.png"]];
    }else{
        [cell.myimageview setImageWithURL:[NSURL URLWithString:fileid] placeholderImage:[UIImage imageNamed:@"nopicture.png"]];
    }
    return cell;
}
#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(90, 110);
}
//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 5, 5, 5);
}
#pragma mark --UICollectionViewDelegate
//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *info = [dataSource objectAtIndex:indexPath.row];
//    NSNumber *sortNum = [info objectForKey:@"sort"];
    CwjDetailViewController *cwj = [[CwjDetailViewController alloc] init];
    cwj.title = self.tabBarController.title;
    cwj.info = info;
    cwj.sortNum = [NSNumber numberWithInt:sort+1];
    [self.navigationController pushViewController:cwj animated:YES];
}
//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

//#pragma mark - scrollView delegate
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    [_slimeView scrollViewDidScroll];
//}
//
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
//{
//    [_slimeView scrollViewDidEndDraging];
//}
//
//#pragma mark - slimeRefresh delegate
////刷新消息列表
//- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView
//{
//    [HUD show:YES];
//    [self loadData];
//    [_slimeView endRefresh];
//}

#pragma mark - RACollectionViewDelegate
//- (CGFloat)sectionSpacingForCollectionView:(UICollectionView *)collectionView
//{
//    return 5.f;
//}

//- (CGFloat)minimumInteritemSpacingForCollectionView:(UICollectionView *)collectionView
//{
//    return 5.f;
//}

//- (CGFloat)minimumLineSpacingForCollectionView:(UICollectionView *)collectionView
//{
//    return 5.f;
//}

//- (UIEdgeInsets)insetsForCollectionView:(UICollectionView *)collectionView
//{
//    return UIEdgeInsetsMake(5.f, 0, 5.f, 0);
//}
//- (CGSize)collectionView:(UICollectionView *)collectionView sizeForLargeItemsInSection:(NSInteger)section
//{
////    return CGSizeMake(90, 110);
//    return RACollectionViewTripletLayoutStyleSquare; //same as default !
//}
//- (UIEdgeInsets)autoScrollTrigerEdgeInsets:(UICollectionView *)collectionView
//{
//    return UIEdgeInsetsMake(50.f, 0, 50.f, 0); //Sorry, horizontal scroll is not supported now.
//}

//- (UIEdgeInsets)autoScrollTrigerPadding:(UICollectionView *)collectionView
//{
//    return UIEdgeInsetsMake(64.f, 0, 0, 0);
//}

//- (CGFloat)reorderingItemAlpha:(UICollectionView *)collectionview
//{
//    return .3f;
//}
//- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    [mycollectionview reloadData];
//}


#pragma mark - LXReorderableCollectionViewDataSource methods

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath {
    
    NSDictionary *info = [dataSource objectAtIndex:fromIndexPath.item];
    
    [dataSource removeObjectAtIndex:fromIndexPath.item];
    [dataSource insertObject:info atIndex:toIndexPath.item];
}

//- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath didMoveToIndexPath:(NSIndexPath *)toIndexPath
//{
////    UIImage *image = [_photosArray objectAtIndex:fromIndexPath.item];
//    NSDictionary *info = [dataSource objectAtIndex:fromIndexPath.item];
//    
//    [dataSource removeObjectAtIndex:fromIndexPath.item];
//    [dataSource insertObject:info atIndex:toIndexPath.item];
//}
- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath
{
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark - LXReorderableCollectionViewDelegateFlowLayout methods

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"will begin drag");
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"did begin drag");
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"will end drag");
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"did end drag");
}

#pragma mark - private
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
