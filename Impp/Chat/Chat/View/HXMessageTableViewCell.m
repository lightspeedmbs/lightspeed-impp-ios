//
//  HXMessageTableViewCell.m
//  IMChat
//
//  Created by Herxun on 2015/1/28.
//  Copyright (c) 2015年 Herxun. All rights reserved.
//

#import "HXMessageTableViewCell.h"
#import "HXAppUtility.h"
#import <SDWebImage/UIImageView+WebCache.h>
#define SENT_MESSAGE_BACKGROUND_OFFSET    20
#define SENT_BINARY_BACKGROUND_OFFSET     10
#define SENT_MESSAGE_TEXTVIEW_OFFSET       6
#define SENT_MESSAGE_TEXTVIEW_Y            0
#define SENT_MESSAGE_TEXTVIEW_X            5

#define RECEIVE_MESSAGE_TEXTVIEW_Y        50/2
#define RECEIVE_MESSAGE_TEXTVIEW_X        10
#define RECEIVE_BINARY_BACKGROUND_OFFSET  18/2 + 20/2 + 5
#define LABEL_WIDTH_OFFSET 20
#define LABEL_X_OFFSET 8
@interface HXMessageTableViewCell ()
@property (strong, nonatomic) NSString *ownerName;
@property (strong, nonatomic) NSString *messageType;
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) UIImage *userPhoto;
@property (strong, nonatomic) NSNumber *date;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *readAckLabel;
@property (strong, nonatomic) UILabel *messageTextView;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UIImageView *messageBackground;
@property (strong, nonatomic) UIImageView *bubbleDot;
@property (strong, nonatomic) UIImageView *binaryDataImage;
@property (strong, nonatomic) UIImageView *photo;
@property (strong, nonatomic) UIImageView *photoMask;
@property (strong, nonatomic) NSData *imageData;
@property (strong, nonatomic) NSString *userPhotoUrlString;
@property (strong, nonatomic) UIImageView *sendingArrow;
@property BOOL isRead;
@end

@implementation HXMessageTableViewCell

+ (CGFloat)cellHeightForOwnerName:(NSString *)ownerName message:(NSString *)message messageType:(NSString *)messageType image:(NSData *)image
{
    if ([messageType isEqualToString:@"text"]) {
        
        UILabel *messageLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 50/2, 352/2, 30/2)];
        messageLabel.text = message;
        messageLabel.font = [UIFont fontWithName:@"STHeitiTC-Light" size:30/2];
        messageLabel.numberOfLines = 0;
        [messageLabel sizeToFit];
        
        if (ownerName) {
            return messageLabel.frame.size.height + 50/2 + 10;
        }else
            return messageLabel.frame.size.height + 20;
    }else if ([messageType isEqualToString:@"location"] || [messageType isEqualToString:@"record"])
    {
        if (ownerName) {
            return 30 + RECEIVE_BINARY_BACKGROUND_OFFSET;
        }else
            return 30 + SENT_BINARY_BACKGROUND_OFFSET;
    }else {
        
        UIImageView *binaryImage = [HXMessageTableViewCell resizedPhotoImageView:[[UIImageView alloc]initWithImage:[UIImage imageWithData:image]]];
        if (ownerName) {
            return binaryImage.frame.size.height + RECEIVE_BINARY_BACKGROUND_OFFSET + 10;
        }else
            return binaryImage.frame.size.height + SENT_BINARY_BACKGROUND_OFFSET + 10;
    }
    return 60;
    
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
          OwnerName:(NSString *)ownerName
profileImageUrlString:(NSString *)profileImageUrlString
            message:(NSString *)message
               date:(NSNumber *)date
               type:(NSString *)type
              image:(NSData *)image
            readACK:(BOOL)isRead
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.ownerName = ownerName;
        self.message = [message isKindOfClass:[NSNull class]] ? @"": message;
        self.date = date;
        self.messageType = type;
        self.imageData = image;
        self.isRead = isRead;
        self.userPhotoUrlString = profileImageUrlString;
        [self initView];
    }
    return self;
}


- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
          OwnerName:(NSString *)ownerName
       profileImage:(UIImage *)profileImage
            message:(NSString *)message
               date:(NSNumber *)date
               type:(NSString *)type
              image:(NSData *)image
            readACK:(BOOL)isRead
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.ownerName = ownerName;
        self.message = [message isKindOfClass:[NSNull class]] ? @"": message;
        self.date = date;
        self.messageType = type;
        self.imageData = image;
        self.isRead = isRead;
        self.userPhoto = profileImage;
        [self initView];
    }
    return self;
}

- (void)initView
{
    CGRect frame;
    
    self.messageTextView = [[UILabel alloc]initWithFrame:CGRectMake(14, 50/2, 352/2, 30/2)];
    self.messageTextView.text = self.message;
    self.messageTextView.font = [UIFont fontWithName:@"STHeitiTC-Light" size:30/2];
    self.messageTextView.textColor = [HXAppUtility hexToColor:0x58595b alpha:1];
    self.messageTextView.backgroundColor = [UIColor clearColor];
    self.messageTextView.numberOfLines = 0;
    [self.messageTextView sizeToFit];
    
    if (![self.messageType isEqualToString:@"text"]) {

        self.binaryDataImage = [self binaryImageView];
        
        UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped)];
        [self.binaryDataImage addGestureRecognizer:imageTap];
        self.binaryDataImage.userInteractionEnabled = YES;
        
        if ([self.messageType isEqualToString:@"record"] || [self.messageType isEqualToString:@"location"])
        {
            frame = self.binaryDataImage.frame;
            frame.size.width = 90;
            frame.size.height = 25;
            self.binaryDataImage.frame = frame;
        }
        frame = self.binaryDataImage.frame;
        frame.origin.x = self.ownerName ? 14 : 10;
        frame.origin.y = 10 + (self.ownerName ? self.bubbleDot.bounds.size.height +4 : 0);
        self.binaryDataImage.frame = frame;
    }
    
    // ===============
    
    
    if (self.ownerName) {
        // With owner name
        // Other user chat bubble
        
        self.height = self.messageTextView.frame.size.height + 50/2 + 10;
        
        self.photoMask = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"contact_mask"]];
        self.photoMask.frame = CGRectMake(0, 0, self.photoMask.frame.size.width, self.photoMask.frame.size.height);
        [self addSubview:self.photoMask];
        
        self.photo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"friend_default"]];
        self.photo.frame = CGRectMake(12,0,36,36);
        self.photo.layer.cornerRadius = self.photo.bounds.size.width/2;
        self.photo.clipsToBounds = YES;
        
        if (self.userPhotoUrlString)
        {
            if (![self.userPhotoUrlString isEqualToString:@""]) {
                SDWebImageManager *manager = [SDWebImageManager sharedManager];
                [manager downloadWithURL:[NSURL URLWithString:self.userPhotoUrlString]
                                 options:0
                                progress:^(NSInteger receivedSize, NSInteger expectedSize){}
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished){
                                   if (image) {
                                       self.photo.image = image;
                                       self.photo.contentMode = UIViewContentModeScaleAspectFill;
                                   }
                                   
                               }];
            }
        }
        else if (self.userPhoto)
        {
            self.photo.image = self.userPhoto;

        }
        
        [self addSubview:self.photo];
        //[self bringSubviewToFront:self.photoMask];
        
        self.bubbleDot = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bubble_dot"]];
        frame = self.bubbleDot.frame;
        frame.origin.y = 16/2;
        frame.origin.x = 14;
        frame.size.width = 8;
        frame.size.height = 11;
        self.bubbleDot.frame = frame;
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(16,
                                                                   18/2,
                                                                   100,
                                                                   20.0f/2)];
        self.nameLabel.text = self.ownerName;
        self.nameLabel.font = [UIFont fontWithName:@"STHeitiTC-Light" size:20.0f/2];
        self.nameLabel.textColor = [HXAppUtility hexToColor:0x58595b alpha:1];
        self.nameLabel.numberOfLines = 1;
        [self.nameLabel sizeToFit];
        

        
        UIImage *backgroundImage = [UIImage imageNamed:@"bubble_left"];
        self.messageBackground  = [[UIImageView alloc] init];
        self.messageBackground.image = backgroundImage;
        frame = self.messageBackground.frame;
        frame.origin.x = self.photo.frame.origin.x + self.photo.frame.size.width +6;
        
        if ([self.messageType isEqualToString:@"location"] || [self.messageType isEqualToString:@"record"]) {
            
            // Location/ voice
            // Other user
            // New cell
            frame = self.messageBackground.frame;
            frame.origin.x = self.photo.frame.origin.x + self.photo.frame.size.width +6;
            frame.size.width = 90 +14 +10;
            frame.size.height = 10 +10 +self.bubbleDot.bounds.size.height +4 +self.binaryDataImage.bounds.size.height;
            self.messageBackground.frame = frame;
            
            [self addSubview:self.messageBackground];
            [self.messageBackground addSubview:self.binaryDataImage];
            
            self.height = 30 + RECEIVE_BINARY_BACKGROUND_OFFSET;
            
        }else if ([self.messageType isEqualToString:@"image"]) {
            
            // Image binary
            // Other user
            // New cell
            
            frame.size.height = self.binaryDataImage.frame.size.height +10 *2 +self.bubbleDot.bounds.size.height +4;
            frame.size.width = self.binaryDataImage.frame.size.width +14 +10;
            self.messageBackground.frame = frame;
            frame = self.binaryDataImage.frame;
            frame.origin.y = 10 + self.bubbleDot.bounds.size.height +4;
            self.binaryDataImage.frame = frame;
            [self addSubview:self.messageBackground];
            [self.messageBackground addSubview:self.binaryDataImage];
            
            self.height = self.binaryDataImage.frame.size.height + RECEIVE_BINARY_BACKGROUND_OFFSET + 10;
        }else{
            
            // Text
            // Other user
            // New cell
            
            frame.size.height = 10*2 + self.messageTextView.frame.size.height +4 +self.nameLabel.bounds.size.height;
            frame.size.width = MAX(self.messageTextView.frame.size.width, self.nameLabel.bounds.size.width + self.bubbleDot.bounds.size.width) +14 +10;
            
            self.messageBackground.frame = frame;
            [self addSubview:self.messageBackground];
            [self.messageBackground addSubview:self.messageTextView];
        }
        
        [self.messageBackground addSubview:self.nameLabel];
        //[self.messageBackground addSubview:self.bubbleDot];
        
        if ([self.date integerValue] != 0)
        {
            NSDate *updatetimestamp = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)[self.date doubleValue]/1000];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"a"];
            
            NSString *timeHint = [dateFormatter stringFromDate:updatetimestamp];
            
            if ([timeHint isEqualToString:@"AM"])
                timeHint = NSLocalizedString(@"上午", nil);
            else if ([timeHint isEqualToString:@"PM"])
                timeHint = NSLocalizedString(@"下午", nil);
            
            [dateFormatter setDateFormat:@"hh:mm"];
            NSString *timestamp = [dateFormatter stringFromDate:updatetimestamp];
            
            self.timeLabel = [[UILabel alloc] init];
            self.timeLabel.text = [NSString stringWithFormat:@"%@ %@",timeHint,timestamp];
            self.timeLabel.font = [UIFont fontWithName:@"STHeitiTC-Light" size:20.0f/2];
            self.timeLabel.textColor = [HXAppUtility hexToColor:0x999999 alpha:1];
            self.timeLabel.numberOfLines = 1;
            [self.timeLabel sizeToFit];
            frame = self.timeLabel.frame;
            frame.origin.y = self.messageBackground.frame.origin.y + self.messageBackground.bounds.size.height - frame.size.height;
            frame.origin.x = self.messageBackground.frame.origin.x + self.messageBackground.bounds.size.width + 12.0f/2;
            self.timeLabel.frame = frame;
            [self addSubview:self.timeLabel];
        }
        
    }else{
        // No owner name
        // Local user chat bubble
        
        self.height = self.messageTextView.frame.size.height + 20;
        
        self.messageTextView.textColor = [UIColor whiteColor];
        frame = self.messageTextView.frame;
        frame.origin.y = 10;
        frame.origin.x = 10;
        self.messageTextView.frame = frame;
        
        
        UIImage *backgroundImage = [UIImage imageNamed:@"bubble_right"];
        self.messageBackground = [[UIImageView alloc]initWithImage:backgroundImage];
        frame = self.messageBackground.frame;
        
        if ([self.messageType isEqualToString:@"location"] || [self.messageType isEqualToString:@"record"]) {
            
            // Localtion/ voice
            // Local user
            // New cell
            frame = self.messageBackground.frame;
            frame.origin.x =
            frame.size.width = 90 +14 +10;
            frame.size.height = 10 +10 +self.binaryDataImage.bounds.size.height;
            self.messageBackground.frame = frame;
            
            [self addSubview:self.messageBackground];
            [self.messageBackground addSubview:self.binaryDataImage];
            
            self.height = 30 + SENT_BINARY_BACKGROUND_OFFSET;
            
        }else if ([self.messageType isEqualToString:@"image"]) {
            
            // Image binary
            // Local user
            // New cell
            
            frame.size.height = self.binaryDataImage.frame.size.height +10 *2;
            frame.size.width = self.binaryDataImage.frame.size.width +14 +10;
            self.messageBackground.frame = frame;
            [self addSubview:self.messageBackground];
            [self.messageBackground addSubview:self.binaryDataImage];
        
            self.height = self.binaryDataImage.frame.size.height + SENT_BINARY_BACKGROUND_OFFSET + 10;
        }else{
            
            // Text
            // Local user
            // New cell
            frame = self.messageTextView.frame;
            
            frame.origin.x = 10;
            frame.origin.y = 10;
            self.messageTextView.frame = frame;
            [self.messageBackground addSubview:self.messageTextView];
            frame = self.messageBackground.frame;
            frame.size.height = self.messageTextView.frame.size.height + 10 *2;
            frame.size.width = self.messageTextView.frame.size.width +14 +10;
            self.messageBackground.frame = frame;
            [self addSubview:self.messageBackground];

        }
        
        frame = self.messageBackground.frame;
        frame.origin.x = [UIScreen mainScreen].bounds.size.width -12 -self.messageBackground.frame.size.width;
        self.messageBackground.frame = frame;
        
        if ([self.date integerValue] != 0)
        {
            NSDate *updatetimestamp = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)[self.date doubleValue]/1000];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"a"];
            
            NSString *timeHint = [dateFormatter stringFromDate:updatetimestamp];
            
            if ([timeHint isEqualToString:@"AM"])
                timeHint = NSLocalizedString(@"上午", nil);
            else if ([timeHint isEqualToString:@"PM"])
                timeHint = NSLocalizedString(@"下午", nil);
            
            [dateFormatter setDateFormat:@"hh:mm"];
            NSString *timestamp = [dateFormatter stringFromDate:updatetimestamp];
            
            self.timeLabel = [[UILabel alloc] init];
            self.timeLabel.text = [NSString stringWithFormat:@"%@ %@",timeHint,timestamp];
            self.timeLabel.font = [UIFont fontWithName:@"STHeitiTC-Light" size:20.0f/2];
            self.timeLabel.textColor = [HXAppUtility hexToColor:0x999999 alpha:1];
            self.timeLabel.numberOfLines = 1;
            [self.timeLabel sizeToFit];
            frame = self.timeLabel.frame;
            frame.origin.y = self.messageBackground.frame.origin.y + self.messageBackground.bounds.size.height - frame.size.height;
            frame.origin.x = self.messageBackground.frame.origin.x - frame.size.width - 12.0f/2;
            self.timeLabel.frame = frame;
            [self addSubview:self.timeLabel];
        }
        
        self.readAckLabel = [[UILabel alloc] init];
        self.readAckLabel.text = NSLocalizedString(@"已讀", nil);
        self.readAckLabel.font = [UIFont fontWithName:@"STHeitiTC-Light" size:20.0f/2];
        self.readAckLabel.textColor = [HXAppUtility hexToColor:0x999999 alpha:1];
        self.readAckLabel.numberOfLines = 1;
        [self.readAckLabel sizeToFit];
        frame = self.readAckLabel.frame;
        frame.origin.x = self.messageBackground.frame.origin.x - 12/2 - frame.size.width;
        frame.origin.y = self.messageBackground.frame.size.height - 50/2;
        self.readAckLabel.frame = frame;
        [self addSubview:self.readAckLabel];
        
        if (self.isRead)
            self.readAckLabel.hidden = NO;
        else
            self.readAckLabel.hidden = YES;
    }
    
    self.messageBackground.userInteractionEnabled = YES;
}

