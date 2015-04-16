//
//  HXComposeView.h
//  IMChat
//
//  Created by Jefferson on 2015/1/8.
//  Copyright (c) 2015年 Herxun. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol HXComposeViewDelegate <NSObject>
- (void)sendMessage:(NSString *)message;
- (void)takePhotoTapped;
- (void)selectPhotoTapped;
- (void)recordVoiceTapped;
- (void)shareLocationTapped;
- (void)videoCallTapped;
- (void)audioCallTapped;
- (void)composeViewWillChangeHeight:(CGFloat)height;
@end

@interface HXComposeView : UIView
@property (weak, nonatomic) id<HXComposeViewDelegate> delegate;
@property BOOL isTopicMode;
- (void)textFieldResignFirstResponder;
- (CGFloat)heightForBackgroundView;
@end
