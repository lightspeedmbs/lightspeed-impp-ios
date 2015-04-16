//
//  CommentUtil.h
//  Impp
//
//  Created by Herxun on 2015/4/7.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HXComment+Additions.h"
@interface CommentUtil : NSObject

+ (HXComment *)getCommentByCommentId:(NSString *)commentId;
+ (HXComment *)saveCommentToDB:(NSDictionary *)commentDic postId:(NSString *)postId;
@end
