//
//  HXChat.h
//  Impp
//
//  Created by Herxun on 2015/4/15.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class HXMessage, HXUser;

@interface HXChat : NSManagedObject

@property (nonatomic, retain) NSString * currentClientId;
@property (nonatomic, retain) NSString * currentUserName;
@property (nonatomic, retain) NSString * lastMsgId;
@property (nonatomic, retain) NSString * targetClientId;
@property (nonatomic, retain) NSString * targetUserName;
@property (nonatomic, retain) NSString * topicId;
@property (nonatomic, retain) NSString * topicName;
@property (nonatomic, retain) NSNumber * updatedTimestamp;
@property (nonatomic, retain) NSSet *messages;
@property (nonatomic, retain) NSSet *users;
@property (nonatomic, retain) HXUser *topicOwner;
@end

@interface HXChat (CoreDataGeneratedAccessors)

- (void)addMessagesObject:(HXMessage *)value;
- (void)removeMessagesObject:(HXMessage *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

- (void)addUsersObject:(HXUser *)value;
- (void)removeUsersObject:(HXUser *)value;
- (void)addUsers:(NSSet *)values;
- (void)removeUsers:(NSSet *)values;

@end
