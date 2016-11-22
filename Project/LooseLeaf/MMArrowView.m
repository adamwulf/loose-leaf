//
//  MMArrowView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 11/21/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMArrowView.h"
#import "Constants.h"


@implementation MMArrowView {
    CAShapeLayer* arrowBorder;
    CAShapeLayer* arrowFill;
    CALayer* maskLayer;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIBezierPath* arrowPath = [self arrowPathForFrame:CGRectMake(0, 0, 80, 80)];

        arrowFill = [CAShapeLayer layer];
        arrowFill.bounds = CGRectMake(0, 0, 80, 80);
        arrowFill.path = arrowPath.CGPath;
        arrowFill.strokeColor = [UIColor clearColor].CGColor;
        arrowFill.fillColor = [UIColor whiteColor].CGColor;
        arrowFill.position = CGRectGetMidPoint(self.bounds);
        [[self layer] addSublayer:arrowFill];
    }
    return self;
}

- (UIBezierPath*)arrowPathForFrame:(CGRect)frame {
    UIBezierPath* arrowPath = [UIBezierPath bezierPath];
    [arrowPath moveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.65190 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17090 * CGRectGetHeight(frame))];
    [arrowPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.65190 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.51266 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.65190 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17089 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.65190 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.44944 * CGRectGetHeight(frame))];
    [arrowPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.81646 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.51266 * CGRectGetHeight(frame))];
    [arrowPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.50000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.82911 * CGRectGetHeight(frame))];
    [arrowPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.18354 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.51266 * CGRectGetHeight(frame))];
    [arrowPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.34810 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.51266 * CGRectGetHeight(frame))];
    [arrowPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.34810 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17089 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.34810 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.44944 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.34810 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17089 * CGRectGetHeight(frame))];
    [arrowPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.65190 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17089 * CGRectGetHeight(frame))];
    [arrowPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.65190 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17090 * CGRectGetHeight(frame))];
    [arrowPath closePath];

    return arrowPath;
}

@end
