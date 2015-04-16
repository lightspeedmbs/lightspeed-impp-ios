//
//  ActivityIndicatorManager.m
//  IMChat
//
//  Created by Jefferson on 2015/1/8.
//  Copyright (c) 2015年 Herxun. All rights reserved.
//

#import "ActivityIndicatorManager.h"

@interface ActivityIndicatorManager ()
@property int activityCount;
@end

@implementation ActivityIndicatorManager

#pragma mark -

- (void)activityStart
{
    _activityCount++;
    //    NSLog(@"%i", activityCount);
    if (_activityCount > 0)
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
}

- (void)activityEnd
{
    _activityCount--;
    //    NSLog(@"%i", activityCount);
    if (_activityCount <= 0)
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        _activityCount = 0;
    }
}

- (void)activityReset
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    _activityCount = 0;
}

#pragma mark - Init

- (id)init
{
    self = [super init];
    if (self)
    {
        _activityCount = 0;
    }
    return self;
}

+ (ActivityIndicatorManager *)manager
{
    
    static ActivityIndicatorManager *_manager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _manager = [[ActivityIndicatorManager alloc] init];
    });
    return _manager;
}


@end
