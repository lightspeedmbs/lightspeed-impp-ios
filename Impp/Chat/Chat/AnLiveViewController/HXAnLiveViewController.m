//
//  HXAnLiveViewController.m
//  iBeacon
//
//  Created by Tim on 3/24/15.
//  Copyright (c) 2015 Herxun. All rights reserved.
//

#import "HXAnLiveViewController.h"
#import "UIColor+CustomColor.h"
#import "UILabel+customLabel.h"
#import "UIFont+customFont.h"
#import "HXAppUtility.h"
#import "HXIMManager.h"
#import "HXRoundButton.h"
#import "AnLive.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface HXAnLiveViewController () <HXIMManagerLiveChatDelegate>
@property (strong, nonatomic) UIView *targetStreamView;
@property (strong, nonatomic) UIView *meStreamView;
@property (strong, nonatomic) UIView *labelBg;
@property (strong, nonatomic) UIView *threeButtonBg;
@property (strong, nonatomic) UIView *twoButtonBg;
@property (strong, nonatomic) UILabel *statusLabel;
@property (strong, nonatomic) HXRoundButton *cancelButton;
@property (strong, nonatomic) HXRoundButton *muteButton;
@property (strong, nonatomic) HXRoundButton *noVideoButton;
@property (strong, nonatomic) HXRoundButton *rightButton;
@property (strong, nonatomic) HXRoundButton *leftButton;
@property BOOL answerCall;
@property (weak, nonatomic) AnLiveVideoView *localVideo;
@property (weak, nonatomic) AnLiveVideoView *remoteVideo;
@property AnLiveMode anLiveMode;
@property BOOL videoState;
@property BOOL audioState;
@property (strong, nonatomic) NSString *clientName;
@property (strong, nonatomic) NSString *clientPhotoImageUrl;
@end

@implementation HXAnLiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [HXIMManager manager].liveChatDelegate = self;
    
}

- (id)initWithClientName:(NSString *)clientName clientPhotoImageUrl:(NSString *)clientPhotoImageUrl mode:(AnLiveMode)anLiveMode role:(AnLiveRole)anLiveRole
{
    self = [super init];
    if (self)
    {
        self.clientName = clientName;
        self.clientPhotoImageUrl = clientPhotoImageUrl;
        self.anLiveMode = anLiveMode;
        [self initView];
        _videoState = YES;
        _audioState = YES;
        
        if (anLiveMode == AnLiveVideoCall && anLiveRole == AnLiveReciever) {
            self.threeButtonBg.hidden = YES;
            [self.rightButton updateTitle:NSLocalizedString(@"接聽", nil) backgroundColor:[HXAppUtility hexToColor:0x8fc31f alpha:1]];
            [self.leftButton updateTitle:NSLocalizedString(@"拒絕", nil) backgroundColor:[UIColor redColor]];
            self.statusLabel.text = NSLocalizedString(@"視訊通話來電中...", nil);
        }
        
        if (anLiveMode == AnLiveVideoCall && anLiveRole == AnLiveCaller) {
            self.twoButtonBg.hidden = YES;
            self.statusLabel.text = NSLocalizedString(@"正在等待對方接受邀請...", nil);
        }
        
        if (anLiveMode == AnLiveAudioCall && anLiveRole == AnLiveReciever) {
            self.threeButtonBg.hidden = YES;
            [self.rightButton updateTitle:NSLocalizedString(@"接聽", nil) backgroundColor:[HXAppUtility hexToColor:0x8fc31f alpha:1]];
            [self.leftButton updateTitle:NSLocalizedString(@"拒絕", nil) backgroundColor:[UIColor redColor]];
            self.statusLabel.text = NSLocalizedString(@"語音通話來電中...", nil);
        }
        
        if (anLiveMode == AnLiveAudioCall && anLiveRole == AnLiveCaller) {
            self.threeButtonBg.hidden = YES;
            [self.rightButton updateTitle:NSLocalizedString(@"掛斷", nil) backgroundColor:[UIColor redColor]];
            [self.leftButton updateTitle:NSLocalizedString(@"靜音", nil) backgroundColor:[UIColor color2]];
            self.statusLabel.text = NSLocalizedString(@"正在等待對方接受邀請...", nil);
        }
        
    }
    return self;
}

