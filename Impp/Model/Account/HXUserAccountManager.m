//
//  HXUserAccountManager.m
//  IMChat
//
//  Created by Herxun on 2015/1/8.
//  Copyright (c) 2015年 Herxun. All rights reserved.
//

#import "HXUserAccountManager.h"
#import "HXAnSocialManager.h"
#import "HXIMManager.h"

@interface HXUserAccountManager ()
@property (strong, nonatomic) NSMutableDictionary *clientIdToContactsInfoDic;
@end

@implementation HXUserAccountManager
#pragma mark - Init

+ (HXUserAccountManager *)manager
{
    static HXUserAccountManager *_manager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _manager = [[HXUserAccountManager alloc] init];
    });
    return _manager;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.likeDic = [[NSMutableDictionary alloc]initWithCapacity:0];
    }
    return self;
}

- (void)saveContactsIds:(NSArray *)contacts
{
    if (!self.clientIdToContactsInfoDic)
        self.clientIdToContactsInfoDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    [contacts enumerateObjectsUsingBlock:^(id contact, NSUInteger idx, BOOL *stop) {
        if (contact[@"clientId"])
            [self.clientIdToContactsInfoDic setObject:contact forKey:contact[@"clientId"]];
    }];
}

- (NSDictionary *)getContactInfoForClientId:(NSString *)clientId
{
    return self.clientIdToContactsInfoDic[clientId];
}

- (void)userSignedInWithId:(NSString *)userId name:(NSString *)name clientId:(NSString *)clientId
{
    self.userId = userId;
    self.userName = name;
    self.clientId = clientId;
    self.nickName = name;
    self.photoUrl = self.userInfo.photoURL;
    self.coverPhotoUrl = self.userInfo.coverPhotoURL;
    self.email = @"";

    [[HXAnSocialManager manager]fetchFriendInfo];
    [HXIMManager manager].isGetTopicList = NO;
    if (clientId)
    {
        [HXIMManager manager].clientId = [clientId mutableCopy];
        NSLog(@"CLIENT ID : %@", clientId);
        dispatch_async(dispatch_get_main_queue(), ^{
           [[HXIMManager manager] checkIMConnection];
        });
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:@{@"userId": userId ? userId : @"",
                                                       @"userName": name ? name : @"",
                                                       @"clientId": clientId ? clientId : @""}
                                              forKey:@"lastLoggedInUser"];
    

}

- (void)userSignedOut
{
    [[[HXIMManager manager]anIM] unbindAnPushService:AnPushTypeiOS];
    [[[HXIMManager manager]anIM] disconnect];
    self.userId = nil;
    self.userName = nil;
    self.clientId = nil;
    [HXIMManager manager].clientId = nil;
    self.userInfo = nil;
    [[NSUserDefaults standardUserDefaults] setObject:nil
                                              forKey:@"lastLoggedInUser"];
}
@end
