#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AnLiveProtocols.h"

@interface AnLiveVideoView : UIView 

@property (nonatomic, readonly) float videoWidth;
@property (nonatomic, readonly) float videoHeight;

@property (nonatomic, weak) id <AnLiveMediaStreamsDelegate> delegate;
- (void) clearView;
@end