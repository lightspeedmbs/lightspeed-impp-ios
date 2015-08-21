//
//  ApiCaller.h
//  AnSocialTwo
//
//  Created by Tim on 10/27/14.
//  Copyright (c) 2014 Herxun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApiCaller : NSObject

+ (ApiCaller *)caller;
- (void)httpRequestWithMethod:(NSString *)method
                          url:(NSString *)urlString
                         body:(NSDictionary *)requestBody
                   attachment:(NSDictionary *)attachment
                   completion:(void (^)(BOOL success, NSDictionary *response, NSError *error))completion;

@end
