//
//  HXCustomButton.m
//  Impp
//
//  Created by Herxun on 2015/3/31.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import "HXCustomButton.h"
#import "UIFont+customFont.h"

@interface HXCustomButton()
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) UIColor *titleColor;
@property (strong, nonatomic) UIColor *buttonBackgroundColor;
@property CGSize size;
@end

@implementation HXCustomButton

- (id)initWithTitle:(NSString *)title titleColor:(UIColor *)titleColor backgroundColor:(UIColor *)backgroundColor
{
    self = [super init];
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
    self.titleLabel.font = [UIFont heitiLightWithSize:13.f];
    self.backgroundColor = self.backgroundColor;
    self.layer.cornerRadius = 2.f;
    [self sizeToFit];
    
    CGRect bframe = self.frame;
    bframe.size.width += 10.f *2;
    bframe.size.height = 26.f;
    bframe.origin.x = 0;
    bframe.origin.y = 0;
    self.frame = bframe;
    self.layer.borderColor = self.titleColor.CGColor;
    self.layer.borderWidth = 1;
}

- (void)updateTitle:(NSString *)title TitleColor:(UIColor *)color
{
    self.layer.borderColor = color.CGColor;
    [self setTitle:title forState:UIControlStateNormal];
    [self setTitleColor:color forState:UIControlStateNormal];
    [self sizeToFit];
    
    CGRect bframe = self.frame;
    bframe.size.width += 10.f *2;
    bframe.size.height = 26.f;
    self.frame = bframe;
    
}
@end
