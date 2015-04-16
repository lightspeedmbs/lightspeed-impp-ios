//
//  UILabel+CustomLabel.m
//  iBeacon
//
//  Created by Tim on 2/24/15.
//  Copyright (c) 2015 Herxun. All rights reserved.
//

#import "UILabel+CustomLabel.h"

@implementation UILabel (customLabel)

+ (UILabel *)labelWithFrame:(CGRect)frame
                        text:(NSString *)text
               textAlignment:(NSTextAlignment)textAlignment
                   textColor:(UIColor *)textColor
                        font:(UIFont *)font
               numberOfLines:(NSInteger)numberOfLines
{
    UILabel *label;
    if (CGRectIsEmpty(frame))
        label = [[UILabel alloc] init];
    else
        label = [[UILabel alloc] initWithFrame:frame];

//    label.text = text;
    NSString *textString = text;
    NSMutableParagraphStyle *style  = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 3.f;
    NSDictionary *attributtes = @{NSParagraphStyleAttributeName : style};
    label.attributedText = [[NSAttributedString alloc] initWithString:textString attributes:attributtes];
    
    label.textAlignment = textAlignment;
    label.textColor = textColor;
    label.font = font;
    label.numberOfLines = numberOfLines;    
    label.lineBreakMode = NSLineBreakByTruncatingTail;

//    if (CGRectIsEmpty(frame))
        [label sizeToFit];
    
    if (numberOfLines == 0)
    {
        CGRect labelFrame = label.frame;
        labelFrame.size.width = frame.size.width;
        label.frame = labelFrame;
    }

    return label;
}

@end
