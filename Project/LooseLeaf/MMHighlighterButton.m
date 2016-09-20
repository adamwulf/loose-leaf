//
//  MMHighlighterButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 1/6/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMHighlighterButton.h"

@implementation MMHighlighterButton

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
    UIColor* avgShadow = [UIColor colorWithRed: 0.9 green: 0.9 blue: 0.9 alpha: 0.275];
    UIColor* barelyWhite = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.25];
    UIColor* halfGreyOpaque = [UIColor colorWithRed: 0.709 green: 0.709 blue: 0.709 alpha: 0.541];

    //// Gradient Declarations
    CGFloat highlighterFillGradientLocations[] = {0.01, 0.46, 1};
    CGGradientRef highlighterFillGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)@[(id)halfGreyFill.CGColor, (id)avgShadow.CGColor, (id)barelyWhite.CGColor], highlighterFillGradientLocations);

    CGRect frame = [self drawableFrame];

    //// Oval
    UIBezierPath* ovalPath = [self ovalPath];


    //// Highlighter Tip Drawing
    UIBezierPath* highlighterTipPath = [UIBezierPath bezierPath];
    [highlighterTipPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.41250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.46250 * CGRectGetHeight(frame))];
    [highlighterTipPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.36250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.51250 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.41250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.46250 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.42500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.45000 * CGRectGetHeight(frame))];
    [highlighterTipPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.28750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.63750 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.30000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.57500 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.28750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.63750 * CGRectGetHeight(frame))];
    [highlighterTipPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.48750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.65000 * CGRectGetHeight(frame))];
    [highlighterTipPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.55000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.60000 * CGRectGetHeight(frame))];
    [highlighterTipPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.41250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.46250 * CGRectGetHeight(frame))];
    [highlighterTipPath closePath];


    //// Highlighter Body Drawing
    UIBezierPath* highlighterBodyPath = [UIBezierPath bezierPath];
    [highlighterBodyPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.88750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.11250 * CGRectGetHeight(frame))];
    [highlighterBodyPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.99890 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31930 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.96705 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.19205 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.99890 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31930 * CGRectGetHeight(frame))];
    [highlighterBodyPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.90747 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.41072 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.99890 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31930 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.99586 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.32233 * CGRectGetHeight(frame))];
    [highlighterBodyPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.70267 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.58447 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.81909 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.49911 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.71396 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.58478 * CGRectGetHeight(frame))];
    [highlighterBodyPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.65910 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.54090 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.69137 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.58416 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.66300 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.54480 * CGRectGetHeight(frame))];
    [highlighterBodyPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.57911 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.62089 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.63490 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.56510 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.60137 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.62173 * CGRectGetHeight(frame))];
    [highlighterBodyPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.37500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.42500 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.55684 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.62005 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.37512 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.44832 * CGRectGetHeight(frame))];
    [highlighterBodyPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.45910 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34090 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.37488 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.40168 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.43490 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.36510 * CGRectGetHeight(frame))];
    [highlighterBodyPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.41553 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.29733 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.45520 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.33700 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.41476 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.30899 * CGRectGetHeight(frame))];
    [highlighterBodyPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.55605 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.13112 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.41631 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.28568 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.49191 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.21683 * CGRectGetHeight(frame))];
    [highlighterBodyPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.58928 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09253 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.56617 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.11760 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.57723 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.10457 * CGRectGetHeight(frame))];
    [highlighterBodyPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.68070 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.00110 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.67767 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.00414 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.68070 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.00110 * CGRectGetHeight(frame))];
    [highlighterBodyPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.88750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.11250 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.68070 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.00110 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.80795 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.03295 * CGRectGetHeight(frame))];
    [highlighterBodyPath closePath];
    highlighterBodyPath.lineWidth = 1;


    //// Lower Shadow Drawing
    UIBezierPath* lowerShadowPath = [UIBezierPath bezierPath];
    [lowerShadowPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.62500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.43750 * CGRectGetHeight(frame))];
    [lowerShadowPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.66250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.52500 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.62500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.43750 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.66250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.48750 * CGRectGetHeight(frame))];
    lowerShadowPath.lineWidth = 1;


    //// Upper Shadow Drawing
    UIBezierPath* upperShadowPath = [UIBezierPath bezierPath];
    [upperShadowPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.52500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.36250 * CGRectGetHeight(frame))];
    [upperShadowPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50833 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.35000 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.52500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.36250 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.52083 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.35625 * CGRectGetHeight(frame))];
    [upperShadowPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.47500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.33750 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.49583 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34375 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.47500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.33750 * CGRectGetHeight(frame))];
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
    [highlighterTipPath fill];
    [highlighterBodyPath fill];
    CGContextSetBlendMode(context, kCGBlendModeNormal);

    // fill marker body with gradient
    CGContextSaveGState(context);
    [highlighterBodyPath addClip];
    UIBezierPath* highlighterBodyRotatedPath = [highlighterBodyPath copy];
    CGAffineTransform highlighterBodyTransform = CGAffineTransformMakeRotation(-140*(-M_PI/180));
    [highlighterBodyRotatedPath applyTransform: highlighterBodyTransform];
    CGRect highlighterBodyBounds = CGPathGetPathBoundingBox(highlighterBodyRotatedPath.CGPath);
    highlighterBodyTransform = CGAffineTransformInvert(highlighterBodyTransform);

    CGContextDrawLinearGradient(context, highlighterFillGradient,
                                CGPointApplyAffineTransform(CGPointMake(CGRectGetMinX(highlighterBodyBounds), CGRectGetMidY(highlighterBodyBounds)), highlighterBodyTransform),
                                CGPointApplyAffineTransform(CGPointMake(CGRectGetMaxX(highlighterBodyBounds), CGRectGetMidY(highlighterBodyBounds)), highlighterBodyTransform),
                                0);
    CGContextRestoreGState(context);

    // draw shadows
    [halfGreyOpaque setStroke];
    [lowerShadowPath stroke];
    [upperShadowPath stroke];

    // clip out the body border
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setStroke];
    [highlighterBodyPath stroke];
    CGContextSetBlendMode(context, kCGBlendModeNormal);

    // stroke body border
    [darkerGreyBorder setStroke];
    [highlighterBodyPath stroke];

    // clip out the highlighter tip
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setFill];
    [highlighterTipPath fill];
    CGContextSetBlendMode(context, kCGBlendModeNormal);

    [pencilShadow setFill];
    [highlighterTipPath fill];

    // clip out the body border
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setStroke];
    [highlighterTipPath stroke];
    CGContextSetBlendMode(context, kCGBlendModeNormal);

    // stroke body border
    [halfGreyFill setStroke];
    [highlighterTipPath stroke];
    [darkerGreyBorder setStroke];
    [highlighterTipPath stroke];



    // clip end of highlighter
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
    CGGradientRelease(highlighterFillGradient);
}


@end
