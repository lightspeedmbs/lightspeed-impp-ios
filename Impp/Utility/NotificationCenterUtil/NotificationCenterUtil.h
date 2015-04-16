//
//  NotificationCenterUtil.h
//  IMChat
//
//  Created by Herxun on 2015/1/26.
//  Copyright (c) 2015年 Herxun. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *ShouldUpdateTabItemBadge = @"ShouldUpdateTabItemBadge";
static NSString *DidReceiveMessage = @"DidReceiveMessage";
static NSString *ShowMessageFromNotificaiton = @"ShowMessageFromNotificaiton";
static NSString *updateMessages = @"updateMessages";
static NSString *ShouldShowChatHistoryPage = @"ShouldShowChatHistoryPage";
static NSString *SaveMessageToLocal = @"SaveMessageToLocal";
static NSString *SaveTopicMessageToLocal = @"SaveTopicMessageToLocal";
static NSString *RefreshFriendList = @"RefreshFriendList";
static NSString *RefreshChatHistory = @"RefreshChatHistory";
static NSString *RefreshWall = @"RefreshWall";
static NSString *UpdateFriendCircleBadge = @"UpdateFriendCircleBadge";
static NSString *GetOfflineChatMessage = @"GetOfflineChatMessage";
static NSString *GetOfflineTopicMessage = @"GetOfflineTopicMessage";
static NSString *FinishVideoAudioCall = @"FinishVideoAudioCall";
static NSString *UpdateLike = @"UpdateLike";
static NSString *DeleteChatHistory = @"DeleteChatHistory";
@interface NotificationCenterUtil : NSObject

@end
