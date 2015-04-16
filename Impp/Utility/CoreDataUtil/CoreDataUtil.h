//
//  CoreDataUtil.h
//  IMChat
//
//  Created by Herxun on 2015/1/15.
//  Copyright (c) 2015年 Herxun. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString* STATUS_CREATE = @"CREATE";
static NSString* STATUS_DELETE = @"DELETE";
static NSString* STATUS_IDLE = @"IDLE";

@interface CoreDataUtil : NSObject

//#pragma mark - Update
//+(void)updateWithEntityName:(NSString *)name
//                  predicate:(NSPredicate *)predicate
//                       data:(NSDictionary*)data;

#pragma mark - Get
+(int)getCountWithEntityName:(NSString *)name;
+(int)getCountWithEntityName:(NSString *)name
                   predicate:(NSPredicate *)predicate;
+(NSArray *)getWithEntityName:(NSString *)name
                    predicate:(NSPredicate *)predicate;
+(NSArray *)getWithEntityName:(NSString *)name
                    predicate:(NSPredicate *)predicate
                   properties:(NSArray *)properties;

#pragma mark - Delete
+(void)deleteObject:(id)object;
+(void)deleteAllWithEntityName:(NSString *)name;
+(void)deleteAllWithEntityName:(NSString *)name
                     predicate:(NSPredicate *)predicate;

#pragma mark - Singleton
+(id)sharedContext;
@end
