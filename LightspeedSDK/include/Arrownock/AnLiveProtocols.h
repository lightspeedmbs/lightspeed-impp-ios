#import <Foundation/Foundation.h>
#import "ArrownockException.h"

@protocol AnLiveMediaStreamsDelegate <NSObject>
- (void)onVideoSizeChanged:(double)width height:(double)height isLocal:(BOOL)isLocal isFirstTime:(BOOL)isFirstTime;
@end

@protocol AnLiveSignalEventDelegate <NSObject>
@required
- (void) onSessionCreated:(NSString*)sessionId partyIds:(NSSet*)partyIds type:(NSString *)type error:(ArrownockException*)error;
- (void) onSessionValidated:(BOOL)isValid sessionId:(NSString*)sessionId partyIds:(NSSet*)partyIds type:(NSString*)type date:(NSDate*)date;
- (void) onInvitationRecieved:(NSString*)sessionId;
- (void) onRemoteHangup:(NSString*)partyId;
- (void) onOfferRecieved:(NSString*)partyId offerJson:(NSString*)offerJson orientation:(int)orientation;
- (void) onAnswerRecieved:(NSString*)partyId answerJson:(NSString*)answerJson orientation:(int)orientation;
- (void) onICECandidate:(NSString*)partyId candidateJson:(NSString*)candidateJson;
@end

// signal controler interface
@protocol AnLiveSignalController <NSObject>
@required
- (BOOL) isOnline;
- (NSString*) getPartyId;
- (void) createSession:(NSSet*)partyIds type:(NSString *)type;
- (void) validateSession:(NSString*)sessionId;
- (void) terminateSession:(NSString*)sessionId;
- (void) sendInvitations:(NSString*)sessionId partyIds:(NSSet*) partyIds type:(NSString *)type notificationData:(NSDictionary*) data;
- (void) sendHangup:(NSSet*)partyIds;

- (void) sendOffer:(NSString*)partyId sdp:(NSString*)sdp orientation:(int)orientation;
- (void) sendAnswer:(NSString*)partyId sdp:(NSString*)sdp orientation:(int)orientation;
- (void) sendICECandidate:(NSString*)partyId candidateJson:(NSString*)candidateJson;
- (void) setSignalEventDelegate:(id <AnLiveSignalEventDelegate>)delegate;
@end