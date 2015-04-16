//
//  CommentUtil.m
//  Impp
//
//  Created by Herxun on 2015/4/7.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import "CommentUtil.h"
#import "CoreDataUtil.h"
#import "UserUtil.h"
#import "PostUtil.h"

#import "HXUser+Additions.h"

@implementation CommentUtil

+ (HXComment *)getCommentByCommentId:(NSString *)commentId
{
    NSArray* results =
    [CoreDataUtil getWithEntityName:NSStringFromClass([HXComment class])
                          predicate:[NSPredicate predicateWithFormat
                                     :@"commentId == %@",commentId]];
    
    if (results.count > 1) {
        NSLog(@"the result count should not > 1");
    }
    
    if (results.count > 0) {
        return results[0];
    } else
        return nil;
}

+ (HXComment *)saveCommentToDB:(NSDictionary *)commentDic postId:(NSString *)postId
{
    HXComment *comment = [CommentUtil getCommentByCommentId:commentDic[@"id"]];
    if (comment == nil) {
        comment = [HXComment initWithDict:commentDic];
        HXUser *user = [UserUtil saveUserIntoDB:commentDic[@"user"]];
        comment.commentOwner = user;
        
        if (commentDic[@"replyUser"]) {
            HXUser *targetUser = [UserUtil saveUserIntoDB:commentDic[@"replyUser"]];
            comment.targetUser = targetUser;
        }
        
        HXPost *post = [PostUtil getPostByPostId:postId];
        comment.post = post;
        
    }else{
        [comment setValuesFromDict:commentDic];
    }
    
    
    NSError *error;
    [[CoreDataUtil sharedContext] save:&error];
    if (error) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    return comment;
}
@end
