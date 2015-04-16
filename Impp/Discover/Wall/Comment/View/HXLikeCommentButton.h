//
//  HXLikeCommentButton.h
//  Impp
//
//  Created by hsujahhu on 2015/4/10.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HXLikeCommentButton : UIButton

- (id)initWithTitle:(NSString *)title tintColor:(UIColor *)tintColor image:(UIImage *)image;

- (void)updateTitle:(NSString *)title tintColor:(UIColor *)color image:(UIImage *)image;
@end
