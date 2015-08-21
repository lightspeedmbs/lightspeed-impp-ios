//
//  MessageUtil.m
//  IMChat
//
//  Created by Herxun on 2015/1/15.
//  Copyright (c) 2015年 Herxun. All rights reserved.
//

#import "MessageUtil.h"
#import "CoreDataUtil.h"
#import "ChatUtil.h"
#import "HXIMManager.h"
#import "HXAnSocialManager.h"
#import "HXUserAccountManager.h"
#import "UserUtil.h"
#import "NotificationCenterUtil.h"
@interface MessageUtil ()
@end

@implementation MessageUtil

+ (NSDictionary *)reformedMessageToDic:(AnIMMessage *)message
{
    NSString *type;
    if (message.fileType) {
        type = message.fileType;
    }else if (message.customData[@"location"]){
        type = @"location";
    }else{
        type = @"text";
    }
    NSDictionary *customData = message.customData;
    NSDictionary *dic = @{@"msgId":message.msgId,
                          @"type":type,
                          @"processStatus":STATUS_CREATE,
                          @"topicId":message.topicId ? message.topicId : @"",
                          @"message":message.message ? message.message : @"",
                          @"content":message.content ? message.content : [NSNull null],
                          @"from":message.from,
                          @"timestamp":message.timestamp,
                          @"senderName":customData[@"name"] ? customData[@"name"] : @"",
                          @"userId":customData[@"userId"] ? customData[@"userId"] : @"",
                          @"fileURL":customData[@"url"] ? customData[@"url"] : @"",
                          @"longitude":customData[@"location"][@"longitude"] ? customData[@"location"][@"longitude"] : [NSNull null],
                          @"latitude":customData[@"location"][@"latitude"] ? customData[@"location"][@"latitude"] : [NSNull null],
                          @"currentClientId":[HXIMManager manager].clientId,
                          @"senderPhotoUrl":customData[@"photoUrl"] ? customData[@"photoUrl"]:@""
                          };
    return dic;
}

+ (HXMessage *)anIMMessageToHXMessage:(AnIMMessage *)message
{
    HXMessage *hxMessage = [HXMessage createTempObjectWithDict:[MessageUtil reformedMessageToDic:message]];
    return hxMessage;
}

+ (NSString *)configureTextMessageType:(NSDictionary *)customData
{
    if (customData[@"location"]) {
        return @"location";
    }else {
        return @"text";
    }
}

+ (NSString *)configureLastMessage:(HXMessage *)message
{
    if (![message.from isEqualToString:[HXIMManager manager].clientId]) {
        if ([message.type isEqualToString:@"text"]) {
            return message.message;
        }else if ([message.type isEqualToString:@"image"]){
            return [NSString stringWithFormat:NSLocalizedString(@"%@_sent_you_an_image", nil),message.senderName];
        }else if ([message.type isEqualToString:@"record"]){
            return [NSString stringWithFormat:NSLocalizedString(@"%@_sent_you_a_voice_message", nil),message.senderName];
        }else if ([message.type isEqualToString:@"location"]){
            return [NSString stringWithFormat:NSLocalizedString(@"%@_sent_you_a_location", nil),message.senderName];
        }else
            return @"";
    }else{
        
        if ([message.type isEqualToString:@"text"]) {
            return message.message;
        }else if ([message.type isEqualToString:@"image"]){
            return NSLocalizedString(@"image_sent" , nil);
        }else if ([message.type isEqualToString:@"record"]){
            return NSLocalizedString(@"voice_message_sent", nil);
        }else if ([message.type isEqualToString:@"location"]){
            return NSLocalizedString(@"location_sent", nil);
        }else
            return @"";
    }
    
}

