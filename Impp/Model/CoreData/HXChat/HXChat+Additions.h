//
//  HXChat+Additions.h
//  IMChat
//
//  Created by Herxun on 2015/1/15.
//  Copyright (c) 2015年 Herxun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HXChat.h"

@interface HXChat(Additions)

+(HXChat*) initWithDict:(NSDictionary*)dict;
-(void) initAllAttributes;
-(BOOL) setValuesFromDict:(NSDictionary*)dict;
-(NSDictionary*) toDict;
@end
