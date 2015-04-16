//
//  HXLike+Additions.m
//  Impp
//
//  Created by Herxun on 2015/4/7.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import "HXLike+Additions.h"
#import "CoreDataUtil.h"

@implementation HXLike(Additions)
+ (BOOL) isObjectAvailable:(id) data {
    return ((data != nil) && ![data isKindOfClass:[NSNull class]]);
}

+ (HXLike *)initWithDict:(NSDictionary *)dict
{
    HXLike *like = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class])
                                                       inManagedObjectContext:[CoreDataUtil sharedContext]];
    [like initAllAttributes];
    [like setValuesFromDict:dict];
    return like;
}

- (void)initAllAttributes
{
    self.created_at = @(0);
    self.parentId = @"";
    self.parentType = @"";
    self.postive = @(0);
    self.updated_at = @(0);
    self.likeId = @"";
    self.customFields = nil;
    self.post = nil;
    self.targetUser = nil;
    self.likeOwner = nil;
}

- (BOOL)setValuesFromDict:(NSDictionary *)dict
{
    if ([HXLike isObjectAvailable:dict[@"postive"]])
        self.postive = dict[@"postive"];
    
    if ([HXLike isObjectAvailable:dict[@"id"]])
        self.likeId = dict[@"id"];
    
    if ([HXLike isObjectAvailable:dict[@"customFields"]])
        self.customFields = dict[@"customFields"];
    
    if ([HXLike isObjectAvailable:dict[@"created_at"]]){
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.zzz'Z'"];
        NSDate* createdTime = [dateFormatter dateFromString:dict[@"created_at"]];
        self.created_at = [NSNumber numberWithDouble:[createdTime timeIntervalSince1970]*1000];
    }
    
    if ([HXLike isObjectAvailable:dict[@"updated_at"]]){
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.zzz'Z'"];
        NSDate* updatedTime = [dateFormatter dateFromString:dict[@"updated_at"]];
        self.updated_at = [NSNumber numberWithDouble:[updatedTime timeIntervalSince1970]*1000];
    }
    
    if ([HXLike isObjectAvailable:dict[@"parentId"]])
        self.parentId = dict[@"parentId"];
    
    if ([HXLike isObjectAvailable:dict[@"parentType"]])
        self.parentType = dict[@"parentType"];
    
    
    NSError *error;
    [[CoreDataUtil sharedContext] save:&error];
    if (error) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        return NO;
    }
    return YES;
}

- (NSDictionary *)toDict
{
    NSDictionary *dict = @{@"postive":self.postive,
                           @"created_at":self.created_at,
                           @"parentId":self.parentId,
                           @"parentType":self.parentType,
                           @"updated_at":self.updated_at,
                           @"likeId":self.likeId};
    return dict;
}
@end
