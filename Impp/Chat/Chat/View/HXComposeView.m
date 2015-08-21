//
//  HXComposeView.m
//  IMChat
//
//  Created by Jefferson on 2015/1/8.
//  Copyright (c) 2015年 Herxun. All rights reserved.
//

#import "HXComposeView.h"
#import "HXAppUtility.h"
#import "UIColor+CustomColor.h"
#import "PHFComposeBarView.h"

@interface HXComposeView () <UIActionSheetDelegate, PHFComposeBarViewDelegate>
@property (strong, nonatomic) PHFComposeBarView *composeBarView;
@property (strong, nonatomic) UIImageView *composeBackground;
@property (strong, nonatomic) UIButton *attachmentBtn;
@property (strong, nonatomic) UIButton *sendMessageBtn;
@end

@implementation HXComposeView

#pragma mark - View

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
    CGRect frame = CGRectMake(0,
                              0,
                              self.bounds.size.width,
                              PHFComposeBarViewInitialHeight);
    _composeBarView = [[PHFComposeBarView alloc] initWithFrame:frame];
    [_composeBarView setMaxLinesCount:5];
    [_composeBarView setUtilityButtonImage:[UIImage imageNamed:@"compose_bu"]];
    [_composeBarView setDelegate:self];
    [_composeBarView setButtonTintColor:[UIColor color2]];
    _composeBarView.textView.tintColor = [UIColor color2];
    _composeBarView.textView.textColor = [UIColor color11];
    
    [self addSubview:_composeBarView];
    
}

- (CGFloat)heightForBackgroundView
{
    return _composeBarView.frame.size.height;
}

- (void)textFieldResignFirstResponder
{
    [self.composeBarView.textView resignFirstResponder];
}


#pragma mark - PHFComposeBarView Delegate

- (void)composeBarViewDidPressButton:(PHFComposeBarView *)composeBarView
{
    [self.delegate sendMessage:self.composeBarView.text];
    [composeBarView setText:@"" animated:YES];
//    [composeBarView resignFirstResponder];
}

- (void)composeBarViewDidPressUtilityButton:(PHFComposeBarView *)composeBarView
{
    [self textFieldResignFirstResponder];
    
    NSString *button1 = NSLocalizedString(@"camera", nil);
    NSString *button2 = NSLocalizedString(@"choose_a_photo", nil);
    NSString *button3 = NSLocalizedString(@"voice_message", nil);
    NSString *button4 = NSLocalizedString(@"location", nil);
    NSString *button5 = NSLocalizedString(@"call", nil);
    NSString *button6 = NSLocalizedString(@"video_call", nil);
    NSString *cancelTitle = NSLocalizedString(@"Cancel", nil);
    
    UIActionSheet *actionSheet;
    if (self.isTopicMode) {
        actionSheet = [[UIActionSheet alloc]
                       initWithTitle:nil
                       delegate:self
                       cancelButtonTitle:cancelTitle
                       destructiveButtonTitle:nil
                       otherButtonTitles:button1, button2, button3, nil];
    }else{
        actionSheet = [[UIActionSheet alloc]
                       initWithTitle:nil
                       delegate:self
                       cancelButtonTitle:cancelTitle
                       destructiveButtonTitle:nil
                       otherButtonTitles:button1, button2, button3,button4,button5,button6, nil];
    }
    [actionSheet showInView:self.superview];
}

- (void)composeBarView:(PHFComposeBarView *)composeBarView
   willChangeFromFrame:(CGRect)startFrame
               toFrame:(CGRect)endFrame
              duration:(NSTimeInterval)duration
        animationCurve:(UIViewAnimationCurve)animationCurve
{

    
    
    
    float diff = (startFrame.size.height - endFrame.size.height);
    [self.delegate composeViewWillChangeHeight:diff];

}

- (void)composeBarView:(PHFComposeBarView *)composeBarView
    didChangeFromFrame:(CGRect)startFrame
               toFrame:(CGRect)endFrame
{

}

#pragma mark - UIActionsheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
 
    switch (buttonIndex) {
        case 0: {
            // take photo
            [self.delegate takePhotoTapped];
            break;
        }
        case 1: {
            // select photo
            [self.delegate selectPhotoTapped];
            break;
        }
        case 2: {
            // record voice
            [self.composeBarView setText:@"" animated:YES];
            [self.delegate recordVoiceTapped];
            break;
        }
        case 3: {
            if (!self.isTopicMode) {
                [self.delegate shareLocationTapped];
            }
            
            break;
        }
        case 4: {
            if (!self.isTopicMode) {
                [self.delegate audioCallTapped];
            }
            
            break;
        }
        
        case 5: {
            if (!self.isTopicMode) {
               [self.delegate videoCallTapped];
            }
            break;
        }
        default:
            break;
    }
}



@end
