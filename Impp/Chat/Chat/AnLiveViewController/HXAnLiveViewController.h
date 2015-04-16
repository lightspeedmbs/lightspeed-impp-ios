//
//  HXAnLiveViewController.h
//  iBeacon
//
//  Created by Tim on 3/24/15.
//  Copyright (c) 2015 Herxun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    AnLiveVideoCall,
    AnLiveAudioCall
} AnLiveMode;

typedef enum {
    AnLiveCaller,
    AnLiveReciever
} AnLiveRole;

@interface HXAnLiveViewController : UIViewController

- (id)initWithClientName:(NSString *)clientName clientPhotoImageUrl:(NSString *)clientPhotoImageUrl mode:(AnLiveMode)anLiveMode role:(AnLiveRole)anLiveRole;
- (id)initAndAnswerWithClientName:(NSString *)clientName;

@end
