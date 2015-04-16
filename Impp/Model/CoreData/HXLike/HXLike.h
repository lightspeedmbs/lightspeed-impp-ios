//
//  HXLike.h
//  Impp
//
//  Created by Herxun on 2015/4/7.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class HXPost, HXUser;

@interface HXLike : NSManagedObject

@property (nonatomic, retain) NSNumber * created_at;
@property (nonatomic, retain) id customFields;
@property (nonatomic, retain) NSString * likeId;
@property (nonatomic, retain) NSString * parentId;
@property (nonatomic, retain) NSString * parentType;
@property (nonatomic, retain) NSNumber * postive;
@property (nonatomic, retain) NSNumber * updated_at;
@property (nonatomic, retain) HXPost *post;
@property (nonatomic, retain) HXUser *targetUser;
@property (nonatomic, retain) HXUser *likeOwner;

@end
