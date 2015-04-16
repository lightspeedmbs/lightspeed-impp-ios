//
//  HXLike+Additions.h
//  Impp
//
//  Created by Herxun on 2015/4/7.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HXLike.h"

@interface HXLike(Additions)
+(HXLike*) initWithDict:(NSDictionary*)dict;
-(void) initAllAttributes;
-(BOOL) setValuesFromDict:(NSDictionary*)dict;
-(NSDictionary*) toDict;
@end
