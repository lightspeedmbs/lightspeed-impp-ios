//
//  HXAnSocialManager.h
//  IMChat
//
//  Created by Jefferson on 2015/1/8.
//  Copyright (c) 2015年 Herxun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AnIM.h"

typedef enum {
    AnSocialManagerGET,
    AnSocialManagerPOST
} AnSocialManagerMethod;

@interface HXAnSocialManager : NSObject

+ (HXAnSocialManager *)manager;
- (void)sendRequest:(NSString *)path
             method:(AnSocialManagerMethod)method
             params:(NSDictionary *)params
            success:(void (^)(NSDictionary *response))success
            failure:(void (^)(NSDictionary *response))failure;

- (void)uploadPhotoToServer:(NSData *)imageData
                    Success:(void (^)(NSDictionary *response))success
                    failure:(void (^)(NSDictionary *response))failure;

- (void)fetchFriendInfo;

- (NSString *)getFriendUserIds;
@end
