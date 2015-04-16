//
//  HXVoiceRecordView.m
//  IMChat
//
//  Created by Jefferson on 2015/1/12.
//  Copyright (c) 2015年 Herxun. All rights reserved.
//

#import "HXVoiceRecordView.h"
#import "HXAppUtility.h"
#import "UIColor+CustomColor.h"
#import <AVFoundation/AVFoundation.h>
@interface HXVoiceRecordView ()
@property (strong, nonatomic) UIImageView *composeBackground;
@property (strong, nonatomic) UIImageView *recordingImage;
@property (strong, nonatomic) UIImageView *recordingAlert;
@property (strong, nonatomic) UIImageView *recordingAnimation;
@property (strong, nonatomic) UIButton *voiceRecordBtn;
@property (strong, nonatomic) UILabel *voiceBtnLabel;
@property (strong, nonatomic) UILabel *recordingMessage;
@property (strong, nonatomic) AVAudioRecorder* voiceRecorder;
@end

@implementation HXVoiceRecordView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initView];
    }
    return self;
}

- (void)initView
{
    self.backgroundColor = [UIColor clearColor];

    
    UIView *bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height -44, self.bounds.size.width, 44)];
    bottomBar.backgroundColor = [UIColor color6];
    [self addSubview:bottomBar];
    
    UIButton *cancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancel setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
    cancel.titleLabel.font = [UIFont fontWithName:@"STHeitiTC-Light" size:34/2];
    [cancel setTitleColor:[UIColor color2] forState:UIControlStateNormal];
    [cancel sizeToFit];
    cancel.frame = CGRectMake(self.bounds.size.width -cancel.bounds.size.width-12*2,
                              self.bounds.size.height -44,
                              cancel.bounds.size.width+12*2,
                              44);
    [cancel addTarget:self action:@selector(cancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancel];
    
    UIImage *voiceButtonImage = [UIImage imageNamed:@"voicepress"];
    UIImage *selectedVoiceButtonImage = [UIImage imageNamed:@"voicepress"];
    self.voiceRecordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.voiceRecordBtn.frame = CGRectMake(12,
                                           self.frame.size.height -44,
                                           self.bounds.size.width -12 -cancel.bounds.size.width,
                                           44);
    [self.voiceRecordBtn setBackgroundImage:voiceButtonImage forState:UIControlStateNormal];
    [self.voiceRecordBtn setBackgroundImage:selectedVoiceButtonImage forState:UIControlStateHighlighted];
    [self.voiceRecordBtn addTarget:self action:@selector(voiceRecordButtonTapped) forControlEvents:UIControlEventTouchDown];
    [self.voiceRecordBtn addTarget:self action:@selector(voiceRecordButtonRelease) forControlEvents:UIControlEventTouchUpInside];
    [self.voiceRecordBtn addTarget:self action:@selector(voiceRecordButtonReleaseOutside) forControlEvents:UIControlEventTouchUpOutside];
    [self.voiceRecordBtn addTarget:self action:@selector(voiceRecordButtonDragEnter) forControlEvents:UIControlEventTouchDragEnter];
    [self.voiceRecordBtn addTarget:self action:@selector(voiceRecordButtonDragExit) forControlEvents:UIControlEventTouchDragExit];
    [self addSubview:self.voiceRecordBtn];
    
    self.voiceBtnLabel = [[UILabel alloc]init];
    self.voiceBtnLabel.font = [UIFont fontWithName:@"STHeitiTC-Light" size:24/2];
    [self.voiceBtnLabel setTextColor:[UIColor whiteColor]];
    [self.voiceBtnLabel setText:NSLocalizedString(@"按住即可錄音", nil)];
    [self.voiceBtnLabel sizeToFit];

    self.voiceBtnLabel.center = CGPointMake(self.voiceRecordBtn.bounds.size.width/2, self.voiceRecordBtn.bounds.size.height/2);
    [self.voiceRecordBtn addSubview:self.voiceBtnLabel];
    
}

- (void)cancelButtonTapped
{
    [self removeFromSuperview];
}

- (void)voiceRecordButtonTapped
{
    self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.6];
    
    [self prepareForRecord];
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryRecord error:nil];
    [session setActive:YES error:nil];
    [self.voiceRecorder record];
    
    [self.voiceBtnLabel setText:NSLocalizedString(@"放開即可傳送", nil)];
    
    if (!self.recordingImage) {
        self.recordingImage = [[UIImageView alloc]initWithFrame:CGRectMake(self.center.x - 110/2/2, self.center.y - (28/2 + 20/2 +110/2)/2,
                                                                           110/2, 110/2)];
        self.recordingMessage = [[UILabel alloc]initWithFrame:CGRectMake(0, self.center.y - (28/2 + 20/2 +110/2)/2 + 110/2 + 20/2,
                                                                         self.frame.size.width, 28/2)];
        self.recordingAnimation = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"voice_record"]];
        self.recordingAnimation.frame = self.recordingImage.frame;
    }
    self.recordingImage.image = [UIImage imageNamed:@"voice_record_bg"];
    [self addSubview:self.recordingImage];
    
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ ];
    rotationAnimation.duration = 1.6;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 1e10f;
    [self.recordingAnimation.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    [self addSubview:self.recordingAnimation];
    
    self.recordingMessage.font = [UIFont fontWithName:@"STHeitiTC-Light" size:28/2];
    self.recordingMessage.textColor = [UIColor whiteColor];
    self.recordingMessage.text = NSLocalizedString(@"錄音中", nil);
    self.recordingMessage.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.recordingMessage];
    
}

