//
//  HXVoiceRecordView.h
//  IMChat
//
//  Created by Jefferson on 2015/1/12.
//  Copyright (c) 2015年 Herxun. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HXVoiceRecordViewDelegate <NSObject>
- (void)sendVoiceData:(NSData *)voice;
@end

@interface HXVoiceRecordView : UIView
@property (weak, nonatomic) id<HXVoiceRecordViewDelegate> delegate;
@end
