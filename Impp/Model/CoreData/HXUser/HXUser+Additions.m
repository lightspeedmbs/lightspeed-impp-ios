//
//  HXUser+Additions.m
//  IMChat
//
//  Created by Herxun on 2015/1/15.
//  Copyright (c) 2015年 Herxun. All rights reserved.
//

#import "HXUser+Additions.h"
#import "CoreDataUtil.h"
@implementation HXUser(Additions)

+ (BOOL) isObjectAvailable:(id) data {
    return ((data != nil) && ![data isKindOfClass:[NSNull class]]);
}

+ (HXUser *)initWithDict:(NSDictionary *)dict
{
    HXUser *user = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class])
                                                 inManagedObjectContext:[CoreDataUtil sharedContext]];
    [user initAllAttributes];
    [user setValuesFromDict:dict];
    return user;
}

+(HXUser *)createTempObjectWithDict:(NSDictionary *)dict
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([self class])
                                              inManagedObjectContext:[CoreDataUtil sharedContext]];
    HXUser *user = [[HXUser alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
    [user initAllAttributes];
    [user setValuesFromDictWithoutSaved:dict];
    return user;
    
}

- (void)initAllAttributes
{
    self.userId = @"";
    self.userName = @"";
    self.clientId = @"";
    self.photoId = @"";
    self.photoURL = @"";
    self.coverPhotoURL = @"";
    self.currentUserId = @"";
    self.topics = nil;
    self.friends = nil;
    self.follows = nil;
}

- (BOOL)setValuesFromDictWithoutSaved:(NSDictionary *)dict
{
    if ([HXUser isObjectAvailable:dict[@"userId"]])
        self.userId = dict[@"userId"];
    
    if ([HXUser isObjectAvailable:dict[@"currentUserId"]])
        self.userId = dict[@"currentUserId"];
    
    if ([HXUser isObjectAvailable:dict[@"userName"]])
        self.userName = dict[@"userName"];
    
    if ([HXUser isObjectAvailable:dict[@"clientId"]])
        self.clientId = dict[@"clientId"];
    
    if ([HXUser isObjectAvailable:dict[@"photoId"]])
        self.photoId = dict[@"photoId"];
    
    if ([HXUser isObjectAvailable:dict[@"photoURL"]])
        self.photoURL = dict[@"photoURL"];
    
    if ([HXUser isObjectAvailable:dict[@"coverPhotoURL"]])
        self.coverPhotoURL = dict[@"coverPhotoURL"];
    
    return YES;
}

- (BOOL)setValuesFromDict:(NSDictionary *)dict
{
    if ([HXUser isObjectAvailable:dict[@"userId"]])
        self.userId = dict[@"userId"];
    
    if ([HXUser isObjectAvailable:dict[@"currentUserId"]])
        self.currentUserId = dict[@"currentUserId"];
    
    if ([HXUser isObjectAvailable:dict[@"userName"]])
        self.userName = dict[@"userName"];
    
    if ([HXUser isObjectAvailable:dict[@"clientId"]])
        self.clientId = dict[@"clientId"];
    
    if ([HXUser isObjectAvailable:dict[@"photoId"]])
        self.photoId = dict[@"photoId"];
    
    if ([HXUser isObjectAvailable:dict[@"photoURL"]])
        self.photoURL = dict[@"photoURL"];
    
    if ([HXUser isObjectAvailable:dict[@"coverPhotoURL"]])
        self.coverPhotoURL = dict[@"coverPhotoURL"];
    
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
    NSDictionary* dict = @{@"userName":self.userName,
                           @"userId":self.userId,
                           @"clientId":self.clientId,
                           @"photoId":self.photoId,
                           @"photoURL":self.photoURL,
                           @"coverPhotoURL":self.coverPhotoURL,
                           @"currentUserId":self.currentUserId};
    return dict;
}
@end
