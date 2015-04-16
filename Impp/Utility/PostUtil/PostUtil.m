//
//  PostUtil.m
//  Impp
//
//  Created by Herxun on 2015/4/7.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import "PostUtil.h"
#import "CoreDataUtil.h"
#import "UserUtil.h"

#import "HXUser+Additions.h"
@implementation PostUtil

+ (HXPost *)getPostByPostId:(NSString *)postId
{
    NSArray* results =
    [CoreDataUtil getWithEntityName:NSStringFromClass([HXPost class])
                          predicate:[NSPredicate predicateWithFormat
                                     :@"postId == %@",postId]];
    
    if (results.count > 1) {
        NSLog(@"the result count should not > 1");
    }
    
    if (results.count > 0) {
        return results[0];
    } else
        return nil;
}

+ (HXPost *)savePostToDB:(NSDictionary *)postDic
{
    HXPost *post = [PostUtil getPostByPostId:postDic[@"id"]];
    if (post == nil) {
        post = [HXPost initWithDict:postDic];
    }else{
        [post setValuesFromDict:postDic];
    }
    
    HXUser *user = [UserUtil saveUserIntoDB:postDic[@"user"]];
    post.postOwner = user;
    
    NSError *error;
    [[CoreDataUtil sharedContext] save:&error];
    if (error) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    return post;
}
@end
