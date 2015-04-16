//
//  HXIMManager.m
//  Impp
//
//  Created by hsujahhu on 2015/3/17.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import "HXIMManager.h"
#import "LightspeedCredentials.h"
#import "AnIMMessage.h"
#import "MessageUtil.h"
#import "ChatUtil.h"
#import "HXChat+Additions.h"
#import "HXUserAccountManager.h"
#import "HXAnLiveViewController.h"
#import "UserUtil.h"
#import "NotificationCenterUtil.h"

#import "UIView+Toast.h"

@interface HXIMManager()<AnIMDelegate, AnLiveEventDelegate>
@property (strong, nonatomic) NSDate *videoCallStartTime;
@property BOOL imConnecting;
@end

@implementation HXIMManager

#pragma mark - Init

+ (HXIMManager *)manager
{
    static HXIMManager *_manager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _manager = [[HXIMManager alloc] init];
    });
    return _manager;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.anIM = [[AnIM alloc] initWithAppKey:LIGHTSPEED_APP_KEY delegate:self secure:YES];
        [AnLive setup:self.anIM delegate:self];
        
        self.remoteNotificationInfo = [[NSMutableDictionary alloc]initWithCapacity:0];
        self.clientId = [[NSMutableString alloc] initWithCapacity:0];
        _clientStatus = NO;
    }
    return self;
}

#pragma mark - Public

// Check connection, if not connected, try to reconnect to the server
- (void)checkIMConnection
{
    
    if (!self.clientId.length) return;
    
    if (!_clientStatus && !_imConnecting)
    {
        NSLog(@"IM Connecting ...");
        _imConnecting = YES;
        
        [self.anIM connect:self.clientId];
    }
    else
    {
        NSLog(@"IM is connected");
    }
    
}

- (NSMutableString *)clientId
{
    if (_clientId.length)
    {
        return _clientId;
    }
    return nil;
}

#pragma mark - AnIM Delegate

- (void)anIM:(AnIM *)anIM didGetClientId:(NSString *)clientId exception:(ArrownockException *)exception
{
    if (clientId && !exception)
        self.clientId = [clientId mutableCopy];
    else
        NSLog(@"AnIM cannot get client ID for chat! %s", __PRETTY_FUNCTION__);
}

- (void)anIM:(AnIM *)anIM didGetTopicList:(NSArray *)topics exception:(ArrownockException *)exception
{

    NSMutableSet *topicIds = [[NSMutableSet alloc]initWithCapacity:0];
    for (NSDictionary *dic in topics){
        /* EXAMPLE
         id = 550fbc28f38d66be4f000004;
         name = "userc,userd,usere";
         owner = "<null>";
         parties =     (
         AIMMLOUFJUKIE4XHNFG2YV9,
         AIMGQP5MCM61762KK8G1XJD,
         AIMFTITH9UNHB94MX2OR8YM
         );
         "parties_count" = 3;
         */
        [MessageUtil updatedTopicSessionWithUsers:dic[@"parties"] topicId:dic[@"id"] topicName:dic[@"name"] topicOwner:dic[@"owner"]];
        [topicIds addObject:dic[@"id"]];
    }
    [UserUtil removeTopicWithTopicIds:topicIds from:self.clientId];
    

    if (self.topicDelegate)
    {
        if ([self.topicDelegate respondsToSelector:@selector(anIMDidGetTopicList:errorCode:exception:)])
            [self.topicDelegate anIMDidGetTopicList:topics errorCode:exception.errorCode exception:exception.message];
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:RefreshFriendList object:nil];
}

#pragma mark - AnIM Topic Delegate

- (void)anIM:(AnIM *)anIM didCreateTopic:(NSString *)topicId exception:(ArrownockException *)exception
{
    if (self.topicDelegate)
    {
        if ([self.topicDelegate respondsToSelector:@selector(anIMDidCreateTopic:errorCode:exception:)])
            [self.topicDelegate anIMDidCreateTopic:topicId errorCode:exception.errorCode exception:exception.message];
    }
}

