//
//  HXUser+Additions.h
//  IMChat
//
//  Created by Herxun on 2015/1/15.
//  Copyright (c) 2015年 Herxun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HXUser.h"

@interface HXUser(Additions)
+(HXUser *) initWithDict:(NSDictionary*)dict;
+(HXUser *)createTempObjectWithDict:(NSDictionary *)dict;
-(void) initAllAttributes;
-(BOOL) setValuesFromDict:(NSDictionary*)dict;
- (BOOL)setValuesFromDictWithoutSaved:(NSDictionary *)dict;
-(NSDictionary*) toDict;
@end
