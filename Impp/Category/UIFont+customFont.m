//
//  UIFont+CustomFont.m
//  iBeacon
//
//  Created by Tim on 2/24/15.
//  Copyright (c) 2015 Herxun. All rights reserved.
//

#import "UIFont+CustomFont.h"

#define HEITI_LIGHT @"STHeitiTC-Light"

@implementation UIFont (customFont)

+ (UIFont *)heitiLightWithSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:HEITI_LIGHT size:fontSize];
}

@end
