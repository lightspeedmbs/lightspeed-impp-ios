//
//  HXPost.h
//  Impp
//
//  Created by Herxun on 2015/4/7.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class HXComment, HXLike, HXUser;

@interface HXPost : NSManagedObject

@property (nonatomic, retain) NSNumber * commentCount;
@property (nonatomic, retain) NSNumber * commentRate;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * created_at;
@property (nonatomic, retain) id customFields;
@property (nonatomic, retain) NSNumber * dislikeCount;
@property (nonatomic, retain) NSString * postId;
@property (nonatomic, retain) NSNumber * likeCount;
@property (nonatomic, retain) NSString * parentId;
@property (nonatomic, retain) NSString * parentType;
@property (nonatomic, retain) id photoUrls;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSNumber * updated_at;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) NSSet *likes;
@property (nonatomic, retain) HXUser *postOwner;
@end

@interface HXPost (CoreDataGeneratedAccessors)

- (void)addCommentsObject:(HXComment *)value;
- (void)removeCommentsObject:(HXComment *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

- (void)addLikesObject:(HXLike *)value;
- (void)removeLikesObject:(HXLike *)value;
- (void)addLikes:(NSSet *)values;
- (void)removeLikes:(NSSet *)values;

@end
