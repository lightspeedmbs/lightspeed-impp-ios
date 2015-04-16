//
//  HXNumberBadge.h
//  Impp
//
//  Created by Herxun on 2015/4/1.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HXNumberBadge : UIView
- (id)initWithFrame:(CGRect)frame badgeNumber:(NSInteger)badgeNumber;
- (void)updateBadgeNumber:(NSInteger)badgeNumber;
- (NSInteger)currentBadgeNumber;
@end
