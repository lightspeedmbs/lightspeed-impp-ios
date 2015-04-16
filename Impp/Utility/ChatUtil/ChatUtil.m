//
//  ChatUtil.m
//  IMChat
//
//  Created by Herxun on 2015/1/15.
//  Copyright (c) 2015年 Herxun. All rights reserved.
//

#import "ChatUtil.h"
#import "CoreDataUtil.h"
#import "HXIMManager.h"
#import "HXUser+Additions.h"
#import "HXMessage+Additions.h"
#import "UserUtil.h"
#import "NotificationCenterUtil.h"
@implementation ChatUtil

+ (HXChat *)createChatSessionWithUser:(NSArray *)users topicId:(NSString *)topicId topicName:(NSString *)topicName currentUserName:(NSString *)currentUserName topicOwnerClientId:(NSString *)topicOwnerClientId
{
    HXChat *chatSession = [ChatUtil getChatSessionByTopicId:topicId];
    if (chatSession == nil) {
        
        NSDictionary *dic = @{@"currentUserName":currentUserName,
                              @"topicName":topicName,
                              @"topicId":topicId,
                              @"currentClientId":[HXIMManager manager].clientId};
        chatSession = [HXChat initWithDict:dic];
        
        if (users) {
            [chatSession addUsers:[NSSet setWithArray:users]];
        }
       
        HXUser *currentUser = [UserUtil getHXUserByClientId:[HXIMManager manager].clientId];
        [currentUser addTopicsObject:chatSession];
        NSLog(@"create topic %@",[chatSession description]);
        NSLog(@"by currentUser %@",[currentUser description]);
    }else{
        /* update info */
        chatSession.topicName = topicName;
        chatSession.topicId = topicId;
        
        /* update users in chat group */
        if (users) {
            if (chatSession.users.count) {
                NSSet *oldUsers = chatSession.users;
                [chatSession removeUsers:oldUsers];
                [chatSession addUsers:[NSSet setWithArray:users]];
            }else{
               [chatSession addUsers:[NSSet setWithArray:users]];
            }
        }
    }
    
    /* update topic owner */
    if ((topicOwnerClientId != nil) && ![topicOwnerClientId isKindOfClass:[NSNull class]]) {
        HXUser *topicOwner = [UserUtil getHXUserByClientId:topicOwnerClientId];
        if (topicOwner == nil) {
            topicOwner = [HXUser initWithDict:@{@"clientId":topicOwnerClientId,
                                                @"userName":@"unknown"}];
        }
        chatSession.topicOwner = topicOwner;
    }
    
    NSError *error;
    [[CoreDataUtil sharedContext] save:&error];
    if (error) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    return chatSession;
    
}

+ (HXChat *)createChatSessionWithUser:(HXUser *)user
{
    /* Handle mutiple user log in */
    
    HXChat *chat = [ChatUtil getChatSessionByClientIds:@[user.clientId,[HXIMManager manager].clientId]];
    if (chat == nil) {
        NSDictionary *dic = @{@"targetClientId":user.clientId,
                              @"currentClientId":[HXIMManager manager].clientId};
        
        HXUser *currentUser = [UserUtil getHXUserByClientId:[HXIMManager manager].clientId];
        
        if (currentUser == nil) {
            abort();
        }
        
        HXChat *chatSession = [HXChat initWithDict:dic];
        
        [chatSession addUsersObject:user];
        [chatSession addUsersObject:currentUser];
        
        NSError *error;
        [[CoreDataUtil sharedContext] save:&error];
        if (error) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        return chatSession;
        
    }else{
        // DEBUG
         
        NSArray *users = [chat.users allObjects];
        for (HXUser *user in users){
           NSLog(@"chat session user: %@",user.userName);
        }
        
        return chat;
    }
    
}

