//
//  HXAnSocialManager.m
//  IMChat
//
//  Created by Jefferson on 2015/1/8.
//  Copyright (c) 2015年 Herxun. All rights reserved.
//

#import "HXAnSocialManager.h"
#import "AnSocial.h"
#import "AnIMMessage.h"
#import "LightspeedCredentials.h"
#import "ActivityIndicatorManager.h"
#import "AppDelegate.h"
#import "HXUser+Additions.h"
#import "UserUtil.h"
#import "HXUserAccountManager.h"
#import "NotificationCenterUtil.h"
#import "AnSocialFile.h"
#import "HXIMManager.h"
#import "MessageUtil.h"

@interface HXAnSocialManager () <AnIMDelegate>
@property (strong, nonatomic) AnSocial *anSocial;
@property BOOL connecting;
@end

@implementation HXAnSocialManager
#pragma mark - Init

+ (HXAnSocialManager *)manager
{
    static HXAnSocialManager *_manager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _manager = [[HXAnSocialManager alloc] init];
    });
    return _manager;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.anSocial = [[AnSocial alloc] initWithAppKey:LIGHTSPEED_APP_KEY];
        [self.anSocial setTimeout:20.0f];
        
    }
    return self;
}

#pragma mark - Public

- (void)sendRequest:(NSString *)path
             method:(AnSocialManagerMethod)method
             params:(NSDictionary *)params
            success:(void (^)(NSDictionary *response))success
            failure:(void (^)(NSDictionary *response))failure
{
    int methodInt = method;
    
    [[ActivityIndicatorManager manager] activityStart];
    [self.anSocial sendRequest:path
                        method:methodInt
                        params:params
                       success:^(NSDictionary *response) {
                           [[ActivityIndicatorManager manager] activityEnd];
                           success(response);
                       } failure:^(NSDictionary *response) {
                           [[ActivityIndicatorManager manager] activityEnd];
                           failure(response);
                       }];
}

- (void)fetchFriendInfo
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@99 forKey:@"limit"];
    [params setObject:[HXUserAccountManager manager].userId forKey:@"user_id"];
    
    [[HXAnSocialManager manager]sendRequest:@"friends/list.json" method:AnSocialManagerGET params:params success:^(NSDictionary* response){
        
        NSLog(@"success log: %@",[response description]);
        NSMutableArray *tempfriends = [[NSMutableArray alloc]initWithCapacity:0];
        NSMutableArray *tempUserArray = [[NSMutableArray alloc]initWithCapacity:0];
        tempfriends = [[NSArray arrayWithArray:[[response objectForKey:@"response"] objectForKey:@"friends"]] mutableCopy];
        
        NSMutableSet *userClientIds = [[NSMutableSet alloc]initWithCapacity:0];
        
        /* To sync with server*/
        dispatch_async(dispatch_get_main_queue(), ^{
            for (NSDictionary *user in tempfriends)
            {
                
                NSDictionary *reformedUser = [UserUtil reformUserInfoDic:user];
                
                HXUser *hxUser = [UserUtil getHXUserByUserId:reformedUser[@"userId"]];
                
                if (hxUser == nil) {
                    hxUser = [HXUser initWithDict:reformedUser];
                }else{
                    //update
                    [hxUser setValuesFromDict:reformedUser];
                }
                
                /* Detect remote user "isMutual" flag*/
                if ([(NSNumber *)user[@"friendProperties"][@"isMutual"] intValue] == 1) {
                    [UserUtil updatedUserFriendsWithCurrentUser:[HXUserAccountManager manager].userInfo targetUser:hxUser];
                }else{
                    [UserUtil updatedUserFollowsWithCurrentUser:[HXUserAccountManager manager].userInfo targetUser:hxUser];
                }
                
                [userClientIds addObject:hxUser.clientId];
                
                //NSLog(@"%@",hxUser.photoURL);
                [tempUserArray addObject:hxUser];
                //[[HXImageStore imageStore]setImageUrl:hxUser.photoURL forKey:hxUser.clientId];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:RefreshFriendList object:nil];

        });
        
    }failure:^(NSDictionary* response){
        NSLog(@"Error: %@", [[response objectForKey:@"meta"] objectForKey:@"message"]);
        
    }];
}