- (void)reuseCellWithOwnerName:(NSString *)ownerName
                  profileImage:(UIImage *)profileImage
         profileImageUrlString:(NSString *)profileImageUrlString
                       message:(NSString *)message
                          date:(NSNumber *)date
                          type:(NSString *)type
                         image:(NSData *)image
                       readACK:(BOOL)isRead
{
    CGRect frame;
    self.isRead = isRead;
    self.messageType = type;
    self.ownerName = ownerName;
    self.date = date;
    self.imageData = image;
    self.userPhoto = profileImage;
    self.userPhotoUrlString = profileImageUrlString;
    
    self.messageTextView.text = message;
    self.messageTextView.frame = CGRectMake(14, 50/2, 352/2, 30/2);
    [self.messageTextView sizeToFit];
    [self.messageTextView layoutIfNeeded];
    
    if (![self.messageType isEqualToString:@"text"]) {
        if (!self.binaryDataImage) {
//            self.binaryDataImage = [[UIImageView alloc]initWithImage:[self binaryImage]];
            self.binaryDataImage = [self binaryImageView];
        }
        else
        {
            self.binaryDataImage = [self binaryImageView];

        }
        
        if ([self.messageType isEqualToString:@"record"] || [self.messageType isEqualToString:@"location"])
        {
            frame = self.binaryDataImage.frame;
            frame.size.width = 90;
            frame.size.height = 25;
            self.binaryDataImage.frame = frame;
        }
        
        UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped)];
        [self.binaryDataImage addGestureRecognizer:imageTap];
        self.binaryDataImage.userInteractionEnabled = YES;

        frame = self.binaryDataImage.frame;
        frame.origin.x = self.ownerName ? 14 : 10;
        frame.origin.y = 10 + (self.ownerName ? self.bubbleDot.bounds.size.height +4 : 0);
        self.binaryDataImage.frame = frame;
    }
    
    
    
    // ===============
    
    if (self.ownerName) {
        // Got owner name
        // Other user
        // Reuse cell
        
        if (self.readAckLabel) {
            self.readAckLabel.hidden = YES;
        }
        
        self.messageTextView.textColor = [HXAppUtility hexToColor:0x58595b alpha:1];

    
        if (!self.photo) {
            self.photo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"friend_default"]];
            self.photo.frame = CGRectMake(12,0,36,36);
            self.photo.layer.cornerRadius = self.photo.bounds.size.width/2;
            self.photo.clipsToBounds = YES;
            [self addSubview:self.photo];
        }
        if (self.userPhoto)
        {
            
            self.photo.image = self.userPhoto;
        }
        if (self.userPhotoUrlString) {
            
            if (![self.userPhotoUrlString isEqualToString:@""]) {
                SDWebImageManager *manager = [SDWebImageManager sharedManager];
                [manager downloadWithURL:[NSURL URLWithString:self.userPhotoUrlString]
                                 options:0
                                progress:^(NSInteger receivedSize, NSInteger expectedSize){}
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished){
                                   if (image) {
                                       self.photo.image = image;
                                       self.photo.contentMode = UIViewContentModeScaleAspectFill;
                                   }
                                   
                               }];
            }
            
        }
        
        
        self.photo.hidden = NO;
        self.photoMask.hidden = NO;
        
        if (!self.bubbleDot) {
            self.bubbleDot = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bubble_dot"]];
            frame = self.bubbleDot.frame;
            frame.origin.y = 16/2;
            frame.origin.x = 14;
            frame.size.width = 8;
            frame.size.height = 11;
            self.bubbleDot.frame = frame;
        }
        
        if (!self.nameLabel) {
            self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(16,
                                                                       18/2, 100, 20.0f/2)];
            self.nameLabel.text = self.ownerName;
            self.nameLabel.font = [UIFont fontWithName:@"STHeitiTC-Light" size:20.0f/2];
            self.nameLabel.textColor = [HXAppUtility hexToColor:0x58595b alpha:1];
            self.nameLabel.numberOfLines = 1;
            [self.nameLabel sizeToFit];
        }else{
            self.nameLabel.text = self.ownerName;
            [self.nameLabel sizeToFit];
        }
            
        UIImage *backgroundImage = [UIImage imageNamed:@"bubble_left"];
        if (!self.messageBackground)
            self.messageBackground  = [[UIImageView alloc] init];
        self.messageBackground.image = backgroundImage;
        frame = self.messageBackground.frame;
        frame.origin.x = self.photo.frame.origin.x + self.photo.frame.size.width +6;
        
        [[self.messageBackground subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        if ([self.messageType isEqualToString:@"location"] || [self.messageType isEqualToString:@"record"]) {
            
            // Location / voice
            // Other user
            // Reuse cell
            
            frame = self.messageBackground.frame;
            frame.origin.x = self.photo.frame.origin.x + self.photo.frame.size.width +6;
            frame.size.width = 90 +14 +10;
            frame.size.height = 10 +10 +self.bubbleDot.bounds.size.height +4 +self.binaryDataImage.bounds.size.height;
            self.messageBackground.frame = frame;
                        
            [self addSubview:self.messageBackground];
            [self.messageBackground addSubview:self.binaryDataImage];
            
        }else if ([self.messageType isEqualToString:@"image"]) {
            
            // Image binary
            // Other user
            // Reuse cell
            
            frame.size.height = self.binaryDataImage.frame.size.height +10 *2 +self.bubbleDot.bounds.size.height +4;
            frame.size.width = self.binaryDataImage.frame.size.width +14 +10;
            self.messageBackground.frame = frame;
            frame = self.binaryDataImage.frame;
            frame.origin.y = 10 + self.bubbleDot.bounds.size.height +4;
            self.binaryDataImage.frame = frame;
            [self addSubview:self.messageBackground];
            [self.messageBackground addSubview:self.binaryDataImage];
            
            
        }else{
            // Text
            // Other user
            // Reuse cell

            frame.size.height = 10*2 + self.messageTextView.frame.size.height +4 +self.nameLabel.bounds.size.height;
            frame.size.width = MAX(self.messageTextView.frame.size.width, self.nameLabel.bounds.size.width + self.bubbleDot.bounds.size.width) +14 +10;

            self.messageBackground.frame = frame;
            [self addSubview:self.messageBackground];
            [self.messageBackground addSubview:self.messageTextView];
        }
        
        [self.messageBackground addSubview:self.nameLabel];
        //[self.messageBackground addSubview:self.bubbleDot];
        
        if ([self.date integerValue] != 0)
        {
            NSDate *updatetimestamp = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)[self.date doubleValue]/1000];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"a"];
            
            NSString *timeHint = [dateFormatter stringFromDate:updatetimestamp];
            
            if ([timeHint isEqualToString:@"AM"])
                timeHint = NSLocalizedString(@"上午", nil);
            else if ([timeHint isEqualToString:@"PM"])
                timeHint = NSLocalizedString(@"下午", nil);
            
            [dateFormatter setDateFormat:@"hh:mm"];
            NSString *timestamp = [dateFormatter stringFromDate:updatetimestamp];
            
            self.timeLabel.text = [NSString stringWithFormat:@"%@ %@",timeHint,timestamp];
            [self.timeLabel sizeToFit];
            frame = self.timeLabel.frame;
            frame.origin.y = self.messageBackground.frame.origin.y + self.messageBackground.bounds.size.height - frame.size.height;
            frame.origin.x = self.messageBackground.frame.origin.x + self.messageBackground.bounds.size.width + 12.0f/2;
            self.timeLabel.frame = frame;
        }
        
    }else{
        // No owner name
        // Local user bubble
        
        if (self.photo ) {
            self.photo.hidden = YES;
        }
        
        self.messageTextView.textColor = [UIColor whiteColor];
        frame = self.messageTextView.frame;
        frame.origin.y = 5;
        frame.origin.x = 0;
        self.messageTextView.frame = frame;
        
        UIImage *backgroundImage = [UIImage imageNamed:@"bubble_right"];
        self.messageBackground.image = backgroundImage;
        frame = self.messageBackground.frame;
        
        [[self.messageBackground subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        if ([self.messageType isEqualToString:@"location"] || [self.messageType isEqualToString:@"record"]) {
        
            // Location / voice
            // Local user
            // Reuse cell
                    
            frame = self.messageBackground.frame;
            frame.size.width = 90 +14 +10;
            frame.size.height = 10 +10 +self.binaryDataImage.bounds.size.height;
            self.messageBackground.frame = frame;
            [self addSubview:self.messageBackground];
            [self.messageBackground addSubview:self.binaryDataImage];
            
        }else if ([self.messageType isEqualToString:@"image"]) {
            
            // Image binary
            // Local user
            // Reuse cell
            

            
            frame.size.height = self.binaryDataImage.frame.size.height +10 *2;
            frame.size.width = self.binaryDataImage.frame.size.width +14 +10;
            self.messageBackground.frame = frame;
            [self addSubview:self.messageBackground];
            [self.messageBackground addSubview:self.binaryDataImage];

            
        }else{
            // Text
            // Local user
            // Reuse cell
            frame = self.messageTextView.frame;
            
            frame.origin.x = 10;
            frame.origin.y = 10;
            self.messageTextView.frame = frame;
            [self.messageBackground addSubview:self.messageTextView];
            frame = self.messageBackground.frame;
            frame.size.height = self.messageTextView.frame.size.height + 10 *2;
            frame.size.width = self.messageTextView.frame.size.width +14 +10;
            self.messageBackground.frame = frame;
            [self addSubview:self.messageBackground];
        }
        
        frame = self.messageBackground.frame;
        frame.origin.x = self.frame.size.width - 26/2 - self.messageBackground.frame.size.width;
        self.messageBackground.frame = frame;
        
        if ([self.date integerValue] != 0)
        {
            NSDate *updatetimestamp = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)[self.date doubleValue]/1000];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"a"];
            
            NSString *timeHint = [dateFormatter stringFromDate:updatetimestamp];
            
            if ([timeHint isEqualToString:@"AM"])
                timeHint = NSLocalizedString(@"上午", nil);
            else if ([timeHint isEqualToString:@"PM"])
                timeHint = NSLocalizedString(@"下午", nil);
            
            [dateFormatter setDateFormat:@"hh:mm"];
            NSString *timestamp = [dateFormatter stringFromDate:updatetimestamp];
            
            self.timeLabel.text = [NSString stringWithFormat:@"%@ %@",timeHint,timestamp];
            [self.timeLabel sizeToFit];
            frame = self.timeLabel.frame;
            frame.origin.y = self.messageBackground.frame.origin.y + self.messageBackground.bounds.size.height - frame.size.height;
            frame.origin.x = self.messageBackground.frame.origin.x - frame.size.width - 12.0f/2;
            self.timeLabel.frame = frame;
        }
        
        if (!self.readAckLabel) {
            self.readAckLabel = [[UILabel alloc] init];
            self.readAckLabel.text = NSLocalizedString(@"已讀", nil);
            self.readAckLabel.font = [UIFont fontWithName:@"STHeitiTC-Light" size:20.0f/2];
            self.readAckLabel.textColor = [HXAppUtility hexToColor:0x999999 alpha:1];
            self.readAckLabel.numberOfLines = 1;
            [self.readAckLabel sizeToFit];
            [self addSubview:self.readAckLabel];
        }
        frame = self.readAckLabel.frame;
        frame.origin.x = self.messageBackground.frame.origin.x - 12/2 - frame.size.width;
        frame.origin.y = self.messageBackground.frame.size.height - 50/2;
        self.readAckLabel.frame = frame;
        
        if (self.isRead)
            self.readAckLabel.hidden = NO;
        else
            self.readAckLabel.hidden = YES;
    }
}

