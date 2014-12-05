//
//  AddActivityViewController.m
//  hmjs
//
//  Created by yons on 14-12-5.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import "AddActivityViewController.h"
#import "MKNetworkKit.h"
#import "Utils.h"
#import "MBProgressHUD.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <MediaPlayer/MPMoviePlayerController.h>

@interface AddActivityViewController ()<MBProgressHUDDelegate>{
    MKNetworkEngine *engine;
    MBProgressHUD *HUD;
    int type;
}

@property (nonatomic, strong) ALAssetsLibrary *specialLibrary;

@end

@implementation AddActivityViewController

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
    
    
    
    self.title = @"发布活动";
    
    //添加手势，点击输入框其他区域隐藏键盘
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGr.cancelsTouchesInView =NO;
    [self.view addGestureRecognizer:tapGr];
    
    [self.imagePickBtn setBackgroundImage:[UIImage imageNamed:@"smiley_add_btn_nor.png"] forState:UIControlStateNormal];
    [self.imagePickBtn setImage:[UIImage imageNamed:@"smiley_add_btn_pressed.png"] forState:UIControlStateHighlighted];
    
    //添加按钮
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]
                                 initWithTitle:@"提交"
                                 style:UIBarButtonItemStyleBordered
                                 target:self
                                 action:@selector(save)];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
//    [self.myscrollview setContentSize:CGSizeMake(self.view.frame.size.width,self.view.frame.size.height+1)];
//    [self.myscrollview setScrollEnabled:YES];
    
    self.chosenImages = [[NSMutableArray alloc] init];
    //[self.myscrollview setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64)];
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

- (void)save{
    NSLog(@"保存");
}