+ (NSInteger)getAllUnreadCount
{
    NSMutableArray* results = [[NSMutableArray alloc]initWithArray:[CoreDataUtil getWithEntityName:@"HXMessage"
                          predicate:[NSPredicate predicateWithFormat
                                     :@"readACK == %d && currentClientId == %@ && from != %@"
                                     ,0,[HXIMManager manager].clientId,[HXIMManager manager].clientId]] ];
    
//    //============================filter out AnRoom chat=======================================
//    NSMutableArray* filterResults = [[NSMutableArray alloc]initWithCapacity:0];
//    NSMutableArray* tempResults = [[NSMutableArray alloc]initWithCapacity:0];
//    for (HXMessage *message in results) {
//        NSMutableDictionary *messageDic = [[NSMutableDictionary alloc]initWithDictionary:[message toDict]];
//        HXChat *chat = messageDic[@"chat"];
//        messageDic[@"chat"] = [chat toDict];
//        [filterResults addObject:messageDic];
//        [tempResults addObject:messageDic];
//    }
//    
//    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF['chat']['isAnRoomChat'] CONTAINS %@",@"ANROOM"];
//    NSMutableArray *tempArray = [[NSMutableArray alloc]initWithCapacity:0];
//    tempArray = [[filterResults filteredArrayUsingPredicate:resultPredicate]mutableCopy];
//    
////    NSMutableArray* tempResults = [[NSMutableArray alloc]initWithCapacity:0];
////    for (HXMessage *message in results) {
////        NSMutableDictionary *messageDic = [[NSMutableDictionary alloc]initWithDictionary:[message toDict]];
////        [tempResults addObject:messageDic];
////    }
//    
//    [tempResults removeObjectsInArray:tempArray];
//    //======================================================================================
//    
    return results.count;

}



+ (BOOL)updateMessageReadAckByMessageId:(NSString *)msgId
{
    
    NSArray* results =
    [CoreDataUtil getWithEntityName:@"HXMessage"
                          predicate:[NSPredicate predicateWithFormat
                                     :@"msgId == %@",msgId]];
    if ([results count] == 0) {
        return NO;
    }
    HXMessage *message ;
    for (HXMessage *messageForCurrent  in results) {
        if ([messageForCurrent.currentClientId isEqualToString:[HXUserAccountManager manager].clientId]) {
            message = messageForCurrent;
            
        }
    }
    message.readACK = @(YES);
   
    
    NSError *error;
    if (![[CoreDataUtil sharedContext] save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        return NO;
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"updateMessageUnreadCount" object:message];
    return YES;
    
}

+ (BOOL)updateRemoteMessageReadAckByMessageId:(NSString *)msgId
{
    
    NSArray* results =
    [CoreDataUtil getWithEntityName:@"HXMessage"
                          predicate:[NSPredicate predicateWithFormat
                                     :@"msgId == %@",msgId]];
    if ([results count] == 0) {
        return NO;
    }
    HXMessage *message = results[0];
    message.readACK = @(YES);
    
    NSError *error;
    if (![[CoreDataUtil sharedContext] save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        return NO;
    }
    
    return YES;
    
}

+ (BOOL)updateMessageReadAckByMessageIds:(NSArray *)msgIds
{
    for (NSString *msgId in msgIds){
        NSArray* results =
        [CoreDataUtil getWithEntityName:@"HXMessage"
                              predicate:[NSPredicate predicateWithFormat
                                         :@"msgId == %@",msgId]];
        if ([results count] != 0) {
            HXMessage *message = results[0];
            message.readACK = @(YES);
        }else
            NSLog(@"couldn't find this msgId in DB!!");
        
    }
    
    NSError *error;
    if (![[CoreDataUtil sharedContext] save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        return NO;
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:ShouldUpdateTabItemBadge object:nil];
    return YES;
    
}

#pragma mark - Fetch Offline Message

+ (void)getOfflineChatHistory
{
    [[[HXIMManager manager]anIM] getOfflineHistory:[HXIMManager manager].clientId
                                             limit:30
                                           success:^(NSArray* messages ,int count){
                                               
                                               if ([messages count]) {
                                                   for (AnIMMessage *message in messages){
                                                       
                                                       /* do not save friend request */
                                                       if (message.fileType){
                                                           if ([message.fileType isEqualToString:@"send"])return;
                                                       }
                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                           [MessageUtil saveChatMessageIntoDB:@[message] withTargetClientId:message.from];
                                                       });
                                                       
                                                   }
                                               }
                                               if (count > 0) {
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       [MessageUtil getOfflineChatHistory];
                                                   });
                                                   
                                               }else{
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       [[NSNotificationCenter defaultCenter]postNotificationName:GetOfflineChatMessage object:nil];
                                                   });
                                                   
                                               }
                                           }
                                           failure:^(ArrownockException *exception){
                                               
                                               NSLog(@"fail to get offline chat history !!!!");
                                               
                                           }];
}