// Add the default friend
- (void)addDefaultFriend:(NSString *)currentUserId
{
    if(!LIGHTSPEED_DEFAULT_FRIEND_ID || [LIGHTSPEED_DEFAULT_FRIEND_ID isEqualToString:currentUserId])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[HXAnSocialManager manager]fetchFriendInfo];
        });
        return;
    }
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:LIGHTSPEED_DEFAULT_FRIEND_ID forKey:@"user_ids"];
    
    [[HXAnSocialManager manager]sendRequest:@"users/get.json" method:AnSocialManagerGET params:params success:^(NSDictionary* response){
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"success log users/get.json: %@",[response description]);
            NSMutableArray *tempUsers = [[NSMutableArray alloc]initWithCapacity:0];
            NSMutableArray *tempUserArray = [[NSMutableArray alloc]initWithCapacity:0];
            tempUsers = [[NSArray arrayWithArray:[[response objectForKey:@"response"] objectForKey:@"users"]] mutableCopy];
            if (tempUsers.count == 0) {
                NSLog(@"add default friend error: default friend is not existed.");
                [[HXAnSocialManager manager]fetchFriendInfo];
                return;
            }
            
            NSMutableSet *userClientIds = [[NSMutableSet alloc]initWithCapacity:0];
            HXUser *currentUser = [UserUtil getHXUserByUserId:currentUserId];
            NSSet *currentUserFriends = currentUser.friends;
            for (NSDictionary *user in tempUsers)
            {
                NSDictionary *defaultFriendDic = [UserUtil reformUserInfoDic:user];
                HXUser *defaultFriend = [UserUtil getHXUserByUserId:defaultFriendDic[@"userId"]];
                if (defaultFriend == nil) {
                    defaultFriend = [HXUser initWithDict:defaultFriendDic];
                }else{
                    //update
                    [defaultFriend setValuesFromDict:defaultFriendDic];
                }
                
                if ([currentUserFriends containsObject:defaultFriend]) {
                    NSLog(@"add default friend. default friend is already added.");
                    [[HXAnSocialManager manager]fetchFriendInfo];
                    return;
                }
                NSMutableDictionary *currentUserAddArrownockParams = [[NSMutableDictionary alloc] init];
                [currentUserAddArrownockParams setObject:currentUserId forKey:@"user_id"];
                [currentUserAddArrownockParams setObject:defaultFriend.userId forKey:@"target_user_id"];
                [[HXAnSocialManager manager]sendRequest:@"friends/add.json" method:AnSocialManagerPOST params:currentUserAddArrownockParams success:^(NSDictionary *response) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSMutableDictionary *arrownockAddCurrentUserParams = [[NSMutableDictionary alloc] init];
                        [arrownockAddCurrentUserParams setObject:currentUserId forKey:@"target_user_id"];
                        [arrownockAddCurrentUserParams setObject:defaultFriend.userId forKey:@"user_id"];
                        
                        [[HXAnSocialManager manager]sendRequest:@"friends/add.json" method:AnSocialManagerPOST params:arrownockAddCurrentUserParams success:^(NSDictionary *response) {
                            NSLog(@"success log arrownockAddCurrentUserParams: %@",[response description]);
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                //在本地将Default friend加为好友
                                [UserUtil updatedUserFollowsWithCurrentUser:[HXUserAccountManager manager].userInfo targetUser:defaultFriend];
                                //添加Default friend发来的一条消息
                                NSDate *datenow = [NSDate date];
                                long long timeSp =(long long)[datenow timeIntervalSince1970];
                                timeSp = timeSp * 1000;
                                NSMutableDictionary *customData = [[NSMutableDictionary alloc] init];
                                [customData setObject:defaultFriend.userName forKey:@"name"];
                                NSString *message = NSLocalizedString(@"welcome_message_from_default_user", nil);
                                AnIMMessage *customMessage = [[AnIMMessage alloc]initWithType:AnIMTextMessage
                                                                                        msgId:@"100000000"
                                                                                      topicId:@""
                                                                                      message:message
                                                                                      content:nil
                                                                                     fileType:nil
                                                                                         from:defaultFriend.clientId
                                                                                   customData:customData
                                                                                    timestamp:[NSNumber numberWithLongLong:timeSp]];
                                
                                HXMessage *hxCustomMessage = [MessageUtil anIMMessageToHXMessage:customMessage];
                                [MessageUtil saveChatMessageIntoDB:@[customMessage] withTargetClientId:hxCustomMessage.from];
                                NSLog(@"saveWelcomeChatMessageIntoDB succ.");
                                [[HXAnSocialManager manager]fetchFriendInfo];
                            });
                            
                        } failure:^(NSDictionary *response) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [[HXAnSocialManager manager]fetchFriendInfo];
                                NSLog(@"addDefaultFriend Error: %@", [[response objectForKey:@"meta"] objectForKey:@"message"]);
                            });
                        }];
                    });
                } failure:^(NSDictionary *response) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[HXAnSocialManager manager]fetchFriendInfo];
                        NSLog(@"addDefaultFriend Error: %@", [[response objectForKey:@"meta"] objectForKey:@"message"]);
                    });
                }];
            }
        });
    }failure:^(NSDictionary* response){
        dispatch_async(dispatch_get_main_queue(), ^{
            [[HXAnSocialManager manager]fetchFriendInfo];
            NSLog(@"addDefaultFriend Error: %@", [[response objectForKey:@"meta"] objectForKey:@"message"]);
        });
    }];
}

- (void)uploadPhotoToServer:(NSData *)imageData
                    Success:(void (^)(NSDictionary *response))success
                    failure:(void (^)(NSDictionary *response))failure
{
    AnSocialFile *imageFile = [AnSocialFile createWithFileName:@"photo"
                                                          data:imageData];
    //NSDictionary *customData = @{@"clientId":[HXUserAccountManager manager].clientId};
    NSDictionary *params = @{@"photo":imageFile,
                             @"user_id":[HXUserAccountManager manager].userId};
    
    [[HXAnSocialManager manager]sendRequest:@"photos/create.json" method:AnSocialManagerPOST params:params success:^(NSDictionary* response){
        success(response);
        NSLog(@"post data :%@",[response description]);
    }failure:^(NSDictionary* response){
        failure(response);
        NSLog(@"fail to post data :%@",[response description]);
    }];
    
    
    
}

- (NSString *)getFriendUserIds
{
    HXUser *currentUser = [UserUtil getHXUserByClientId:[HXIMManager manager].clientId];
    NSSet *friends = currentUser.friends;
    NSMutableString* userIdList = [[NSMutableString alloc] init];
    [userIdList setString:currentUser.userId];
    
    for (HXUser *friend in friends){
        [userIdList appendString:[NSString stringWithFormat:@",%@",friend.userId]];
    }
    NSLog(@"userId List: %@",userIdList);
    
    return [userIdList mutableCopy];
}

@end