- (UIImage *)binaryImage
{
    if ([self.messageType isEqualToString:@"location"]) {
        
        if (self.ownerName)
            return [UIImage imageNamed:@"location_receive"];
        else
            return [UIImage imageNamed:@"location_deliver"];
        
    }else if ([self.messageType isEqualToString:@"record"]) {
        
        if (self.ownerName)
        {
            return [UIImage imageNamed:@"voice_receive"];
        }
        else
        {
            return [UIImage imageNamed:@"voice_deliver"];
        }
    }else {
        UIImage *image = [UIImage imageWithData:self.imageData];
        
        return [HXMessageTableViewCell resizedImage:image];
    }
    
}

- (UIImageView *)binaryImageView
{
    if ([self.messageType isEqualToString:@"location"]) {
        
        if (self.ownerName)
            return [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"location_receive"]];
        else
            return [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"location_deliver"]];
        
    }else if ([self.messageType isEqualToString:@"record"]) {
        
        if (self.ownerName)
        {
            return [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"voice_receive"]];
        }
        else
        {
            return [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"voice_deliver"]];
        }
    }else {
        UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageWithData:self.imageData]];
        
        return [HXMessageTableViewCell resizedPhotoImageView:imageView];
    }
    
}

+ (UIImage *)resizedImage:(UIImage *)image
{
    if (image.size.height > image.size.width) {
        if (image.size.width<200/2) {
            image = [HXAppUtility imageWithImage:image scaledToSize:CGSizeMake(200/2, 200/2)];
        }else
            image = [HXAppUtility imageWithImage:image scaledToSize:CGSizeMake(image.size.width*100/image.size.height, 200/2)];
    }else if(image.size.height < image.size.width){
        if (image.size.height<200/2) {
            image = [HXAppUtility imageWithImage:image scaledToSize:CGSizeMake(200/2,200/2)];
        }else
            image = [HXAppUtility imageWithImage:image scaledToSize:CGSizeMake(200/2, image.size.height*100/image.size.width)];
    }else {
        image = [HXAppUtility imageWithImage:image scaledToSize:CGSizeMake(200/2, 200/2)];
    }
    return image;
}