+ (void)getOfflineTopicHistory
{
    [[[HXIMManager manager]anIM] getOfflineTopicHistory:[HXIMManager manager].clientId
                                                  limit:30
                                                success:^(NSArray* messages ,int count){
                                                    
                                                    if ([messages count]) {
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            [MessageUtil saveTopicMessageIntoDB:messages];
                                                        });
                                                        
                                                    }
                                                    if (count > 0) {
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            [MessageUtil getOfflineTopicHistory];
                                                        });
                                                        
                                                    }else{
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            [[NSNotificationCenter defaultCenter]postNotificationName:GetOfflineTopicMessage object:nil];
                                                        });
                                                        
                                                    }
                                                    
                                                } failure:^(ArrownockException *exception){
                                                    
                                                    NSLog(@"fail to get offline topic history !!!!");
                                                    
                                                }];
    
}

+ (void)saveChatMessageIntoDB:(NSArray *)messages withTargetClientId:(NSString *)targetClientId
{
    for (AnIMMessage *message in messages)
    {
        
        HXChat *chatSession = [ChatUtil createChatSessionWithCurrentClientId:[HXIMManager manager].clientId targetClientId:targetClientId currentUserName:[HXUserAccountManager manager].userName targetUserName:@""];
        
        NSDictionary *dic = [MessageUtil reformedMessageToDic:message];
        HXMessage *hxMessage = [HXMessage initWithDict:dic];
        hxMessage.chat = chatSession;
        [chatSession addMessagesObject:hxMessage];
        [MessageUtil updateMessage:@[hxMessage] processStatus:STATUS_IDLE];
        
//        HXUser *sender = [UserUtil getHXUserByClientId:dic[@"from"]];
//        if (!sender || [sender.photoURL isEqualToString:@""] || sender.photoURL == nil) {
//            [noPhotoUserClientIds addObject:dic[@"from"]];
//        }
        
        [ChatUtil UpdatedLastMessageInfo:hxMessage chatSession:chatSession];
        [[NSNotificationCenter defaultCenter] postNotificationName:SaveMessageToLocal object:hxMessage.msgId];
        
        /* for click push notification */
        if ([HXIMManager manager].remoteNotificationInfo[@"from"]) {
            /* reset notification info */
            [HXIMManager manager].remoteNotificationInfo = [[NSMutableDictionary alloc]initWithCapacity:0];
            [[NSNotificationCenter defaultCenter]postNotificationName:ShowMessageFromNotificaiton object:@{@"mode":@"chat",
                                                                                                           @"chatSession":chatSession}];
        }
    }

}

