//
//  HXCommentView.m
//  Impp
//
//  Created by hsujahhu on 2015/4/8.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import "HXCommentView.h"
#import "UIColor+CustomColor.h"
#import "PHFComposeBarView.h"

@interface HXCommentView()<PHFComposeBarViewDelegate>
@property (strong, nonatomic) PHFComposeBarView *composeBarView;
@end
@implementation HXCommentView

#pragma mark - init

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
    _composeBarView = [[PHFComposeBarView alloc] initWithFrame:frame withTextViewOffset:28];
    [_composeBarView setMaxLinesCount:5];
    [_composeBarView setUtilityButtonImage:[UIImage imageNamed:@"compose_bu"]];
    [_composeBarView setDelegate:self];
    [_composeBarView setButtonTintColor:[UIColor color2]];
    _composeBarView.textView.tintColor = [UIColor color2];
    _composeBarView.textView.textColor = [UIColor color11];
    _composeBarView.utilityButton.hidden = YES;
    frame = _composeBarView.toolBarBackgroundImage.frame;
    frame.origin.x = 12;
    frame.size.width += 40 - 12;
    _composeBarView.toolBarBackgroundImage.frame = frame;
    [self addSubview:_composeBarView];
    
}

- (void)textFieldResignFirstResponder
{
    [self.composeBarView.textView resignFirstResponder];
}

- (void)textFieldBecomeFirstResponder
{
    [self.composeBarView.textView becomeFirstResponder];
}

#pragma mark - PHFComposeBarView Delegate

- (void)composeBarViewDidPressButton:(PHFComposeBarView *)composeBarView
{
    [self.delegate commentButtonTappedWithMessage:self.composeBarView.text];
    [composeBarView setText:@"" animated:YES];
}

- (void)composeBarViewDidPressUtilityButton:(PHFComposeBarView *)composeBarView
{
    [self textFieldResignFirstResponder];
}


@end
