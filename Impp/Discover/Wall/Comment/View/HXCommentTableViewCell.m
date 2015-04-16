//
//  HXCommentTableViewCell.m
//  Impp
//
//  Created by hsujahhu on 2015/4/8.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import "HXCommentTableViewCell.h"
#import "HXUserAccountManager.h"
#import "HXAnSocialManager.h"
#import "UIColor+CustomColor.h"
#import "HXFriendProfileViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define SCREEN_WIDTH [[UIScreen mainScreen] applicationFrame].size.width
@interface HXCommentTableViewCell()
@property (strong, nonatomic) HXComment *commentInfo;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *commentLabel;
@end
@implementation HXCommentTableViewCell

+ (CGFloat)heightForCellComment:(NSString *)comment
{
    UILabel *messageLabel = [[UILabel alloc]initWithFrame:CGRectMake(100/2, 58/2, 500/2, 14)];
    messageLabel.text = comment;
    messageLabel.font = [UIFont fontWithName:@"STHeitiTC-Light" size:14];
    messageLabel.textAlignment = NSTextAlignmentLeft;
    messageLabel.numberOfLines = 0;
    [messageLabel sizeToFit];
    
    CGFloat height = messageLabel.frame.size.height + 26 + 14;
    return height;
}

- (id)initWithCommentInfo:(HXComment *)commentInfo
          reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.commentInfo = commentInfo;
        [self initView];
    }
    return self;
}

- (void)initView
{
    NSString *titleText = self.commentInfo.targetUser ? [NSString stringWithFormat:@"%@ 回覆 %@",self.commentInfo.commentOwner.userName, self.commentInfo.targetUser.userName] : self.commentInfo.commentOwner.userName;
    self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(56, 10, SCREEN_WIDTH - 100 - 15, 16)];
    self.titleLabel.text = titleText;
    self.titleLabel.font = [UIFont fontWithName:@"STHeitiTC-Medium" size:16];
    self.titleLabel.textColor = [UIColor color4];
    self.titleLabel.numberOfLines = 1;
    
    [self.contentView addSubview:self.titleLabel];
    
    self.commentLabel = [[UILabel alloc]initWithFrame:CGRectMake(56, self.titleLabel.frame.size.height + self.titleLabel.frame.origin.y + 6, SCREEN_WIDTH - 100 - 15, 14)];
    self.commentLabel.text = self.commentInfo.content;
    self.commentLabel.font = [UIFont fontWithName:@"STHeitiTC-Light" size:14];
    self.commentLabel.textColor = [UIColor color11];
    self.commentLabel.numberOfLines = 0;
    [self.commentLabel sizeToFit];
    [self.contentView addSubview:self.commentLabel];
    
    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
    self.imageView.image = [UIImage imageNamed:@"friend_default"];
    self.imageView.layer.cornerRadius = 36/2;
    self.imageView.clipsToBounds = YES;
    self.imageView.layer.masksToBounds = YES;

    
    [self updatePhotoIcon];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect frame = self.imageView.frame;
    
    frame.size = CGSizeMake(36, 36);
    frame.origin = CGPointMake(10, 10);
    self.imageView.frame = frame;
    self.separatorInset = UIEdgeInsetsMake(0, 56, 0, 0);
}

#pragma mark - Helper

- (void)updatePhotoIcon
{
    if (self.commentInfo.commentOwner.photoURL) {
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager downloadWithURL:[NSURL URLWithString:self.commentInfo.commentOwner.photoURL]
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


@end
