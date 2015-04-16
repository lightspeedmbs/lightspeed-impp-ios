//
//  UILabel+CustomLabel.h
//  iBeacon
//
//  Created by Tim on 2/24/15.
//  Copyright (c) 2015 Herxun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (customLabel)


// Give NSRectNull to frame and numerOfLines = 1 to get label frame sizeToFit
// else give label frame and numberOfLines = 0 to get unlimited number of lines + auto bounds adjust
+ (UILabel *)labelWithFrame:(CGRect)frame
                        text:(NSString *)text
               textAlignment:(NSTextAlignment)textAlignment
                   textColor:(UIColor *)textColor
                        font:(UIFont *)font
               numberOfLines:(NSInteger)numberOfLines;

@end
