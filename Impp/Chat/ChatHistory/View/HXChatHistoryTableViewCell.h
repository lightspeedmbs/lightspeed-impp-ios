//
//  HXChatHistoryTableViewCell.h
//  Impp
//
//  Created by Herxun on 2015/4/9.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HXChatHistoryTableViewCell : UITableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier title:(NSString *)title subtitle:(NSString*)subtitle timestamp:(NSNumber *)timestamp photoUrl:(NSString *)photoUrl placeholderImage:(UIImage *)placeholderImage badgeValue:(NSInteger)badgeValue;

- (void)reuseCellWithTitle:(NSString *)title subtitle:(NSString*)subtitle timestamp:(NSNumber *)timestamp photoUrl:(NSString *)photoUrl placeholderImage:(UIImage *)placeholderImage badgeValue:(NSInteger)badgeValue;
@end
