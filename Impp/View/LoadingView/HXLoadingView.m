//
//  HXLoadingView.m
//  Impp
//
//  Created by hsujahhu on 2015/3/17.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import "HXLoadingView.h"

@interface HXLoadingView()
@property (nonatomic, strong) UIImageView *indicatorBackground;
@end

@implementation HXLoadingView

@synthesize indicatorBackground;

#pragma mark -

- (void)loadFailed
{
    
    [self removeFromSuperview];
}

- (void)loadCompleted
{
    
   [self removeFromSuperview];
}

- (id)initLoadingView
{
    self = [super initWithFrame:[[UIApplication sharedApplication] keyWindow].frame];
    if (self)
    {
    
        UIActivityIndicatorView *activityindicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityindicator.frame = CGRectMake(self.bounds.size.width/2 - activityindicator.bounds.size.width/2,
                                             self.bounds.size.height/2 - activityindicator.bounds.size.height/2,
                                             activityindicator.bounds.size.width,
                                             activityindicator.bounds.size.width);
        [activityindicator startAnimating];
        [self addSubview:activityindicator];
    }
    return self;
}

@end