- (id)initAndAnswerWithClientName:(NSString *)clientName
{
    self = [super init];
    if (self)
    {
        self.clientName = clientName;
        _answerCall = YES;
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)initView
{
    self.view.backgroundColor = [UIColor blackColor];
    CGRect frame;
    
    // photoIcon
    UIImageView *photoIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"friend_default"]];
    photoIcon.frame = CGRectMake(self.view.center.x - 74/2, self.view.frame.size.height * .18, 74, 74);
    photoIcon.contentMode = UIViewContentModeScaleAspectFill;
    photoIcon.layer.cornerRadius = 74/2;
    photoIcon.clipsToBounds = YES;
    photoIcon.layer.masksToBounds = YES;
    [self.view addSubview:photoIcon];
    
    if (self.clientPhotoImageUrl && ![self.clientPhotoImageUrl isEqualToString:@""]) {
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager downloadWithURL:[NSURL URLWithString:self.clientPhotoImageUrl]
                         options:0
                        progress:^(NSInteger receivedSize, NSInteger expectedSize){}
                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished){
                           if (image) {
                               photoIcon.image = image;
                               photoIcon.contentMode = UIViewContentModeScaleAspectFill;
                               photoIcon.clipsToBounds = YES;
                           }
                           
                       }];
    }
    
    // target stream view
    self.targetStreamView = [[UIView alloc] initWithFrame:self.view.frame];
    self.targetStreamView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.targetStreamView];
    
    // name label
    UILabel *nameTitleLabel = [UILabel labelWithFrame:CGRectNull
                                                 text:self.clientName
                                        textAlignment:NSTextAlignmentCenter
                                            textColor:[UIColor color5]
                                                 font:[UIFont fontWithName:@"STHeitiTC-Medium" size:21]
                                        numberOfLines:1];
    nameTitleLabel.frame = CGRectMake(0, 0, self.view.frame.size.width, nameTitleLabel.frame.size.height);
    
    // status label
    self.statusLabel = [UILabel labelWithFrame:CGRectNull
                                          text:NSLocalizedString(@"正在等待對方接受邀請...", nil)
                                 textAlignment:NSTextAlignmentCenter
                                     textColor:[UIColor color5]
                                          font:[UIFont heitiLightWithSize:14]
                                 numberOfLines:1];
    
    self.statusLabel.frame = CGRectMake(0,nameTitleLabel.frame.origin.y + nameTitleLabel.frame.size.height + 10,
                                        self.view.frame.size.width,
                                        self.statusLabel.frame.size.height);
    
    // label bg
    self.labelBg = [[UIView alloc] initWithFrame:CGRectMake(0,photoIcon.frame.origin.y + photoIcon.frame.size.height + 15,
                                                            self.view.bounds.size.width,
                                                            self.statusLabel.frame.size.height + nameTitleLabel.frame.size.height + 10)];
    self.labelBg.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.labelBg];
    [self.labelBg addSubview:nameTitleLabel];
    [self.labelBg addSubview:self.statusLabel];
    
    
    // three button bg
    self.threeButtonBg = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height -30 - 36, self.view.bounds.size.width, 30 + 36)];
    self.threeButtonBg.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.threeButtonBg];
    
    //my stream view
    self.meStreamView = [[UIView alloc] initWithFrame:CGRectMake(self.view.center.x - 74/2, self.threeButtonBg.frame.origin.y - 30 - 111,74,111)];
    self.meStreamView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.meStreamView];
    
    // mute button
    frame.size.width = (self.threeButtonBg.bounds.size.width -30 -6 -6 -30) /3;
    frame.size.height = 36;
    frame.origin.x = 30;
    frame.origin.y = 0;
    self.muteButton = [[HXRoundButton alloc]initWithTitle:NSLocalizedString(@"靜音", nil) titleColor:[UIColor color5] backgroundColor:[UIColor color2] frame:frame];
    [self.muteButton addTarget:self action:@selector(muteButtonListener:) forControlEvents:UIControlEventTouchUpInside];
    [self.muteButton addTarget:self action:@selector(buttonDownListener:) forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragEnter];
    [self.muteButton addTarget:self action:@selector(buttonUpListener:) forControlEvents:UIControlEventTouchUpOutside | UIControlEventTouchDragExit];
    [self.threeButtonBg addSubview:self.muteButton];

    // no video button
    frame.size.width = (self.threeButtonBg.bounds.size.width -30 -6 -6 -30) /3;
    frame.size.height = 36;
    frame.origin.x = 6 +self.muteButton.frame.origin.x +self.muteButton.bounds.size.width;
    frame.origin.y = 0;
    self.noVideoButton = [[HXRoundButton alloc]initWithTitle:NSLocalizedString(@"關閉鏡頭", nil) titleColor:[UIColor color5] backgroundColor:[UIColor color2] frame:frame];
    
    [self.noVideoButton addTarget:self action:@selector(noVideoButtonListener:) forControlEvents:UIControlEventTouchUpInside];
    [self.noVideoButton addTarget:self action:@selector(buttonDownListener:) forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragEnter];
    [self.noVideoButton addTarget:self action:@selector(buttonUpListener:) forControlEvents:UIControlEventTouchUpOutside | UIControlEventTouchDragExit];
    [self.threeButtonBg addSubview:self.noVideoButton];

    // cancel button
    frame.size.width = (self.threeButtonBg.bounds.size.width -30 -6 -6 -30) /3;
    frame.size.height = 36;
    frame.origin.x = 6 +self.noVideoButton.frame.origin.x +self.noVideoButton.bounds.size.width;
    frame.origin.y = 0;
    self.cancelButton = [[HXRoundButton alloc]initWithTitle:NSLocalizedString(@"掛斷", nil) titleColor:[UIColor color5] backgroundColor:[UIColor redColor] frame:frame];
    [self.cancelButton addTarget:self action:@selector(cancelButtonListener:) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelButton addTarget:self action:@selector(buttonDownListener:) forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragEnter];
    [self.cancelButton addTarget:self action:@selector(buttonUpListener:) forControlEvents:UIControlEventTouchUpOutside | UIControlEventTouchDragExit];
    [self.threeButtonBg addSubview:self.cancelButton];
    
    // two button bg
    self.twoButtonBg = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height -30 - 36, self.view.bounds.size.width, 30 + 36)];
    self.twoButtonBg.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.twoButtonBg];
    
    // right button
    frame.size.width = (self.twoButtonBg.bounds.size.width -30 -6 -30) /2;
    frame.size.height = 36;
    frame.origin.x = 30;
    frame.origin.y = 0;
    self.leftButton = [[HXRoundButton alloc]initWithTitle:NSLocalizedString(@"掛斷", nil) titleColor:[UIColor color5] backgroundColor:[UIColor color2] frame:frame];
    
    [self.leftButton addTarget:self action:@selector(leftButtonListener:) forControlEvents:UIControlEventTouchUpInside];
    [self.leftButton addTarget:self action:@selector(buttonDownListener:) forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragEnter];
    [self.leftButton addTarget:self action:@selector(buttonUpListener:) forControlEvents:UIControlEventTouchUpOutside | UIControlEventTouchDragExit];
    [self.twoButtonBg addSubview:self.leftButton];
    
    // left button
    frame.size.width = (self.twoButtonBg.bounds.size.width -30 -6 -30) /2;
    frame.size.height = 36;
    frame.origin.x = self.leftButton.frame.origin.x + self.leftButton.frame.size.width + 6;
    frame.origin.y = 0;
    self.rightButton = [[HXRoundButton alloc]initWithTitle:NSLocalizedString(@"靜音", nil) titleColor:[UIColor color5] backgroundColor:[UIColor redColor] frame:frame];
    
    [self.rightButton addTarget:self action:@selector(rightButtonListener:) forControlEvents:UIControlEventTouchUpInside];
    [self.rightButton addTarget:self action:@selector(buttonDownListener:) forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragEnter];
    [self.rightButton addTarget:self action:@selector(buttonUpListener:) forControlEvents:UIControlEventTouchUpOutside | UIControlEventTouchDragExit];
    [self.twoButtonBg addSubview:self.rightButton];
    
}

