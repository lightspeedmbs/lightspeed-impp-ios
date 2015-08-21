//
//  AnRoomUtil.h
//  Impp
//
//  Created by 雷翊廷 on 2015/7/15.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HXAnRoom.h"


@interface AnRoomUtil : NSObject
+ (HXAnRoom *)getRoomByTopicId:(NSString *)topicId;
+ (HXAnRoom *)getRoomByRoomId:(NSString *)RoomId;
+ (HXAnRoom *)saveRoomToDB:(NSDictionary *)RoomDic;
+ (void)deleteRoom:(HXAnRoom *)room;

@end
