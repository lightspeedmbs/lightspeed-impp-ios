//
//  HXChatHistoryTableViewCell.m
//  Impp
//
//  Created by Herxun on 2015/4/9.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import "HXChatHistoryTableViewCell.h"
#import "HXNumberBadge.h"
#import "UIColor+CustomColor.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define SCREEN_WIDTH [[UIScreen mainScreen] applicationFrame].size.width
@interface HXChatHistoryTableViewCell()
@property (strong, nonatomic) NSString *photoUrl;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *lastMessage;
@property (strong, nonatomic) NSNumber *timestamp;
@property (strong, nonatomic) UILabel *timestampLabel;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *lastMessageLabel;
@property (strong, nonatomic) UIImage *placeholderImage;
@property (strong, nonatomic) HXNumberBadge *badge;
@property  NSInteger badgeValue;
@end

@implementation HXChatHistoryTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier title:(NSString *)title subtitle:(NSString *)subtitle timestamp:(NSNumber *)timestamp photoUrl:(NSString *)photoUrl placeholderImage:(UIImage *)placeholderImage badgeValue:(NSInteger)badgeValue
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.title = title;
        self.photoUrl = photoUrl;
        self.placeholderImage = placeholderImage;
        self.badgeValue = badgeValue;
        self.timestamp = timestamp;
        self.lastMessage = subtitle;
        [self initView];
    }
    return self;
}

- (void)reuseCellWithTitle:(NSString *)title subtitle:(NSString *)subtitle timestamp:(NSNumber *)timestamp photoUrl:(NSString *)photoUrl placeholderImage:(UIImage *)placeholderImage badgeValue:(NSInteger)badgeValue
{
    
}

- (void)initView
{
    CGRect frame;
    self.imageView.image = self.placeholderImage;
    self.imageView.layer.cornerRadius = 54/2;
    self.imageView.clipsToBounds = YES;
    self.imageView.layer.masksToBounds = YES;
    self.badge = [[HXNumberBadge alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 30 - 18, 74/2 - 18/2, 18, 18) badgeNumber:self.badgeValue];
    [self addSubview:self.badge];
    
    if ([self.timestamp integerValue] != 0)
    {
        NSDate *updatetimestamp = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)[self.timestamp doubleValue]/1000];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        NSString *timestamp = [dateFormatter stringFromDate:updatetimestamp];
        
        self.timestampLabel = [[UILabel alloc] init];
        self.timestampLabel.text = timestamp;
        self.timestampLabel.font = [UIFont fontWithName:@"STHeitiTC-Light" size:24.0f/2];
        self.timestampLabel.textColor = [UIColor color8];
        self.timestampLabel.numberOfLines = 1;
        self.timestampLabel.textAlignment = NSTextAlignmentRight;
        [self.timestampLabel sizeToFit];
        frame = self.timestampLabel.frame;
        frame.origin.x = SCREEN_WIDTH - 30 - frame.size.width;
        frame.origin.y = 10;
        self.timestampLabel.frame = frame;
        [self.contentView addSubview:self.timestampLabel];
    }
    
    self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(74, 10, self.timestampLabel.frame.origin.x - 15 - 74, 16)];
    self.titleLabel.text = self.title;
    self.titleLabel.font = [UIFont fontWithName:@"STHeitiTC-Medium" size:16];
    self.titleLabel.textColor = [UIColor color4];
    self.titleLabel.numberOfLines = 1;
    self.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [self.contentView addSubview:self.titleLabel];
    
    self.lastMessageLabel = [[UILabel alloc]initWithFrame:CGRectMake(74,
                                                                     self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 6,
                                                                     self.badge.frame.origin.x - 74 - 15 , 28)];
    self.lastMessageLabel.text = self.lastMessage;
    self.lastMessageLabel.font = [UIFont fontWithName:@"STHeitiTC-Light" size:28.0f/2];
    self.lastMessageLabel.textColor = [UIColor color11];
    self.lastMessageLabel.textAlignment = NSTextAlignmentLeft;
    self.lastMessageLabel.numberOfLines = 2;
    self.lastMessageLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self addSubview:self.lastMessageLabel];
    
    [self updatePhotoIcon];
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
                               CGPoint center = self.imageView.center;
                               self.imageView.image = image;
                               self.imageView.contentMode = UIViewContentModeScaleAspectFill;
                               self.imageView.center = center;
                           }
                           
                       }];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect frame = self.imageView.frame;
    frame.size = CGSizeMake(54, 54);
    frame.origin = CGPointMake(10, 10);
    self.imageView.frame = frame;
    self.separatorInset = UIEdgeInsetsMake(0, 74, 0, 0);
    
}
@end
