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
#import <MobileCoreServices/UTCoreTypes.h>
#import "UITextView+PlaceHolder.h"
#import "AFNetworking.h"

@interface MyNoticeReviewDetailViewController (){
    MKNetworkEngine *engine;
    NSMutableArray *fileArr;
    NSString *detailid;
}
@property (nonatomic, strong) ALAssetsLibrary *specialLibrary;

@end

@implementation MyNoticeReviewDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.contentTextview addPlaceHolder:@"请填写内容"];
    [self.contentTextview.placeHolderTextView setHidden:YES];
    //初始化引擎
    engine = [[MKNetworkEngine alloc] initWithHostName:[Utils getHostname] customHeaderFields:nil];
    
    
    CGRect rect = self.titleLabel.frame;
    rect.size.height = 40;
    self.titleLabel.frame = rect;
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.contentTextview.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }else{
        [self.titleLabel setFrame:CGRectMake(self.titleLabel.frame.origin.x, self.titleLabel.frame.origin.y-64, self.titleLabel.frame.size.width, self.titleLabel.frame.size.height)];
        [self.contentTextview setFrame:CGRectMake(self.contentTextview.frame.origin.x, self.contentTextview.frame.origin.y-64, self.contentTextview.frame.size.width, 250)];
    }
    
    self.contentTextview.layer.borderColor = [UIColor colorWithRed:219/255.0 green:219/255.0 blue:219/255.0 alpha:1].CGColor;
    self.contentTextview.layer.borderWidth = 1.0;
    self.contentTextview.layer.cornerRadius = 5.0f;
    [self.contentTextview.layer setMasksToBounds:YES];
    
    self.view.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1];
    
    if (self.data != nil) {
        NSString *noticeTitle = [self.data objectForKey:@"noticeTitle"];
        NSString *noticeContent = [self.data objectForKey:@"noticeContent"];
        NSNumber *status = [self.data objectForKey:@"status"];
        self.titleLabel.text = noticeTitle;
        self.contentTextview.text = noticeContent;
        detailid = [self.data objectForKey:@"id"];
        if ([status intValue] == 2) {//待审核 隐藏按钮 控件禁用
            [self.titleLabel setEnabled:NO];
            [self.contentTextview setEditable:NO];
        }else{
            UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"删除" style:UIBarButtonItemStylePlain target:self action:@selector(deleteInfo)];
            UIBarButtonItem *rightBtn2 = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStylePlain target:self action:@selector(saveInfo)];
            self.navigationItem.rightBarButtonItems = @[rightBtn2,rightBtn];
        }
    }
    
    //添加手势，点击输入框其他区域隐藏键盘
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGr.cancelsTouchesInView =NO;
    [self.view addGestureRecognizer:tapGr];
    
    [self.myscrollview setContentSize:CGSizeMake(self.view.frame.size.width,self.view.frame.size.height+1)];
    [self.myscrollview setScrollEnabled:YES];
    
    self.chosenImages = [[NSMutableArray alloc] init];
    //[self.myscrollview setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64)];
    fileArr = [[NSMutableArray alloc] init];
    
    
    
    [self loadData];
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

-(void)loadData{
    [self showHudInView:self.view hint:@"加载中"];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userid = [userDefaults objectForKey:@"userid"];
    [dic setValue:userid forKey:@"userId"];
    [dic setValue:detailid forKey:@"tnid"];
    
    NSString *urlString = [NSString stringWithFormat:@"http://%@/Notice/findbyid.do",HOST];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
    [manager GET:urlString parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", operation.responseString);
        [self hideHud];
        NSString *result = [NSString stringWithFormat:@"%@",[operation responseString]];
        NSError *error;
        NSDictionary *resultDict= [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (resultDict == nil) {
            NSLog(@"json parse failed \r\n");
        }else{
            NSNumber *success = [resultDict objectForKey:@"success"];
            NSString *msg = [resultDict objectForKey:@"msg"];
            //        NSString *code = [resultDict objectForKey:@"code"];
            if ([success boolValue]) {
                NSDictionary *data = [resultDict objectForKey:@"data"];
                if (data != nil) {
                    NSArray *picList = [data objectForKey:@"picList"];
                    for (int i = 0; i < picList.count; i++) {
                        NSString *fileId = [[picList objectAtIndex:i] objectForKey:@"fileId"];
                        if (![fileId isEqualToString:@""]) {
                            UIImage  *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:fileId]]];
                            [self.chosenImages addObject:image];
                        }
                    }
                    if (self.chosenImages.count != 0) {
                        [self reloadImageToView];
                    }
                }
            }else{
                [self showHint:msg];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"发生错误！%@",error);
        [self hideHud];
        [self showHint:@"连接失败"];
    }];
}