- (void)anIM:(AnIM *)anIM didGetTopicInfo:(NSString *)topicId name:(NSString *)topicName parties:(NSSet *)parties createdDate:(NSDate *)createdDate exception:(ArrownockException *)exception
{
    [MessageUtil updatedTopicSessionWithUsers:parties topicId:topicId topicName:topicName topicOwner:nil];
    
    if ([self.topicDelegate respondsToSelector:@selector(anIMDidGetTopicInfo:name:parties:createdDate:exception:)])
    {
        [self.topicDelegate anIMDidGetTopicInfo:topicId name:topicName parties:parties createdDate:createdDate exception:exception.message];
    }
}

- (void)anIM:(AnIM *)anIM didGetClientsStatus:(NSDictionary *)clientsStatus exception:(ArrownockException *)exception
{
    if ([self.topicDelegate respondsToSelector:@selector(anIMDidGetClientsStatus:exception:)])
    {
        [self.topicDelegate anIMDidGetClientsStatus:clientsStatus exception:exception.message];
    }
}

- (void)anIM:(AnIM *)anIM didUpdateStatus:(BOOL)status exception:(ArrownockException *)exception
{
    NSLog(@"AnIM status changed: %i", status);
    _imConnecting = NO;
    _clientStatus = status;
    if (self.isAppEnterBackground)return;
        
    if (!status)
    {
        UIWindow *displayWindow = [[[UIApplication sharedApplication] delegate] window];
        dispatch_async(dispatch_get_main_queue(), ^{
            [displayWindow makeImppToast:@"IM Disconnect" navigationBarHeight:0];
            [self performSelector:@selector(checkIMConnection) withObject:nil afterDelay:5.0];
        });
        
    }else{
        
        UIWindow *displayWindow = [[[UIApplication sharedApplication] delegate] window];
        dispatch_async(dispatch_get_main_queue(), ^{
            [displayWindow makeImppToast:@"IM Connect" navigationBarHeight:0];
        });
        /* just get topic once */
        if (!self.isGetTopicList) {
            [self.anIM getMyTopics];
            self.isGetTopicList = YES;
        }
        
        [MessageUtil getOfflineChatHistory];
        [MessageUtil getOfflineTopicHistory];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"connect" object:nil];
    }
    
}

#pragma mark - AnIM Chat Delgate

- (void)anIM:(AnIM *)anIM didAddClientsWithException:(ArrownockException *)exception
{
    if ([self.chatDelegate respondsToSelector:@selector(anIMDidAddClientsWithException:)])
    {
        [self.chatDelegate anIMDidAddClientsWithException:exception.message];
    }
}

- (void)anIM:(AnIM *)anIM messageSent:(NSString *)messageId
{
    if ([self.chatDelegate respondsToSelector:@selector(anIMMessageSent:)])
    {
        [self.chatDelegate anIMMessageSent:messageId];
    }
}

- (void)anIM:(AnIM *)anIM sendReturnedException:(ArrownockException *)exception messageId:(NSString *)messageId
{
    
    if ([self.chatDelegate respondsToSelector:@selector(anIMSendReturnedException:messageId:)])
    {
        [self.chatDelegate anIMSendReturnedException:exception.message messageId:messageId];
    }
}

- (void)anIM:(AnIM *)anIM didReceiveMessage:(NSString *)message customData:(NSDictionary *)customData from:(NSString *)from parties:(NSSet *)parties messageId:(NSString *)messageId at:(NSNumber *)timestamp
{
    
    /* configure location or text */
    NSString *fileType = [MessageUtil configureTextMessageType:customData];
    
    AnIMMessage *customMessage = [[AnIMMessage alloc]initWithType:AnIMTextMessage
                                                            msgId:messageId
                                                          topicId:@""
                                                          message:message
                                                          content:nil
                                                         fileType:fileType
                                                             from:from
                                                       customData:customData
                                                        timestamp:timestamp];
    
    HXMessage *hxCustomMessage = [MessageUtil anIMMessageToHXMessage:customMessage];
    
    if ([self.chatDelegate respondsToSelector:@selector(anIMDidReceiveMessage:customData:from:topicId:messageId:at:customMessage:)])
    {
        [self.chatDelegate anIMDidReceiveMessage:message
                                      customData:customData
                                            from:from
                                         topicId:@""
                                       messageId:messageId
                                              at:timestamp
                                   customMessage:hxCustomMessage];
    }
    [MessageUtil saveChatMessageIntoDB:@[customMessage] withTargetClientId:hxCustomMessage.from];
}