#pragma mark - AnLive Delegate

- (void)localVideoViewReady:(AnLiveLocalVideoView*)view
{
    self.localVideo = view;
    self.localVideo.frame = CGRectMake(0,
                                       0,
                                       self.meStreamView.bounds.size.width,
                                       self.view.bounds.size.height/self.view.bounds.size.width *self.meStreamView.bounds.size.width);
    self.localVideo.center = CGPointMake(self.meStreamView.bounds.size.width/2, self.meStreamView.bounds.size.height/2);

    [self.meStreamView addSubview:self.localVideo];
}

- (void)localVideoSizeChanged:(CGSize)size
{
    CGPoint center = self.localVideo.center;
    
    if (size.width > size.height)
    {
        self.localVideo.bounds = CGRectMake(0,
                                            0,
                                            size.width *self.meStreamView.bounds.size.height/size.height,
                                            self.meStreamView.bounds.size.height);
    }
    else
    {
        self.localVideo.bounds = CGRectMake(0,
                                            0,
                                            self.meStreamView.bounds.size.width,
                                            size.height *self.meStreamView.bounds.size.width/size.width);
    }
    self.localVideo.center = center;

}

- (void)remotePartyConnected:(NSString*)partyId
{
    NSLog(@"Remote party connected!");
    
    if (self.anLiveMode == AnLiveVideoCall) {
        dispatch_async(dispatch_get_main_queue(), ^{
            CGRect frame;
            frame = self.labelBg.frame;
            frame.origin.y = self.view.frame.size.height *.08;
            self.labelBg.frame = frame;
            self.statusLabel.text = NSLocalizedString(@"視訊通話進行中...", nil);
        });
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.statusLabel.text = NSLocalizedString(@"語音通話進行中...", nil);
        });
        
    }
}

