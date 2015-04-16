//
//  HXCustomTableViewCell.m
//  Impp
//
//  Created by Herxun on 2015/3/31.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import "HXCustomTableViewCell.h"
#import "HXNumberBadge.h"
#import "HXCustomButton.h"
#import "UIColor+CustomColor.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define SCREEN_WIDTH [[UIScreen mainScreen] applicationFrame].size.width
#define FRIEND_SEARCH_CELL @"friendSearchCell"
#define FRIEND_REQUEST_CELL @"friendRequestCell"
#define FRIEND_LIST_CELL @"friendListCell"

@interface HXCustomTableViewCell()
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *photoUrl;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) UILabel *statusLabel;
@property (strong, nonatomic) HXNumberBadge *badge;
@property (strong, nonatomic) HXCustomButton *friendSearchButton;
@property (nonatomic) HXCustomCellStyle customStyle;
@property  NSInteger badgeValue;
@property  NSInteger index;
@end
@implementation HXCustomTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier title:(NSString *)title photoUrl:(NSString *)photoUrl image:(UIImage *)image badgeValue:(NSInteger)badgeValue style:(HXCustomCellStyle)customCellStyle
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.title = title;
        self.photoUrl = photoUrl;
        self.image = image;
        self.badgeValue = badgeValue;
        self.customStyle = customCellStyle;
        [self initView];
    }
    return self;
}

- (void)reuseCellWithTitle:(NSString *)title photoUrl:(NSString *)photoUrl image:(UIImage *)image badgeValue:(NSInteger)badgeValue
{
    self.title = title;
    self.photoUrl = photoUrl;
    self.image = image;
    self.imageView.image = self.image;
    self.textLabel.text = self.title;
    self.badgeValue = badgeValue;
    [self.badge updateBadgeNumber:badgeValue];
    
    [self updatePhotoIcon];
    
}

- (void)initView
{
    UITapGestureRecognizer *photoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoTapped)];
    self.imageView.image = self.image;
    self.textLabel.text = self.title;
    self.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    self.imageView.layer.cornerRadius = 36/2;
    self.imageView.clipsToBounds = YES;
    self.imageView.layer.masksToBounds = YES;
    self.imageView.userInteractionEnabled = YES;
    [self.imageView addGestureRecognizer:photoTap];
    self.badge = [[HXNumberBadge alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 30 - 18, self.center.y - 18/2, 18, 18) badgeNumber:self.badgeValue];
    [self addSubview:self.badge];
    
    [self updatePhotoIcon];
    
    if (self.customStyle == HXCustomCellStyleSearch) {
        
        self.friendSearchButton = [[HXCustomButton alloc]initWithTitle:NSLocalizedString(@"加入好友", nil) titleColor:[UIColor color3] backgroundColor:[UIColor color5]];
        [self.friendSearchButton addTarget:self action:@selector(customButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        CGRect bframe = self.friendSearchButton.frame;
        bframe.origin.x = SCREEN_WIDTH - 15 - bframe.size.width;
        bframe.origin.y = (48 - bframe.size.height)/2;
        self.friendSearchButton.frame = bframe;
        [self addSubview:self.friendSearchButton];
        
        self.statusLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 15, self.frame.size.height)];
        self.statusLabel.text = NSLocalizedString(@"已是好友", nil);
        self.statusLabel.textAlignment = NSTextAlignmentRight;
        self.statusLabel.textColor = [UIColor color8];
        self.statusLabel.font = [UIFont fontWithName:@"STHeitiTC-Light" size:13];
        [self addSubview:self.statusLabel];
        self.statusLabel.hidden = YES;
    }

}

- (void)updatePhotoIcon
{
    if (self.photoUrl) {
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager downloadWithURL:[NSURL URLWithString:self.photoUrl]
                         options:0
                        progress:^(NSInteger receivedSize, NSInteger expectedSize){}
                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished){
                           if (image) {
                               self.imageView.image = image;
                               self.imageView.contentMode = UIViewContentModeScaleAspectFill;
                           }
                           
                       }];
    }
}

- (void)updateTitle:(NSString *)title TitleColor:(UIColor *)color
{
    self.friendSearchButton.hidden = NO;
    self.friendSearchButton.enabled = YES;
    self.statusLabel.hidden = YES;
    [self.friendSearchButton updateTitle:title TitleColor:color];
}

- (void)updateBadgeNumber:(NSInteger)badgeValue
{
    [self.badge updateBadgeNumber:badgeValue];
}

- (void)showLabelWithTitle:(NSString *)title
{
    self.friendSearchButton.hidden = YES;
    self.statusLabel.text = title;
    self.statusLabel.hidden = NO;
}

- (void)setButtonDisable
{
    self.friendSearchButton.enabled = NO;
}

- (void)setButtonTag:(NSInteger)tag
{
    self.friendSearchButton.tag = tag;
}

- (void)setIndexValue:(NSInteger)index
{
    self.index = index;
}

- (void)customButtonTapped:(UIButton*)sender
{
    if(self.delegate){
        [self.delegate customCellButtonTapped:sender];
    }
}

- (void)photoTapped
{
    if(self.defaultDelegate){
        [self.defaultDelegate customCellPhotoTapped:self.index];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect frame = self.imageView.frame;
    frame.size = CGSizeMake(36, 36);
    frame.origin = CGPointMake(10, 6);
    self.imageView.frame = frame;
    frame = self.textLabel.frame;
    frame.origin.x = 56;
    self.textLabel.frame = frame;
    self.separatorInset = UIEdgeInsetsMake(0, 56, 0, 0);
    
}
@end
