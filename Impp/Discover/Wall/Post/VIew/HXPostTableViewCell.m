//
//  HXPostTableViewCell.m
//  Impp
//
//  Created by Herxun on 2015/4/8.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import "HXPostTableViewCell.h"
#import "HXAppUtility.h"
#import "HXUserAccountManager.h"
#import "HXAnSocialManager.h"
#import "HXLikeCommentButton.h"
#import "UIColor+CustomColor.h"
#import "HXCommentViewController.h"
#import "HXIMManager.h"
#import "HXFriendProfileViewController.h"
#import "UserUtil.h"
#import "NotificationCenterUtil.h"
#import <SDWebImage/UIImageView+WebCache.h>
#define SCREEN_WIDTH [[UIScreen mainScreen] applicationFrame].size.width

@implementation HXIndexedCollectionView

@end

@interface HXPostTableViewCell()
@property (strong, nonatomic) NSDictionary *postInfo;
@property (strong, nonatomic) UIImageView *defaultPhoto;
@property (strong, nonatomic) UIImageView *profilePhoto;
@property (strong, nonatomic) UIImageView *photoMask;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *locationLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UILabel *messageLabel;
@property (strong, nonatomic) UILabel *likesCountLabel;
@property (strong, nonatomic) UILabel *commentsCountLabel;
@property (strong, nonatomic) UILabel *likeText;
@property (strong, nonatomic) UILabel *commentText;
@property (strong, nonatomic) UIImageView *postImage;
@property (strong, nonatomic) UIImageView *UpLikeButtonImage;
@property (strong, nonatomic) UIImageView *selectLikeButtonImage;
@property (strong, nonatomic) HXLikeCommentButton *commentButton;
@property (strong, nonatomic) HXLikeCommentButton *likeButton;
@property (strong, nonatomic) NSIndexPath *index;
@end

@implementation HXPostTableViewCell

+ (CGFloat)heightForCellPost:(NSString *)post postType:(PostType)type
{
    if (type == TextPost || type == ImageAndTextPost) {
        UILabel *messageLabel = [[UILabel alloc]initWithFrame:CGRectMake(20.0f/2, 120.0f/2, 580.0f/2, 28/2)];
        messageLabel.text = post;
        messageLabel.font = [UIFont fontWithName:@"STHeitiTC-Light" size:28.0f/2];
        messageLabel.textAlignment = NSTextAlignmentLeft;
        messageLabel.numberOfLines = 0;
        [messageLabel sizeToFit];
        
        if (type == TextPost)
            return messageLabel.frame.size.height + 20 + 21 + 36 + 26 + 15;
        else
            return messageLabel.frame.size.height + 20 + 21 + 36 + 26 + 15 + 10 + 108;
        
    }else{
        return 20 + 21 + 36 + 26 + 15 + 10 + 108;
    }
}

- (id)initWithPostInfo:(NSDictionary *)postInfo
       reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.postInfo = postInfo;
        
        [self initView];
    }
    return self;
}