+ (void)saveTopicMessageIntoDB:(NSArray *)messages
{
    //NSMutableString *noPhotoClientIds = [[NSMutableString alloc] initWithString: @""];
    //NSMutableArray *noPhotoUserClientIds = [[NSMutableArray alloc]initWithCapacity:0];
    for (AnIMMessage *message in messages)
    {
        NSDictionary *dic = [MessageUtil reformedMessageToDic:message];
        HXChat *chatSession = [ChatUtil getChatSessionByTopicId:dic[@"topicId"]];
        HXMessage *hxMessage = [HXMessage initWithDict:dic];
        [MessageUtil updateMessage:@[hxMessage] processStatus:STATUS_IDLE];
        
        
        
        
        if (chatSession == nil) {
            chatSession = [ChatUtil createChatSessionWithUser:nil topicId:message.topicId topicName:@"" currentUserName:[HXUserAccountManager manager].userName topicOwnerClientId:nil];
            
            HXUser *sender = [UserUtil getHXUserByClientId:dic[@"from"]];

            if (sender) {
                if (![hxMessage.senderPhotoUrl isEqualToString:sender.photoURL]) {
                    //[UserUtil updateUser:sender PhotoUrl:hxMessage.senderPhotoUrl];
                    
                    [[HXAnSocialManager manager]sendRequest:@"users/query.json"
                                                     method:AnSocialManagerGET
                                                     params:@{@"clientId":dic[@"from"]}
                                                    success:^(NSDictionary *response){
                                                                     NSDictionary *userInfo = response[@"response"][@"users"][0];
                                                                     [sender setValuesFromDict:[UserUtil reformUserInfoDic:userInfo]];
                     
                                                                     //add notification
                                                                     [[NSNotificationCenter defaultCenter] postNotificationName:DidUserUpdated object:nil];
                     
                                                                 } failure:^(NSDictionary *response){
                     
                                                                     NSLog(@"fail to get user info !!!!");
                                                                     
                                                                 }];

                }
                
            }else{
                sender = [HXUser initWithDict:@{@"clientId":dic[@"from"],
                                                @"userName":dic[@"senderName"],
                                                @"senderPhotoUrl":hxMessage.senderPhotoUrl
                                                }];
            }
            
            if (![chatSession.users containsObject:sender]) {
                [chatSession addUsersObject:sender];
            }
//            /* for click push notification */
//            if ([HXIMManager manager].remoteNotificationInfo[@"topic_id"]) {
//                /* reset notification info */
//                [HXIMManager manager].remoteNotificationInfo = [[NSMutableDictionary alloc]initWithCapacity:0];
//                [[NSNotificationCenter defaultCenter]postNotificationName:ShowMessageFromNotificaiton object:@{@"mode":@"topic",
//                                                                                                               @"chatSession":chatSession}];
//            }
            
            [[[HXIMManager manager]anIM] getTopicInfo:dic[@"topicId"] success:^(NSString *topicId, NSString *topicName, NSString *owner, NSSet *parties, NSDate *createdDate) {
                
                dispatch_async(dispatch_get_main_queue(), ^{

                    NSMutableSet *users = [[NSMutableSet alloc]initWithSet:parties];
                    if (![parties containsObject:[HXUserAccountManager manager].clientId]) {
                        [users addObject:[HXUserAccountManager manager].clientId];
                    }
                    [MessageUtil updatedTopicSessionWithUsers:users topicId:topicId topicName:topicName topicOwner:owner];
                    HXChat *chatSessionNew = [ChatUtil getChatSessionByTopicId:dic[@"topicId"]];
                    hxMessage.chat = chatSessionNew;
                    //hxMessage.chatDic = [chatSession toDict];
                    [chatSessionNew addMessagesObject:hxMessage];
                    [ChatUtil UpdatedLastMessageInfo:hxMessage chatSession:chatSessionNew];
                    [[NSNotificationCenter defaultCenter] postNotificationName:SaveTopicMessageToLocal object:hxMessage.msgId];

                });
                
                
            } failure:^(ArrownockException *exception) {
                NSLog(@"AnIm getTopicInfo failed, error : %@", exception.getMessage);
            }];
        }else{
            
            HXUser *sender = [UserUtil getHXUserByClientId:dic[@"from"]];

            if (sender) {
                if (![hxMessage.senderPhotoUrl isEqualToString:sender.photoURL]) {
                    //[UserUtil updateUser:sender PhotoUrl:hxMessage.senderPhotoUrl];
                    [[HXAnSocialManager manager]sendRequest:@"users/query.json"
                                                     method:AnSocialManagerGET
                                                     params:@{@"clientId":dic[@"from"]}
                                                    success:^(NSDictionary *response){
                                                        NSDictionary *userInfo = response[@"response"][@"users"][0];
                                                        [sender setValuesFromDict:[UserUtil reformUserInfoDic:userInfo]];
                                                        
                                                        //add notification
                                                        [[NSNotificationCenter defaultCenter] postNotificationName:DidUserUpdated object:nil];
                                                        
                                                    } failure:^(NSDictionary *response){
                                                        
                                                        NSLog(@"fail to get user info !!!!");
                                                        
                                                    }];
                }
                
                
            }else{
                sender = [HXUser initWithDict:@{@"clientId":dic[@"from"],
                                                @"userName":dic[@"senderName"],
                                                @"senderPhotoUrl":hxMessage.senderPhotoUrl
                                                }];
            }
            if (![chatSession.users containsObject:sender]) {
                [chatSession addUsersObject:sender];
            }
            
            if (![chatSession.users containsObject:[HXUserAccountManager manager].userInfo]) {
                [chatSession addUsersObject:[HXUserAccountManager manager].userInfo];
            }
            
            
            hxMessage.chat = chatSession;
            //hxMessage.chatDic = [chatSession toDict];
            [chatSession addMessagesObject:hxMessage];
            [ChatUtil UpdatedLastMessageInfo:hxMessage chatSession:chatSession];
            [[NSNotificationCenter defaultCenter] postNotificationName:SaveTopicMessageToLocal object:hxMessage.msgId];
            
            /* for click push notification */

        }
        if ([HXIMManager manager].remoteNotificationInfo[@"topic_id"]) {
            /* reset notification info */
            [HXIMManager manager].remoteNotificationInfo = [[NSMutableDictionary alloc]initWithCapacity:0];
            [[NSNotificationCenter defaultCenter]postNotificationName:ShowMessageFromNotificaiton object:@{@"mode":@"topic",
                                                                                                           @"chatSession":chatSession}];
        }
        
    }


    
    
}

