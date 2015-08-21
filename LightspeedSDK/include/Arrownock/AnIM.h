//
//  AnIM.h
//  AnIM
//
//  Copyright (c) 2014 arrownock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ArrownockException.h"
#import "AnLiveProtocols.h"

@class AnIM;
@protocol AnIMDelegate <NSObject>

@optional
- (void)anIM:(AnIM *)anIM messageSent:(NSString *)messageId at:(NSNumber *)timestamp;
- (void)anIM:(AnIM *)anIM sendReturnedException:(ArrownockException *)exception messageId:(NSString *)messageId;
- (void)anIM:(AnIM *)anIM messageReceived:(NSString *)messageId from:(NSString *)from;
- (void)anIM:(AnIM *)anIM messageRead:(NSString *)messageId from:(NSString *)from;

- (void)anIM:(AnIM *)anIM didReceiveMessage:(NSString *)message customData:(NSDictionary *)customData from:(NSString *)from parties:(NSSet *)parties messageId:(NSString *)messageId at:(NSNumber *)timestamp;
- (void)anIM:(AnIM *)anIM didReceiveBinary:(NSData *)data fileType:(NSString *)fileType customData:(NSDictionary *)customData from:(NSString *)from parties:(NSSet *)parties messageId:(NSString *)messageId at:(NSNumber *)timestamp;
- (void)anIM:(AnIM *)anIM didReceiveMessage:(NSString *)message customData:(NSDictionary *)customData from:(NSString *)from topicId:(NSString *)topicId messageId:(NSString *)messageId at:(NSNumber *)timestamp;
- (void)anIM:(AnIM *)anIM didReceiveBinary:(NSData *)data fileType:(NSString *)fileType customData:(NSDictionary *)customData from:(NSString *)from topicId:(NSString *)topicId messageId:(NSString *)messageId at:(NSNumber *)timestamp;
- (void)anIM:(AnIM *)anIM didReceiveNotice:(NSString *)notice customData:(NSDictionary *)customData from:(NSString *)from topicId:(NSString *)topicId messageId:(NSString *)messageId at:(NSNumber *)timestamp;

//------------------------------------------
//receive topic updated events
- (void)anIM:(AnIM *)anIM didReceiveCreateTopicEvent:(NSString *)eventId from:(NSString *)from topicId:(NSString *)topicId owner:(NSString *)owner name:(NSString *)topicName parties:(NSSet *)parties at:(NSNumber *)timestamp;
- (void)anIM:(AnIM *)anIM didReceiveUpdateTopicEvent:(NSString *)eventId from:(NSString *)from topicId:(NSString *)topicId owner:(NSString *)owner name:(NSString *)topicName at:(NSNumber *)timestamp;
- (void)anIM:(AnIM *)anIM didReceiveAddClientsToTopicEvent:(NSString *)eventId from:(NSString *)from topicId:(NSString *)topicId parties:(NSSet *)parties at:(NSNumber *)timestamp;
- (void)anIM:(AnIM *)anIM didReceiveRemoveClientsFromTopicEvent:(NSString *)eventId from:(NSString *)from topicId:(NSString *)topicId parties:(NSSet *)parties at:(NSNumber *)timestamp;
- (void)anIM:(AnIM *)anIM didReceiveRemoveTopicEvent:(NSString *)eventId from:(NSString *)from topicId:(NSString *)topicId at:(NSNumber *)timestamp;

