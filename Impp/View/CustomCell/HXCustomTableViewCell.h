//
//  HXCustomTableViewCell.h
//  Impp
//
//  Created by Herxun on 2015/3/31.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum {
    HXCustomCellStyleDefault,
    HXCustomCellStyleSearch,
    HXCustomCellStyleRequest
} HXCustomCellStyle;

@protocol HXCustomCellSearchDelegate <NSObject>
- (void)customCellButtonTapped:(UIButton*)sender;
@end

@protocol HXCustomCellDefaultDelegate <NSObject>
- (void)customCellPhotoTapped:(NSUInteger)index;
@end

@interface HXCustomTableViewCell : UITableViewCell
@property (weak, nonatomic) id<HXCustomCellSearchDelegate> delegate;
@property (weak, nonatomic) id<HXCustomCellDefaultDelegate> defaultDelegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier title:(NSString *)title photoUrl:(NSString *)photoUrl image:(UIImage *)image badgeValue:(NSInteger)badgeValue style:(HXCustomCellStyle)customCellStyle;
- (void)reuseCellWithTitle:(NSString *)title photoUrl:(NSString *)photoUrl image:(UIImage *)image badgeValue:(NSInteger)badgeValue;

- (void)updateTitle:(NSString *)title TitleColor:(UIColor *)color;
- (void)updateBadgeNumber:(NSInteger)badgeValue;
- (void)showLabelWithTitle:(NSString *)title;
- (void)setButtonDisable;
- (void)setButtonTag:(NSInteger)tag;
- (void)setIndexValue:(NSInteger)index;
@end
