//
//  HXPost+Additions.h
//  Impp
//
//  Created by Herxun on 2015/4/7.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "HXPost.h"

@interface HXPost(Additions)
+(HXPost*) initWithDict:(NSDictionary*)dict;
-(void) initAllAttributes;
-(BOOL) setValuesFromDict:(NSDictionary*)dict;
-(NSDictionary*) toDict;
-(NSDictionary *) getCustomFields;
@end