//------------------------------------------
// return the error with ArrownockException
- (void)anIM:(AnIM *)anIM didGetClientId:(NSString *)clientId exception:(ArrownockException *)exception;
- (void)anIM:(AnIM *)anIM didUpdateStatus:(BOOL)status exception:(ArrownockException *)exception;
- (void)anIM:(AnIM *)anIM didCreateTopic:(NSString *)topicId exception:(ArrownockException *)exception;
- (void)anIM:(AnIM *)anIM didUpdateTopicWithException:(ArrownockException *)exception;
- (void)anIM:(AnIM *)anIM didAddClientsWithException:(ArrownockException *)exception;
- (void)anIM:(AnIM *)anIM didRemoveClientsWithException:(ArrownockException *)exception;
- (void)anIM:(AnIM *)anIM didRemoveTopic:(NSString *)topicId exception:(ArrownockException *)exception;
- (void)anIM:(AnIM *)anIM didGetTopicInfo:(NSString *)topicId name:(NSString *)topicName parties:(NSSet *)parties createdDate:(NSDate *)createdDate exception:(ArrownockException *)exception;
- (void)anIM:(AnIM *)anIM didGetTopicLog:(NSArray *)logs exception:(ArrownockException *)exception __attribute__((deprecated));
- (void)anIM:(AnIM *)anIM didGetTopicList:(NSArray *)topics exception:(ArrownockException *)exception;
- (void)anIM:(AnIM *)anIM didBindServiceWithException:(ArrownockException *)exception;
- (void)anIM:(AnIM *)anIM didUnbindServiceWithException:(ArrownockException *)exception;
- (void)anIM:(AnIM *)anIM didGetClientsStatus:(NSDictionary *)clientsStatus exception:(ArrownockException *)exception;
- (void)anIM:(AnIM *)anIM didGetSessionInfo:(NSString *)sessionId parties:(NSSet *)parties exception:(ArrownockException *)exception;
@end

typedef enum {
    AnPushTypeiOS,
    AnPushTypeAndroid,
    AnPushTypeWP8
} AnPushType;

typedef enum {
    AnIMTextMessage,
    AnIMBinaryMessage
} AnIMMessageType;

@interface AnIM : NSObject <AnLiveSignalController>
- (AnIM *)initWithAppKey:(NSString *)appKey delegate:(id <AnIMDelegate>)delegate secure:(BOOL)secure;

- (void)getClientId:(NSString *)userId __attribute__((deprecated("Use getClientId:userId success failure instead.")));
- (void)getClientId:(NSString *)userId success:(void (^)(NSString *clientId))success failure:(void (^)(ArrownockException *exception))failure;
- (NSString *)getRemoteClientId:(NSString *)userId;
- (void)connect:(NSString *)clientId;
- (void)disconnect;

// deprecated private chat methods
- (NSString *)sendMessage:(NSString *)message toClients:(NSSet *)clientIds needReceiveACK:(BOOL)need  __attribute__((deprecated("Use sendMessage:toClient:needReceiveACK instead.")));
- (NSString *)sendMessage:(NSString *)message customData:(NSDictionary *)customData toClients:(NSSet *)clientIds needReceiveACK:(BOOL)need __attribute__((deprecated("Use sendMessage:customData:toClient:needReceiveACK instead.")));
- (NSString *)sendBinary:(NSData *)data fileType:(NSString *)fileType toClients:(NSSet *)clientIds needReceiveACK:(BOOL)need __attribute__((deprecated("Use sendBinary:fileType:toClient:needReceiveACK instead.")));
- (NSString *)sendBinary:(NSData *)data fileType:(NSString *)fileType customData:(NSDictionary *)customData toClients:(NSSet *)clientIds needReceiveACK:(BOOL)need __attribute__((deprecated("Use sendBinary:fileType:customData:toClient:needReceiveACK instead.")));
// end

- (NSString *)sendMessage:(NSString *)message toClient:(NSString *)clientId needReceiveACK:(BOOL)need;
- (NSString *)sendMessage:(NSString *)message customData:(NSDictionary *)customData toClient:(NSString *)clientId needReceiveACK:(BOOL)need;
- (NSString *)sendBinary:(NSData *)data fileType:(NSString *)fileType toClient:(NSString *)clientId needReceiveACK:(BOOL)need;
- (NSString *)sendBinary:(NSData *)data fileType:(NSString *)fileType customData:(NSDictionary *)customData toClient:(NSString *)clientId needReceiveACK:(BOOL)need;

