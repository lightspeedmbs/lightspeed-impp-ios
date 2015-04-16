//
//  HXAppUtility.m
//  IMChat
//
//  Created by Jefferson on 2015/1/7.
//  Copyright (c) 2015年 Herxun. All rights reserved.
//

#import "HXAppUtility.h"

@implementation HXAppUtility

+ (NSString *)removeWhitespace:(NSString *)originalString
{
    return [originalString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

+ (NSString *)removeExtraWhitespace:(NSString *)originalString
{
    //    Replace only space: [ ]+
    //    Replace space and tabs: [ \\t]+
    //    Replace space, tabs and newlines: \\s+
    
    NSString *squashed = [originalString stringByReplacingOccurrencesOfString:@"[ ]+"
                                                                   withString:@" "
                                                                      options:NSRegularExpressionSearch
                                                                        range:NSMakeRange(0, originalString.length)];
    
    return [squashed stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (UIColor *)hexToColor:(int)hexValue alpha:(CGFloat)alpha
{
    NSNumber* red = [NSNumber numberWithInt:(hexValue >> 16)];
    NSNumber* green = [NSNumber numberWithInt:((hexValue >> 8) & 0xFF)];
    NSNumber* blue = [NSNumber numberWithInt:(hexValue & 0xFF)];
    
    CGFloat fAlpha = (alpha)? alpha : 1.0f;
    UIColor* color = [UIColor colorWithRed:[red floatValue]/255.0f green:[green floatValue]/255.0f blue:[blue floatValue]/255.0f alpha:fAlpha];
    
    return color;
}

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

+ (NSString*)colorToWeb:(UIColor*)color
{
    NSString *webColor = nil;
    
    if (color && CGColorGetNumberOfComponents(color.CGColor) == 4)
    {
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        
        CGFloat red, green, blue;
        red = roundf(components[0] * 255.0);
        green = roundf(components[1] * 255.0);
        blue = roundf(components[2] * 255.0);
        
        webColor = [[NSString alloc]initWithFormat:@"%02x%02x%02x", (int)red, (int)green, (int)blue];
    }
    return webColor;
}

+ (BOOL)is4inchScreen
{
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    return screenBound.size.height > 560 ? YES : NO;
}

+ (BOOL)isiOS7
{
    return [[[UIDevice currentDevice] systemVersion] intValue] >= 7.0f ? YES : NO;
}

+ (BOOL)isiOS8
{
    return [[[UIDevice currentDevice] systemVersion] intValue] >= 8.0f ? YES : NO;
}

//+ (BOOL)isConnectedToNetwork
//{
//    BOOL isInternet;
//    Reachability* reachability = [Reachability reachabilityWithHostName:@"www.google.com"];
//    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
//
//    if(remoteHostStatus == NotReachable)
//    {
//        isInternet = NO;
//    }
//    else
//    {
//        isInternet = TRUE;
//    }
//    return isInternet;
//}

+ (UIImage *)thumbnailImage:(UIImage *)image
{
    if (image.size.height > image.size.width) {
        if (image.size.width<200) {
            image = [HXAppUtility imageWithImage:image scaledToSize:CGSizeMake(200, 200)];
        }else
            image = [HXAppUtility imageWithImage:image scaledToSize:CGSizeMake(image.size.width*200/image.size.height, 200)];
    }else if(image.size.height < image.size.width){
        if (image.size.height<200) {
            image = [HXAppUtility imageWithImage:image scaledToSize:CGSizeMake(200,200)];
        }else
            image = [HXAppUtility imageWithImage:image scaledToSize:CGSizeMake(200, image.size.height*200/image.size.width)];
    }else {
        image = [HXAppUtility imageWithImage:image scaledToSize:CGSizeMake(200, 200)];
    }
    return image;
}

+ (UIImage *)resizedOriginalImage:(UIImage *)image maxOffset:(CGFloat)maxOffset
{
    CGSize size;
    if (image.size.height > image.size.width && image.size.height > maxOffset)
    {
        size = CGSizeMake(image.size.width * maxOffset/image.size.height, maxOffset);
    }
    else if(image.size.width > image.size.height && image.size.width > maxOffset)
    {
        size = CGSizeMake(maxOffset, image.size.height * maxOffset/image.size.width);
    }
    else
    {
        return image;
    }
    
    return [HXAppUtility imageWithImage:image scaledToSize:size];
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 1.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)setImage:(UIImage *)image withAlpha:(CGFloat)alpha
{
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, image.size.width, image.size.height);
    
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    CGContextSetAlpha(ctx, alpha);
    CGContextDrawImage(ctx, area, image.CGImage);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (void)initNavigationTitle:(NSString *)title barTintColor:(UIColor *)color withViewController:(UIViewController *)vc
{
    UILabel *navTitle=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, vc.navigationItem.titleView.frame.size.width,40)];
    navTitle.text = title;
    navTitle.textAlignment = NSTextAlignmentCenter;
    navTitle.font = [UIFont fontWithName:@"STHeitiTC-Medium" size:34/2];
    navTitle.textColor = [UIColor whiteColor];
    navTitle.lineBreakMode = NSLineBreakByTruncatingMiddle;
    vc.navigationItem.titleView = navTitle;
    
    vc.navigationController.navigationBar.translucent = NO;
    vc.navigationController.navigationBar.barTintColor = color;
    vc.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [vc.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor whiteColor],NSForegroundColorAttributeName,
      [UIFont fontWithName:@"STHeitiTC-Medium" size:34/2],
      NSFontAttributeName, nil]];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
}

+ (void)initNavigationTitleView:(UIImageView *)titleView barTintColor:(UIColor *)barTintColor tintColor:(UIColor *)tintColor withViewController:(UIViewController *)vc
{
    vc.navigationItem.titleView = titleView;
    vc.navigationController.navigationBar.translucent = NO;
    vc.navigationController.navigationBar.barTintColor = barTintColor;
    vc.navigationController.navigationBar.tintColor = tintColor;
    [vc.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                   [UIColor whiteColor],NSForegroundColorAttributeName,
                                                                   [UIFont fontWithName:@"STHeitiTC-Medium" size:34/2],
                                                                   NSFontAttributeName, nil]];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
}
@end