- (void)initView
{
    CGRect frame;
    
    self.contentView.userInteractionEnabled = YES;
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentView.layer.borderWidth = 1/2;
    self.contentView.layer.borderColor = [HXAppUtility hexToColor:0xb3b3b3 alpha:1].CGColor;
    
    /*
     Profile photo
     */
    
    self.profilePhoto = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"friend_default"]];
    self.profilePhoto.frame = CGRectMake(15 ,
                                         21,
                                         36, 36);
    self.profilePhoto.layer.cornerRadius = self.profilePhoto.frame.size.width/2;
    self.profilePhoto.clipsToBounds = YES;
    self.profilePhoto.layer.masksToBounds = YES;
    self.profilePhoto.userInteractionEnabled = YES;
    UITapGestureRecognizer *photoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoTapped)];
    [self.profilePhoto addGestureRecognizer:photoTap];
    
    if (self.postInfo[@"photoURL"]) {
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager downloadWithURL:[NSURL URLWithString:self.postInfo[@"photoURL"]]
                         options:0
                        progress:^(NSInteger receivedSize, NSInteger expectedSize){}
                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished){
                           if (image) {
                               self.profilePhoto.image = image;
                               self.profilePhoto.contentMode = UIViewContentModeScaleAspectFill;
                           }
                           
                       }];
    }
    [self.contentView addSubview:self.profilePhoto];
    
    
    
    /*
     Name label
     */
    NSString *userName = self.postInfo[@"userName"];
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.profilePhoto.frame.origin.x + self.profilePhoto.frame.size.width + 10,
                                                               self.profilePhoto.frame.origin.y + (self.profilePhoto.frame.size.height - 16)/2 ,
                                                               SCREEN_WIDTH - self.profilePhoto.frame.origin.x - self.profilePhoto.frame.size.width - 10 -15, 16)];
    self.nameLabel.backgroundColor = [UIColor clearColor];
    self.nameLabel.text = userName;
    self.nameLabel.font = [UIFont fontWithName:@"STHeitiTC-Light" size:16];
    self.nameLabel.textColor = [UIColor color4];
    self.nameLabel.textAlignment = NSTextAlignmentLeft;
    self.nameLabel.numberOfLines = 1;
    [self.contentView addSubview:self.nameLabel];

    
    
    /*
     Time label
     */
    
    NSDate *updatetimestamp = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)[self.postInfo[@"created_at"] doubleValue]/1000];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *timestamp = [dateFormatter stringFromDate:updatetimestamp];
    
    
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.backgroundColor = [UIColor clearColor];
    self.timeLabel.text = timestamp ? timestamp : @"未知";
    self.timeLabel.font = [UIFont fontWithName:@"STHeitiTC-Light" size:24.0f/2];
    self.timeLabel.textColor = [HXAppUtility hexToColor:0x999999 alpha:1];
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    [self.timeLabel sizeToFit];
    
    frame = self.timeLabel.frame;
    frame.origin.x = (SCREEN_WIDTH - 15) - self.timeLabel.frame.size.width;
    frame.origin.y = 15;
    self.timeLabel.frame = frame;
    [self.contentView addSubview:self.timeLabel];
    
    /*
     Message
     */
    NSString *content = self.postInfo[@"content"];
    self.messageLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, self.profilePhoto.frame.size.height + self.profilePhoto.frame.origin.y + 10,
                                                                 580.0f/2, 28/2)];
    self.messageLabel.backgroundColor = [UIColor clearColor];
    self.messageLabel.text = content ? content : @"";
    self.messageLabel.font = [UIFont fontWithName:@"STHeitiTC-Light" size:28.0f/2];
    self.messageLabel.textColor = [HXAppUtility hexToColor:0x58595b alpha:1];
    self.messageLabel.textAlignment = NSTextAlignmentLeft;
    self.messageLabel.numberOfLines = 0;
    [self.messageLabel sizeToFit];
    
    if (content)
        self.messageLabel.hidden = NO;
    else
        self.messageLabel.hidden = YES;
    
    [self.contentView addSubview:self.messageLabel];
    
    /*
     Image
     */
    
    if (self.postInfo[@"customFields"][@"photoUrls"]) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        //layout.sectionInset = UIEdgeInsetsMake(10, 10, 9, 10);
        layout.minimumInteritemSpacing = 1;
        layout.minimumLineSpacing = 1;
        layout.itemSize = CGSizeMake(108, 108);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.collectionView = [[HXIndexedCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:CollectionViewCellIdentifier];
        self.collectionView.backgroundColor = [UIColor clearColor];
        self.collectionView.showsHorizontalScrollIndicator = NO;
        [self.contentView addSubview:self.collectionView];
        
        frame = self.collectionView.frame;
        if (content)
            frame.origin.y = self.messageLabel.frame.origin.y + self.messageLabel.frame.size.height + 20/2;
        else
            frame.origin.y = self.profilePhoto.frame.origin.y + self.profilePhoto.frame.size.height + 10;
        
        frame.size = CGSizeMake(SCREEN_WIDTH - 15, 108);
        frame.origin.x = 15;
        self.collectionView.frame = frame;
    }
    
    
    
    /*
     Like button
     */
    
    NSString* likeStr = [NSString stringWithFormat:@"%@%d",NSLocalizedString(@"讚", nil),(int)[(NSNumber *)self.postInfo[@"likeCount"] intValue]];
    if (![[HXUserAccountManager manager].likeDic objectForKey:self.postInfo[@"id"]])
        self.likeButton = [[HXLikeCommentButton alloc]initWithTitle:likeStr tintColor:[UIColor color1] image:[UIImage imageNamed:@"unlike"]];
    else
        self.likeButton = [[HXLikeCommentButton alloc]initWithTitle:likeStr tintColor:[UIColor redColor] image:[UIImage imageNamed:@"like"]];
    
    self.likeButton.adjustsImageWhenHighlighted = NO;
    
    [self.likeButton setHighlighted:NO];
    self.likeButton.adjustsImageWhenDisabled = NO;
    
    if (self.postInfo[@"customFields"][@"photoUrls"]) {
        self.likeButton.frame = CGRectMake(15,
                                           self.collectionView.frame.origin.y + self.collectionView.bounds.size.height + 10,
                                           self.likeButton.bounds.size.width,
                                           self.likeButton.bounds.size.height);
    }else{
        self.likeButton.frame = CGRectMake(15,
                                           self.messageLabel.frame.origin.y + self.messageLabel.bounds.size.height + 10,
                                           self.likeButton.bounds.size.width,
                                           self.likeButton.bounds.size.height);
    }
    
    [self.likeButton addTarget:self action:@selector(likeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.likeButton];

    
    /*
     Comment button
     */
    //NSString *commentStr = [NSString stringWithFormat:@"留言%d",(int)[(NSNumber *)self.postInfo[@"commentCount"] intValue]];
    self.commentButton = [[HXLikeCommentButton alloc]initWithTitle:NSLocalizedString(@"留言", nil) tintColor:[UIColor color1] image:[UIImage imageNamed:@"comment"]];
    [self.commentButton addTarget:self action:@selector(commentButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.commentButton setFrame:CGRectMake(self.likeButton.frame.size.width + self.likeButton.frame.origin.x + 6,
                                            self.likeButton.frame.origin.y,
                                            self.commentButton.bounds.size.width,
                                            self.commentButton.bounds.size.height)];
    [self.contentView addSubview:self.commentButton];
    
    
}

-(void)commentButtonTapped
{
    
    HXCommentViewController *vc = [[HXCommentViewController alloc]initWithPostInfo:[self.postInfo mutableCopy]];
    [[self viewController].navigationController pushViewController:vc animated:YES];
}

- (void)likeButtonTapped
{
    self.likeButton.userInteractionEnabled = NO;
    
    if ([[HXUserAccountManager manager].likeDic objectForKey:self.postInfo[@"id"]])
        [self deleteLike];
    else
        [self createLike];
}

- (void)deleteLike
{

    NSString* likeStr = [NSString stringWithFormat:@"%@%d",NSLocalizedString(@"讚", nil),(int)[(NSNumber *)self.postInfo[@"likeCount"] intValue]-1];
    [self.likeButton updateTitle:likeStr tintColor:[UIColor color1] image:[UIImage imageNamed:@"unlike"]];
    
    if ([(NSNumber *)self.postInfo[@"likeCount"] integerValue] - 1)
        self.likeText.hidden = NO;
    else
        self.likeText.hidden = YES;
    
    NSDictionary *params = @{@"like_id":[[HXUserAccountManager manager].likeDic objectForKey:self.postInfo[@"id"]]};
    
    [[HXAnSocialManager manager]sendRequest:@"likes/delete.json" method:AnSocialManagerPOST params:params success:^(NSDictionary *response){
        NSLog(@"delete like :%@",[response description]);
        [[HXUserAccountManager manager].likeDic removeObjectForKey:self.postInfo[@"id"]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSInteger likeCount = [(NSNumber *)self.postInfo[@"likeCount"] intValue]-1;
            [[NSNotificationCenter defaultCenter]postNotificationName:UpdateLike object:@{@"index":self.index,
                                                                                          @"likeCount":[[NSNumber alloc] initWithInteger:likeCount]}];
            self.likeButton.userInteractionEnabled = YES;
        });
        
    } failure:^(NSDictionary *response){
        NSLog(@"fail to delete like :%@",[response description]);
    }];
}

