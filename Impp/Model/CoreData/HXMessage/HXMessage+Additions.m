//
//  HXMessage+Additions.m
//  IMChat
//
//  Created by Herxun on 2015/1/15.
//  Copyright (c) 2015年 Herxun. All rights reserved.
//

#import "HXMessage+Additions.h"
#import "CoreDataUtil.h"

@implementation HXMessage(Additions)

+ (BOOL) isObjectAvailable:(id) data {
    return ((data != nil) && ![data isKindOfClass:[NSNull class]]);
}

+(HXMessage *)initWithDict:(NSDictionary *)dict
{
    HXMessage *message = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class])
                                                       inManagedObjectContext:[CoreDataUtil sharedContext]];
    
    [message initAllAttributes];
    [message setValuesFromDict:dict];
    return message;
}

+(HXMessage *)createTempObjectWithDict:(NSDictionary *)dict
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([self class])
                                              inManagedObjectContext:[CoreDataUtil sharedContext]];
    HXMessage *message = [[HXMessage alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
    [message initAllAttributes];
    [message setValuesFromDictWithoutSaved:dict];
    return message;
    
}

- (void)initAllAttributes
{
    self.type = @"";
    self.msgId = @"";
    self.topicId = @"";
    self.message = @"";
    self.content = nil;
    self.from = @"";
    self.timestamp = @(0);
    self.readACK = @(NO);
    self.senderName = @"";
    self.userId = @"";
    self.currentClientId = @"";
    self.fileURL = @"";
    self.latitude = @(999.0f);
    self.longitude = @(999.0f);
    self.processStatus = STATUS_CREATE;
    self.chat = nil;
}

- (BOOL)setValuesFromDict:(NSDictionary *)dict
{
    if ([HXMessage isObjectAvailable:dict[@"type"]])
        self.type = dict[@"type"];
    
    if ([HXMessage isObjectAvailable:dict[@"msgId"]])
        self.msgId = dict[@"msgId"];
    
    if ([HXMessage isObjectAvailable:dict[@"topicId"]])
        self.topicId = dict[@"topicId"];
    
    if ([HXMessage isObjectAvailable:dict[@"message"]])
        self.message = dict[@"message"];
    
    if ([HXMessage isObjectAvailable:dict[@"content"]])
        self.content = dict[@"content"];
    
    if ([HXMessage isObjectAvailable:dict[@"from"]])
        self.from = dict[@"from"];
    
    if ([HXMessage isObjectAvailable:dict[@"timestamp"]])
        self.timestamp = dict[@"timestamp"];
    
    if ([HXMessage isObjectAvailable:dict[@"readACK"]])
        self.readACK = dict[@"readACK"];
    
    if ([HXMessage isObjectAvailable:dict[@"senderName"]])
        self.senderName = dict[@"senderName"];
    
    if ([HXMessage isObjectAvailable:dict[@"userId"]])
        self.userId = dict[@"userId"];
    
    if ([HXMessage isObjectAvailable:dict[@"currentClientId"]])
        self.currentClientId = dict[@"currentClientId"];
    
    if ([HXMessage isObjectAvailable:dict[@"fileURL"]])
        self.fileURL = dict[@"fileURL"];
    
    if ([HXMessage isObjectAvailable:dict[@"longitude"]])
        self.longitude = @([dict[@"longitude"] doubleValue]);
    
    if ([HXMessage isObjectAvailable:dict[@"latitude"]])
        self.latitude = @([dict[@"latitude"] doubleValue]);
    
    if ([HXMessage isObjectAvailable:dict[@"chat"]])
        self.chat = dict[@"chat"];
    
    if ([HXMessage isObjectAvailable:dict[@"processStatus"]])
        self.processStatus = dict[@"processStatus"];
    
    
    NSError *error;
    [[CoreDataUtil sharedContext] save:&error];
    if (error) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        return NO;
    }
    return YES;
}

- (BOOL)setValuesFromDictWithoutSaved:(NSDictionary *)dict
{
    if ([HXMessage isObjectAvailable:dict[@"type"]])
        self.type = dict[@"type"];
    
    if ([HXMessage isObjectAvailable:dict[@"msgId"]])
        self.msgId = dict[@"msgId"];
    
    if ([HXMessage isObjectAvailable:dict[@"topicId"]])
        self.topicId = dict[@"topicId"];
    
    if ([HXMessage isObjectAvailable:dict[@"message"]])
        self.message = dict[@"message"];
    
    if ([HXMessage isObjectAvailable:dict[@"content"]])
        self.content = dict[@"content"];
    
    if ([HXMessage isObjectAvailable:dict[@"from"]])
        self.from = dict[@"from"];
    
    if ([HXMessage isObjectAvailable:dict[@"timestamp"]])
        self.timestamp = dict[@"timestamp"];
    
    if ([HXMessage isObjectAvailable:dict[@"readACK"]])
        self.readACK = dict[@"readACK"];
    
    if ([HXMessage isObjectAvailable:dict[@"senderName"]])
        self.senderName = dict[@"senderName"];
    
    if ([HXMessage isObjectAvailable:dict[@"userId"]])
        self.userId = dict[@"userId"];
    
    if ([HXMessage isObjectAvailable:dict[@"currentClientId"]])
        self.currentClientId = dict[@"currentClientId"];
    
    if ([HXMessage isObjectAvailable:dict[@"fileURL"]])
        self.fileURL = dict[@"fileURL"];
    
    if ([HXMessage isObjectAvailable:dict[@"longitude"]])
        self.longitude = @([dict[@"longitude"] doubleValue]);
    
    if ([HXMessage isObjectAvailable:dict[@"latitude"]])
        self.latitude = @([dict[@"latitude"] doubleValue]);
    
    if ([HXMessage isObjectAvailable:dict[@"chat"]])
        self.chat = dict[@"chat"];
    
    if ([HXMessage isObjectAvailable:dict[@"processStatus"]])
        self.processStatus = dict[@"processStatus"];
    

    return YES;
}

- (NSDictionary*)toDict{
    NSDictionary* dict = @{@"type":self.type,
                           @"msgId":self.msgId,
                           @"processStatus":self.processStatus,
                           @"topicId":self.topicId,
                           @"message":self.message,
                           @"content":self.content,
                           @"from":self.from,
                           @"timestamp":self.timestamp,
                           @"readACK":self.readACK,
                           @"senderName":self.senderName,
                           @"userId":self.userId,
                           @"currentClientId":self.currentClientId,
                           @"fileURL":self.fileURL,
                           @"longitude":self.longitude,
                           @"latitude":self.latitude};
    return dict;
    
}
@end