+ (UIImageView *)resizedPhotoImageView:(UIImageView *)imageView
{
    CGRect frame = imageView.frame;
    if (frame.size.height > frame.size.width) {
        if (frame.size.width<200/2) {
            frame.size = CGSizeMake(200/2, 200/2);
        }else
            frame.size = CGSizeMake(frame.size.width*100/frame.size.height, 200/2);
    }else if(frame.size.height < frame.size.width){
        if (frame.size.height<200/2) {
            frame.size = CGSizeMake(200/2,200/2);
        }else
            frame.size = CGSizeMake(200/2, frame.size.height*100/frame.size.width);
    }else {
        frame.size = CGSizeMake(200/2, 200/2);
    }
    imageView.frame = frame;
    return imageView;
}

- (void)imageTapped
{
    if (self.delegate) {
        [self.delegate messageCellImageTapped:self.tappedTag];
    }
}

#pragma mark - Public

- (void)showSendingArrow
{
    if (!self.sendingArrow)
        self.sendingArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"send_arrow"]];
    CGRect frame = self.sendingArrow.frame;
    frame.origin.x = self.timeLabel.frame.origin.x - frame.size.width;
    frame.origin.y = self.timeLabel.frame.origin.y;
    self.sendingArrow.frame = frame;
    [self addSubview:self.sendingArrow];
}

- (void)removeSendingArrow
{
    [self.sendingArrow removeFromSuperview];
}

@end
