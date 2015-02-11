//
//  AddXsydViewController.m
//  hmjs
//
//  Created by yons on 15-2-10.
//  Copyright (c) 2015年 yons. All rights reserved.
//

#import "AddXsydViewController.h"

@interface AddXsydViewController ()

@end

@implementation AddXsydViewController
@synthesize mytableview;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIBarButtonItem *buttonItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
    [self.navigationItem setRightBarButtonItem:buttonItem1];
    
    self.title = @"异动详情";
    //初始化tableview
    CGRect cg;
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
        cg = CGRectMake(0, 64, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-64);
        self.automaticallyAdjustsScrollViewInsets = NO;
    }else{
        cg = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-64);
    }
    mytableview = [[UITableView alloc] initWithFrame:cg style:UITableViewStylePlain];
    mytableview.dataSource = self;
    mytableview.delegate = self;
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [mytableview setTableFooterView:v];
    if ([mytableview respondsToSelector:@selector(setSeparatorInset:)]) {
        [mytableview setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([mytableview respondsToSelector:@selector(setLayoutMargins:)]) {
        [mytableview setLayoutMargins:UIEdgeInsetsZero];
    }
    [self.view addSubview:mytableview];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];;
    }
    
    switch (indexPath.row) {
        case 0:
        {
            cell.textLabel.text = @"日期";
            cell.detailTextLabel.text = @"请选择";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
            break;
        case 1:
        {
            cell.textLabel.text = @"班级";
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSDictionary *class= [userDefaults objectForKey:@"class"];
            NSString *classname = [class objectForKey:@"className"];
            cell.detailTextLabel.text = classname;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
            break;
        case 2:
        {
            cell.textLabel.text = @"姓名";
            cell.detailTextLabel.text = @"未填写";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
            break;
        case 3:
        {
            cell.textLabel.text = @"类型";
            cell.detailTextLabel.text = @"请选择";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
            break;
        case 4:
        {
            cell.textLabel.text = @"原因";
            cell.detailTextLabel.text = @"未填写";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            [cell.detailTextLabel sizeToFit];
            cell.detailTextLabel.numberOfLines = 0;
            cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
            [cell.detailTextLabel setTextAlignment:NSTextAlignmentLeft];
        }
            break;
        case 5:
        {
            cell.textLabel.text = @"备注";
            cell.detailTextLabel.text = @"未填写";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            [cell.detailTextLabel sizeToFit];
            cell.detailTextLabel.numberOfLines = 0;
            cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
            [cell.detailTextLabel setTextAlignment:NSTextAlignmentLeft];
        }
            break;
        default:
            break;
    }
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    float width = [UIScreen mainScreen].bounds.size.width;
    CGSize size = CGSizeMake(width-100,CGFLOAT_MAX);
    if (indexPath.row == 4) {
        CGSize labelsize = [@"未填写" sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
        if (labelsize.height+20 < 44) {
            return 44;
        }else{
            return labelsize.height+20;
        }
    }
    return 44;

}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)save{
    
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

@end
