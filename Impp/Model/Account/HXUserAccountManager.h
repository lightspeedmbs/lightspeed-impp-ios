//
//  HXUserAccountManager.h
//  IMChat
//
//  Created by Herxun on 2015/1/8.
//  Copyright (c) 2015年 Herxun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HXUser+Additions.h"

@interface HXUserAccountManager : NSObject
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *nickName;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *clientId;
@property (strong, nonatomic) NSString *photoUrl;
@property (strong, nonatomic) NSString *coverPhotoUrl;
@property (strong, nonatomic) NSMutableDictionary *likeDic;
@property (strong, nonatomic) NSDictionary *clientStatus;
@property (strong, nonatomic) HXUser *userInfo;

+ (HXUserAccountManager *)manager;
- (void)saveContactsIds:(NSArray *)contacts;
- (NSDictionary *)getContactInfoForClientId:(NSString *)clientId;
- (void)userSignedInWithId:(NSString *)userId name:(NSString *)name clientId:(NSString *)clientId;
- (void)userSignedOut;
@end
