//
//  HXIMManager.h
//  Impp
//
//  Created by hsujahhu on 2015/3/17.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AnIM.h"
#import "AnLive.h"
#import "HXMessage+Additions.h"
#import "HXChatViewController.h"

@protocol HXIMManagerTopicDelegate <NSObject>
@optional
- (void)anIMDidCreateTopic:(NSString *)topicId errorCode:(NSInteger)ArrownockErrorCode exception:(NSString *)exception;
- (void)anIMDidGetTopicList:(NSArray *)topics errorCode:(NSInteger)ArrownockErrorCode exception:(NSString *)exception;
- (void)anIMDidGetTopicInfo:(NSString *)topicId name:(NSString *)topicName parties:(NSSet *)parties createdDate:(NSDate *)createdDate exception:(NSString *)exception;
- (void)anIMDidUpdateStatus:(BOOL)status exception:(NSString *)exception;
- (void)anIMDidGetClientsStatus:(NSDictionary *)clientsStatus exception:(NSString *)exception;

@end

@protocol HXIMManagerChatDelegate <NSObject>
- (void)anIMDidAddClientsWithException:(NSString *)exception;
- (void)anIMMessageSent:(NSString *)messageId;
- (void)anIMSendReturnedException:(NSString *)exception messageId:(NSString *)messageId;
- (void)anIMDidReceiveMessage:(NSString *)message customData:(NSDictionary *)customData from:(NSString *)from topicId:(NSString *)topicId messageId:(NSString *)messageId at:(NSNumber *)timestamp customMessage:(HXMessage *)customMessage;
- (void)anIMDidReceiveBinaryData:(NSData *)data fileType:(NSString *)fileType customData:(NSDictionary *)customData from:(NSString *)from topicId:(NSString *)topicId messageId:(NSString *)messageId at:(NSNumber *)timestamp customMessage:(HXMessage *)customMessage;
@optional
- (void)anIMDidUpdateStatus:(BOOL)status exception:(NSString *)exception;
- (void)anIMDidGetClientsStatus:(NSDictionary *)clientsStatus exception:(NSString *)exception;
@end

@protocol HXIMManagerNoticeDelegate <NSObject>
- (void)anIMDidReceiveNotice:(NSString *)notice customData:(NSDictionary *)customData from:(NSString *)from topicId:(NSString *)topicId messageId:(NSString *)messageId at:(NSNumber *)timestamp;

@end

@protocol HXIMManagerLiveChatDelegate <NSObject>
@optional
- (void)receivedInvitation:(BOOL)isValid sessionId:(NSString*)sessionId partyId:(NSString*)partyId type:(NSString*)type createdAt:(NSDate*)createdAt;
- (void)localVideoViewReady:(AnLiveLocalVideoView*)view;
- (void)localVideoSizeChanged:(CGSize)size;
- (void)remotePartyConnected:(NSString*)partyId;
- (void)remotePartyDisconnected:(NSString*)partyId;
- (void)remotePartyVideoViewReady:(NSString*)partyId
                  remoteVideoView:(AnLiveVideoView*)view;
- (void)remotePartyVideoSizeChanged:(NSString*)partyId videoSize:(CGSize)size;
- (void)remotePartyVideoStateChanged:(NSString*)partyId state:(AnLiveVideoState)state;
- (void)remotePartyAudioStateChanged:(NSString*)partyId state:(AnLiveAudioState)state;
- (void)error:(NSString*)partyId exception:(ArrownockException*)exception;

@end


@interface HXIMManager : NSObject

+ (HXIMManager *)manager;

@property (weak, nonatomic) id<HXIMManagerTopicDelegate> topicDelegate;
@property (weak, nonatomic) id<HXIMManagerChatDelegate> chatDelegate;
@property (weak, nonatomic) id<HXIMManagerNoticeDelegate> noticeDelegate;
@property (weak, nonatomic) id<HXIMManagerLiveChatDelegate> liveChatDelegate;
@property (strong, nonatomic) AnIM *anIM;
@property (strong, nonatomic) NSMutableString *clientId;
@property (strong, nonatomic) NSMutableDictionary *remoteNotificationInfo;
@property (strong, nonatomic) NSString *anLiveCallStr;
@property BOOL clientStatus;
@property BOOL isAppEnterBackground;
@property BOOL isGetTopicList;

- (void)checkIMConnection;
- (HXChatViewController *)getChatViewWithTargetClientId:(NSString *)targetClientId targetUserName:(NSString *)targetUserName currentUserName:(NSString *)currentUserName;
- (void)sendFriendRequestApprovedMessageWithClientId:(NSString *)clientId;
- (void)sendFriendRequestMessageWithClientId:(NSString *)clientId targetUserName:(NSString *)username;
- (void)sendSocialNoticeWithClientId:(NSSet *)clientIds objectType:(NSString *)type objectInfo:(NSDictionary *)objectInfo notificationAlert:(NSString *)notificationAlert;
@end
