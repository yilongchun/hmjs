//
//  MyActivityReviewViewController.m
//  hmjs
//
//  Created by yons on 14-12-4.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import "MyActivityReviewViewController.h"
#import "Utils.h"
#import "UIImageView+AFNetworking.h"
#import "MKNetworkKit.h"
#import "MBProgressHUD.h"
#import "ContentCell.h"
#import "PinglunTableViewCell.h"
#import "CustomMoviePlayerViewController.h"
#import "TapImageView.h"
#import "ImgScrollView.h"
#import "SRRefreshView.h"
#import "MLPhotoBrowserViewController.h"

@interface MyActivityReviewViewController ()<MBProgressHUDDelegate,TapImageViewDelegate,ImgScrollViewDelegate,UIScrollViewDelegate,SRRefreshDelegate>{
    MKNetworkEngine *engine;
    MBProgressHUD *HUD;
    NSNumber *totalpage;
    NSNumber *page;
    NSNumber *rows;
    NSNumber *activityType;
    
    UIScrollView *myScrollView;
    NSInteger currentIndex;
    int imgCount;
    UIView *markView;
    UIView *scrollPanel;
    ContentCell *tapCell;
}

@property (strong, nonatomic)UIButton *videoPlayButton;
@property (nonatomic, strong) SRRefreshView         *slimeView;
@end

@implementation MyActivityReviewViewController
@synthesize mytableview;

