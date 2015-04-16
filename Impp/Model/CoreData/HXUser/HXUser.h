//
//  HXUser.h
//  Impp
//
//  Created by Herxun on 2015/3/26.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class HXChat, HXUser;

@interface HXUser : NSManagedObject

@property (nonatomic, retain) NSString * clientId;
@property (nonatomic, retain) NSString * coverPhotoURL;
@property (nonatomic, retain) NSString * currentUserId;
@property (nonatomic, retain) NSString * photoId;
@property (nonatomic, retain) NSString * photoURL;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSSet *topics;
@property (nonatomic, retain) NSSet *friends;
@property (nonatomic, retain) NSSet *follows;
@end

@interface HXUser (CoreDataGeneratedAccessors)

- (void)addTopicsObject:(HXChat *)value;
- (void)removeTopicsObject:(HXChat *)value;
- (void)addTopics:(NSSet *)values;
- (void)removeTopics:(NSSet *)values;

- (void)addFriendsObject:(HXUser *)value;
- (void)removeFriendsObject:(HXUser *)value;
- (void)addFriends:(NSSet *)values;
- (void)removeFriends:(NSSet *)values;

- (void)addFollowsObject:(HXUser *)value;
- (void)removeFollowsObject:(HXUser *)value;
- (void)addFollows:(NSSet *)values;
- (void)removeFollows:(NSSet *)values;

@end
