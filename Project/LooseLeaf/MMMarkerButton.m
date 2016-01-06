//
//  MMMarkerButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 1/6/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMMarkerButton.h"

@implementation MMMarkerButton

- (id)initWithFrame:(CGRect)frame
{
    // adjust the frame so that

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
- (void)drawRect:(CGRect)rect
{
    // Create the context
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    //Make sure the remove the anti-alias effect from circle
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetShouldAntialias(context, true);

    //// Color Declarations
    UIColor* darkerGreyBorder = [self borderColor];
    UIColor* halfGreyFill = [self backgroundColor];
    UIColor* pencilShadow = [UIColor colorWithRed: 0.57 green: 0.57 blue: 0.57 alpha: 0.35];
    UIColor* barelyWhite = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.25];

    //// Gradient Declarations
    NSArray* pencilFillGradientColors = [NSArray arrayWithObjects:
                                         (id)halfGreyFill.CGColor,
                                         (id)[UIColor colorWithRed: 0.71 green: 0.71 blue: 0.71 alpha: 0.42].CGColor,
                                         (id)pencilShadow.CGColor,
                                         (id)[UIColor colorWithRed: 0.71 green: 0.71 blue: 0.71 alpha: 0.42].CGColor,
                                         (id)halfGreyFill.CGColor,
                                         (id)[UIColor colorWithRed: 0.71 green: 0.71 blue: 0.71 alpha: 0.42].CGColor,
                                         (id)pencilShadow.CGColor,
                                         (id)halfGreyFill.CGColor,
                                         (id)[UIColor colorWithRed: 0.71 green: 0.71 blue: 0.71 alpha: 0.42].CGColor,
                                         (id)pencilShadow.CGColor, nil];
    CGFloat pencilFillGradientLocations[] = {0, 0.26, 0.33, 0.33, 0.33, 0.5, 0.65, 0.66, 0.75, 0.93};
    CGGradientRef pencilFillGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)pencilFillGradientColors, pencilFillGradientLocations);

    CGRect frame = [self drawableFrame];

    //// Oval
    UIBezierPath* ovalPath = [self ovalPath];


    //// Marker Tip Drawing
    UIBezierPath* markerTipPath = [UIBezierPath bezierPath];
    [markerTipPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.41250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.46250 * CGRectGetHeight(frame))];
    [markerTipPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.36250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.51250 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.41250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.46250 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.40625 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.43750 * CGRectGetHeight(frame))];
    [markerTipPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.32500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.68750 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.31875 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.58750 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.32500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.68750 * CGRectGetHeight(frame))];
    [markerTipPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.48750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.63750 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.32500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.68750 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.41250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.68125 * CGRectGetHeight(frame))];
    [markerTipPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.53750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.58750 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.56250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.59375 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.53750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.58750 * CGRectGetHeight(frame))];
    [markerTipPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.41250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.46250 * CGRectGetHeight(frame))];
    [markerTipPath closePath];


    //// Marker Body Drawing
    UIBezierPath* markerBodyPath = [UIBezierPath bezierPath];
    [markerBodyPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 35.5, CGRectGetMinY(frame) + 4.5)];
    [markerBodyPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.99890 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31930 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 38.68, CGRectGetMinY(frame) + 7.68) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.99890 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31930 * CGRectGetHeight(frame))];
    [markerBodyPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.90747 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.41072 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.99890 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31930 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.99586 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.32233 * CGRectGetHeight(frame))];
    [markerBodyPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.67767 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.53447 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.81909 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.49911 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.67767 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.53447 * CGRectGetHeight(frame))];
    [markerBodyPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.67160 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.52840 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.67767 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.53447 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.67550 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.53230 * CGRectGetHeight(frame))];
    [markerBodyPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.60411 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.59589 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.64740 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.55260 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.60411 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.59589 * CGRectGetHeight(frame))];
    [markerBodyPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.53339 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.59589 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.58458 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.61542 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.55292 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.61542 * CGRectGetHeight(frame))];
    [markerBodyPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.40411 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.46661 * CGRectGetHeight(frame))];
    [markerBodyPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.38958 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.42779 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.39346 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.45596 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.38862 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.44171 * CGRectGetHeight(frame))];
    [markerBodyPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.40411 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.39589 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.39038 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.41617 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.39522 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.40478 * CGRectGetHeight(frame))];
    [markerBodyPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.47160 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.32840 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.40411 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.39589 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.44740 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.35260 * CGRectGetHeight(frame))];
    [markerBodyPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.46553 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.32233 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.46770 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.32450 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.46553 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.32233 * CGRectGetHeight(frame))];
    [markerBodyPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.55605 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.13112 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.46553 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.32233 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.49191 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.21683 * CGRectGetHeight(frame))];
    [markerBodyPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.58928 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09253 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.56617 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.11760 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.57723 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.10457 * CGRectGetHeight(frame))];
    [markerBodyPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.68070 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.00110 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.67767 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.00414 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.68070 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.00110 * CGRectGetHeight(frame))];
    [markerBodyPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 35.5, CGRectGetMinY(frame) + 4.5) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.68070 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.00110 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 32.32, CGRectGetMinY(frame) + 1.32)];
    [markerBodyPath closePath];
    markerBodyPath.lineWidth = 1;


    //// Lower Shadow Drawing
    UIBezierPath* lowerShadowPath = [UIBezierPath bezierPath];
    [lowerShadowPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 27.5, CGRectGetMinY(frame) + 21.5)];
    [lowerShadowPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 26.83, CGRectGetMinY(frame) + 20) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 27.5, CGRectGetMinY(frame) + 21.5) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 27.33, CGRectGetMinY(frame) + 20.75)];
    [lowerShadowPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 25.5, CGRectGetMinY(frame) + 18.5) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 26.33, CGRectGetMinY(frame) + 19.25) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 25.5, CGRectGetMinY(frame) + 18.5)];
    lowerShadowPath.lineWidth = 1;


    //// Upper Shadow Drawing
    UIBezierPath* upperShadowPath = [UIBezierPath bezierPath];
    [upperShadowPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 21.5, CGRectGetMinY(frame) + 14.5)];
    [upperShadowPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 20.83, CGRectGetMinY(frame) + 14) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 21.5, CGRectGetMinY(frame) + 14.5) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 21.33, CGRectGetMinY(frame) + 14.25)];
    [upperShadowPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 19.5, CGRectGetMinY(frame) + 13.5) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 20.33, CGRectGetMinY(frame) + 13.75) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 19.5, CGRectGetMinY(frame) + 13.5)];
    upperShadowPath.lineWidth = 1;


    // Fill Oval Drawing
    [ovalPath closePath];
    [halfGreyFill setFill];
    [ovalPath fill];

    // get cliping mask for circle
    //
    // our pencil path extends outside the circle.
    // so we need to clip the pencil out of the filled
    // circle, then stroke the pencil, then clip the
    // portion of the pencil stroke that is outside the circle
    // then stroke the circle

    UIBezierPath *circleClipPath = [UIBezierPath bezierPathWithRect:CGRectInfinite];
    [circleClipPath appendPath:ovalPath];
    circleClipPath.usesEvenOddFillRule = YES;

    // cut marker
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setFill];
    [markerTipPath fill];
    [markerBodyPath fill];
    CGContextSetBlendMode(context, kCGBlendModeNormal);

    // fill marker body tip
    [pencilShadow setFill];
    [barelyWhite setFill];
    [markerBodyPath fill];

    // draw shadows
    [halfGreyFill setStroke];
    [lowerShadowPath stroke];
    [upperShadowPath stroke];

    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setStroke];
    [markerBodyPath stroke];
    CGContextSetBlendMode(context, kCGBlendModeNormal);

    [darkerGreyBorder setStroke];
    [markerBodyPath stroke];

    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setFill];
    [markerTipPath fill];
    CGContextSetBlendMode(context, kCGBlendModeNormal);

    [darkerGreyBorder setFill];
    [markerTipPath fill];


    // clip end of pencil
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

    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(pencilFillGradient);
}

@end
