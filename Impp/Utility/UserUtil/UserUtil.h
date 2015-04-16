//
//  UserUtil.h
//  IMChat
//
//  Created by Herxun on 2015/1/15.
//  Copyright (c) 2015年 Herxun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataUtil.h"
#import "HXUser+Additions.h"
@interface UserUtil : NSObject

+ (HXUser *)getHXUserByUserId:(NSString *)userId;
+ (HXUser *)getHXUserByClientId:(NSString *)clientId;
+ (HXUser *)getHXUserByUserId:(NSString *)userId currentUserId:(NSString *)currentUserId;
+ (HXUser *)insertUserWithDic:(NSDictionary *)user;

+ (void)updatedUserFriendsWithCurrentUser:(HXUser *)currentUser targetUser:(HXUser *)targetUser;
+ (void)updatedUserFollowsWithCurrentUser:(HXUser *)currentUser targetUser:(HXUser *)targetUser;
+ (void)removeAllFriendsWithCurrentUser:(HXUser *)currentUser;
+ (void)removeAllFollowsWithCurrentUser:(HXUser *)currentUser;
+ (BOOL)checkFriendRelationshipWithCurrentUser:(HXUser *)currentUser targetUser:(HXUser *)targetUser;
+ (BOOL)checkFollowRelationshipWithCurrentUser:(HXUser *)currentUser targetUser:(HXUser *)targetUser;
+ (BOOL)checkFriendRelationshipWithCliendId:(NSString *)clientId;
+ (BOOL)checkFollowRelationshipWithCliendId:(NSString *)clientId;

+ (HXUser *)saveUserIntoDB:(NSDictionary *)userInfo;
+ (NSDictionary *)reformUserInfoDic:(NSDictionary *)userInfo;
+ (NSString *)getUserPhotoUrlByClientId:(NSString *)clientId;
+ (void)removeTopic:(HXChat *)topic from:(NSString *)clientId;
+ (void)removeTopicWithTopicIds:(NSSet *)topicIds from:(NSString *)clientId;
@end
