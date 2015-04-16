//
//  HXRoundButton.h
//  Impp
//
//  Created by Herxun on 2015/4/9.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HXRoundButton : UIButton

- (id)initWithTitle:(NSString *)title titleColor:(UIColor *)titleColor backgroundColor:(UIColor *)backgroundColor frame:(CGRect)frame;
- (void)updateTitle:(NSString *)title backgroundColor:(UIColor *)backgroundColor;
@end
