//
//  HXChatViewController.h
//  IMChat
//
//  Created by Jefferson on 2015/1/8.
//  Copyright (c) 2015年 Herxun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HXChat.h"

@interface HXChatViewController : UIViewController
- (id)initWithChatInfo:(HXChat *)chatInfo setTopicMode:(BOOL)isTopicMode;
@end
