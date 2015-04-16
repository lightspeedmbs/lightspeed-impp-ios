//
//  HXAppUtility.h
//  IMChat
//
//  Created by Jefferson on 2015/1/7.
//  Copyright (c) 2015年 Herxun. All rights reserved.
//

@import UIKit;
#import <Foundation/Foundation.h>

@interface HXAppUtility : NSObject

+ (NSString *)removeWhitespace:(NSString *)originalString;      // Remove whitespace at the front and end of the string
+ (NSString *)removeExtraWhitespace:(NSString *)originalString; // Remove whitespace at the front and the end of the string + leave only one whitespace between words

+ (UIColor*)hexToColor:(int)hexValue alpha:(CGFloat)alpha;
+ (UIColor *)colorWithHexString:(NSString *)coloString alpha:(CGFloat)alpha;
+ (NSString*)colorToWeb:(UIColor*)color;

+ (BOOL)is4inchScreen;
+ (BOOL)isiOS7;
+ (BOOL)isiOS8;

//+ (BOOL)isConnectedToNetwork;
+ (UIImage *)thumbnailImage:(UIImage *)image;
+ (UIImage *)resizedOriginalImage:(UIImage *)image maxOffset:(CGFloat)maxOffset;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
+ (UIImage *)setImage:(UIImage *)image withAlpha:(CGFloat)alpha;

+ (void)initNavigationTitle:(NSString *)title barTintColor:(UIColor *)color withViewController:(UIViewController *)vc;
+ (void)initNavigationTitleView:(UIImageView *)titleView barTintColor:(UIColor *)barTintColor tintColor:(UIColor *)tintColor withViewController:(UIViewController *)vc;
@end
