//
//  HXChat+Additions.m
//  IMChat
//
//  Created by Herxun on 2015/1/15.
//  Copyright (c) 2015年 Herxun. All rights reserved.
//

#import "HXChat+Additions.h"
#import "CoreDataUtil.h"

@implementation HXChat(Additions)

+ (BOOL) isObjectAvailable:(id) data {
    return ((data != nil) && ![data isKindOfClass:[NSNull class]]);
}

+ (HXChat *)initWithDict:(NSDictionary *)dict
{
    HXChat *chat = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class])
                                                 inManagedObjectContext:[CoreDataUtil sharedContext]];
    [chat initAllAttributes];
    [chat setValuesFromDict:dict];
    return chat;
}

- (void)initAllAttributes
{
    self.topicName = @"";
    self.topicId = @"";
    self.targetClientId = @"";
    self.targetUserName = @"";
    self.currentClientId = @"";
    self.currentUserName = @"";
    self.lastMsgId = @"";
    self.updatedTimestamp = @(0);
    self.messages = [NSSet set];
    self.users = [NSSet set];
    self.topicOwner = nil;
}

- (BOOL)setValuesFromDict:(NSDictionary *)dict
{
    if ([HXChat isObjectAvailable:dict[@"topicName"]])
        self.topicName = dict[@"topicName"];
    
    if ([HXChat isObjectAvailable:dict[@"topicId"]])
        self.topicId = dict[@"topicId"];

    if ([HXChat isObjectAvailable:dict[@"targetClientId"]])
        self.targetClientId = dict[@"targetClientId"];
    
    if ([HXChat isObjectAvailable:dict[@"targetUserName"]])
        self.targetUserName = dict[@"targetUserName"];
    
    if ([HXChat isObjectAvailable:dict[@"currentClientId"]])
        self.currentClientId = dict[@"currentClientId"];
    
    if ([HXChat isObjectAvailable:dict[@"currentUserName"]])
        self.currentUserName = dict[@"currentUserName"];
    
    if ([HXChat isObjectAvailable:dict[@"lastMsgId"]])
        self.lastMsgId = dict[@"lastMsgId"];
    
    if ([HXChat isObjectAvailable:dict[@"updatedTimestamp"]])
        self.updatedTimestamp = dict[@"updatedTimestamp"];
    
    if ([HXChat isObjectAvailable:dict[@"messages"]])
        self.messages = dict[@"messages"];
    
    if ([HXChat isObjectAvailable:dict[@"users"]])
        self.users = dict[@"users"];
    
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
    NSDictionary *dict = @{@"topicName":self.topicName,
                           @"topicId":self.topicId,
                           @"targetClientId":self.targetClientId,
                           @"targetUserName":self.targetUserName,
                           @"currentUserName":self.currentUserName,
                           @"currentClientId":self.currentClientId,
                           @"lastMsgId":self.lastMsgId,
                           @"updatedTimestamp":self.updatedTimestamp};
    return dict;
}
@end
