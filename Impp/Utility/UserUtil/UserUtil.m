//
//  UserUtil.m
//  IMChat
//
//  Created by Herxun on 2015/1/15.
//  Copyright (c) 2015年 Herxun. All rights reserved.
//

#import "UserUtil.h"
#import "ChatUtil.h"
#import "HXUserAccountManager.h"
#import "HXIMManager.h"
@implementation UserUtil

+ (HXUser *)getHXUserByUserId:(NSString *)userId
{
    NSArray* results =
    [CoreDataUtil getWithEntityName:@"HXUser"
                          predicate:[NSPredicate predicateWithFormat
                                     :@"%K == %@", @"userId", userId]];
    if (results.count > 0) {
#ifdef DEBUG
        if (results.count > 1) { // the result count should not > 1
            //abort();
        }
#endif
        return results[0];
    } else
        return nil;
}

+ (HXUser *)getHXUserByUserId:(NSString *)userId currentUserId:(NSString *)currentUserId
{
    NSArray* results =
    [CoreDataUtil getWithEntityName:@"HXUser"
                          predicate:[NSPredicate predicateWithFormat
                                     :@"userId == %@ && currentUserId == %@",userId ,currentUserId]];
    if (results.count > 0) {
#ifdef DEBUG
        if (results.count > 1) { // the result count should not > 1
            //abort();
        }
#endif
        return results[0];
    } else
        return nil;
}

+ (HXUser *)getHXUserByClientId:(NSString *)clientId currentUserId:(NSString *)currentUserId
{
    NSArray* results =
    [CoreDataUtil getWithEntityName:@"HXUser"
                          predicate:[NSPredicate predicateWithFormat
                                     :@"clientId == %@ && currentUserId == %@",clientId ,currentUserId]];
    if (results.count > 0) {
#ifdef DEBUG
        if (results.count > 1) { // the result count should not > 1
            //abort();
        }
#endif
        return results[0];
    } else
        return nil;
}

+ (HXUser *)getHXUserByClientId:(NSString *)clientId
{
    NSArray* results =
    [CoreDataUtil getWithEntityName:@"HXUser"
                          predicate:[NSPredicate predicateWithFormat
                                     :@"%K == %@", @"clientId", clientId]];
    if (results.count > 0) {
#ifdef DEBUG
        if (results.count > 1) { // the result count should not > 1
            //abort();
        }
#endif
        return results[0];
    } else
        return nil;
}

+ (void)removeAllFriendsWithCurrentUser:(HXUser *)currentUser
{
    [currentUser removeFriends:currentUser.friends];
}

+ (void)removeAllFollowsWithCurrentUser:(HXUser *)currentUser
{
    
}

