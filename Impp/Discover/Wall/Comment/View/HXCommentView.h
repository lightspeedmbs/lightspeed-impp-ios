//
//  HXCommentView.h
//  Impp
//
//  Created by hsujahhu on 2015/4/8.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol HXCommentViewDelegate <NSObject>
- (void)commentButtonTappedWithMessage:(NSString *)message;
@end

@interface HXCommentView : UIView
@property (weak, nonatomic) id<HXCommentViewDelegate> delegate;
- (void)textFieldResignFirstResponder;
- (void)textFieldBecomeFirstResponder;
@end