+ (HXChat *)createChatSessionWithCurrentClientId:(NSString *)currentClientId targetClientId:(NSString *)targetClientId currentUserName:(NSString *)currentUserName targetUserName:(NSString *)targetUserName
{
    /* Handle mutiple user log in */
    
    /* Get chat session */
    
    HXChat *chat = [ChatUtil getChatSessionByCurrentClientId:currentClientId targetClientId:targetClientId];
    
    if (chat == nil) {
        
        /* Get session user info */
        HXUser *currentUser = [UserUtil getHXUserByClientId:currentClientId];
        HXUser *targetUser = [UserUtil getHXUserByClientId:targetClientId];
        
        if (currentUser == nil) {
            currentUser = [HXUser initWithDict:@{@"clientId":currentClientId,
                                                 @"userName":currentUserName}];
        }
        if (targetUser == nil) {
            targetUser = [HXUser initWithDict:@{@"clientId":targetClientId,
                                                @"userName":targetUserName}];
        }
        
        NSDictionary *dic = @{@"targetClientId":targetClientId,
                              @"targetUserName":targetUser.userName,
                              @"currentClientId":currentClientId,
                              @"currentUserName":currentUser.userName};
        
        HXChat *chatSession = [HXChat initWithDict:dic];
        
        [chatSession addUsersObject:targetUser];
        //[chatSession addUsersObject:currentUser];
        
        NSError *error;
        [[CoreDataUtil sharedContext] save:&error];
        if (error) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        return chatSession;
        
    }else{
        
        /* Updated session user name */
        
        if ([chat.currentUserName isEqualToString:@""] || [chat.targetUserName isEqualToString:@""]) {
            chat.currentUserName = currentUserName;
            chat.targetUserName = targetUserName;
        
            
        }
        if (!chat.users || !chat.users.count) {
            HXUser *targetUser = [UserUtil getHXUserByClientId:targetClientId];
            [chat addUsersObject:targetUser];
        }
        
        NSError *error;
        [[CoreDataUtil sharedContext] save:&error];
        if (error) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        
        /* DEBUG */
//        NSArray *users = [chat.users allObjects];
//        for (HXUser *user in users){
//            NSLog(@"chat session user: %@",user.userName);
//        }
        
        return chat;
    }
    
}

+ (HXChat *)getChatSessionByClientIds:(NSArray *)clientIds
{
    NSArray* results =
    [CoreDataUtil getWithEntityName:NSStringFromClass([HXChat class])
                          predicate:[NSPredicate predicateWithFormat
                                     :@"targetClientId == %@ && currentClientId == %@", clientIds[0], clientIds[1]]];
    if (results.count == 0) {
        results =
        [CoreDataUtil getWithEntityName:NSStringFromClass([HXChat class])
                              predicate:[NSPredicate predicateWithFormat
                                         :@"targetClientId == %@ && currentClientId == %@", clientIds[1], clientIds[0]]];
    }
    for(HXChat* cs in results){
        NSLog(@"chat: %@", [cs toDict]);
    }
    
    if (results.count > 1) {
        NSLog(@"the result count should not > 1");
    }
    
    if (results.count > 0) {
        return results[0];
    } else
        return nil;
}

+ (HXChat *)getChatSessionByCurrentClientId:(NSString *)clientId
{
    NSArray* results =
    [CoreDataUtil getWithEntityName:NSStringFromClass([HXChat class])
                          predicate:[NSPredicate predicateWithFormat
                                     :@"currentClientId == %@", clientId]];
    for(HXChat* cs in results){
        NSLog(@"chat: %@", [cs toDict]);
    }
    
    if (results.count > 1) {
        NSLog(@"the result count should not > 1");
    }
    
    if (results.count > 0) {
        return results[0];
    } else
        return nil;
}

+ (HXChat *)getChatSessionByCurrentClientId:(NSString *)clientId targetClientId:(NSString *)targetClientId
{
    NSArray* results =
    [CoreDataUtil getWithEntityName:NSStringFromClass([HXChat class])
                          predicate:[NSPredicate predicateWithFormat
                                     :@"currentClientId == %@ && targetClientId == %@", clientId, targetClientId]];
    for(HXChat* cs in results){
        NSLog(@"chat: %@", [cs toDict]);
    }
    
    if (results.count > 1) {
        NSLog(@"the result count should not > 1");
    }
    
    if (results.count > 0) {
        return results[0];
    } else
        return nil;
}

