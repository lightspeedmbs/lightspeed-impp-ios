//
//  HXFriendRequestTableViewCell.m
//  Impp
//
//  Created by Herxun on 2015/3/24.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import "HXFriendRequestTableViewCell.h"
#import "HXCustomButton.h"
#import "UIColor+CustomColor.h"
#import <SDWebImage/UIImageView+WebCache.h>
#define SCREEN_WIDTH [[UIScreen mainScreen] applicationFrame].size.width

@interface HXFriendRequestTableViewCell()
@property (strong, nonatomic) NSDictionary *userInfo;
@property (strong, nonatomic) HXCustomButton *approveButton;
@property (strong, nonatomic) HXCustomButton *rejectButton;
@property (strong, nonatomic) UILabel *statusLabel;
@end
@implementation HXFriendRequestTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
           userInfo:(NSDictionary *)userInfo
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.userInfo = userInfo;
        [self initView];
    }
    return self;
}

- (void)reuseCellWithUserInfo:(NSDictionary *)userInfo
{
    self.textLabel.text = self.userInfo[@"username"];
    self.imageView.image = [UIImage imageNamed:@"friend_default"];
    [self updateCellLayoutWithStatus:self.userInfo[@"status"]];
    [self updatePhotoIcon];
}

- (void)initView
{
    CGRect frame;
    
    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.textLabel.text = self.userInfo[@"username"];
    self.imageView.image = [UIImage imageNamed:@"friend_default"];
    self.imageView.layer.cornerRadius = 36/2;
    self.imageView.clipsToBounds = YES;
    self.imageView.layer.masksToBounds = YES;
    
    self.rejectButton = [[HXCustomButton alloc]initWithTitle:NSLocalizedString(@"拒絕", nil) titleColor:[UIColor redColor] backgroundColor:[UIColor color5]];
    frame = self.rejectButton.frame;
    frame.origin = CGPointMake(SCREEN_WIDTH - frame.size.width - 15, self.center.y - frame.size.height/2);
    self.rejectButton.frame = frame;
    [self.rejectButton addTarget:self action:@selector(rejectButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.rejectButton];
    
    self.approveButton = [[HXCustomButton alloc]initWithTitle:NSLocalizedString(@"接受", nil) titleColor:[UIColor color3] backgroundColor:[UIColor color5]];
    frame = self.approveButton.frame;
    frame.origin = CGPointMake(self.rejectButton.frame.origin.x - frame.size.width - 6, self.center.y - frame.size.height/2);
    self.approveButton.frame = frame;
    [self.approveButton addTarget:self action:@selector(approveButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.approveButton];
    
    self.statusLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,0, SCREEN_WIDTH - 15, self.bounds.size.height)];
    self.statusLabel.text = self.userInfo[@"status"];
    self.statusLabel.textAlignment = NSTextAlignmentRight;
    self.statusLabel.font = [UIFont fontWithName:@"STHeitiTC-Light" size:13];
    self.statusLabel.textColor = [UIColor color8];
    self.statusLabel.numberOfLines = 0;
    [self addSubview:self.statusLabel];
    
    [self updateCellLayoutWithStatus:self.userInfo[@"status"]];
    
    [self updatePhotoIcon];

}

- (void)updatePhotoIcon
{
    if (self.userInfo[@"photo"]) {
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager downloadWithURL:[NSURL URLWithString:self.userInfo[@"photo"][@"url"]]
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

- (void)updateCellLayoutWithStatus:(NSString *)status
{
    if ([status isEqualToString:@"pending"]) {
        [self showButton];
    }else if([status isEqualToString:@"approved"]){
        [self showStatusLabelWithTitle:NSLocalizedString(@"已接受", nil)];
    }else{
        [self showStatusLabelWithTitle:NSLocalizedString(@"已拒絕", nil)];
    }
}

- (void)showStatusLabelWithTitle:(NSString *)title
{
    self.approveButton.hidden = YES;
    self.rejectButton.hidden = YES;
    self.statusLabel.hidden = NO;
    self.statusLabel.text = title;
}

- (void)showButton
{
    self.approveButton.hidden = NO;
    self.rejectButton.hidden = NO;
    self.statusLabel.hidden = YES;
}


- (void)approveButtonTapped
{
    self.approveButton.hidden = YES;
    self.rejectButton.hidden = YES;
    self.statusLabel.hidden = NO;
    self.statusLabel.text = NSLocalizedString(@"已接受", nil);
    
    if (self.delegate) {
        [self.delegate didApproveButtonTappedWithRequestId:self.userInfo[@"requestId"]
                                            targetClientId:self.userInfo[@"clientId"]
                                              targetUserId:self.userInfo[@"id"]];
    }
    
}

- (void)rejectButtonTapped
{
    self.approveButton.hidden = YES;
    self.rejectButton.hidden = YES;
    self.statusLabel.hidden = NO;
    self.statusLabel.text = NSLocalizedString(@"已拒絕", nil);
    
    if (self.delegate) {
        [self.delegate didRejectButtonTappedWithRequestId:self.userInfo[@"requestId"]];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect frame = self.imageView.frame;
    CGPoint center = self.imageView.center;
    frame.size = CGSizeMake(36, 36);
    self.imageView.frame = frame;
    self.imageView.center = center;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
