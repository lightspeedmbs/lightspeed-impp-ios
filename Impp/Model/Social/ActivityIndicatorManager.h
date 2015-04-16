//
//  ActivityIndicatorManager.h
//  IMChat
//
//  Created by Jefferson on 2015/1/8.
//  Copyright (c) 2015年 Herxun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface ActivityIndicatorManager : NSObject

+ (ActivityIndicatorManager *)manager;
- (void)activityStart;
- (void)activityEnd;
- (void)activityReset;
@end
