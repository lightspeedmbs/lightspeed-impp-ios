//
//  HXMessageTableViewCell.h
//  IMChat
//
//  Created by Herxun on 2015/1/28.
//  Copyright (c) 2015年 Herxun. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HXMessageCellDelegate <NSObject>
- (void)messageCellImageTapped:(NSInteger)index;
@end

@interface HXMessageTableViewCell : UITableViewCell
@property (weak, nonatomic) id<HXMessageCellDelegate> delegate;
@property (nonatomic) NSInteger tappedTag;
@property CGFloat height;
- (void)showSendingArrow;
- (void)removeSendingArrow;

+ (CGFloat)cellHeightForOwnerName:(NSString *)ownerName
                          message:(NSString *)message
                      messageType:(NSString *)messageType
                            image:(NSData *)image;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
          OwnerName:(NSString *)ownerName
       profileImage:(UIImage *)profileImage
            message:(NSString *)message
               date:(NSNumber *)date
               type:(NSString *)type
              image:(NSData *)image
            readACK:(BOOL)isRead;

- (void)reuseCellWithOwnerName:(NSString *)ownerName
                  profileImage:(UIImage *)profileImage
         profileImageUrlString:(NSString *)profileImageUrlString
                       message:(NSString *)message
                          date:(NSNumber *)date
                          type:(NSString *)type
                         image:(NSData *)image
                       readACK:(BOOL)isRead;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
          OwnerName:(NSString *)ownerName
profileImageUrlString:(NSString *)profileImageUrlString
            message:(NSString *)message
               date:(NSNumber *)date
               type:(NSString *)type
              image:(NSData *)image
            readACK:(BOOL)isRead;

@end