+ (void)updatedUserFriendsWithCurrentUser:(HXUser *)currentUser targetUser:(HXUser *)targetUser
{
    if (![self checkFriendRelationshipWithCurrentUser:currentUser targetUser:targetUser]) {
        [currentUser addFriendsObject:targetUser];
    }
    
    /* update followRelationship into friendRelationship */
    if ([self checkFollowRelationshipWithCurrentUser:currentUser targetUser:targetUser]) {
        [currentUser removeFollowsObject:targetUser];
    }
    
    NSError *error;
    if (![[CoreDataUtil sharedContext] save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}

+ (void)updatedUserFollowsWithCurrentUser:(HXUser *)currentUser targetUser:(HXUser *)targetUser
{
    if (![self checkFollowRelationshipWithCurrentUser:currentUser targetUser:targetUser]) {
        [currentUser addFollowsObject:targetUser];
        NSError *error;
        if (![[CoreDataUtil sharedContext] save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }
}

+ (BOOL)checkFriendRelationshipWithCurrentUser:(HXUser *)currentUser targetUser:(HXUser *)targetUser
{
    return [[currentUser.friends valueForKey:@"objectID"] containsObject:[targetUser valueForKey:@"objectID"]];
}

+ (BOOL)checkFollowRelationshipWithCurrentUser:(HXUser *)currentUser targetUser:(HXUser *)targetUser
{
    return [[currentUser.follows valueForKey:@"objectID"] containsObject:[targetUser valueForKey:@"objectID"]];
}

+ (BOOL)checkFriendRelationshipWithCliendId:(NSString *)clientId
{
    //HXUser *currentUser = [UserUtil getHXUserByClientId:[HXIMManager manager].clientId];
    NSArray* results =
    [CoreDataUtil getWithEntityName:NSStringFromClass([HXUser class])
                          predicate:[NSPredicate predicateWithFormat:
                                     @"clientId == %@ AND ANY friends.clientId == %@",
                                     [HXIMManager manager].clientId, clientId]];
    
    
    if (results.count > 1) {
        NSLog(@"more than one result, must be somthing wrong.");
    }
    
    return (results.count > 0);
}

+ (BOOL)checkFollowRelationshipWithCliendId:(NSString *)clientId
{
    //HXUser *currentUser = [UserUtil getHXUserByClientId:[HXIMManager manager].clientId];
    NSArray* results =
    [CoreDataUtil getWithEntityName:NSStringFromClass([HXUser class])
                          predicate:[NSPredicate predicateWithFormat:
                                     @"clientId == %@ AND ANY follows.clientId == %@",
                                     [HXIMManager manager].clientId, clientId]];
    
    
    if (results.count > 1) {
        NSLog(@"more than one result, must be somthing wrong.");
    }
    
    return (results.count > 0);
}

+ (NSString *)getUserPhotoUrlByClientId:(NSString *)clientId
{
    NSArray* results =
    [CoreDataUtil getWithEntityName:@"HXUser"
                          predicate:[NSPredicate predicateWithFormat
                                     :@"%K == %@", @"clientId", clientId]];
    if (results.count > 0) {
#ifdef DEBUG
        if (results.count > 1) { // the result count should not > 1
            //abort();
        }
#endif
        HXUser *user = results[0];
        return user.photoURL;
    } else
        return nil;
}

+ (HXUser *)insertUserWithDic:(NSDictionary *)user
{
    NSDictionary *reformedUser = [UserUtil reformUserInfoDic:user];
    HXUser *hxUser = [HXUser initWithDict:reformedUser];
    return hxUser;
}

+ (HXUser *)saveUserIntoDB:(NSDictionary *)userInfo
{
    /* save user info into DB */
    NSDictionary *reformedUser = [UserUtil reformUserInfoDic:userInfo];

    HXUser *hxUser = [UserUtil getHXUserByClientId:reformedUser[@"clientId"]];
    
    if (hxUser == nil) {
        hxUser = [HXUser initWithDict:reformedUser];
    }else{
        //update
        [hxUser setValuesFromDict:reformedUser];
    }
    return hxUser;
}

+ (void)removeTopic:(HXChat *)topic from:(NSString *)clientId
{
    [[UserUtil getHXUserByClientId:clientId] removeTopicsObject:topic];
    NSError *error;
    if (![[CoreDataUtil sharedContext] save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}

+ (void)removeTopicWithTopicIds:(NSSet *)topicIds from:(NSString *)clientId
{
    /* topics -> id*/
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT(topicId IN  %@)", topicIds];
    HXUser *currentUser = [UserUtil getHXUserByClientId:clientId];
    NSSet *removeTopics = [currentUser.topics filteredSetUsingPredicate:predicate];
    
    if (removeTopics && removeTopics.count) {
        
        [currentUser removeTopics:removeTopics];
        for (HXChat *chat in removeTopics){
            [ChatUtil deleteChat:chat];
        }
        
        NSError *error;
        if (![[CoreDataUtil sharedContext] save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }
    
}

+ (NSDictionary *)reformUserInfoDic:(NSDictionary *)userInfo
{
    NSDictionary* dict = @{@"userName":userInfo[@"username"],
                           @"userId":userInfo[@"id"],
                           @"clientId":userInfo[@"clientId"] ?userInfo[@"clientId"] : @"",
                           @"photoId":userInfo[@"photo"][@"id"] ? userInfo[@"photo"][@"id"] : @"",
                           @"photoURL":userInfo[@"photo"][@"url"] ? userInfo[@"photo"][@"url"] : @"",
                           @"coverPhotoURL":userInfo[@"customFields"][@"coverPhotoURL"]?userInfo[@"customFields"][@"coverPhotoURL"] : @""};
    return dict;
}
@end