- (id)init{
    self = [super init];
    if(self){
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
        self.automaticallyAdjustsScrollViewInsets = NO;
    }else{
        [self.mytableview setFrame:CGRectMake(0, 0, self.mytableview.frame.size.width, self.mytableview.frame.size.height+64)];
    }
    
    engine = [[MKNetworkEngine alloc] initWithHostName:[Utils getHostname] customHeaderFields:nil];
    
    //添加加载等待条
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"加载中...";
    [self.view addSubview:HUD];
    HUD.delegate = self;
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [mytableview setTableFooterView:v];
    if ([self.mytableview respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.mytableview setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.mytableview respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.mytableview setLayoutMargins:UIEdgeInsetsZero];
    }
    
    [self.mytableview addSubview:self.slimeView];
    
    
    
    scrollPanel = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    scrollPanel.backgroundColor = [UIColor clearColor];
    scrollPanel.alpha = 0;
    [self.view addSubview:scrollPanel];
    
    markView = [[UIView alloc] initWithFrame:scrollPanel.bounds];
    markView.backgroundColor = [UIColor blackColor];
    markView.alpha = 0.0;
    [scrollPanel addSubview:markView];
    
    myScrollView = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [scrollPanel addSubview:myScrollView];
    myScrollView.pagingEnabled = YES;
    myScrollView.delegate = self;
    
    
    imgCount = 0;
    
    [self setTitle:self.title];
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

//加载内容
- (void)loadData{
    
    
    [HUD show:YES];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:self.detailid forKey:@"activityId"];
    [dic setValue:[userDefaults objectForKey:@"userid"] forKey:@"userId"];
    MKNetworkOperation *op = [engine operationWithPath:@"/classActivity/findbyid.do" params:dic httpMethod:@"GET"];
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
        //        NSString *code = [resultDict objectForKey:@"code"];
        if ([success boolValue]) {
            NSDictionary *data = [resultDict objectForKey:@"data"];
            if (data != nil) {
                self.dataSource = [NSMutableArray arrayWithObject:data];
                
                
                NSArray *filelist = [data objectForKey:@"filelist"];
                if ([filelist count] > 0) {
                    CGSize contentSize = myScrollView.contentSize;
                    contentSize.height = self.view.bounds.size.height;
                    contentSize.width = self.view.bounds.size.width * [filelist count];
                    myScrollView.contentSize = contentSize;
                    imgCount = (int)[filelist count];
                }
                [self.mytableview reloadData];
            }
            [HUD hide:YES];
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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self dataSource] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
        static NSString *cellIdentifier = @"contentcell";
        ContentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"ContentCell" owner:self options:nil] lastObject];
        }
        NSDictionary *data = [self.dataSource objectAtIndex:indexPath.row];
        NSString *title = [data objectForKey:@"activityTitle"];
        NSString *date = [data objectForKey:@"createDate"];
        NSString *content = [data objectForKey:@"activityContent"];
        NSArray *filelist = [data objectForKey:@"filelist"];
        cell.contentTitle.text = title;
        cell.contentDate.text = date;
        cell.content.text = content;
        //            cell.content.text = @"测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试";
        cell.content.numberOfLines = 0;
        cell.content.lineBreakMode = NSLineBreakByCharWrapping;
        [cell.content sizeToFit];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        CGFloat contentWidth = [UIScreen mainScreen].bounds.size.width ;
        UIFont *font = [UIFont systemFontOfSize:17];
        CGSize size = [content sizeWithFont:font constrainedToSize:CGSizeMake(contentWidth-16, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
        [cell.content setFrame:CGRectMake(cell.content.frame.origin.x, cell.content.frame.origin.y, cell.content.frame.size.width, size.height)];
    
        if ([filelist count] > 0) {
            NSDictionary *file = [filelist objectAtIndex:0];
            NSString *type = [file objectForKey:@"type"];
            if ([type isEqualToString:@"t_activity_image"]) {//显示图片
                CGFloat x = 0;
                CGFloat y = cell.content.frame.origin.y+10+cell.content.frame.size.height;
                for (int i = 0 ; i < [filelist count]; i++) {
                    file = [filelist objectAtIndex:i];
                    if ((i % 3 == 0) && i != 0) {
                        y += 105;
                    }
                    x = 5+ 105 * (i % 3);
                    
//                    TapImageView *tmpView = [[TapImageView alloc] initWithFrame:CGRectMake(x, y, 100, 100)];
//                    tmpView.t_delegate = self;
//                    [tmpView setImageWithURL:[file objectForKey:@"fileId"]];
//                    tmpView.tag = 10 + i;
//                    [cell.contentView addSubview:tmpView];
//                    
//                    tmpView = (TapImageView *)[cell.contentView viewWithTag:10+i];
//                    tmpView.identifier = cell;
                    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 100, 100)];
                    [imageview setImageWithURL:[file objectForKey:@"fileId"]];
                    imageview.tag = i;
                    imageview.userInteractionEnabled = YES;
                    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPic:)];
                    [imageview addGestureRecognizer:tap];
                    [cell.contentView addSubview:imageview];
                }
                
                
                
                
                //                for (int i = 0; i < 3; i ++)
                //                {
                //                    TapImageView *tmpView = [[TapImageView alloc] initWithFrame:CGRectMake(5+105*i, 10, 100, 100)];
                //                    tmpView.t_delegate = self;
                //                    tmpView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg",i+1]];
                //                    tmpView.tag = 10 + i;
                //                    [cell.contentView addSubview:tmpView];
                //                }
                
                
            }else if ([type isEqualToString:@"t_activity_video"]){//显示视频
                self.videoPlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
                UIImage *backgroundImage = [UIImage imageNamed:@"chat_video_play.png"];
                [self.videoPlayButton setBackgroundImage:backgroundImage forState:UIControlStateNormal];
                [self.videoPlayButton addTarget:self action:@selector(playVideoAction) forControlEvents:UIControlEventTouchUpInside];
                [self.videoPlayButton setFrame:CGRectMake(10, cell.content.frame.origin.y+10+cell.content.frame.size.height, 50, 50)];
                [cell addSubview:self.videoPlayButton];
            }
        }
        return cell;
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
        NSInteger row = [indexPath row];
        // 列寬
        CGFloat contentWidth = [UIScreen mainScreen].bounds.size.width;
        // 用何種字體進行顯示
        UIFont *font = [UIFont systemFontOfSize:17];
        // 該行要顯示的內容
        NSString *content = [[self.dataSource objectAtIndex:row] objectForKey:@"activityContent"];
        //            NSString *content = @"测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试";
        // 計算出顯示完內容需要的最小尺寸
        CGSize size = [content sizeWithFont:font constrainedToSize:CGSizeMake(contentWidth-16, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
        size.height = size.height + 87;
        NSDictionary *data = [self.dataSource objectAtIndex:indexPath.row];
        NSArray *filelist = [data objectForKey:@"filelist"];
        if ([filelist count] > 0) {
            NSDictionary *file = [filelist objectAtIndex:0];
            NSString *type = [file objectForKey:@"type"];
            if ([type isEqualToString:@"t_activity_image"]) {//显示图片
                int count = 0;
                if ([filelist count] % 3 == 0) {
                    count = (int)([filelist count] / 3);
                }else{
                    count = (int)([filelist count] / 3 + 1);
                }
                size.height = size.height + 100 * count + 5;
            }else if ([type isEqualToString:@"t_activity_video"]){//显示视频
                size.height = size.height + 70;
            }
        }
        return size.height;
    
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
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

#pragma mark - video

/**
 @method 播放视频
 */
-(void)playVideoAction{
    NSDictionary *data = [self.dataSource objectAtIndex:0];
    NSArray *filelist = [data objectForKey:@"filelist"];
    if ([filelist count] > 0) {
        NSDictionary *video = [filelist objectAtIndex:0];
        NSString *fileId = [video objectForKey:@"fileId"];
        if ([Utils isBlankString:fileId]) {
            [self alertMsg:@"视频地址错误，播放失败"];
            return;
        }
        CustomMoviePlayerViewController *moviePlayer = [[CustomMoviePlayerViewController alloc] init];
        //将视频地址传过去
        moviePlayer.movieURL = [NSURL URLWithString:fileId];
        //然后播放就OK了
        [moviePlayer readyPlayer];
        [self presentViewController:moviePlayer animated:YES completion:^{
        }];
    }
}


#pragma mark -
#pragma mark - custom method
- (void) addSubImgView
{
    for (UIView *tmpView in myScrollView.subviews)
    {
        [tmpView removeFromSuperview];
    }
    
    for (int i = 0; i < imgCount; i ++)
    {
        if (i == currentIndex)
        {
            continue;
        }
        
        TapImageView *tmpView = (TapImageView *)[tapCell viewWithTag:10 + i];
        
        //转换后的rect
        CGRect convertRect = [[tmpView superview] convertRect:tmpView.frame toView:self.view];
        
        ImgScrollView *tmpImgScrollView = [[ImgScrollView alloc] initWithFrame:(CGRect){i*myScrollView.bounds.size.width,0,myScrollView.bounds.size}];
        [tmpImgScrollView setContentWithFrame:convertRect];
        [tmpImgScrollView setImage:tmpView.image];
        [myScrollView addSubview:tmpImgScrollView];
        tmpImgScrollView.i_delegate = self;
        
        [tmpImgScrollView setAnimationRect];
    }
}

- (void) setOriginFrame:(ImgScrollView *) sender
{
    [UIView animateWithDuration:0.2 animations:^{
        [sender setAnimationRect];
        markView.alpha = 1.0;
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    }];
}

#pragma mark -
#pragma mark - custom delegate
- (void) tappedWithObject:(id)sender
{
    
    [self.view bringSubviewToFront:scrollPanel];
    scrollPanel.alpha = 1.0;
    
    TapImageView *tmpView = sender;
    currentIndex = tmpView.tag - 10;
    
    tapCell = tmpView.identifier;
    
    //转换后的rect
    CGRect convertRect = [[tmpView superview] convertRect:tmpView.frame toView:self.view];
    
    CGPoint contentOffset = myScrollView.contentOffset;
    contentOffset.x = currentIndex*self.view.frame.size.width;
    myScrollView.contentOffset = contentOffset;
    
    //添加
    [self addSubImgView];
    
    ImgScrollView *tmpImgScrollView = [[ImgScrollView alloc] initWithFrame:(CGRect){contentOffset,myScrollView.bounds.size}];
    [tmpImgScrollView setContentWithFrame:convertRect];
    [tmpImgScrollView setImage:tmpView.image];
    [myScrollView addSubview:tmpImgScrollView];
    tmpImgScrollView.i_delegate = self;
    
    [self performSelector:@selector(setOriginFrame:) withObject:tmpImgScrollView afterDelay:0.1];
    
}

- (void) tapImageViewTappedWithObject:(id)sender
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    ImgScrollView *tmpImgView = sender;
    
    [UIView animateWithDuration:0.2 animations:^{
        markView.alpha = 0;
        [tmpImgView rechangeInitRdct];
    } completion:^(BOOL finished) {
        scrollPanel.alpha = 0;
    }];
    
}

#pragma mark -
#pragma mark - scrollView delegate
- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    currentIndex = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

/**
 *  点击图片查看大图
 */
-(void)showPic:(UITapGestureRecognizer *)recognizer{
    // 图片游览器
    MLPhotoBrowserViewController *photoBrowser = [[MLPhotoBrowserViewController alloc] init];
    // 缩放动画
    photoBrowser.status = UIViewAnimationAnimationStatusFade;
    // 可以删除
    photoBrowser.editing = NO;
    // 数据源/delegate
    //    photoBrowser.delegate = self;
    // 同样支持数据源/DataSource
    //                    photoBrowser.dataSource = self;
    
    NSMutableArray *imgDataSource = [NSMutableArray array];
    
    
    NSDictionary *data = [self.dataSource objectAtIndex:0];
    NSArray *picList = [data objectForKey:@"filelist"];
    
    for (int i = 0; i < picList.count; i++) {
        MLPhotoBrowserPhoto *photo = [[MLPhotoBrowserPhoto alloc] init];
        photo.photoURL = [NSURL URLWithString:[[picList objectAtIndex:i] objectForKey:@"fileId"]];
        [imgDataSource addObject:photo];
    }
    
    photoBrowser.photos = imgDataSource;
    int index = (int)recognizer.view.tag;
    // 当前选中的值
    photoBrowser.currentIndexPath = [NSIndexPath indexPathForItem:index inSection:0];
    // 展示控制器
    [photoBrowser showPickerVc:self];
}
@end