//
//  FriendCell.m
//  hmjz
//
//  Created by yons on 14-11-13.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import "FriendCell.h"

@implementation FriendCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.myimageview.layer.cornerRadius = 3.0;
    self.myimageview.layer.masksToBounds = YES;
}

@end