- (void)anIM:(AnIM *)anIM didReceiveMessage:(NSString *)message customData:(NSDictionary *)customData from:(NSString *)from topicId:(NSString *)topicId messageId:(NSString *)messageId at:(NSNumber *)timestamp
{
    
    /* configure location or text */
    NSString *fileType = [MessageUtil configureTextMessageType:customData];
    
    AnIMMessage *customMessage = [[AnIMMessage alloc]initWithType:AnIMTextMessage
                                                            msgId:messageId
                                                          topicId:topicId
                                                          message:message
                                                          content:nil
                                                         fileType:fileType
                                                             from:from
                                                       customData:customData
                                                        timestamp:timestamp];
    
    if ([self.chatDelegate respondsToSelector:@selector(anIMDidReceiveMessage:customData:from:topicId:messageId:at:customMessage:)])
    {
        [self.chatDelegate anIMDidReceiveMessage:message
                                      customData:customData
                                            from:from
                                         topicId:topicId
                                       messageId:messageId
                                              at:timestamp
                                   customMessage:[MessageUtil anIMMessageToHXMessage:customMessage]];
    }
    [MessageUtil saveTopicMessageIntoDB:@[customMessage]];
}

- (void)anIM:(AnIM *)anIM didReceiveBinary:(NSData *)data fileType:(NSString *)fileType customData:(NSDictionary *)customData from:(NSString *)from parties:(NSSet *)parties messageId:(NSString *)messageId at:(NSNumber *)timestamp
{
    if ([fileType isEqualToString:@"send"]) {
        if ([customData[@"type"] isEqualToString:@"approve"]) {
            
            NSLog(@"received approve message");
            HXUser *friend = [UserUtil getHXUserByClientId:from];
            [UserUtil updatedUserFriendsWithCurrentUser:[HXUserAccountManager manager].userInfo targetUser:friend];
            
            /* show toast*/
            UIWindow *displayWindow = [[[UIApplication sharedApplication] delegate] window];
            dispatch_async(dispatch_get_main_queue(), ^{
                [displayWindow makeImppToast:NSLocalizedString(@"好友邀請同意", nil) navigationBarHeight:0];
            });

        
            [[NSNotificationCenter defaultCenter]postNotificationName:RefreshFriendList object:nil];
            
        }else if ([customData[@"type"] isEqualToString:@"send"]){
            
            NSLog(@"received friend request ");
            /* show toast*/
            UIWindow *displayWindow = [[[UIApplication sharedApplication] delegate] window];
            dispatch_async(dispatch_get_main_queue(), ^{
                [displayWindow makeImppToast:NSLocalizedString(@"收到好友邀請", nil) navigationBarHeight:0];
            });
            NSNumber *unreadCount = [[NSUserDefaults standardUserDefaults] objectForKey:@"unreadFriendRequestCount"];
            [[NSUserDefaults standardUserDefaults] setObject:@([unreadCount intValue]+1) forKey:@"unreadFriendRequestCount"];
            [[NSNotificationCenter defaultCenter]postNotificationName:RefreshFriendList object:nil];
        }else{
            
            NSNumber *unreadCount = [[NSUserDefaults standardUserDefaults] objectForKey:@"unreadSocialNoticeCount"];
            [[NSUserDefaults standardUserDefaults] setObject:@([unreadCount intValue]+1) forKey:@"unreadSocialNoticeCount"];
            [[NSNotificationCenter defaultCenter]postNotificationName:UpdateFriendCircleBadge object:nil];
            
            UIWindow *displayWindow = [[[UIApplication sharedApplication] delegate] window];
            dispatch_async(dispatch_get_main_queue(), ^{
                [displayWindow makeImppToast:customData[@"notification_alert"] navigationBarHeight:0];
            });
        }
            
        return;
    }
    
    AnIMMessage *customMessage = [[AnIMMessage alloc]initWithType:AnIMBinaryMessage
                                                            msgId:messageId
                                                          topicId:@""
                                                          message:@""
                                                          content:data
                                                         fileType:fileType
                                                             from:from
                                                       customData:customData
                                                        timestamp:timestamp];
    
    HXMessage *hxCustomMessage = [MessageUtil anIMMessageToHXMessage:customMessage];
    
    if ([self.chatDelegate respondsToSelector:@selector(anIMDidReceiveBinaryData:fileType:customData:from:topicId:messageId:at:customMessage:)])
    {
        [self.chatDelegate anIMDidReceiveBinaryData:data
                                           fileType:fileType
                                         customData:customData
                                               from:from
                                            topicId:@""
                                          messageId:messageId
                                                 at:timestamp
                                      customMessage:[MessageUtil anIMMessageToHXMessage:customMessage]];
    }
    [MessageUtil saveChatMessageIntoDB:@[customMessage] withTargetClientId:hxCustomMessage.from];
}