- (void)remotePartyDisconnected:(NSString*)partyId
{
    NSLog(@"Remote party disconnected!");
    [[AnLive shared] hangup];
    
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (void)remotePartyVideoViewReady:(NSString*)partyId remoteVideoView:(AnLiveVideoView*)view
{
    self.remoteVideo = view;

    self.remoteVideo.frame = self.targetStreamView.frame;
    self.remoteVideo.contentMode = UIViewContentModeScaleAspectFill;
    self.remoteVideo.clipsToBounds = YES;
    [self.targetStreamView  addSubview:self.remoteVideo];

}

- (void)remotePartyVideoSizeChanged:(NSString *)partyId videoSize:(CGSize)size
{
    CGPoint center = self.remoteVideo.center;
    

    self.remoteVideo.bounds = self.targetStreamView.bounds;
    self.remoteVideo.center = center;
    self.remoteVideo.contentMode = UIViewContentModeScaleAspectFill;
    self.remoteVideo.clipsToBounds = YES;
}



- (void)error:(NSString*)partyId exception:(ArrownockException*)exception
{
    NSLog(@"AnLive Error: %@", exception.description);

}

#pragma mark - Button Listener

- (void)muteButtonListener:(UIButton *)button
{
    self.noVideoButton.userInteractionEnabled = YES;
    self.cancelButton.userInteractionEnabled = YES;
    
    
    if (_audioState) {
        [self.muteButton setTitle:NSLocalizedString(@"取消靜音", nil) forState:UIControlStateNormal];
    }else
        [self.muteButton setTitle:NSLocalizedString(@"靜音", nil) forState:UIControlStateNormal];
    
    [[AnLive shared] setAudioState:!_audioState];
    _audioState = !_audioState;
}

- (void)noVideoButtonListener:(UIButton *)button
{
    self.muteButton.userInteractionEnabled = YES;
    self.cancelButton.userInteractionEnabled = YES;
    
    [[AnLive shared] setVideoState:!_videoState];
    _videoState = !_videoState;
    
    if (_videoState) {
        [self.noVideoButton setTitle:NSLocalizedString(@"關閉鏡頭", nil) forState:UIControlStateNormal];
    }else
        [self.noVideoButton setTitle:NSLocalizedString(@"開啟鏡頭", nil) forState:UIControlStateNormal];
    
}

- (void)cancelButtonListener:(UIButton *)button
{
    self.muteButton.userInteractionEnabled = YES;
    self.noVideoButton.userInteractionEnabled = YES;
    
    [[AnLive shared] hangup];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)rightButtonListener:(UIButton *)button
{
    self.leftButton.userInteractionEnabled = YES;
    if ([button.titleLabel.text isEqualToString:NSLocalizedString(@"接聽", nil)]) {
        
        [[AnLive shared] answer:YES];
        
        if (self.anLiveMode == AnLiveVideoCall) {
            self.twoButtonBg.hidden = YES;
            self.threeButtonBg.hidden = NO;
            CGRect frame;
            frame = self.labelBg.frame;
            frame.origin.y = self.view.frame.size.height *.08;
            self.labelBg.frame = frame;
            self.statusLabel.text = NSLocalizedString(@"視訊通話進行中...", nil);
        }else{
            self.threeButtonBg.hidden = YES;
            [self.rightButton updateTitle:NSLocalizedString(@"掛斷", nil) backgroundColor:[UIColor redColor]];
            [self.leftButton updateTitle:NSLocalizedString(@"靜音", nil) backgroundColor:[UIColor color2]];
            self.statusLabel.text = NSLocalizedString(@"語音通話進行中...", nil);
        }
        
    }
    else if([button.titleLabel.text isEqualToString:NSLocalizedString(@"拒絕", nil)] || [button.titleLabel.text isEqualToString:NSLocalizedString(@"掛斷", nil)])
    {
       [[AnLive shared] hangup];
       [self dismissViewControllerAnimated:YES completion:nil]; 
    }
    
}

- (void)leftButtonListener:(UIButton *)button
{
    self.rightButton.userInteractionEnabled = YES;
    if([button.titleLabel.text isEqualToString:NSLocalizedString(@"拒絕", nil)] || [button.titleLabel.text isEqualToString:NSLocalizedString(@"掛斷", nil)])
    {
        [[AnLive shared] hangup];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if([button.titleLabel.text isEqualToString:NSLocalizedString(@"靜音", nil)])
    {
        [[AnLive shared] setAudioState:!_audioState];
        _audioState = !_audioState;
        [self.leftButton updateTitle:NSLocalizedString(@"取消靜音", nil) backgroundColor:[UIColor color2]];
    }
    else if([button.titleLabel.text isEqualToString:NSLocalizedString(@"取消靜音", nil)])
    {
        [[AnLive shared] setAudioState:!_audioState];
        _audioState = !_audioState;
        [self.leftButton updateTitle:NSLocalizedString(@"靜音", nil) backgroundColor:[UIColor color2]];
    }
    
}

- (void)buttonDownListener:(UIButton *)button
{
    if (button == self.muteButton)
    {
        self.noVideoButton.userInteractionEnabled = NO;
        self.cancelButton.userInteractionEnabled = NO;
    }
    else if (button == self.noVideoButton)
    {
        self.muteButton.userInteractionEnabled = NO;
        self.cancelButton.userInteractionEnabled = NO;
    }
    else if (button == self.cancelButton)
    {
        self.muteButton.userInteractionEnabled = NO;
        self.noVideoButton.userInteractionEnabled = NO;
    }
    else if (button == self.rightButton)
    {
        self.leftButton.userInteractionEnabled = NO;
    }else if (button == self.leftButton)
    {
        self.rightButton.userInteractionEnabled = NO;
    }
}

- (void)buttonUpListener:(UIButton *)button
{
    if (button == self.muteButton)
    {
        self.noVideoButton.userInteractionEnabled = YES;
        self.cancelButton.userInteractionEnabled = YES;
    }
    else if (button == self.noVideoButton)
    {
        self.muteButton.userInteractionEnabled = YES;
        self.cancelButton.userInteractionEnabled = YES;
    }
    else if (button == self.cancelButton)
    {
        self.muteButton.userInteractionEnabled = YES;
        self.noVideoButton.userInteractionEnabled = YES;
    }
    else if (button == self.rightButton)
    {
        self.leftButton.userInteractionEnabled = YES;
    }else if (button == self.leftButton)
    {
        self.rightButton.userInteractionEnabled = YES;
    }
}

@end
