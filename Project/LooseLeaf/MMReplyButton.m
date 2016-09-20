//
//  MMReplyButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/6/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMReplyButton.h"


@implementation MMReplyButton

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();

    //// Color Declarations
    UIColor* halfGreyFill = [self backgroundColor];


    CGContextSaveGState(context);


    UIBezierPath* replyArrowPath = UIBezierPath.bezierPath;
    [replyArrowPath moveToPoint:CGPointMake(36, 24.5)];
    [replyArrowPath addLineToPoint:CGPointMake(27, 33.5)];
    [replyArrowPath addLineToPoint:CGPointMake(36, 42.5)];
    [replyArrowPath addLineToPoint:CGPointMake(36, 37)];
    [replyArrowPath addCurveToPoint:CGPointMake(44.5, 39) controlPoint1:CGPointMake(36, 37) controlPoint2:CGPointMake(40, 35.5)];
    [replyArrowPath addCurveToPoint:CGPointMake(47, 51) controlPoint1:CGPointMake(48.99, 42.49) controlPoint2:CGPointMake(47, 51)];
    [replyArrowPath addCurveToPoint:CGPointMake(48, 36) controlPoint1:CGPointMake(47, 51) controlPoint2:CGPointMake(53.5, 43)];
    [replyArrowPath addCurveToPoint:CGPointMake(36, 30) controlPoint1:CGPointMake(43.17, 29.23) controlPoint2:CGPointMake(36, 30)];
    [replyArrowPath addLineToPoint:CGPointMake(36, 24.5)];
    [replyArrowPath closePath];

    [halfGreyFill setFill];
    [replyArrowPath fill];

    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setStroke];
    replyArrowPath.lineWidth = 2;
    [replyArrowPath stroke];
    CGContextSetBlendMode(context, kCGBlendModeNormal);

    [halfGreyFill setStroke];
    [replyArrowPath stroke];

    CGContextRestoreGState(context);
}
@end