- (void)anIM:(AnIM *)anIM didReceiveBinary:(NSData *)data fileType:(NSString *)fileType customData:(NSDictionary *)customData from:(NSString *)from topicId:(NSString *)topicId messageId:(NSString *)messageId at:(NSNumber *)timestamp
{
    
    AnIMMessage *customMessage = [[AnIMMessage alloc]initWithType:AnIMBinaryMessage
                                                            msgId:messageId
                                                          topicId:topicId
                                                          message:@""
                                                          content:data
                                                         fileType:fileType
                                                             from:from
                                                       customData:customData
                                                        timestamp:timestamp];
    
    if ([self.chatDelegate respondsToSelector:@selector(anIMDidReceiveBinaryData:fileType:customData:from:topicId:messageId:at:customMessage:)])
    {
        [self.chatDelegate anIMDidReceiveBinaryData:data
                                           fileType:fileType
                                         customData:customData
                                               from:from
                                            topicId:topicId
                                          messageId:messageId
                                                 at:timestamp
                                      customMessage:[MessageUtil anIMMessageToHXMessage:customMessage]];
    }
    [MessageUtil saveTopicMessageIntoDB:@[customMessage]];
    
}

- (void)anIM:(AnIM *)anIM didReceiveNotice:(NSString *)notice customData:(NSDictionary *)customData from:(NSString *)from topicId:(NSString *)topicId messageId:(NSString *)messageId at:(NSNumber *)timestamp
{
    
    if (self.noticeDelegate) {
        [self.noticeDelegate anIMDidReceiveNotice:notice customData:customData from:from topicId:topicId messageId:messageId at:timestamp];
    }
}

- (void)anIM:(AnIM *)anIM messageRead:(NSString *)messageId from:(NSString *)from
{
    [MessageUtil updateRemoteMessageReadAckByMessageId:messageId];
    //add notificaiton update badge
    [[NSNotificationCenter defaultCenter]postNotificationName:@"ReceiveRemoteReadAck" object:messageId];
}

#pragma mark - AnLive

- (void) onReceivedInvitation:(BOOL)isValid sessionId:(NSString*)sessionId partyId:(NSString*)partyId type:(NSString*)type createdAt:(NSDate*)createdAt
{
    [HXIMManager manager].anLiveCallStr = nil;
    HXUser *user = [UserUtil getHXUserByClientId:partyId];
    HXAnLiveViewController *vc = [[HXAnLiveViewController alloc] initWithClientName:user.userName
                                                                clientPhotoImageUrl:user.photoURL
                                                                               mode:[type isEqualToString:@"record"] ? AnLiveAudioCall : AnLiveVideoCall
                                                                               role:AnLiveReciever];
    
    [[self topViewController] presentViewController:vc animated:YES completion:nil];
}

- (void) onLocalVideoViewReady:(AnLiveLocalVideoView*)view
{
    if ([self.liveChatDelegate respondsToSelector:@selector(localVideoViewReady:)])
        [self.liveChatDelegate localVideoViewReady:view];
}

- (void) onLocalVideoSizeChanged:(CGSize)size
{
    if ([self.liveChatDelegate respondsToSelector:@selector(localVideoSizeChanged:)])
        [self.liveChatDelegate localVideoSizeChanged:size];
}

- (void) onRemotePartyConnected:(NSString*)partyId
{
    self.videoCallStartTime = [NSDate date];
    if ([self.liveChatDelegate respondsToSelector:@selector(remotePartyConnected:)])
        [self.liveChatDelegate remotePartyConnected:partyId];
}

