//
//  MessageUtil.h
//  IMChat
//
//  Created by Herxun on 2015/1/15.
//  Copyright (c) 2015年 Herxun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HXMessage+Additions.h"
#import "AnIMMessage.h"

static NSString *DidUserUpdated = @"DidUserUpdated";
static NSString *DidGetOfflineChatMessage = @"DidGetOfflineChatMessage";
static NSString *DidGetOfflineTopicMessage = @"DidGetOfflineTopicMessage";

@interface MessageUtil : NSObject
+ (NSDictionary *)reformedMessageToDic:(AnIMMessage *)message;

+ (NSString *)configureTextMessageType:(NSDictionary *)customData;
+ (NSString *)configureLastMessage:(HXMessage *)message;

+ (void)getOfflineChatHistory;
+ (void)getOfflineTopicHistory;
+ (void)updateMessage:(NSArray *)message processStatus:(NSString *)status;

+ (NSArray *)getMessageByTopicId:(NSString *)topicId processStatus:(NSString *)processStatus;
+ (NSArray *)getMessageByChatSession:(HXChat *)chat;

+ (HXMessage *)getMessageByMessageId:(NSString *)msgId;
+ (HXMessage *)anIMMessageToHXMessage:(AnIMMessage *)message;

+ (void)saveChatMessageToLocal:(NSArray *)messages withReceiverId:(NSString *)receiverId;
+ (void)saveTopicMessageIntoDB:(NSArray *)messages;
+ (void)saveTopicMessageToLocal:(NSArray *)messages;
+ (void)saveChatMessageIntoDB:(NSArray *)messages withTargetClientId:(NSString *)targetClientId;
+ (void)updatedTopicSessionWithUsers:(NSSet *)users topicId:(NSString *)topicId topicName:(NSString *)topicName topicOwner:(NSString *)topicOwner;

+ (BOOL)updateMessageReadAckByMessageId:(NSString *)msgId;
+ (BOOL)updateMessageReadAckByMessageIds:(NSArray *)msgIds;
+ (BOOL)updateRemoteMessageReadAckByMessageId:(NSString *)msgId;
+ (NSInteger)getAllUnreadCount;
@end
