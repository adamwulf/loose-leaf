//
//  MMPalmTreeButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 4/9/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMPalmTreeButton.h"

@implementation MMPalmTreeButton

- (id)initWithFrame:(CGRect)frame
{
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
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* darkerGreyBorder = [self borderColor];
    UIColor* halfGreyFill = [self backgroundColor];
    UIColor* barelyWhite = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.25];
    UIColor* mostlyWhite = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.65];
    UIColor* darkerGrey = [UIColor colorWithRed: 0.2 green: 0.2 blue: 0.2 alpha: 0.25];
    UIColor* treeHighlight = [UIColor colorWithRed: 0.471 green: 0.471 blue: 0.471 alpha: 0.294];

    //// Gradient Declarations
    NSArray* faceGradientColors = [NSArray arrayWithObjects:
                                   (id)mostlyWhite.CGColor,
                                   (id)[UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.449].CGColor,
                                   (id)barelyWhite.CGColor, nil];
    CGFloat faceGradientLocations[] = {0, 0.71, 1};
    CGGradientRef faceGradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)faceGradientColors, faceGradientLocations);
    
    NSArray* treehighlightfillColors = [NSArray arrayWithObjects:
                                        (id)darkerGrey.CGColor,
                                        (id)[UIColor colorWithRed: 0.335 green: 0.335 blue: 0.335 alpha: 0.272].CGColor,
                                        (id)treeHighlight.CGColor, nil];
    CGFloat treehighlightfillLocations[] = {0, 0.47, 1};
    CGGradientRef treehighlightfill = CGGradientCreateWithColors(colorSpace, (CFArrayRef)treehighlightfillColors, treehighlightfillLocations);

    CGRect frame = [self drawableFrame];
    
    //// Oval
    UIBezierPath* ovalPath = [self ovalPath];
