//
//  ChildrenTableViewCell.h
//  hmjz
//  选择宝宝单元格
//  Created by yons on 14-11-3.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChildrenTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *img;
@property (weak, nonatomic) IBOutlet UILabel *namelabel;
@property (weak, nonatomic) IBOutlet UILabel *sexlabel;

@end
