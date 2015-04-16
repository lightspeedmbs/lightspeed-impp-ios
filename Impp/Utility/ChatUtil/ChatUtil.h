//
//  ChatUtil.h
//  IMChat
//
//  Created by Herxun on 2015/1/15.
//  Copyright (c) 2015年 Herxun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataUtil.h"
#import "HXChat+Additions.h"

@interface ChatUtil : NSObject

+ (HXChat *)createChatSessionWithUser:(NSArray *)users topicId:(NSString *)topicId topicName:(NSString *)topicName currentUserName:(NSString *)currentUserName topicOwnerClientId:(NSString *)topicOwnerClientId;
+ (HXChat *)createChatSessionWithUser:(HXUser *)user;
+ (HXChat *)createChatSessionWithCurrentClientId:(NSString *)currentClientId targetClientId:(NSString *)targetClientId currentUserName:(NSString *)currentUserName targetUserName:(NSString *)targetUserName;

+ (HXChat *)getChatSessionByCurrentClientId:(NSString *)clientId;
+ (HXChat *)getChatSessionByClientId:(NSString *)clientId;
+ (HXChat *)getChatSessionByTopicId:(NSString *)topicId;
+ (HXChat *)getChatSessionByClientIds:(NSArray *)clientIds;
+ (HXChat *)getChatSessionByCurrentClientId:(NSString *)clientId targetClientId:(NSString *)targetClientId;

+ (BOOL)isChatSessionCreatedByTopicId:(NSString *)topicId;
+ (BOOL)isChatSessionCreatedByClientId:(NSString *)clientId;
+ (BOOL)UpdatedLastMessageInfo:(HXMessage *)message chatSession:(HXChat *)chat;

+ (HXMessage *)getLastMessage:(HXChat *)chatSession;

+ (NSInteger)unreadCount:(HXChat *)chatSession;
+ (void)deleteChatHistory:(HXChat *)chat;
+ (void)deleteChat:(HXChat *)chat;
@end
