//
//  PostUtil.h
//  Impp
//
//  Created by Herxun on 2015/4/7.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HXPost+Additions.h"

@interface PostUtil : NSObject

+ (HXPost *)getPostByPostId:(NSString *)postId;
+ (HXPost *)savePostToDB:(NSDictionary *)postDic;
@end
