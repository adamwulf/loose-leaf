//
//  MMPenButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 1/6/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMPenButton.h"
#import "UIColor+RHInterpolationAdditions.h"


@implementation MMPenButton

- (id)initWithFrame:(CGRect)frame {
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
- (void)drawRect:(CGRect)rect {
    // Create the context
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    //Make sure the remove the anti-alias effect from circle
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetShouldAntialias(context, true);

    //// Color Declarations
    UIColor* darkerGreyBorder = [self borderColor];
    UIColor* halfGreyFill = [self backgroundColor];
    UIColor* white = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    UIColor* halfWhite = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.502];
    UIColor* penTipColor = [UIColor colorWithRed:0.502 green:0.502 blue:0.502 alpha:0.702];

    //// Gradient Declarations
    CGFloat penBodyLocations[] = {0, 0.31, 0.56, 0.74, 0.87};
    CGGradientRef penBody = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) @[(id)white.CGColor, (id)[white blendedColorWithFraction:0.5 ofColor:halfWhite].CGColor, (id)halfWhite.CGColor, (id)[halfWhite blendedColorWithFraction:0.5 ofColor:halfGreyFill].CGColor, (id)halfGreyFill.CGColor], penBodyLocations);

    CGRect frame = [self drawableFrame];

    //// Oval
    UIBezierPath* ovalPath = [self ovalPath];


    //// Pencil Tip Drawing
    UIBezierPath* pencilTipPath = [UIBezierPath bezierPath];
    [pencilTipPath moveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.46132 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.62278 * CGRectGetHeight(frame))];
    [pencilTipPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.40299 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.64848 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.44034 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.63199 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.42048 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.64074 * CGRectGetHeight(frame))];
    [pencilTipPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.36263 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.61437 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.36255 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.66636 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.34606 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.65272 * CGRectGetHeight(frame))];
    [pencilTipPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.38982 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.55128 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.37069 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.59572 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.37999 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.57416 * CGRectGetHeight(frame))];
    [pencilTipPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.46132 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.62278 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.41361 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.57507 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.43764 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.59910 * CGRectGetHeight(frame))];
    [pencilTipPath closePath];

    //// Pencil Outline Drawing
    UIBezierPath* pencilBodyPath = [UIBezierPath bezierPath];
    [pencilBodyPath moveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.85625 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09375 * CGRectGetHeight(frame))];
    [pencilBodyPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.99964 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31174 * CGRectGetHeight(frame))];
    [pencilBodyPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.91214 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.39924 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.99964 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31174 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.94964 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.36174 * CGRectGetHeight(frame))];
    [pencilBodyPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.72906 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.50627 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.86214 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.44924 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.75887 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.49350 * CGRectGetHeight(frame))];
    [pencilBodyPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.68714 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.52424 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.71565 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.51202 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.70160 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.51804 * CGRectGetHeight(frame))];
    [pencilBodyPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.47774 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.63125 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.64346 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.54104 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.55852 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.59578 * CGRectGetHeight(frame))];
    [pencilBodyPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.38125 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.53476 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.45407 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.60757 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.40503 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.55854 * CGRectGetHeight(frame))];
    [pencilBodyPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.48714 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.32424 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.41618 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.45344 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.47034 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.36792 * CGRectGetHeight(frame))];
    [pencilBodyPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.51109 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26836 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.49553 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.30466 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.50359 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.28586 * CGRectGetHeight(frame))];
    [pencilBodyPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.55877 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17203 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.51729 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.25390 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.53478 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.21307 * CGRectGetHeight(frame))];
    [pencilBodyPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.61214 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09924 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.57428 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.14550 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.59251 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.11887 * CGRectGetHeight(frame))];
    [pencilBodyPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.69964 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01174 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.64964 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.06174 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.69964 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01174 * CGRectGetHeight(frame))];
    [pencilBodyPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.85625 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09375 * CGRectGetHeight(frame))];
    [pencilBodyPath closePath];


    // Body Line
    UIBezierPath* bodyLinePath = [UIBezierPath bezierPath];
    [bodyLinePath moveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.87500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.42500 * CGRectGetHeight(frame))];
    [bodyLinePath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.76875 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24375 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.87500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.42500 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.83594 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.32344 * CGRectGetHeight(frame))];
    [bodyLinePath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.58125 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.13125 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.70156 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.16406 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.58125 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.13125 * CGRectGetHeight(frame))];


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

    UIBezierPath* circleClipPath = [UIBezierPath bezierPathWithRect:CGRectInfinite];
    [circleClipPath appendPath:ovalPath];
    circleClipPath.usesEvenOddFillRule = YES;

    // cut pencil out
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setFill];
    [pencilBodyPath fill];
    CGContextSetBlendMode(context, kCGBlendModeNormal);

    // fill pencil body
    CGContextSaveGState(context);
    [pencilBodyPath addClip];
    UIBezierPath* pencilBodyRotatedPath = [pencilBodyPath copy];
    CGAffineTransform pencilBodyTransform = CGAffineTransformMakeRotation(58 * (-M_PI / 180));
    [pencilBodyRotatedPath applyTransform:pencilBodyTransform];
    CGRect pencilBodyBounds = CGPathGetPathBoundingBox(pencilBodyRotatedPath.CGPath);
    pencilBodyTransform = CGAffineTransformInvert(pencilBodyTransform);

    CGContextDrawLinearGradient(context, penBody,
                                CGPointApplyAffineTransform(CGPointMake(CGRectGetMinX(pencilBodyBounds), CGRectGetMidY(pencilBodyBounds)), pencilBodyTransform),
                                CGPointApplyAffineTransform(CGPointMake(CGRectGetMaxX(pencilBodyBounds), CGRectGetMidY(pencilBodyBounds)), pencilBodyTransform),
                                0);
    CGContextRestoreGState(context);


    [penTipColor setFill];
    [pencilTipPath fill];

    // stroke pencil body
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setStroke];
    [pencilBodyPath stroke];
    [bodyLinePath stroke];
    CGContextSetBlendMode(context, kCGBlendModeNormal);

    [darkerGreyBorder setStroke];
    [pencilBodyPath stroke];

    // body line
    [darkerGreyBorder setStroke];
    [bodyLinePath setLineWidth:.5];
    [bodyLinePath stroke];


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
    CGGradientRelease(penBody);
}


@end
