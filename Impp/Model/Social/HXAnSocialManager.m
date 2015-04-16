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
        [self.anSocial setSecureConnection:YES];
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
        
    }failure:^(NSDictionary* response){
        NSLog(@"Error: %@", [[response objectForKey:@"meta"] objectForKey:@"message"]);
        
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
