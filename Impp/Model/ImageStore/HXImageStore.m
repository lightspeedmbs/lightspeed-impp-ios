//
//  HXImageStore.m
//  Sotomo
//
//  Created by Tim on 9/9/14.
//  Copyright (c) 2014 Herxun. All rights reserved.
//

#import "HXImageStore.h"
#import "ActivityIndicatorManager.h"

@interface HXImageStore ()
@property (nonatomic, strong) NSMutableDictionary *imageMutableDictionary;
@property (nonatomic, strong) NSMutableDictionary *imageUrlMutableDictionary;

@end

@implementation HXImageStore
@synthesize imageMutableDictionary;

#pragma mark - Init

+ (HXImageStore *)imageStore
{
    static HXImageStore *_imageStore = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _imageStore = [[HXImageStore alloc] init];
    });
    return _imageStore;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.imageMutableDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
        self.imageUrlMutableDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
        self.likeSet = [[NSMutableSet alloc] initWithCapacity:0];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [self.imageMutableDictionary removeAllObjects];
    [self.imageUrlMutableDictionary removeAllObjects];
}

#pragma mark - Public

- (void)imageForKey:(NSString *)imageUrlString completion:(void(^)(UIImage *image, NSString *error))completion
{
    if ([self imageForKey:imageUrlString] && completion)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion([self imageForKey:imageUrlString], nil);
        });
    }
    else
    {
        [[ActivityIndicatorManager manager] activityStart];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrlString]
                                                    cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                timeoutInterval:20.0];
        [NSURLConnection sendAsynchronousRequest:urlRequest
                                           queue:[NSOperationQueue currentQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   [[ActivityIndicatorManager manager] activityEnd];
                                   if (data != nil && error == nil)
                                   {
                                       UIImage *gotImage = [UIImage imageWithData:data];
                                       if (gotImage)
                                       {
//                                           NSLog(@"ImgStore finish fetching image! \n<%@>", imageUrlString);
                                           [self setImage:gotImage forKey:imageUrlString];
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               if (completion)
                                                   completion(gotImage, nil);
                                           });
                                       }
                                       else
                                       {
                                           if (completion)
                                               completion(nil, @"Did not get image data");
                                       }
                                   }
                                   else
                                   {
                                       completion(nil, error.localizedDescription);
                                   }
                               }];

    }
    
}

- (UIImage *)imageForKey:(NSString *)imageUrlString
{
    return self.imageMutableDictionary[imageUrlString];
}

- (NSString *)imageUrlForKey:(NSString *)userId
{
    return self.imageUrlMutableDictionary[userId];
}

- (void)setImageUrl:(NSString *)imageUrl forKey:(NSString *)userId
{
    if (imageUrl)
    {
        [self.imageUrlMutableDictionary setObject:imageUrl forKey:userId];
    }
}

- (void)setImage:(UIImage *)image forKey:(NSString *)imageUrlString
{
    if (image)
    {
        [self.imageMutableDictionary setObject:image forKey:imageUrlString];
    }
}

@end