- (NSString *)sendMessage:(NSString *)message toTopicId:(NSString *)topicId needReceiveACK:(BOOL)need;
- (NSString *)sendMessage:(NSString *)message toTopicId:(NSString *)topicId needReceiveACK:(BOOL)need mentionedClientIds:(NSSet*)clientIds;
- (NSString *)sendMessage:(NSString *)message customData:(NSDictionary *)customData toTopicId:(NSString *)topicId needReceiveACK:(BOOL)need;
- (NSString *)sendMessage:(NSString *)message customData:(NSDictionary *)customData toTopicId:(NSString *)topicId needReceiveACK:(BOOL)need mentionedClientIds:(NSSet*)clientIds;
- (NSString *)sendBinary:(NSData *)data fileType:(NSString *)fileType toTopicId:(NSString *)topicId needReceiveACK:(BOOL)need;
- (NSString *)sendBinary:(NSData *)data fileType:(NSString *)fileType customData:(NSDictionary *)customData toTopicId:(NSString *)topicId needReceiveACK:(BOOL)need;

- (NSString *)sendNotice:(NSString *)notice toClients:(NSSet *)clientIds needReceiveACK:(BOOL)need;
- (NSString *)sendNotice:(NSString *)notice customData:(NSDictionary *)customData toClients:(NSSet *)clientIds needReceiveACK:(BOOL)need;
- (NSString *)sendNotice:(NSString *)notice toTopicId:(NSString *)topicId needReceiveACK:(BOOL)need;
- (NSString *)sendNotice:(NSString *)notice customData:(NSDictionary *)customData toTopicId:(NSString *)topicId needReceiveACK:(BOOL)need;

- (NSString *)sendReadACK:(NSString *)messageId toClients:(NSSet *)clientIds __attribute__((deprecated("Use sendReadACK:toClient instead.")));
- (NSString *)sendReadACK:(NSString *)messageId toClient:(NSString *)clientId;
- (NSString *)sendReadACKBatch:(NSSet *)messageIds toClient:(NSString *)clientId;