- (void) onRemotePartyDisconnected:(NSString*)partyId
{
    NSDate *now = [NSDate date];
    NSTimeInterval passed = [now timeIntervalSinceDate:self.videoCallStartTime];
    int min = passed / 60;
    int second = passed - min *60;
    NSString *duration = [NSString stringWithFormat:@"%02d:%02d",min,second];

    [[NSNotificationCenter defaultCenter]postNotificationName:FinishVideoAudioCall
                                                       object:@{@"clientId":partyId,
                                                                @"duration":duration}];
    if ([self.liveChatDelegate respondsToSelector:@selector(remotePartyDisconnected:)])
        [self.liveChatDelegate remotePartyDisconnected:partyId];
}

- (void) onRemotePartyVideoViewReady:(NSString*)partyId remoteVideoView:(AnLiveVideoView*)view
{
    if ([self.liveChatDelegate respondsToSelector:@selector(remotePartyVideoViewReady:remoteVideoView:)])
        [self.liveChatDelegate remotePartyVideoViewReady:partyId remoteVideoView:view];
}

- (void) onRemotePartyVideoSizeChanged:(NSString*)partyId videoSize:(CGSize)size
{
    if ([self.liveChatDelegate respondsToSelector:@selector(remotePartyVideoSizeChanged:videoSize:)])
        [self.liveChatDelegate remotePartyVideoSizeChanged:partyId videoSize:size];
}

- (void) onRemotePartyVideoStateChanged:(NSString*)partyId state:(AnLiveVideoState)state
{
    if ([self.liveChatDelegate respondsToSelector:@selector(remotePartyVideoStateChanged:state:)])
        [self.liveChatDelegate remotePartyVideoStateChanged:partyId state:state];
}

- (void) onRemotePartyAudioStateChanged:(NSString*)partyId state:(AnLiveAudioState)state
{
    if ([self.liveChatDelegate respondsToSelector:@selector(remotePartyAudioStateChanged:state:)])
        [self.liveChatDelegate remotePartyAudioStateChanged:partyId state:state];
}

- (void) onError:(NSString*)partyId exception:(ArrownockException*)exception
{
    if ([self.liveChatDelegate respondsToSelector:@selector(error:exception:)])
        [self.liveChatDelegate error:partyId exception:exception];
}

#pragma mark - chat view helper

- (HXChatViewController *)getChatViewWithTargetClientId:(NSString *)targetClientId targetUserName:(NSString *)targetUserName currentUserName:(NSString *)currentUserName
{
    HXChat *chatSession = [ChatUtil createChatSessionWithCurrentClientId:[HXIMManager manager].clientId targetClientId:targetClientId currentUserName:currentUserName targetUserName:targetUserName];
    HXChatViewController *chatVc = [[HXChatViewController alloc]initWithChatInfo:chatSession setTopicMode:NO];
    return chatVc;
}

#pragma mark - Friend request
- (void)sendFriendRequestApprovedMessageWithClientId:(NSString *)clientId
{
    UInt8 j= 0x0f;
    NSData *data = [[NSData alloc] initWithBytes:&j length:sizeof(j)];
    [[[HXIMManager manager]anIM] sendBinary:data
                                   fileType:@"send"
                                 customData:@{@"type":@"approve"}
                                  toClients:[NSSet setWithObject:clientId]
                             needReceiveACK:NO];
}

- (void)sendFriendRequestMessageWithClientId:(NSString *)clientId targetUserName:(NSString *)username
{
    UInt8 j= 0x0f;
    NSData *data = [[NSData alloc] initWithBytes:&j length:sizeof(j)];
    [[[HXIMManager manager]anIM] sendBinary:data
                                   fileType:@"send"
                                 customData:@{@"type":@"send",
                                              @"username":username}
                                  toClients:[NSSet setWithObject:clientId]
                             needReceiveACK:NO];
}

#pragma mark - Social Notice

- (void)sendSocialNoticeWithClientId:(NSSet *)clientIds objectType:(NSString *)type objectInfo:(NSDictionary *)objectInfo notificationAlert:(NSString *)notificationAlert
{
    
    UInt8 j= 0x0f;
    NSData *data = [[NSData alloc] initWithBytes:&j length:sizeof(j)];
    NSDictionary *customData = @{@"type":type,
                                 @"objectInfo":objectInfo,
                                 @"notification_alert":notificationAlert};
    [[[HXIMManager manager]anIM] sendBinary:data
                                   fileType:@"send"
                                 customData:customData
                                  toClients:clientIds
                             needReceiveACK:NO];
}

#pragma mark - Helper

- (UIViewController*)topViewController {
    return [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}


@end