+ (HXChat *)getChatSessionByClientId:(NSString *)clientId
{
    NSArray* results =
    [CoreDataUtil getWithEntityName:NSStringFromClass([HXChat class])
                          predicate:[NSPredicate predicateWithFormat
                                     :@"%K == %@", @"clientId", clientId]];
    for(HXChat* cs in results){
        NSLog(@"chat: %@", [cs toDict]);
    }
    
    if (results.count > 1) {
        NSLog(@"the result count should not > 1");
    }
    
    if (results.count > 0) {
        return results[0];
    } else
        return nil;
}

+ (HXChat *)getChatSessionByTopicId:(NSString *)topicId
{
    NSArray* results =
    [CoreDataUtil getWithEntityName:NSStringFromClass([HXChat class])
                          predicate:[NSPredicate predicateWithFormat
                                     :@"topicId == %@ && currentClientId == %@",topicId, [HXIMManager manager].clientId]];
    for(HXChat* cs in results){
        NSLog(@"chat exist!! chat info: %@", [cs toDict]);
    }
    
    if (results.count > 1) {
        NSLog(@"the result count should not > 1");
    }
    
    if (results.count > 0) {
        return results[0];
    } else
        return nil;
}

+ (HXMessage *)getLastMessage:(HXChat *)chatSession
{
    NSArray* results =
    [CoreDataUtil getWithEntityName:@"HXMessage"
                          predicate:[NSPredicate predicateWithFormat:
                                     @"self IN %@",
                                     chatSession.messages]];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp"
                                                                   ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    NSArray *messages = [results sortedArrayUsingDescriptors:sortDescriptors];
    return [messages lastObject];
}

+ (NSInteger)unreadCount:(HXChat *)chatSession
{
    NSArray* results =
    [CoreDataUtil getWithEntityName:@"HXMessage"
                          predicate:[NSPredicate predicateWithFormat:
                                     @"self IN %@ && from != %@ && readACK == %d",
                                     chatSession.messages,[HXIMManager manager].clientId,0]];
    return results.count;
}

+ (BOOL)isChatSessionCreatedByClientId:(NSString *)clientId
{
    NSArray* results =
    [CoreDataUtil getWithEntityName:NSStringFromClass([HXChat class])
                          predicate:[NSPredicate predicateWithFormat:
                                     @"%K == %@",
                                     @"clientId",clientId]];
                                     
    
    if (results.count > 1) {
        NSLog(@"more than one result, must be somthing wrong.");
    }
    
    return (results.count > 0);
}

+ (BOOL)isChatSessionCreatedByTopicId:(NSString *)topicId
{
    NSArray* results =
    [CoreDataUtil getWithEntityName:NSStringFromClass([HXChat class])
                          predicate:[NSPredicate predicateWithFormat:
                                     @"%K == %@",
                                     @"topicId",topicId]];
    
    
    if (results.count > 1) {
        NSLog(@"more than one result, must be somthing wrong.");
    }
    
    return (results.count > 0);
}

+ (BOOL)UpdatedLastMessageInfo:(HXMessage *)message chatSession:(HXChat *)chat
{
    chat.lastMsgId = message.msgId;
    chat.updatedTimestamp = message.timestamp;
    
    NSError *error;
    [[CoreDataUtil sharedContext] save:&error];
    if (error) {
        NSLog(@"(update chat) Whoops, couldn't save: %@", [error localizedDescription]);
        return NO;
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:RefreshChatHistory object:nil];
    return YES;
}

+ (void)deleteChatHistory:(HXChat *)chat
{
    [CoreDataUtil deleteAllWithEntityName:@"HXMessage"
                                predicate:[NSPredicate predicateWithFormat:@"self IN %@",chat.messages]];
    [[NSNotificationCenter defaultCenter]postNotificationName:DeleteChatHistory object:nil];
}

+ (void)deleteChat:(HXChat *)chat
{
    [CoreDataUtil deleteObject:chat];
}

@end
