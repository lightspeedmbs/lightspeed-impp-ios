//
//  HXPost+Additions.m
//  Impp
//
//  Created by Herxun on 2015/4/7.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import "HXPost+Additions.h"
#import "CoreDataUtil.h"
@implementation HXPost(Additions)

+ (BOOL) isObjectAvailable:(id) data {
    return ((data != nil) && ![data isKindOfClass:[NSNull class]]);
}

+ (HXPost *)initWithDict:(NSDictionary *)dict
{
    HXPost *post = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class])
                                                       inManagedObjectContext:[CoreDataUtil sharedContext]];
    [post initAllAttributes];
    [post setValuesFromDict:dict];
    return post;
}

- (void)initAllAttributes
{
    self.commentCount = @(0);
    self.commentRate = @(0);
    self.content = @"";
    self.customFields = nil;
    self.likeCount = @(0);
    self.created_at = @(0);
    self.dislikeCount = @(0);
    self.parentId = @"";
    self.parentType = @"";
    self.photoUrls = nil;
    self.updated_at = @(0);
    self.postId = @"";
    self.postOwner = nil;
    self.title = @"";
    self.type = @"";
    self.comments = nil;
    self.likes = nil;
    self.postOwner = nil;
}

- (BOOL)setValuesFromDict:(NSDictionary *)dict
{
    if ([HXPost isObjectAvailable:dict[@"commentCount"]])
        self.commentCount = dict[@"commentCount"];
    
    if ([HXPost isObjectAvailable:dict[@"commentRate"]])
        self.commentRate = dict[@"commentRate"];
    
    if ([HXPost isObjectAvailable:dict[@"content"]])
        self.content = dict[@"content"];
    
    if ([HXPost isObjectAvailable:dict[@"customFields"]])
        self.customFields = [NSKeyedArchiver archivedDataWithRootObject:dict[@"customFields"]];
    
    if ([HXPost isObjectAvailable:dict[@"created_at"]]){
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.zzz'Z'"];
        NSDate* createdTime = [dateFormatter dateFromString:dict[@"created_at"]];
        self.created_at = [NSNumber numberWithDouble:[createdTime timeIntervalSince1970]*1000];
    }
    
    if ([HXPost isObjectAvailable:dict[@"updated_at"]]){
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.zzz'Z'"];
        NSDate* updatedTime = [dateFormatter dateFromString:dict[@"updated_at"]];
        self.updated_at = [NSNumber numberWithDouble:[updatedTime timeIntervalSince1970]*1000];
    }
    
    if ([HXPost isObjectAvailable:dict[@"dislikeCount"]])
        self.dislikeCount = dict[@"dislikeCount"];
    
    if ([HXPost isObjectAvailable:dict[@"likeCount"]])
        self.likeCount = dict[@"likeCount"];
    
    if ([HXPost isObjectAvailable:dict[@"parentId"]])
        self.parentId = dict[@"parentId"];
    
    if ([HXPost isObjectAvailable:dict[@"parentType"]])
        self.parentType = dict[@"parentType"];
    
    if ([HXPost isObjectAvailable:dict[@"imageIds"]])
        self.photoUrls = [NSKeyedArchiver archivedDataWithRootObject:dict[@"imageIds"]];
    
    if ([HXPost isObjectAvailable:dict[@"type"]])
        self.type = dict[@"type"];
    
    if ([HXPost isObjectAvailable:dict[@"title"]])
        self.title = dict[@"title"];
    
    if ([HXPost isObjectAvailable:dict[@"id"]])
        self.postId = dict[@"id"];
    
    
    NSError *error;
    [[CoreDataUtil sharedContext] save:&error];
    if (error) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        return NO;
    }
    return YES;
}

- (NSDictionary *)getCustomFields
{
    if (self.customFields) {
        NSDictionary *customFields = [NSKeyedUnarchiver unarchiveObjectWithData:self.customFields];
        
        if (!customFields[@"photoUrls"])return [[NSDictionary alloc]init];
        
        NSArray *photoUrls = [customFields[@"photoUrls"] componentsSeparatedByString:@","];
        return @{@"photoUrls":photoUrls};
    }
    return [[NSDictionary alloc]init];
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
                           @"id":self.postId,
                           @"customFields":[self getCustomFields]};
    return dict;
}
@end
