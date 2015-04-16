//
//  HXMessage.h
//  IMChat
//
//  Created by Herxun on 2015/1/16.
//  Copyright (c) 2015年 Herxun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class HXChat;

@interface HXMessage : NSManagedObject

@property (nonatomic, retain) NSData * content;
@property (nonatomic, retain) NSString * fileURL;
@property (nonatomic, retain) NSString * from;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSNumber * readACK;
@property (nonatomic, retain) NSString * senderName;
@property (nonatomic, retain) NSNumber * timestamp;
@property (nonatomic, retain) NSString * topicId;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * currentClientId;
@property (nonatomic, retain) NSString * msgId;
@property (nonatomic, retain) NSString * processStatus;
@property (nonatomic, retain) HXChat *chat;

@end
