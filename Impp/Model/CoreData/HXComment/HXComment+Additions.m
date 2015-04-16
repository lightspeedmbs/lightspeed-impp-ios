//
//  HXComment+Additions.m
//  Impp
//
//  Created by Herxun on 2015/4/7.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import "HXComment+Additions.h"
#import "CoreDataUtil.h"
@implementation HXComment(Additions)

+ (BOOL) isObjectAvailable:(id) data {
    return ((data != nil) && ![data isKindOfClass:[NSNull class]]);
}

+ (HXComment *)initWithDict:(NSDictionary *)dict
{
    HXComment *comment = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class])
                                                 inManagedObjectContext:[CoreDataUtil sharedContext]];
    [comment initAllAttributes];
    [comment setValuesFromDict:dict];
    return comment;
}

- (void)initAllAttributes
{
    self.commentCount = @(0);
    self.commentRate = @(0);
    self.content = @"";
    self.created_at = @(0);
    self.dislikeCount = @(0);
    self.likeCount = @(0);
    self.parentId = @"";
    self.parentType = @"";
    self.updated_at = @(0);
    self.commentId = @"";
    self.commentOwner = nil;
    self.post = nil;
    self.targetUser = nil;
}

- (BOOL)setValuesFromDict:(NSDictionary *)dict
{
    if ([HXComment isObjectAvailable:dict[@"commentCount"]])
        self.commentCount = dict[@"commentCount"];
    
    if ([HXComment isObjectAvailable:dict[@"commentRate"]])
        self.commentRate = dict[@"commentRate"];
    
    if ([HXComment isObjectAvailable:dict[@"content"]])
        self.content = dict[@"content"];
    
    if ([HXComment isObjectAvailable:dict[@"created_at"]]){
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.zzz'Z'"];
        NSDate* createdTime = [dateFormatter dateFromString:dict[@"created_at"]];
        self.created_at = [NSNumber numberWithDouble:[createdTime timeIntervalSince1970]*1000];
    }
    
    if ([HXComment isObjectAvailable:dict[@"updated_at"]]){
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.zzz'Z'"];
        NSDate* updatedTime = [dateFormatter dateFromString:dict[@"updated_at"]];
        self.updated_at = [NSNumber numberWithDouble:[updatedTime timeIntervalSince1970]*1000];
    }
    
    if ([HXComment isObjectAvailable:dict[@"dislikeCount"]])
        self.dislikeCount = dict[@"dislikeCount"];
    
    if ([HXComment isObjectAvailable:dict[@"likeCount"]])
        self.likeCount = dict[@"likeCount"];
    
    if ([HXComment isObjectAvailable:dict[@"parentId"]])
        self.parentId = dict[@"parentId"];
    
    if ([HXComment isObjectAvailable:dict[@"parentType"]])
        self.parentType = dict[@"parentType"];
    
    if ([HXComment isObjectAvailable:dict[@"id"]])
        self.commentId = dict[@"id"];

    
//    NSError *error;
//    [[CoreDataUtil sharedContext] save:&error];
//    if (error) {
//        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
//        return NO;
//    }
    return YES;
}

- (NSDictionary *)toDict
{
    NSDictionary *dict = @{@"commentCount":self.commentCount,
                           @"commentRate":self.commentRate,
                           @"content":self.content,
                           @"created_at":self.created_at,
                           @"dislikeCount":self.dislikeCount,
                           @"likeCount":self.likeCount,
                           @"parentId":self.parentId,
                           @"parentType":self.parentType,
                           @"updated_at":self.updated_at,
                           @"commentId":self.commentId};
    return dict;
}

@end
