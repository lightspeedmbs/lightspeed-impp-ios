//
//  HXLikeCommentButton.m
//  Impp
//
//  Created by hsujahhu on 2015/4/10.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import "HXLikeCommentButton.h"
#import "UIColor+CustomColor.h"

@interface HXLikeCommentButton()
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) UIColor *tintColor;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) UIImageView *icon;
@property (strong, nonatomic) UILabel *likeCommentLabel;

@property CGSize size;
@end

@implementation HXLikeCommentButton

- (id)initWithTitle:(NSString *)title tintColor:(UIColor *)tintColor image:(UIImage *)image
{
    self = [super init];
    if (self)
    {
        self.title = title;
        self.tintColor = tintColor;
        self.image = image;
        [self initView];
    }
    return self;
}

- (void)initView
{
    self.icon = [[UIImageView alloc]initWithImage:self.image];
    self.icon.frame = CGRectMake(10, 7, 14, 12);
    
    self.likeCommentLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.icon.frame.origin.x + self.icon.frame.size.width+6, 7, 50, 13)];
    self.likeCommentLabel.text = self.title;
    self.likeCommentLabel.font = [UIFont fontWithName:@"STHeitiTC-Light" size:13];
    self.likeCommentLabel.textColor = self.tintColor;
    self.likeCommentLabel.numberOfLines = 1;
    [self.likeCommentLabel sizeToFit];
    
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 2.f;
    [self sizeToFit];
    
    CGRect bframe = self.frame;
    bframe.size.width = 10.f *2 + self.likeCommentLabel.frame.size.width + 6 + 14;
    bframe.size.height = 26.f;
    bframe.origin.x = 0;
    bframe.origin.y = 0;
    self.frame = bframe;
    self.layer.borderColor = self.tintColor.CGColor;
    self.layer.borderWidth = 1;
    [self addSubview:self.likeCommentLabel];
    [self addSubview:self.icon];
   
}

- (void)updateTitle:(NSString *)title tintColor:(UIColor *)color image:(UIImage *)image
{
    self.icon.image = image;
    self.likeCommentLabel.text = title;
    self.likeCommentLabel.textColor = color;
    [self.likeCommentLabel sizeToFit];
    
    CGRect bframe = self.frame;
    bframe.size.width = 10.f *2 + self.likeCommentLabel.frame.size.width + 6 + 14;
    bframe.size.height = 26.f;
    self.frame = bframe;
    self.layer.borderColor = color.CGColor;
    
}


@end
