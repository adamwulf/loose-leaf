//
//  MMLikeButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/2/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMLikeButton.h"


@implementation MMLikeButton

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
    CGContextRef context = UIGraphicsGetCurrentContext();

    //// Color Declarations
    UIColor* darkerGreyBorder = [self borderColor];
    UIColor* halfGreyFill = [self backgroundColor];
    UIColor* barelyWhite = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.25];
    UIColor* pencilShadow = [UIColor colorWithRed:0.57 green:0.57 blue:0.57 alpha:0.35];

    CGRect frame = [self drawableFrame];

    //// Oval
    UIBezierPath* ovalPath = [self ovalPath];
    [halfGreyFill setFill];
    [ovalPath fill];

    // oval clip
    UIBezierPath* circleClipPath = [UIBezierPath bezierPathWithRect:CGRectInfinite];
    [circleClipPath appendPath:ovalPath];
    circleClipPath.usesEvenOddFillRule = YES;


    //// sleeve Drawing
    UIBezierPath* sleevePath = [UIBezierPath bezierPath];
    [sleevePath moveToPoint:CGPointMake(CGRectGetMinX(frame) + 11.5, CGRectGetMinY(frame) + 17.5)];
    [sleevePath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 11.5, CGRectGetMinY(frame) + 33.5)];
    [sleevePath addLineToPoint:CGPointMake(CGRectGetMinX(frame), CGRectGetMinY(frame) + 33.5)];
    [sleevePath addLineToPoint:CGPointMake(CGRectGetMinX(frame), CGRectGetMinY(frame) + 17.5)];
    [sleevePath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 11.5, CGRectGetMinY(frame) + 17.5)];
    [sleevePath closePath];


    //// Button Drawing
    UIBezierPath* buttonPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.17500 + 0.5), CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.70000 + 0.5), floor(CGRectGetWidth(frame) * 0.25000 + 0.5) - floor(CGRectGetWidth(frame) * 0.17500 + 0.5), floor(CGRectGetHeight(frame) * 0.77500 + 0.5) - floor(CGRectGetHeight(frame) * 0.70000 + 0.5))];


    //// hand Drawing
    UIBezierPath* handPath = [UIBezierPath bezierPath];
    [handPath moveToPoint:CGPointMake(CGRectGetMinX(frame) + 11.5, CGRectGetMinY(frame) + 19.5)];
    [handPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 13.5, CGRectGetMinY(frame) + 19.5)];
    [handPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 14.5, CGRectGetMinY(frame) + 18.5)];
    [handPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 15.5, CGRectGetMinY(frame) + 17.5)];
    [handPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 16.5, CGRectGetMinY(frame) + 15.5)];
    [handPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 17.5, CGRectGetMinY(frame) + 13.5)];
    [handPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 17.5, CGRectGetMinY(frame) + 9.5)];
    [handPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 18.5, CGRectGetMinY(frame) + 8.5)];
    [handPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 19.5, CGRectGetMinY(frame) + 8.5)];
    [handPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 21.5, CGRectGetMinY(frame) + 10.5)];
    [handPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 22, CGRectGetMinY(frame) + 12)];
    [handPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 22, CGRectGetMinY(frame) + 15.5)];
    [handPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 21.5, CGRectGetMinY(frame) + 17.5)];
    [handPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 28.5, CGRectGetMinY(frame) + 17.5) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 21.5, CGRectGetMinY(frame) + 17.5) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 27.78, CGRectGetMinY(frame) + 17.41)];
    [handPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 30.5, CGRectGetMinY(frame) + 19.5) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 29.22, CGRectGetMinY(frame) + 17.59) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 30.39, CGRectGetMinY(frame) + 18.36)];
    [handPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 30.5, CGRectGetMinY(frame) + 24) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 30.61, CGRectGetMinY(frame) + 20.64) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 30.55, CGRectGetMinY(frame) + 23.16)];
    [handPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 29.5, CGRectGetMinY(frame) + 25.5) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 30.47, CGRectGetMinY(frame) + 24.43) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 29.75, CGRectGetMinY(frame) + 24.75)];
    [handPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 29, CGRectGetMinY(frame) + 28.5) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 29.25, CGRectGetMinY(frame) + 26.25) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 29.25, CGRectGetMinY(frame) + 27.75)];
    [handPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 27.5, CGRectGetMinY(frame) + 30.5) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 28.75, CGRectGetMinY(frame) + 29.25) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 27.5, CGRectGetMinY(frame) + 30.5)];
    [handPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 26, CGRectGetMinY(frame) + 31.5) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 27.5, CGRectGetMinY(frame) + 30.5) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 27.46, CGRectGetMinY(frame) + 31.37)];
    [handPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 11.5, CGRectGetMinY(frame) + 31.5) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 24.54, CGRectGetMinY(frame) + 31.63) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 11.5, CGRectGetMinY(frame) + 31.5)];
    [handPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 11.5, CGRectGetMinY(frame) + 19.5)];
    [handPath closePath];
    //    [halfGrey setFill];
    //    [handPath fill];


    // hand
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setStroke];
    [[UIColor whiteColor] setFill];
    [handPath stroke];
    [handPath fill];
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    [barelyWhite setFill];
    [handPath fill];
    [darkerGreyBorder setStroke];
    handPath.lineWidth = 1;
    [handPath stroke];


    // sleeve
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setStroke];
    [[UIColor whiteColor] setFill];
    [sleevePath stroke];
    [sleevePath fill];
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    [pencilShadow setFill];
    [sleevePath fill];
    [darkerGreyBorder setStroke];
    [sleevePath stroke];


    // button
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setStroke];
    [[UIColor whiteColor] setFill];
    [buttonPath fill];
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    [halfGreyFill setFill];
    [buttonPath fill];


    // clip end of sleeve
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setFill];
    [circleClipPath fill];
    CGContextSetBlendMode(context, kCGBlendModeNormal);

    // stroke circle
    [darkerGreyBorder setStroke];
    ovalPath.lineWidth = 1;
    [ovalPath stroke];


    [self drawDropshadowIfSelected];

    [super drawRect:rect];
}

@end