//删除
- (void)deleteInfo{
    [self viewTapped:nil];

    [self showHudInView:self.view hint:@"加载中"];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userid = [userDefaults objectForKey:@"userid"];
    
    [dic setValue:userid forKey:@"userid"];
    [dic setValue:detailid forKey:@"noticeId"];
    
    MKNetworkOperation *op = [engine operationWithPath:@"/Notice/delete.do" params:dic httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        //        NSLog(@"[operation responseData]-->>%@", [operation responseString]);
        [self hideHud];
        NSString *result = [operation responseString];
        NSError *error;
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (resultDict == nil) {
            NSLog(@"json parse failed \r\n");
        }
        NSNumber *success = [resultDict objectForKey:@"success"];
        if ([success boolValue]) {
            
            self.titleLabel.text = @"";
            self.contentTextview.text = @"";
            [self showHint:@"删除成功"];
            [self.navigationController popViewControllerAnimated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMyNoticeRevice" object:nil];
        }else{
            [self showHint:@"删除失败"];
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        [self hideHud];
        [self showHint:@"连接失败"];
    }];
    [engine enqueueOperation:op];
}



-(void)saveInfo{
    [self viewTapped:nil];
    if (self.titleLabel.text.length == 0) {
        [self showHint:@"请填写标题"];
    }else if(self.contentTextview.text.length == 0){
        [self showHint:@"请填写内容"];
    }else{
        [self showHudInView:self.view hint:@"加载中"];
        if (self.chosenImages.count == 0) {
            [self insertData];
        }else{
            [fileArr removeAllObjects];
            for (int i = 0 ; i < self.chosenImages.count; i++) {
                [self uploadImg:i];
            }
        }
    }
}

-(void)insertData{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userid = [userDefaults objectForKey:@"userid"];
    
    [dic setValue:userid forKey:@"userid"];
    [dic setValue:detailid forKey:@"id"];
    [dic setValue:self.titleLabel.text forKey:@"noticetitle"];
    [dic setValue:self.contentTextview.text forKey:@"noticecontent"];
    if (fileArr.count !=0 && fileArr.count == self.chosenImages.count) {
        NSMutableString *fileids = [[NSMutableString alloc] init];
        for (int i = 0 ; i < fileArr.count; i++) {
            NSString *fileid = [fileArr objectAtIndex:i];
            [fileids appendString:fileid];
            if (i < fileArr.count -1) {
                [fileids appendString:@","];
            }
        }
        [dic setValue:fileids forKey:@"fileid"];
    }else{
        [dic setValue:@"" forKey:@"fileid"];
    }
    MKNetworkOperation *op = [engine operationWithPath:@"/Notice/releasenotice.do" params:dic httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSLog(@"[operation responseData]-->>%@", [operation responseString]);
        [self hideHud];
        NSString *result = [operation responseString];
        NSError *error;
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (resultDict == nil) {
            NSLog(@"json parse failed \r\n");
        }
        NSNumber *success = [resultDict objectForKey:@"success"];
        if ([success boolValue]) {
            self.titleLabel.text = @"";
            self.contentTextview.text = @"";
            [self showHint:@"发布成功"];
            [self.navigationController popViewControllerAnimated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMyNoticeRevice" object:nil];
        }else{
            [self showHint:@"发布失败"];
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        [self hideHud];
        [self showHint:@"连接失败"];
    }];
    [engine enqueueOperation:op];
}

//上传图片
-(void)uploadImg:(int)num{
    UIImage *image = [self.chosenImages objectAtIndex:num];
    NSData *fileData = UIImageJPEGRepresentation(image, 0.5);
    
    //将文件保存到本地
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentsDirectory=[paths objectAtIndex:0];
    NSString *savedImagePath=[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.jpg",num]];
    BOOL saveFlag = [fileData writeToFile:savedImagePath atomically:YES];
    
    MKNetworkOperation *op =[engine operationWithURLString:[NSString stringWithFormat:@"http://%@/image/upload.do",[Utils getImageHostname]] params:nil httpMethod:@"POST"];
    
    [op addFile:savedImagePath forKey:@"allFile"];
    [op setFreezable:NO];
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
            NSString *fileurl = [resultDict objectForKey:@"data"];
            [fileArr addObject:fileurl];
            NSLog(@"上传成功 %d",num);
            if (fileArr.count == self.chosenImages.count) {
                [self insertData];
            }
        }else{
            [self hideHud];
            NSLog(@"上传失败 %@ %d",msg,num);
            [self showHint:@"上传失败"];
        }
        if (saveFlag) {
            NSFileManager *fileMgr = [NSFileManager defaultManager];
            NSError *err;
            [fileMgr removeItemAtPath:savedImagePath error:&err];
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        NSLog(@"%@ %d",[err localizedDescription],num);
        if (saveFlag) {
            NSFileManager *fileMgr = [NSFileManager defaultManager];
            NSError *err;
            [fileMgr removeItemAtPath:savedImagePath error:&err];
        }
        [self hideHud];
        [self showHint:[err localizedDescription]];
    }];
    [engine enqueueOperation:op];
}

- (IBAction)launchController{
    UIActionSheet *actionsheet = [[UIActionSheet alloc] initWithTitle:@"选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"选择照片", nil];
    actionsheet.tag = 1;
    [actionsheet showInView:self.view];
}

- (void)reloadImageToView{
    NSTimeInterval animationDuration = 0.5f;
    [UIView beginAnimations:@"ReloadImage" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    for (UIView *v in [self.myscrollview subviews]) {
        if ([v isKindOfClass:[UIButton class]]) {
            if (v.tag != 99) {
                [v removeFromSuperview];
            }
        }
    }
    
    CGRect workingFrame = CGRectMake(15, 220, 90, 90);
    
    for (int i = 0 ; i < self.chosenImages.count; i++) {
        UIImage *tempimage = [self.chosenImages objectAtIndex:i];
        
        if (i != 0 ) {
            if (i % 3 == 0) {
                workingFrame.origin.x = 15;
                workingFrame.origin.y += 100;
            }else{
                workingFrame.origin.x = workingFrame.origin.x + workingFrame.size.width + 10;
            }
        }
        
        UIButton *btn = [[UIButton alloc] initWithFrame:workingFrame];
        btn.tag = i;
        [btn setImage:tempimage forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnclick:) forControlEvents:UIControlEventTouchUpInside];
        [self.myscrollview addSubview:btn];
        
        if (i == self.chosenImages.count-1) {
            if ((i+1) % 3 == 0) {
                workingFrame.origin.x = 15;
                workingFrame.origin.y += 100;
            }else{
                workingFrame.origin.x = workingFrame.origin.x + workingFrame.size.width + 10;
            }
        }
        
    }
    [self.imagePickBtn setFrame:workingFrame];
    
    NSNumber *status = [self.data objectForKey:@"status"];
    
    if (self.chosenImages.count == 9 || [status intValue] == 2) {
        [self.imagePickBtn setHidden:YES];
    }else{
        [self.imagePickBtn setHidden:NO];
    }
    [UIView commitAnimations];
}

- (void)btnclick:(UIButton *)sender {
    
    NSNumber *status = [self.data objectForKey:@"status"];
    if ([status intValue] != 2) {//待审核 隐藏按钮 控件禁用
        [sender removeFromSuperview];
        [self.chosenImages removeObject:sender.imageView.image];
        [self reloadImageToView];
    }
    
}

#pragma mark ELCImagePickerControllerDelegate Methods

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    for (NSDictionary *dict in info) {
        if ([dict objectForKey:UIImagePickerControllerMediaType] == ALAssetTypePhoto){
            if ([dict objectForKey:UIImagePickerControllerOriginalImage]){
                UIImage* image=[dict objectForKey:UIImagePickerControllerOriginalImage];
                [self.chosenImages addObject:image];
            } else {
                NSLog(@"UIImagePickerControllerReferenceURL = %@", dict);
            }
        } else if ([dict objectForKey:UIImagePickerControllerMediaType] == ALAssetTypeVideo){
        } else {
            NSLog(@"Uknown asset type");
        }
    }
    [self reloadImageToView];
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0://照相机
        {
            //检查相机模式是否可用
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                NSLog(@"sorry, no camera or camera is unavailable.");
                return;
            }
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.allowsEditing = YES;
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePicker.mediaTypes =  @[(NSString *)kUTTypeImage];
            [self presentViewController:imagePicker animated:YES completion:nil];
        }
            break;
        case 1://本地相簿
        {
            ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initImagePicker];
            elcPicker.maximumImagesCount = 9 - self.chosenImages.count; //Set the maximum number of images to select to 100
            elcPicker.returnsOriginalImage = YES; //Only return the fullScreenImage, not the fullResolutionImage
            elcPicker.returnsImage = YES; //Return UIimage if YES. If NO, only return asset location information
            elcPicker.onOrder = YES; //For multiple image selection, display and return order of selected images
            elcPicker.mediaTypes = @[(NSString *)kUTTypeImage]; //Supports image and movie types
            elcPicker.imagePickerDelegate = self;
            [self presentViewController:elcPicker animated:YES completion:nil];
        }
            break;
        default:
            break;
    }
}

#pragma mark - UIImagePickerController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:@"public.image"]) {
        UIImage  *image = [info objectForKey:UIImagePickerControllerEditedImage];
        [self.chosenImages addObject:image];
        [self reloadImageToView];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
