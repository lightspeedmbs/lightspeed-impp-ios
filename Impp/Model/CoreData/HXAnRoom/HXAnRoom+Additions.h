//
//  HXAnRoom+Additions.h
//  Impp
//
//  Created by 雷翊廷 on 2015/7/15.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import "HXAnRoom.h"

@interface HXAnRoom (Additions)
+ (BOOL) isObjectAvailable:(id) data;
+(HXAnRoom*) initWithDict:(NSDictionary*)dict;
-(void) initAllAttributes;
-(BOOL) setValuesFromDict:(NSDictionary*)dict;
-(NSDictionary*) toDict;
@end
