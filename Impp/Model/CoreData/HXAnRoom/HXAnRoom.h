//
//  HXAnRoom.h
//  Impp
//
//  Created by 雷翊廷 on 2015/7/15.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface HXAnRoom : NSManagedObject

@property (nonatomic, retain) NSString * topicId;
@property (nonatomic, retain) NSString * anRoomId;
@property (nonatomic, retain) NSString * photoUrl;
@property (nonatomic, retain) NSString * roomDescription;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * circleOwner;
@property (nonatomic, retain) NSArray * users;
@property (nonatomic, retain) NSString * roomName;
@property (nonatomic, retain) NSNumber * createdAt;

@end
