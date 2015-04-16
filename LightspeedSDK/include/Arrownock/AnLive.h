#import <Foundation/Foundation.h>
#import "AnLiveProtocols.h"
#import "AnLiveLocalVideoView.h"
#import "ArrownockException.h"

typedef enum {
    AnLiveVideoOff,
    AnLiveVideoOn
} AnLiveVideoState;

typedef enum {
    AnLiveAudioOff,
    AnLiveAudioOn
} AnLiveAudioState;

@protocol AnLiveEventDelegate <NSObject>
@required
- (void) onReceivedInvitation:(BOOL)isValid sessionId:(NSString*)sessionId partyId:(NSString*)partyId type:(NSString*)type createdAt:(NSDate*)createdAt;

- (void) onLocalVideoViewReady:(AnLiveLocalVideoView*)view;
- (void) onLocalVideoSizeChanged:(CGSize)size;

- (void) onRemotePartyConnected:(NSString*)partyId;
- (void) onRemotePartyDisconnected:(NSString*)partyId;

- (void) onRemotePartyVideoViewReady:(NSString*)partyId remoteVideoView:(AnLiveVideoView*)view;
- (void) onRemotePartyVideoSizeChanged:(NSString*)partyId videoSize:(CGSize)size;
- (void) onRemotePartyVideoStateChanged:(NSString*)partyId state:(AnLiveVideoState)state;
- (void) onRemotePartyAudioStateChanged:(NSString*)partyId state:(AnLiveAudioState)state;

- (void) onError:(NSString*)partyId exception:(ArrownockException*)exception;
@end

@interface AnLive : NSObject 
+ (void) setup:(id <AnLiveSignalController>)controller delegate:(id <AnLiveEventDelegate>)delegate;
+ (AnLive *)shared;

- (void) videoCall:(NSString *)partyId video:(BOOL)onOrOff notificationData:(NSDictionary *)data success:(void (^)(NSString* sessionId))success failure:(void (^)(ArrownockException* error))failure;
- (void) voiceCall:(NSString *)partyId notificationData:(NSDictionary *)data success:(void (^)(NSString* sessionId))success failure:(void (^)(ArrownockException* error))failure;
- (void) answer:(BOOL)videoOn;
- (void) hangup;
- (BOOL) isOnCall;
- (NSString *)getCurrentSessionType;

- (void) setAudioState:(AnLiveAudioState)state;
- (void) setVideoState:(AnLiveVideoState)state;
@end