//    [halfGreyFill setFill];
//    [ovalPath fill];
    
    CGContextSaveGState(context);
    [ovalPath addClip];
    CGRect faceBounds = CGPathGetPathBoundingBox(ovalPath.CGPath);
    CGContextDrawLinearGradient(context, faceGradient,
                                CGPointMake(CGRectGetMidX(faceBounds), CGRectGetMinY(faceBounds)),
                                CGPointMake(CGRectGetMidX(faceBounds), CGRectGetMaxY(faceBounds)),
                                0);
    CGContextRestoreGState(context);

    
    // oval clip
    UIBezierPath *circleClipPath = [UIBezierPath bezierPathWithRect:CGRectInfinite];
    [circleClipPath appendPath:ovalPath];
    circleClipPath.usesEvenOddFillRule = YES;
    
    
    
    
    //// Button Drawing
    UIBezierPath* buttonPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.17500 + 0.5), CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.70000 + 0.5), floor(CGRectGetWidth(frame) * 0.25000 + 0.5) - floor(CGRectGetWidth(frame) * 0.17500 + 0.5), floor(CGRectGetHeight(frame) * 0.77500 + 0.5) - floor(CGRectGetHeight(frame) * 0.70000 + 0.5))];
    
    
    //// hand Drawing
    UIBezierPath* palmTreePath = [UIBezierPath bezierPath];
    [palmTreePath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 6.5, CGRectGetMinY(frame) + 36.5)];
    [palmTreePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 27.5, CGRectGetMinY(frame) + 35.5)];
    [palmTreePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 28.5, CGRectGetMinY(frame) + 34.5)];
    [palmTreePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 25.5, CGRectGetMinY(frame) + 29.5)];
    [palmTreePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 24.5, CGRectGetMinY(frame) + 26.5)];
    [palmTreePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 22.5, CGRectGetMinY(frame) + 22.5)];
    [palmTreePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 19.5, CGRectGetMinY(frame) + 21.5)];
    [palmTreePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 18.5, CGRectGetMinY(frame) + 22.5)];
    [palmTreePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 18.5, CGRectGetMinY(frame) + 26.5)];
    [palmTreePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 19.5, CGRectGetMinY(frame) + 28.5)];
    [palmTreePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 20.5, CGRectGetMinY(frame) + 30.5)];
    [palmTreePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 16, CGRectGetMinY(frame) + 27.5) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 20.5, CGRectGetMinY(frame) + 30.5) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 17.59, CGRectGetMinY(frame) + 29.68)];
    [palmTreePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 15.5, CGRectGetMinY(frame) + 20.5) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 14.41, CGRectGetMinY(frame) + 25.32) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 15.5, CGRectGetMinY(frame) + 20.5)];
    [palmTreePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 14.5, CGRectGetMinY(frame) + 22)];
    [palmTreePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 12.5, CGRectGetMinY(frame) + 23.5)];
    [palmTreePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 11.5, CGRectGetMinY(frame) + 26.5)];
    [palmTreePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 10.5, CGRectGetMinY(frame) + 24.5)];
    [palmTreePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 11, CGRectGetMinY(frame) + 20.5) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 10.5, CGRectGetMinY(frame) + 24.5) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 10, CGRectGetMinY(frame) + 22.25)];
    [palmTreePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 14, CGRectGetMinY(frame) + 17) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 12, CGRectGetMinY(frame) + 18.75) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 14, CGRectGetMinY(frame) + 17)];
    [palmTreePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 15.5, CGRectGetMinY(frame) + 15.5)];
    [palmTreePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 12.56, CGRectGetMinY(frame) + 14.35)];
    [palmTreePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 9, CGRectGetMinY(frame) + 15.5)];
    [palmTreePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 12.4, CGRectGetMinY(frame) + 12.18) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 9, CGRectGetMinY(frame) + 15.5) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 9.65, CGRectGetMinY(frame) + 12.43)];
    [palmTreePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 16.5, CGRectGetMinY(frame) + 12.5) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 14.55, CGRectGetMinY(frame) + 11.99) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 16.5, CGRectGetMinY(frame) + 12.5)];
    [palmTreePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 18.5, CGRectGetMinY(frame) + 11.5)];
    [palmTreePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 19.5, CGRectGetMinY(frame) + 8.5) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 18.5, CGRectGetMinY(frame) + 11.5) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 18.43, CGRectGetMinY(frame) + 10.93)];
    [palmTreePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 24.5, CGRectGetMinY(frame) + 8) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 20.57, CGRectGetMinY(frame) + 6.07) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 24.5, CGRectGetMinY(frame) + 8)];
    [palmTreePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 22, CGRectGetMinY(frame) + 10)];
    [palmTreePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 21, CGRectGetMinY(frame) + 12.5)];
    [palmTreePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 23.5, CGRectGetMinY(frame) + 12.5)];
    [palmTreePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 26.5, CGRectGetMinY(frame) + 10.5) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 23.5, CGRectGetMinY(frame) + 12.5) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 24.75, CGRectGetMinY(frame) + 11)];
    [palmTreePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 30.5, CGRectGetMinY(frame) + 11.5) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 28.25, CGRectGetMinY(frame) + 10) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 28.75, CGRectGetMinY(frame) + 10.5)];
    [palmTreePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 34, CGRectGetMinY(frame) + 15) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 32.25, CGRectGetMinY(frame) + 12.5) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 34, CGRectGetMinY(frame) + 15)];
    [palmTreePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 31.5, CGRectGetMinY(frame) + 15) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 34, CGRectGetMinY(frame) + 15) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 32.62, CGRectGetMinY(frame) + 15.38)];
    [palmTreePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 29, CGRectGetMinY(frame) + 13.5) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 30.38, CGRectGetMinY(frame) + 14.62) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 30.5, CGRectGetMinY(frame) + 13.88)];
    [palmTreePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 26, CGRectGetMinY(frame) + 14) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 27.5, CGRectGetMinY(frame) + 13.12) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 26, CGRectGetMinY(frame) + 14)];
    [palmTreePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 24.5, CGRectGetMinY(frame) + 16.5)];
    [palmTreePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 27.5, CGRectGetMinY(frame) + 17.5)];
    [palmTreePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 28.5, CGRectGetMinY(frame) + 18.5)];
    [palmTreePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 30.5, CGRectGetMinY(frame) + 21.5)];
    [palmTreePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 30.5, CGRectGetMinY(frame) + 24.5)];
    [palmTreePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 25.5, CGRectGetMinY(frame) + 19.5)];
    [palmTreePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 24.5, CGRectGetMinY(frame) + 20.5)];
    [palmTreePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 24.5, CGRectGetMinY(frame) + 22.5)];
    [palmTreePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 26.5, CGRectGetMinY(frame) + 25.5)];
    [palmTreePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 27.5, CGRectGetMinY(frame) + 27.5)];
    [palmTreePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 28.5, CGRectGetMinY(frame) + 29.5)];
    [palmTreePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 29.5, CGRectGetMinY(frame) + 31.5)];
    [palmTreePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 30.5, CGRectGetMinY(frame) + 33.5)];
    [palmTreePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 33.5, CGRectGetMinY(frame) + 34.5)];
    [palmTreePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 37.5, CGRectGetMinY(frame) + 35.5)];
    [palmTreePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 38.5, CGRectGetMinY(frame) + 39.5)];
    [palmTreePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.5, CGRectGetMinY(frame) + 39.5)];
    [palmTreePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 6.5, CGRectGetMinY(frame) + 36.5)];
    [palmTreePath closePath];
    
    // cut the stroke out so it's crisp
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setFill];
    [palmTreePath fill];
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    
    CGContextSaveGState(context);
    [palmTreePath addClip];
    CGRect palmTreeBounds = CGPathGetPathBoundingBox(palmTreePath.CGPath);
    CGFloat palmTreeResizeRatio = MIN(CGRectGetWidth(palmTreeBounds) / 38, CGRectGetHeight(palmTreeBounds) / 33);
    CGContextDrawRadialGradient(context, treehighlightfill,
                                CGPointMake(CGRectGetMidX(palmTreeBounds) + 0.51 * palmTreeResizeRatio, CGRectGetMidY(palmTreeBounds) + -5.76 * palmTreeResizeRatio), 10 * palmTreeResizeRatio,
                                CGPointMake(CGRectGetMidX(palmTreeBounds) + 0.5 * palmTreeResizeRatio, CGRectGetMidY(palmTreeBounds) + -3.76 * palmTreeResizeRatio), 2.44 * palmTreeResizeRatio,
                                kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    CGContextRestoreGState(context);
    [darkerGrey setStroke];
    palmTreePath.lineWidth = 1;
    [palmTreePath stroke];
    
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setStroke];
    [palmTreePath stroke];
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    // fill face with gradient
    [darkerGreyBorder setStroke];
    [palmTreePath stroke];

    
    
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