- (void)createTopic:(NSString *)topicName __attribute__((deprecated("Use createTopic:topicName success failure instead.")));
- (void)createTopic:(NSString *)topicName success:(void (^)(NSString *topicId, NSNumber *createdTimestamp, NSNumber *updatedTimestamp))success failure:(void (^)(ArrownockException *exception))failure;
- (void)createTopic:(NSString *)topicName withClients:(NSSet *)clientIds __attribute__((deprecated("Use createTopic:topicName clientIds success failure instead.")));
- (void)createTopic:(NSString *)topicName withClients:(NSSet *)clientIds success:(void (^)(NSString *topicId, NSNumber *createdTimestamp, NSNumber *updatedTimestamp))success failure:(void (^)(ArrownockException *exception))failure;
- (void)createTopic:(NSString *)topicName withOwner:(NSString *)owner withClients:(NSSet *)clientIds __attribute__((deprecated("Use createTopic:topicName owner clientIds success failure instead.")));
- (void)createTopic:(NSString *)topicName withOwner:(NSString *)owner withClients:(NSSet *)clientIds success:(void (^)(NSString *topicId, NSNumber *createdTimestamp, NSNumber *updatedTimestamp))success failure:(void (^)(ArrownockException *exception))failure;
- (void)createTopic:(NSString *)topicName withOwner:(NSString *)owner withClients:(NSSet *)clientIds isNeedNotice:(BOOL)isNeedNotice currentClientId:(NSString *)currentClientId success:(void (^)(NSString *topicId, NSNumber *createdTimestamp, NSNumber *updatedTimestamp))success failure:(void (^)(ArrownockException *exception))failure;
- (void)updateTopic:(NSString *)topicId withName:(NSString *)topicName withOwner:(NSString *)owner __attribute__((deprecated("Use updateTopic:topicId topicName owner success failure instead.")));
- (void)updateTopic:(NSString *)topicId withName:(NSString *)topicName withOwner:(NSString *)owner success:(void (^)(NSString *topicId, NSNumber *createdTimestamp, NSNumber *updatedTimestamp))success failure:(void (^)(ArrownockException *exception))failure;
- (void)updateTopic:(NSString *)topicId withName:(NSString *)topicName withOwner:(NSString *)owner isNeedNotice:(BOOL)isNeedNotice currentClientId:(NSString *)currentClientId success:(void (^)(NSString *topicId, NSNumber *createdTimestamp, NSNumber *updatedTimestamp))success failure:(void (^)(ArrownockException *exception))failure;
- (void)addClients:(NSSet *)clientIds toTopicId:(NSString *)topicId __attribute__((deprecated("Use addClients:clientIds topicId success failure instead.")));
- (void)addClients:(NSSet *)clientIds toTopicId:(NSString *)topicId success:(void (^)(NSString *topicId, NSNumber *createdTimestamp, NSNumber *updatedTimestamp))success failure:(void (^)(ArrownockException *exception))failure;
- (void)addClients:(NSSet *)clientIds toTopicId:(NSString *)topicId isNeedNotice:(BOOL)isNeedNotice currentClientId:(NSString *)currentClientId success:(void (^)(NSString *topicId, NSNumber *createdTimestamp, NSNumber *updatedTimestamp))success failure:(void (^)(ArrownockException *exception))failure;
- (void)removeClients:(NSSet *)clientIds fromTopicId:(NSString *)topicId __attribute__((deprecated("Use removeClients:clientIds topicId success failure instead.")));
- (void)removeClients:(NSSet *)clientIds fromTopicId:(NSString *)topicId success:(void (^)(NSString *topicId, NSNumber *createdTimestamp, NSNumber *updatedTimestamp))success failure:(void (^)(ArrownockException *exception))failure;
- (void)removeClients:(NSSet *)clientIds fromTopicId:(NSString *)topicId isNeedNotice:(BOOL)isNeedNotice currentClientId:(NSString *)currentClientId success:(void (^)(NSString *topicId, NSNumber *createdTimestamp, NSNumber *updatedTimestamp))success failure:(void (^)(ArrownockException *exception))failure;
- (void)removeTopic:(NSString *)topicId __attribute__((deprecated("Use removeTopic:topicId success failure instead.")));
- (void)removeTopic:(NSString *)topicId success:(void (^)(NSString *topicId, NSNumber *createdTimestamp, NSNumber *updatedTimestamp))success failure:(void (^)(ArrownockException *exception))failure;
- (void)removeTopic:(NSString *)topicId isNeedNotice:(BOOL)isNeedNotice currentClientId:(NSString *)currentClientId success:(void (^)(NSString *topicId, NSNumber *createdTimestamp, NSNumber *updatedTimestamp))success failure:(void (^)(ArrownockException *exception))failure;
- (void)getTopicInfo:(NSString *)topicId __attribute__((deprecated("Use getTopicInfo:topicId success failure instead.")));
- (void)getTopicInfo:(NSString *)topicId success:(void (^)(NSString *topicId, NSString *topicName, NSString *owner, NSSet *parties, NSDate *createdDate))success failure:(void (^)(ArrownockException *exception))failure;
- (void)getTopicLog:(NSString *)topicId start:(NSDate *)start end:(NSDate *)end __attribute__((deprecated));

- (void)getTopicHistory:(NSString *)topicId clientId:(NSString *)clientId limit:(int)limit timestamp:(NSNumber *)timestamp success:(void (^)(NSArray *messages))success failure:(void (^)(ArrownockException *exception))failure;

- (void)getFullTopicHistory:(NSString *)topicId limit:(int)limit timestamp:(NSNumber *)timestamp success:(void (^)(NSArray *messages))success failure:(void (^)(ArrownockException *exception))failure;

- (void)getFullTopicHistory:(NSString *)topicId clientId:(NSString *)clientId limit:(int)limit timestamp:(NSNumber *)timestamp success:(void (^)(NSArray *messages))success failure:(void (^)(ArrownockException *exception))failure;

- (void)getHistory:(NSSet *)clientIds clientId:(NSString *)clientId limit:(int)limit timestamp:(NSNumber *)timestamp success:(void (^)(NSArray *messages))success failure:(void (^)(ArrownockException *exception))failure;

- (void)getOfflineTopicHistory:(NSString *)clientId limit:(int)limit success:(void (^)(NSArray *messages, int count))success failure:(void (^)(ArrownockException *exception))failure;

