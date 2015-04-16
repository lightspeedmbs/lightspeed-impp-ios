//
//  HXNumberBadge.m
//  Impp
//
//  Created by Herxun on 2015/4/1.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import "HXNumberBadge.h"
#import "UIColor+CustomColor.h"
#import "UILabel+customLabel.h"
#import "UIFont+customFont.h"

@interface HXNumberBadge ()
@property NSInteger badgeNumber;
@property (strong, nonatomic) UILabel *numberLabel;
@property NSInteger defaultWidth;
@end

@implementation HXNumberBadge

- (id)initWithFrame:(CGRect)frame badgeNumber:(NSInteger)badgeNumber
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _badgeNumber = badgeNumber;
        _defaultWidth = frame.size.width;
        [self initView];
    }
    return self;
}

- (void)initView
{
    self.backgroundColor = [UIColor color3];
    self.layer.cornerRadius = 9;
    
    self.numberLabel = [UILabel labelWithFrame:CGRectNull
                                          text:[NSString stringWithFormat:@"%li", (long)_badgeNumber]
                                 textAlignment:NSTextAlignmentCenter
                                     textColor:[UIColor color5]
                                          font:[UIFont heitiLightWithSize:11]
                                 numberOfLines:1];
    CGRect frame = self.frame;
    frame.origin.x += frame.size.width;
    frame.size.width = MAX(self.numberLabel.bounds.size.width +6*2, _defaultWidth);
    frame.origin.x -= frame.size.width;
    self.frame = frame;
    self.numberLabel.center = CGPointMake(self.bounds.size.width/2 , self.bounds.size.height/2);
    [self addSubview:self.numberLabel];
    
    if (_badgeNumber <= 0) self.alpha = 0;
}

- (void)updateBadgeNumber:(NSInteger)badgeNumber
{
    _badgeNumber = badgeNumber;
    
    self.numberLabel.text = [NSString stringWithFormat:@"%li", (long)_badgeNumber];
    [self.numberLabel sizeToFit];
    CGRect frame = self.frame;
    frame.origin.x += frame.size.width;
    frame.size.width = MAX(self.numberLabel.bounds.size.width +6*2, _defaultWidth);
    frame.origin.x -= frame.size.width;
    self.frame = frame;
    self.numberLabel.center = CGPointMake(self.bounds.size.width/2 , self.bounds.size.height/2);
    
    if (_badgeNumber <= 0) self.alpha = 0;
    else self.alpha = 1;
}

- (NSInteger)currentBadgeNumber
{
    return _badgeNumber;
}

@end