- (void)createLike
{
    
    /* send notice */
    [[HXIMManager manager] sendSocialNoticeWithClientId:[NSSet setWithObject:self.postInfo[@"clientId"]] objectType:@"like" objectInfo:self.postInfo notificationAlert:[NSString stringWithFormat:@"%@ 在你的貼文點讚",[HXUserAccountManager manager].userInfo.userName]];
    
    NSString* likeStr = [NSString stringWithFormat:@"%@%d",NSLocalizedString(@"讚", nil),(int)[(NSNumber *)self.postInfo[@"likeCount"] intValue]+1];
    [self.likeButton updateTitle:likeStr tintColor:[UIColor redColor] image:[UIImage imageNamed:@"like"]];
    
    if ([(NSNumber *)self.postInfo[@"likeCount"] integerValue] + 1)
        self.likeText.hidden = NO;
    else
        self.likeText.hidden = YES;
    
    NSDictionary *customData = @{@"clientId":[HXUserAccountManager manager].clientId};
    
    NSDictionary *params = @{@"object_type": @"Post",
                             @"object_id": self.postInfo[@"id"],
                             @"like": @YES,
                             @"user_id":[HXUserAccountManager manager].userId,
                             @"custom_fields": customData};
    
    [[HXAnSocialManager manager]sendRequest:@"likes/create.json" method:AnSocialManagerPOST params:params success:^(NSDictionary *response){
        NSLog(@"create like :%@",[response description]);
        
        NSString *likeId = response[@"response"][@"like"][@"id"];
        [[HXUserAccountManager manager].likeDic setObject: likeId forKey:self.postInfo[@"id"]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSInteger likeCount = [(NSNumber *)self.postInfo[@"likeCount"] intValue]+1;
            [[NSNotificationCenter defaultCenter]postNotificationName:UpdateLike object:@{@"index":self.index,
                                                                                           @"likeCount":[[NSNumber alloc] initWithInteger:likeCount]}];
            self.likeButton.userInteractionEnabled = YES;
        });
        
    } failure:^(NSDictionary *response){
        NSLog(@"fail to create like :%@",[response description]);
    }];
}

