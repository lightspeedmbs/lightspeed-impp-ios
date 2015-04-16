//
//  HXCustomButton.h
//  Impp
//
//  Created by Herxun on 2015/3/31.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HXCustomButton : UIButton
- (id)initWithTitle:(NSString *)title titleColor:(UIColor *)titleColor backgroundColor:(UIColor *)backgroundColor;

- (void)updateTitle:(NSString *)title TitleColor:(UIColor *)color;
@end
