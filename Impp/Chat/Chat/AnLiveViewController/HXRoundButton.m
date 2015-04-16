//
//  HXRoundButton.m
//  Impp
//
//  Created by Herxun on 2015/4/9.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import "HXRoundButton.h"

@interface HXRoundButton()
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) UIColor *titleColor;
@property (strong, nonatomic) UIColor *buttonBackgroundColor;
@end

@implementation HXRoundButton

- (id)initWithTitle:(NSString *)title titleColor:(UIColor *)titleColor backgroundColor:(UIColor *)backgroundColor frame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.title = title;
        self.titleColor = titleColor;
        self.buttonBackgroundColor = backgroundColor;
        [self initView];
    }
    return self;
}

- (void)initView
{
    [self setTitle:self.title forState:UIControlStateNormal];
    [self setTitleColor:self.titleColor forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont fontWithName:@"STHeitiTC-Medium" size:14];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.backgroundColor = self.buttonBackgroundColor;
    self.layer.cornerRadius = 2.f;
}

- (void)updateTitle:(NSString *)title backgroundColor:(UIColor *)backgroundColor
{
    [self setTitle:title forState:UIControlStateNormal];
    self.backgroundColor = backgroundColor;
}
@end
