//
//  HXMessage+Additions.h
//  IMChat
//
//  Created by Herxun on 2015/1/15.
//  Copyright (c) 2015年 Herxun. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "HXMessage.h"

@interface HXMessage(Additions)

+(HXMessage*) initWithDict:(NSDictionary*)dict;
+(HXMessage *)createTempObjectWithDict:(NSDictionary *)dict;
-(void) initAllAttributes;
-(BOOL) setValuesFromDict:(NSDictionary*)dict;
-(NSDictionary*) toDict;

@end