- (IBAction)launchController{
    if (self.chosenImages.count > 0 && type == 1) {
        UIActionSheet *actionsheet = [[UIActionSheet alloc] initWithTitle:@"选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"选择照片", nil];
        actionsheet.tag = 1;
        [actionsheet showInView:self.view];
    }else{
        UIActionSheet *actionsheet = [[UIActionSheet alloc] initWithTitle:@"选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"选择照片",@"录像",@"选择视频", nil];
        actionsheet.tag = 2;
        [actionsheet showInView:self.view];
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

- (void)reloadImageToView{
    
    
    for (UIView *v in [self.myscrollview subviews]) {
        if ([v isKindOfClass:[UIButton class]]) {
            NSLog(@"%@",v);
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
    if (type == 1) {
        if (self.chosenImages.count == 9) {
            [self.imagePickBtn setHidden:YES];
        }else{
            [self.imagePickBtn setHidden:NO];
        }
    }else if(type == 2){
        if (self.chosenImages.count == 1) {
            [self.imagePickBtn setHidden:YES];
        }else{
            [self.imagePickBtn setHidden:NO];
        }
    }
    
    
    [self.imagePickBtn setFrame:workingFrame];
    
    if (self.imagePickBtn.hidden) {
        UIButton *lastBtn = self.myscrollview.subviews.lastObject;
        [self.myscrollview setContentSize:CGSizeMake(self.view.frame.size.width,lastBtn.frame.origin.y + lastBtn.frame.size.height + 10)];
    }else{
        [self.myscrollview setContentSize:CGSizeMake(self.view.frame.size.width,self.imagePickBtn.frame.origin.y + self.imagePickBtn.frame.size.height + 10)];
    }
    
}

- (void)btnclick:(UIButton *)sender {
    [sender removeFromSuperview];
    [self.chosenImages removeObject:sender.imageView.image];
    [self reloadImageToView];
}

#pragma mark ELCImagePickerControllerDelegate Methods

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
    
    
    
//    NSMutableArray *images = [NSMutableArray arrayWithCapacity:[info count]];
    for (NSDictionary *dict in info) {
        if ([dict objectForKey:UIImagePickerControllerMediaType] == ALAssetTypePhoto){
            if ([dict objectForKey:UIImagePickerControllerOriginalImage]){
                UIImage* image=[dict objectForKey:UIImagePickerControllerOriginalImage];
//                [images addObject:image];
                [self.chosenImages addObject:image];
                
                
//                UIImageView *imageview = [[UIImageView alloc] initWithImage:image];
                
//                UIImageView *imageview = [[UIImageView alloc] initWithFrame:workingFrame];
//                imageview.image = image;
//                [imageview setContentMode:UIViewContentModeScaleAspectFit];
////                imageview.frame = workingFrame;
//                [self.view addSubview:imageview];
                
//                UIButton *btn = [[UIButton alloc] initWithFrame:workingFrame];
////                [btn setBackgroundImage:image forState:UIControlStateNormal];
//                btn.tag = self.chosenImages.count - 1;
//                [btn setImage:image forState:UIControlStateNormal];
//                [self.myscrollview addSubview:btn];
                
                
                
            } else {
                NSLog(@"UIImagePickerControllerReferenceURL = %@", dict);
            }
        } else if ([dict objectForKey:UIImagePickerControllerMediaType] == ALAssetTypeVideo){
//            if ([dict objectForKey:UIImagePickerControllerOriginalImage]){
//                UIImage* image=[dict objectForKey:UIImagePickerControllerOriginalImage];
//                
//                [images addObject:image];
//                
//                UIImageView *imageview = [[UIImageView alloc] initWithImage:image];
//                [imageview setContentMode:UIViewContentModeScaleAspectFit];
////                imageview.frame = workingFrame;
//                
////                [_scrollView addSubview:imageview];
//                
////                workingFrame.origin.x = workingFrame.origin.x + workingFrame.size.width;
//            } else {
//                NSLog(@"UIImagePickerControllerReferenceURL = %@", dict);
//            }
        } else {
            NSLog(@"Uknown asset type");
        }
    }
//    NSLog(@"%@",images);
//    [self.chosenImages addObjectsFromArray:[images copy]];
    [self reloadImageToView];
//    [_scrollView setPagingEnabled:YES];
//    [_scrollView setContentSize:CGSizeMake(workingFrame.origin.x, workingFrame.size.height)];
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
            type = 1;
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
            //            imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:imagePicker.sourceType];
            [self presentViewController:imagePicker animated:YES completion:nil];
        }
            break;
        case 1://本地相簿
        {
            type = 1;
//            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
//            imagePicker.delegate = self;
//            imagePicker.allowsEditing = YES;
//            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//            imagePicker.mediaTypes =  [[NSArray alloc] initWithObjects:@"public.image", nil];
//            [self presentViewController:imagePicker animated:YES completion:^{
//                
//            }];
            
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
        case 2://录像
        {
            if(actionSheet.tag == 2){
                type = 2;
                if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                    NSLog(@"sorry, no camera or camera is unavailable.");
                    return;
                }
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.delegate = self;
                imagePicker.allowsEditing = YES;
                imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                imagePicker.mediaTypes =  @[(NSString *)kUTTypeMovie];
                //            imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:imagePicker.sourceType];
                [self presentViewController:imagePicker animated:YES completion:nil];
            }
        }
            break;
        case 3://选择视频
        {
            if(actionSheet.tag == 2){
                type = 2;
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.delegate = self;
                imagePicker.allowsEditing = YES;
                imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                imagePicker.mediaTypes =  @[(NSString *)kUTTypeMovie];
                [self presentViewController:imagePicker animated:YES completion:nil];
                //            ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initImagePicker];
                //
                //            elcPicker.maximumImagesCount = 1; //Set the maximum number of images to select to 100
                //            elcPicker.returnsOriginalImage = YES; //Only return the fullScreenImage, not the fullResolutionImage
                //            elcPicker.returnsImage = YES; //Return UIimage if YES. If NO, only return asset location information
                //            elcPicker.onOrder = YES; //For multiple image selection, display and return order of selected images
                //            elcPicker.mediaTypes = @[(NSString *)kUTTypeMovie]; //Supports image and movie types
                //
                //            elcPicker.imagePickerDelegate = self;
                //            
                //            [self presentViewController:elcPicker animated:YES completion:nil];
            }
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
        NSData *fildData = UIImageJPEGRepresentation(image, 1.0);//UIImagePNGRepresentation(img); //
        [self.chosenImages addObject:image];
        [self reloadImageToView];
        
        
        
        //        self.fileData = UIImageJPEGRepresentation(img, 1.0);
    }
    else if([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:@"public.movie"])
    {
        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        NSLog(@"found a video");
        //获取视频的thumbnail
        MPMoviePlayerController *player = [[MPMoviePlayerController alloc]initWithContentURL:videoURL];
        UIImage  *image = [player thumbnailImageAtTime:1.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
        [self.chosenImages addObject:image];
        [self reloadImageToView];
    }
    [picker dismissViewControllerAnimated:YES completion:^{
        
        
    }];
}

@end
