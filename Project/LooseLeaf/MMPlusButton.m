//
//  MMPlusButton.m
//  Loose Leaf
//
//  Created by Adam Wulf on 6/21/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "MMPlusButton.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"


@implementation MMPlusButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    //// Color Declarations
    UIColor* darkerGreyBorder = [self borderColor];
    UIColor* halfGreyFill = [self backgroundColor];

    CGRect frame = [self drawableFrame];

    //// Oval
    UIBezierPath* ovalPath = [self ovalPath];
    [ovalPath moveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.4 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.2 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.4 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.4 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.2 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.4 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.2 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.6 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.4 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.6 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.4 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.8 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.6 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.8 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.6 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.6 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.8 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.6 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.8 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.4 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.6 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.4 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.6 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.2 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.4 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.2 * CGRectGetHeight(frame))];
    [ovalPath closePath];
    [halfGreyFill setFill];
    [ovalPath fill];
    [darkerGreyBorder setStroke];
    ovalPath.lineWidth = 1;
    [ovalPath stroke];

    [self drawDropshadowIfSelected];

    [super drawRect:rect];
}


@end