- (void)removeLikeText
{
    [self.likeText removeFromSuperview];
}

- (void)removeCommentText
{
    [self.commentText removeFromSuperview];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    CGRect frame;
    frame = self.contentView.frame;
    
    self.contentView.frame = frame;

}

- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath
{
    if (!self.collectionView)return;
    
    self.collectionView.dataSource = dataSourceDelegate;
    self.collectionView.delegate = dataSourceDelegate;
    self.collectionView.indexPath = indexPath;
    [self.collectionView reloadData];
}

- (void)photoTapped
{
    HXUser * user = [UserUtil getHXUserByClientId:self.postInfo[@"clientId"]];
    HXFriendProfileViewController *vc = [[HXFriendProfileViewController alloc]initWithUserInfo:user withViewController:[self viewController]];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
    [[self viewController] presentViewController:nav animated:YES completion:nil];
    
}

- (void)setCellIndex:(NSIndexPath *)index
{
    self.index = index;
}

- (UIViewController*)viewController
{
    for (UIView* next = [self superview]; next; next = next.superview)
    {
        UIResponder* nextResponder = [next nextResponder];
        
        if ([nextResponder isKindOfClass:[UIViewController class]])
        {
            return (UIViewController*)nextResponder;
        }
    }
    
    return nil;
}
@end
