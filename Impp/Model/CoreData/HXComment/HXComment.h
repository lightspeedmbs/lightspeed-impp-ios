//
//  HXComment.h
//  Impp
//
//  Created by Herxun on 2015/4/7.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class HXPost, HXUser;

@interface HXComment : NSManagedObject

@property (nonatomic, retain) NSNumber * commentCount;
@property (nonatomic, retain) NSNumber * commentRate;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * created_at;
@property (nonatomic, retain) NSNumber * dislikeCount;
@property (nonatomic, retain) NSNumber * likeCount;
@property (nonatomic, retain) NSString * parentId;
@property (nonatomic, retain) NSString * parentType;
@property (nonatomic, retain) NSNumber * updated_at;
@property (nonatomic, retain) NSString * commentId;
@property (nonatomic, retain) HXUser *commentOwner;
@property (nonatomic, retain) HXPost *post;
@property (nonatomic, retain) HXUser *targetUser;

@end
