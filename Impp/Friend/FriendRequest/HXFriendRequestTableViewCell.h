//
//  HXFriendRequestTableViewCell.h
//  Impp
//
//  Created by Herxun on 2015/3/24.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol HXFriendRequestTableViewCellDelegate <NSObject>
@optional
- (void)didApproveButtonTappedWithRequestId:(NSString *)requestId targetClientId:(NSString *)clientId targetUserId:(NSString *)userId;
- (void)didRejectButtonTappedWithRequestId:(NSString *)requestId;
@end

@interface HXFriendRequestTableViewCell : UITableViewCell

@property (weak, nonatomic) id<HXFriendRequestTableViewCellDelegate> delegate;
- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
           userInfo:(NSDictionary *)userInfo;

- (void)reuseCellWithUserInfo:(NSDictionary *)userInfo;
@end