+ (void)saveChatMessageToLocal:(NSArray *)messages withReceiverId:(NSString *)receiverId
{
    for (AnIMMessage *message in messages)
    {
        if ([MessageUtil isMessageSaved:message.msgId]) return;
        
        NSDictionary *dic = [MessageUtil reformedMessageToDic:message];
        
        HXUser *user = [UserUtil getHXUserByUserId:dic[@"clientId"]];
        
        if ([dic[@"clientId"] isEqualToString:[HXIMManager manager].clientId]) {
            user = [UserUtil getHXUserByUserId:receiverId];
        }
        
        
        if (user == nil) {
            
            /* save user */
            user = [UserUtil insertUserWithDic:@{@"clientId":dic[@"from"],
                                                 @"id":dic[@"userId"],
                                                 @"customData":@{@"username":message.customData[@"name"]}}];
            /* update user */
//            [[HXAnSocialManager manager]sendRequest:@"users/get.json"
//                                             method:AnSocialManagerGET
//                                             params:@{@"user_ids":dic[@"userId"]}
//                                            success:^(NSDictionary *response){
//                                                NSDictionary *userInfo = response[@"response"][@"users"][0];
//                                                [user setValuesFromDict:[UserUtil reformUserInfoDic:userInfo]];
//                                                
//                                                //add notification
//                                                [[NSNotificationCenter defaultCenter] postNotificationName:DidUserUpdated object:nil];
//                                                
//                                            } failure:^(NSDictionary *response){
//                                                
//                                                NSLog(@"fail to get user info !!!!");
//                                                
//                                            }];
        }
        
        HXChat *chatSession = [ChatUtil createChatSessionWithUser:user];
        HXMessage *hxMessage = [HXMessage initWithDict:dic];
        hxMessage.chat = chatSession;
        [chatSession addMessagesObject:hxMessage];
        [MessageUtil updateMessage:@[hxMessage] processStatus:STATUS_IDLE];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:SaveMessageToLocal object:@[hxMessage]];
        [[NSNotificationCenter defaultCenter] postNotificationName:DidGetOfflineChatMessage object:nil];
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:@"updateMessageUnreadCount" object:nil];
    
//    if ([HXAnSocialManager manager].shouldShowChatVc && [HXAnSocialManager manager].notificationInfo)
//        [[NSNotificationCenter defaultCenter]postNotificationName:ShowMessageFromNotificaiton object:nil];
//    else if ([HXAnSocialManager manager].notificationInfo)
//        [[NSNotificationCenter defaultCenter]postNotificationName:updateMessages object:nil];
}

