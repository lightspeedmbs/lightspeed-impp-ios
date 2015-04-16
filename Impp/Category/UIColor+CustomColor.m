//
//  UIColor+CustomColor.m
//  
//
//  Created by Tim on 2/24/15.
//
//

#import "UIColor+CustomColor.h"

#define COLOR1 @"5cb5b5"
#define COLOR2 @"52aaaa"
#define COLOR3 @"429b9b"

#define COLOR4 @"000000"
#define COLOR5 @"ffffff"
#define COLOR6 @"efefef"
#define COLOR7 @"e0e0e0"
#define COLOR8 @"bdbdbd"
#define COLOR9 @"989898"
#define COLOR10 @"757575"
#define COLOR11 @"4c4c4c"
#define COLOR12 @"212121"

#define COLOR13 @"eeff41"
#define COLOR14 @"e6ef2e"

@implementation UIColor (CustomColor)

+ (UIColor *)color1
{
    return [self colorWithHexString:COLOR1 alpha:1.0f];
}

+ (UIColor *)color2
{
    return [self colorWithHexString:COLOR2 alpha:1.0f];
}

+ (UIColor *)color3
{
    return [self colorWithHexString:COLOR3 alpha:1.0f];
}

+ (UIColor *)color4
{
    return [self colorWithHexString:COLOR4 alpha:1.0f];
}

+ (UIColor *)color5
{
    return [self colorWithHexString:COLOR5 alpha:1.0f];
}

+ (UIColor *)color6
{
    return [self colorWithHexString:COLOR6 alpha:1.0f];
}

+ (UIColor *)color7
{
    return [self colorWithHexString:COLOR7 alpha:1.0f];
}

+ (UIColor *)color8
{
    return [self colorWithHexString:COLOR8 alpha:1.0f];
}

+ (UIColor *)color9
{
    return [self colorWithHexString:COLOR9 alpha:1.0f];
}

+ (UIColor *)color10
{
    return [self colorWithHexString:COLOR10 alpha:1.0f];
}

+ (UIColor *)color11
{
    return [self colorWithHexString:COLOR11 alpha:1.0f];
}

+ (UIColor *)color12
{
    return [self colorWithHexString:COLOR12 alpha:1.0f];
}

+ (UIColor *)color13
{
    return [self colorWithHexString:COLOR13 alpha:1.0f];
}

+ (UIColor *)color14
{
    return [self colorWithHexString:COLOR14 alpha:1.0f];
}


#pragma mark -

+ (UIColor *)colorWithHexString:(NSString *)hexValue alpha:(CGFloat)alpha
{
    UIColor *defaultResult = [UIColor whiteColor];
    if ([hexValue hasPrefix:@"#"] && [hexValue length] > 1) {
        hexValue = [hexValue substringFromIndex:1];
    }
    NSUInteger componentLength = 0;
    if ([hexValue length] == 3) {
        componentLength = 1;
    } else if ([hexValue length] == 6) {
        componentLength = 2;
    } else {
        return defaultResult;
    }
    
    BOOL isValid = YES;
    CGFloat components[3];
    
    for (NSUInteger i = 0; i < 3; i++) {
        NSString *component = [hexValue substringWithRange:NSMakeRange(componentLength * i, componentLength)];
        if (componentLength == 1) {
            component = [component stringByAppendingString:component];
        }
        NSScanner *scanner = [NSScanner scannerWithString:component];
        unsigned int value;
        isValid &= [scanner scanHexInt:&value];
        components[i] = (CGFloat)value / 255.0f;
    }
    if (!isValid)
        return defaultResult;
    
    return [UIColor colorWithRed:components[0]
                           green:components[1]
                            blue:components[2]
                           alpha:alpha];
}

@end