- (void)voiceRecordButtonRelease
{
    
    [self.voiceRecorder stop];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    int flags = AVAudioSessionSetActiveFlags_NotifyOthersOnDeactivation;
    [session setActive:NO withFlags:flags error:nil];
    
    AVAudioPlayer* player = [[AVAudioPlayer alloc] initWithData:[[NSFileManager defaultManager]
                                                                 contentsAtPath:self.voiceRecorder.url.path] error:nil];
    if (player.duration < 1.0f)
    {
        if (!self.recordingAlert) {
            self.recordingAlert = [[UIImageView alloc]initWithFrame:self.recordingImage.frame];
            self.recordingAlert.image = [UIImage imageNamed:@"voice_alert"];
        }
        self.recordingMessage.text = NSLocalizedString(@"聲音訊息過短", nil);
        self.voiceBtnLabel.text = NSLocalizedString(@"按住即可錄音", nil);
        [self.recordingImage removeFromSuperview];
        [self.recordingAnimation removeFromSuperview];
        [self addSubview:self.recordingAlert];
    }
    else
    {
        self.backgroundColor = [UIColor clearColor];
        [self.recordingImage removeFromSuperview];
        [self.recordingAnimation removeFromSuperview];
        [self.recordingAlert removeFromSuperview];
        [self.recordingMessage removeFromSuperview];
        
        NSString* voiceURL = [self.voiceRecorder.url path];
        NSData* voice = [[NSFileManager defaultManager] contentsAtPath:voiceURL];
        
        /* trimming the voice to small than one Mb*/
        NSInteger numOfOneMBytes = 1024*1024;
        if ([voice length] > numOfOneMBytes) {
            voice = [NSData dataWithBytesNoCopy:(char*)[[[NSFileManager defaultManager] contentsAtPath:voiceURL] bytes]
                                         length:numOfOneMBytes - 1
                                   freeWhenDone:NO];
        }
        [self.delegate sendVoiceData:voice];
    }
}

- (void)voiceRecordButtonReleaseOutside
{
    [self.voiceRecorder stop];
    
    self.backgroundColor = [UIColor clearColor];
    self.voiceBtnLabel.text = NSLocalizedString(@"按住即可錄音", nil);
    [self.recordingImage removeFromSuperview];
    [self.recordingAnimation removeFromSuperview];
    [self.recordingAlert removeFromSuperview];
    [self.recordingMessage removeFromSuperview];
}

- (void)voiceRecordButtonDragEnter
{
    self.recordingMessage.text = NSLocalizedString(@"錄音中", nil);
    [self.recordingAlert removeFromSuperview];
    [self addSubview:self.recordingImage];
    [self addSubview:self.recordingAnimation];
}

- (void)voiceRecordButtonDragExit
{
    if (!self.recordingAlert) {
        self.recordingAlert = [[UIImageView alloc]initWithFrame:self.recordingImage.frame];
        self.recordingAlert.image = [UIImage imageNamed:@"voice_alert"];
    }
    self.recordingMessage.text = NSLocalizedString(@"放開以取消傳送", nil);
    [self.recordingImage removeFromSuperview];
    [self.recordingAnimation removeFromSuperview];
    [self addSubview:self.recordingAlert];
}

- (void)prepareForRecord
{
    if (!self.voiceRecorder)
    {
        NSArray* arrayDirPaths;
        NSString* strDocsDir;
        
        arrayDirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        strDocsDir = [arrayDirPaths objectAtIndex:0];
        NSString *strSoundFilePath = [strDocsDir stringByAppendingPathComponent:@"sound.m4a"];
        
        NSURL *soundFileURL = [NSURL fileURLWithPath:strSoundFilePath];
        
        NSDictionary *recordSettings = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kAudioFormatMPEG4AAC], AVFormatIDKey,
                                        [NSNumber numberWithFloat:16000.0], AVSampleRateKey,
                                        [NSNumber numberWithInt: 1], AVNumberOfChannelsKey, nil];
        
        NSError* error;
        self.voiceRecorder = [[AVAudioRecorder alloc] initWithURL:soundFileURL settings:recordSettings error:&error];
        if (!error)
        {
            [self.voiceRecorder prepareToRecord];
        }
    }
}

@end