+ (void)saveTopicMessageToLocal:(NSArray *)messages
{
    for (AnIMMessage *message in messages)
    {
        if (![MessageUtil isMessageSaved:message.msgId]) {
            
            NSDictionary *dic = [MessageUtil reformedMessageToDic:message];
            HXChat *chatSession;
            chatSession = [ChatUtil getChatSessionByTopicId:dic[@"topicId"]];
            
            if (chatSession == nil) {
                HXMessage *hxMessage = [HXMessage initWithDict:dic];
                [MessageUtil updateMessage:@[hxMessage] processStatus:STATUS_CREATE];
                
                [[[HXIMManager manager]anIM] getTopicInfo:dic[@"topicId"] success:^(NSString *topicId, NSString *topicName, NSString *owner, NSSet *parties, NSDate *createdDate) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                          [MessageUtil updatedTopicSessionWithUsers:parties topicId:topicId topicName:topicName topicOwner:nil];
                    });

                } failure:^(ArrownockException *exception) {
                    NSLog(@"AnIm getTopicInfo failed, error : %@", exception.getMessage);
                }];
            }else{ 

                dispatch_async(dispatch_get_main_queue(), ^{
                    HXMessage *hxMessage = [HXMessage initWithDict:dic];
                    hxMessage.chat = chatSession;
                    [chatSession addMessagesObject:hxMessage];
                    [MessageUtil updateMessage:@[hxMessage] processStatus:STATUS_IDLE];
                    [[NSNotificationCenter defaultCenter]postNotificationName:SaveTopicMessageToLocal object:@[hxMessage]];
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"updateMessageUnreadCount" object:nil];
                    
//                    if ([HXAnSocialManager manager].shouldShowChatVc && [HXAnSocialManager manager].notificationInfo)
//                        [[NSNotificationCenter defaultCenter]postNotificationName:ShowMessageFromNotificaiton object:nil];
//                    else if ([HXAnSocialManager manager].notificationInfo)
//                        [[NSNotificationCenter defaultCenter]postNotificationName:updateMessages object:nil];
                });
            }
        }
        
    }
    
}

+ (void)updateMessage:(NSArray *)messages processStatus:(NSString *)status
{
    
    
        for (HXMessage *message in messages){
            message.processStatus = status;
        }
        
        NSError *error;
        if (![[CoreDataUtil sharedContext] save:&error]) {
            NSLog(@"(update message) Whoops, couldn't save: %@", [error localizedDescription]);
        }
    
    
}

+ (NSArray *)getMessageByTopicId:(NSString *)topicId processStatus:(NSString *)processStatus
{
    
    NSArray* results =
    [CoreDataUtil getWithEntityName:@"HXMessage"
                          predicate:[NSPredicate predicateWithFormat
                                     :@"topicId == %@ && processStatus == %@",topicId , processStatus]];
    return results;
}

+ (NSArray *)getMessageByTopicId:(NSString *)topicId
{
    
    NSArray* results =
    [CoreDataUtil getWithEntityName:@"HXMessage"
                          predicate:[NSPredicate predicateWithFormat
                                     :@"topicId == %@",topicId]];
    return results;
}

+ (NSArray *)getMessageByChatSession:(HXChat *)chat
{
    NSArray* results =
    [CoreDataUtil getWithEntityName:@"HXMessage"
                          predicate:[NSPredicate predicateWithFormat
                                     :@"chat.targetClientId == %@",chat.targetClientId]];
    return results;
}

+ (HXMessage *)getMessageByMessageId:(NSString *)msgId
{
    NSArray* results =
    [CoreDataUtil getWithEntityName:@"HXMessage"
                          predicate:[NSPredicate predicateWithFormat
                                     :@"msgId == %@",msgId]];
    return results[0];
}

+ (BOOL)isMessageSaved:(NSString *)messageId
{
    NSArray* results =
    [CoreDataUtil getWithEntityName:NSStringFromClass([HXMessage class])
                          predicate:[NSPredicate predicateWithFormat:
                                     @"%K == %@",
                                     @"msgId",messageId]];
    
    
    if (results.count > 1) {
        NSLog(@"more than one result, must be somthing wrong.");
    }
    
    return (results.count > 0);
}