- (void)getOfflineTopicHistory:(NSString *)topicId clientId:(NSString *)clientId limit:(int)limit success:(void (^)(NSArray *messages, int count))success failure:(void (^)(ArrownockException *exception))failure;

- (void)getOfflineHistory:(NSString *)clientId limit:(int)limit success:(void (^)(NSArray *messages, int count))success failure:(void (^)(ArrownockException *exception))failure;

- (void)getOfflineHistory:(NSSet *)clientIds clientId:(NSString *)clientId limit:(int)limit success:(void (^)(NSArray *messages, int count))success failure:(void (^)(ArrownockException *exception))failure;

- (void)getAllTopics __attribute__((deprecated("Use getTopicList:success:failure instead.")));
- (void)getMyTopics __attribute__((deprecated("Use getTopicList:clientId:success:failure instead.")));
- (void)getTopicList:(void (^)(NSMutableArray *topicList))success failure:(void (^)(ArrownockException *exception))failure;
- (void)getTopicList:(NSString *)clientId success:(void (^)(NSMutableArray *topicList))success failure:(void (^)(ArrownockException *exception))failure;

- (void)bindAnPushService:(NSString *)anId appKey:(NSString *)appKey deviceType:(AnPushType)deviceType __attribute__((deprecated("Use bindAnPushService:anId appKey clientId success failure instead.")));
- (void)bindAnPushService:(NSString *)anId appKey:(NSString *)appKey clientId:(NSString *)clientId success:(void (^)())success failure:(void (^)(ArrownockException *exception))failure;
- (void)unbindAnPushService:(AnPushType)deviceType __attribute__((deprecated("Use unbindAnPushService:deviceType success failure instead.")));
- (void)unbindAnPushService:(AnPushType)deviceType success:(void (^)())success failure:(void (^)(ArrownockException *exception))failure __attribute__((deprecated("Use unbindAnPushService:anId:appKey:clientId:success:failure instead.")));
- (void)unbindAnPushService:(NSString *)anId appKey:(NSString *)appKey clientId:(NSString *)clientId success:(void (^)())success failure:(void (^)(ArrownockException *exception))failure;

- (void)getClientsStatus:(NSSet *)clientIds __attribute__((deprecated("Use getClientsStatus:clientIds success failure instead.")));;
- (void)getClientsStatus:(NSSet *)clientIds success:(void (^)(NSDictionary *clientsStatus))success failure:(void (^)(ArrownockException *exception))failure;
- (void)getClientsStatusOfTopic:(NSString *)topicId __attribute__((deprecated("Use getClientsStatus:topicId success failure instead.")));;;
- (void)getClientsStatusOfTopic:(NSString *)topicId success:(void (^)(NSDictionary *clientsStatus))success failure:(void (^)(ArrownockException *exception))failure;
- (void)getSessionInfo:(NSString *)sessionId;

- (void)setPushNotificationForChatSession:(NSString *)clientId isEnable:(BOOL)isEnable success:(void (^)())success failure:(void (^)(ArrownockException *exception))failure;
- (void)setPushNotificationForTopic:(NSString *)clientId isEnable:(BOOL)isEnable success:(void (^)())success failure:(void (^)(ArrownockException *exception))failure;
- (void)setPushNotificationForNotice:(NSString *)clientId isEnable:(BOOL)isEnable success:(void (^)())success failure:(void (^)(ArrownockException *exception))failure;
- (void)enablePushNotificationForTopics:(NSString *)clientId topicIds:(NSSet *)topicIds success:(void (^)())success failure:(void (^)(ArrownockException *exception))failure;
- (void)disablePushNotificationForTopics:(NSString *)clientId topicIds:(NSSet *)topicIds success:(void (^)())success failure:(void (^)(ArrownockException *exception))failure;
- (void)setPushNotificationForMentioning:(NSString *)clientId isEnable:(BOOL)isEnable success:(void (^)())success failure:(void (^)(ArrownockException *exception))failure;

- (void)setHosts:(NSString *)apiHost dsHost:(NSString *)dsHost;
@end
