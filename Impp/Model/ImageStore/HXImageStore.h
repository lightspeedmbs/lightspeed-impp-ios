//
//  HXImageStore.h
//  Sotomo
//
//  Created by Tim on 9/9/14.
//  Copyright (c) 2014 Herxun. All rights reserved.
//

@import UIKit;
//#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface HXImageStore : NSObject
@property (strong, nonatomic) NSMutableSet *likeSet;

+ (HXImageStore *)imageStore;
- (void)imageForKey:(NSString *)imageUrlString completion:(void(^)(UIImage *image, NSString *error))completion;
- (UIImage *)imageForKey:(NSString *)imageUrlString;
- (void)setImage:(UIImage *)image forKey:(NSString *)imageUrlString;

- (NSString *)imageUrlForKey:(NSString *)userId;
- (void)setImageUrl:(NSString *)imageUrl forKey:(NSString *)userId;

- (void)didReceiveMemoryWarning;

@end
