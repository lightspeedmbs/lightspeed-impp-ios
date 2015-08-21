//
//  HXGroupCollectionViewCell.m
//  Impp
//
//  Created by 雷翊廷 on 2015/7/9.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import "HXRoomCollectionViewCell.h"
#import "UIColor+CustomColor.h"
#import "UIFont+customFont.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation HXRoomCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame

{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _groupImage = [[UIImageView alloc]initWithFrame:CGRectMake(15, 15, frame.size.width-30, frame.size.width-30)];
        _groupImage.image = nil;
        _groupImage.backgroundColor = [UIColor color6];
        _groupImage.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_groupImage];
        _groupImage.layer.cornerRadius = _groupImage.frame.size.width/2;
        _groupImage.clipsToBounds = YES;
        _groupImage.layer.masksToBounds = YES;
        
        _groupNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, _groupImage.frame.size.height+25, frame.size.width-30, 14)];
        _groupNameLabel.text = @"";
        _groupNameLabel.numberOfLines = 1;
        _groupNameLabel.font =[UIFont heitiLightWithSize:14];
        _groupNameLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_groupNameLabel];
    }

    return self;
}

@end
