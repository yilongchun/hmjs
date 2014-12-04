//
//  MyNoticeReviewViewController.h
//  hmjs
//  我的公告 待审核
//  Created by yons on 14-12-4.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyNoticeReviewViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>{
    
}

@property (nonatomic, strong) UITableView *mytableView;
@property (nonatomic, strong) NSMutableArray *dataSource;



@end
