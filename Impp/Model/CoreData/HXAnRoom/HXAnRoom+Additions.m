//
//  HXAnRoom+Additions.m
//  Impp
//
//  Created by 雷翊廷 on 2015/7/15.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import "HXAnRoom+Additions.h"
#import "CoreDataUtil.h"

@implementation HXAnRoom (Additions)


+ (BOOL) isObjectAvailable:(id) data {
    return ((data != nil) && ![data isKindOfClass:[NSNull class]]);
}

+(HXAnRoom*) initWithDict:(NSDictionary*)dict{
    HXAnRoom *anRoom = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class])
                                                 inManagedObjectContext:[CoreDataUtil sharedContext]];
    [anRoom initAllAttributes];
    [anRoom setValuesFromDict:dict];
    return anRoom;
}
-(void) initAllAttributes{
    self.topicId = @"";
    self.anRoomId = @"";
    self.photoUrl = @"";
    self.roomDescription = @"";
    self.type = @"";
    self.createdAt = @(0);
    self.roomName = @"";

}
-(BOOL) setValuesFromDict:(NSDictionary*)dict{
    if ([HXAnRoom isObjectAvailable:dict[@"customFields"]])
        self.topicId = dict[@"customFields"][@"topic_id"];
    
    if ([HXAnRoom isObjectAvailable:dict[@"id"]])
        self.anRoomId = dict[@"id"];
    
    if ([HXAnRoom isObjectAvailable:dict[@"customFields"][@"description"]])
        self.roomDescription = dict[@"customFields"][@"description"];
    
    if ([HXAnRoom isObjectAvailable:dict[@"customFields"][@"photoUrls"]]){
        self.photoUrl = dict[@"customFields"][@"photoUrls"];
    }else{
        self.photoUrl = nil;
    }
    
    if ([HXAnRoom isObjectAvailable:dict[@"created_at"]]){
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.zzz'Z'"];
        NSDate* createdTime = [dateFormatter dateFromString:dict[@"created_at"]];
        self.createdAt = [NSNumber numberWithDouble:[createdTime timeIntervalSince1970]*1000];
    }
    

    if ([HXAnRoom isObjectAvailable:dict[@"type"]])
        self.type = dict[@"type"];
    
    if ([HXAnRoom isObjectAvailable:dict[@"name"]])
        self.roomName = dict[@"name"];
    
    if ([HXAnRoom isObjectAvailable:dict[@"user"][@"clientId"]])
        self.circleOwner = dict[@"user"][@"clientId"];
    
    if ([HXAnRoom isObjectAvailable:dict[@"users"]])
        self.users = dict[@"users"];

    
    NSError *error;
    [[CoreDataUtil sharedContext] save:&error];
    if (error) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        return NO;
    }
    return YES;
}
-(NSDictionary*) toDict{
    NSDictionary *dict = @{
                           @"topicId":self.topicId,
                           @"anRoomId":self.anRoomId,
                           @"photoUrl":self.photoUrl ? self.photoUrl:@"",
                           @"roomDescription":self.roomDescription,
                           @"type":self.type,
                           @"roomName":self.roomName,
                           @"createdAt":self.createdAt,
                           @"users":self.users,
                           @"circleOwner":self.circleOwner,
                           };
    return dict;

}
@end
