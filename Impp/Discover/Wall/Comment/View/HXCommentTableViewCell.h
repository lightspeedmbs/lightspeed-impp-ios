//
//  HXCommentTableViewCell.h
//  Impp
//
//  Created by hsujahhu on 2015/4/8.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HXComment+Additions.h"
@interface HXCommentTableViewCell : UITableViewCell

- (id)initWithCommentInfo:(HXComment *)commentInfo
          reuseIdentifier:(NSString *)reuseIdentifier;

+ (CGFloat)heightForCellComment:(NSString *)comment;
@end