+ (void)updatedTopicSessionWithUsers:(NSSet *)users topicId:(NSString *)topicId topicName:(NSString *)topicName topicOwner:(NSString *)topicOwner
{
    
        NSArray *userClientIds = [users allObjects];
        NSMutableArray *hxUsers = [[NSMutableArray alloc]initWithCapacity:0];
        NSMutableArray *unknownUserClientIds = [[NSMutableArray alloc]initWithCapacity:0];
        
        HXUser *currentUser;
        for (NSString *clientId in userClientIds){
            HXUser *hxUser = [UserUtil getHXUserByClientId:clientId];
            if (hxUser == nil) {
                hxUser = [HXUser initWithDict:@{@"clientId":clientId,
                                                @"userName":@"unknown"}];
                [unknownUserClientIds addObject:hxUser.clientId];
            }
            [hxUsers addObject:hxUser];
            if ([hxUser.clientId isEqualToString:[HXIMManager manager].clientId]) {
                currentUser = hxUser;
            }
        }
    
        //NSLog(@"user need to add to topic %@", [hxUsers description]);
    
        //get unknown userInfo from server
    
    if (unknownUserClientIds.count != 0) {
        NSMutableString *clientIds = [NSMutableString stringWithString:@""];
        for (int i = 0; i<unknownUserClientIds.count; i++) {
            if (i) {
                [clientIds appendFormat:@",%@",unknownUserClientIds[i] ];
            }else{
                [clientIds appendFormat:@"%@",unknownUserClientIds[0]];
            }
        }
        [[HXAnSocialManager manager] sendRequest:@"users/query.json"
                                          method:AnSocialManagerGET
                                          params:@{@"clientId":clientIds}
                                         success:^(NSDictionary *response){
                                             NSLog(@"Got user info :%@",response[@"response"][@"users"]);
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 NSArray *usersAdd = response[@"response"][@"users"];
                                                 for (NSDictionary *userInfo in usersAdd) {
                                                     [UserUtil saveUserIntoDB:userInfo];
                                                 }
                                                 [MessageUtil updatedTopicSessionWithUsers:users topicId:topicId topicName:topicName topicOwner:topicOwner];
                                             });
                                             
                                             //add notification
                                             //[[NSNotificationCenter defaultCenter] postNotificationName:DidUserUpdated object:nil];
                                             
                                         } failure:^(NSDictionary *response){
                                             
                                             NSLog(@"fail to get user info !!!!");
                                             
                                         }];

        
        
    }
    
        //update info
        
        [ChatUtil createChatSessionWithUser:[NSSet setWithArray:[hxUsers mutableCopy]]  topicId:topicId topicName:topicName currentUserName:currentUser.userName topicOwnerClientId:topicOwner];
        
        /* to fefresh chat history*/
        [[NSNotificationCenter defaultCenter]postNotificationName:RefreshChatHistory object:nil];
    

}


+ (void)deleteMessage:(HXMessage *)message
{
    [CoreDataUtil deleteObject:message];
}

-(void)fetchUserInfoWithId:(NSString*)clientIds topicId:(NSString *)topicId topicName:(NSString *)topicName topicOwner:(NSString *)topicOwner{
    
    [[HXAnSocialManager manager] sendRequest:@"users/query.json"
                                     method:AnSocialManagerGET
                                     params:@{@"clientId":clientIds}
                                    success:^(NSDictionary *response){
                                        NSLog(@"Got user info :%@",response[@"response"][@"users"]);
                                        NSArray *users = response[@"response"][@"users"];
                                        for (NSDictionary *userInfo in users) {
                                            [UserUtil saveUserIntoDB:userInfo];
                                        }
                                        
                                        //add notification
                                        [[NSNotificationCenter defaultCenter] postNotificationName:DidUserUpdated object:nil];
                                        
                                    } failure:^(NSDictionary *response){
                                        
                                        NSLog(@"fail to get user info !!!!");
                                        
                                    }];
}
@end
