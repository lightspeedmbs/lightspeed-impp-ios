//
//  AnRoomUtil.m
//  Impp
//
//  Created by 雷翊廷 on 2015/7/15.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import "AnRoomUtil.h"
#import "CoreDataUtil.h"
#import "HXAnRoom+Additions.h"

@implementation AnRoomUtil
+ (HXAnRoom *)getRoomByRoomId:(NSString *)roomId
{
    NSArray* results =
    [CoreDataUtil getWithEntityName:NSStringFromClass([HXAnRoom class])
                          predicate:[NSPredicate predicateWithFormat
                                     :@"anRoomId == %@",roomId]];
    
    if (results.count > 1) {
        NSLog(@"the result count should not > 1");
    }
    
    if (results.count > 0) {
        return results[0];
    } else
        return nil;
}

+ (HXAnRoom *)getRoomByTopicId:(NSString *)topicId
{
    NSArray* results =
    [CoreDataUtil getWithEntityName:NSStringFromClass([HXAnRoom class])
                          predicate:[NSPredicate predicateWithFormat
                                     :@"topicId == %@",topicId]];
    
    if (results.count > 1) {
        NSLog(@"the result count should not > 1");
    }
    
    if (results.count > 0) {
        return results[0];
    } else
        return nil;
}

+ (HXAnRoom *)saveRoomToDB:(NSDictionary *)RoomDic
{
    HXAnRoom *room = [AnRoomUtil getRoomByRoomId:RoomDic[@"id"]];
    if (room == nil) {
        room = [HXAnRoom initWithDict:RoomDic];
    }else{
        [room setValuesFromDict:RoomDic];
    }
    
//    HXUser *user = [UserUtil saveUserIntoDB:postDic[@"user"]];
//    post.postOwner = user;
    
    NSError *error;
    [[CoreDataUtil sharedContext] save:&error];
    if (error) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    return room;
}

+ (void)deleteRoom:(HXAnRoom *)room
{
    [CoreDataUtil deleteObject:room];
}
@end
