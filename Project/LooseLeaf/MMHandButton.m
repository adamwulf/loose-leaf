//
//  MMHandButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 6/1/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMHandButton.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"

@implementation MMHandButton

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
    CGContextRef context = UIGraphicsGetCurrentContext();

    //// Color Declarations
    UIColor* darkerGreyBorder = [self borderColor];
    UIColor* halfGreyFill = [self backgroundColor];
    UIColor* barelyWhite = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.25];
    
    CGRect frame = [self drawableFrame];
    
    //// Oval Drawing
    UIBezierPath* ovalPath = [self ovalPath];
    [halfGreyFill setFill];
    [ovalPath fill];
    [darkerGreyBorder setStroke];
    ovalPath.lineWidth = 1;
    [ovalPath stroke];
    
    
    //// Hand Drawing
    UIBezierPath* handPath = [UIBezierPath bezierPath];
    [handPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 13.69, CGRectGetMinY(frame) + 21.43)];
    [handPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 13, CGRectGetMinY(frame) + 18.8) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 13.52, CGRectGetMinY(frame) + 20.8) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 13.36, CGRectGetMinY(frame) + 20)];
    [handPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 12.21, CGRectGetMinY(frame) + 16.72) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 12.72, CGRectGetMinY(frame) + 17.86) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 12.43, CGRectGetMinY(frame) + 17.35)];
    [handPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 11.37, CGRectGetMinY(frame) + 14.72) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 11.95, CGRectGetMinY(frame) + 15.95) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 11.7, CGRectGetMinY(frame) + 15.5)];
    [handPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 10.6, CGRectGetMinY(frame) + 12.28) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 11.14, CGRectGetMinY(frame) + 14.16) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 10.76, CGRectGetMinY(frame) + 12.94)];
    [handPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 11.01, CGRectGetMinY(frame) + 10.24) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 10.4, CGRectGetMinY(frame) + 11.42) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 10.66, CGRectGetMinY(frame) + 10.72)];
    [handPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 13.3, CGRectGetMinY(frame) + 9.64) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 11.44, CGRectGetMinY(frame) + 9.66) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 12.64, CGRectGetMinY(frame) + 9.41)];
    [handPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 14.85, CGRectGetMinY(frame) + 10.98) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 13.93, CGRectGetMinY(frame) + 9.86) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 14.56, CGRectGetMinY(frame) + 10.51)];
    [handPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 16.06, CGRectGetMinY(frame) + 13.59) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 15.33, CGRectGetMinY(frame) + 11.76) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 15.45, CGRectGetMinY(frame) + 12.05)];
    [handPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 17.09, CGRectGetMinY(frame) + 17.36) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 16.72, CGRectGetMinY(frame) + 15.27) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 17.01, CGRectGetMinY(frame) + 16.83)];
    [handPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 17.23, CGRectGetMinY(frame) + 18.13)];
    [handPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 17.16, CGRectGetMinY(frame) + 16.16) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 17.23, CGRectGetMinY(frame) + 18.06) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 17.16, CGRectGetMinY(frame) + 16.23)];
    [handPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 17.09, CGRectGetMinY(frame) + 11.19) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 17.1, CGRectGetMinY(frame) + 14.42) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 17.06, CGRectGetMinY(frame) + 13.08)];
    [handPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 17.24, CGRectGetMinY(frame) + 9.98) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 17.1, CGRectGetMinY(frame) + 10.97) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 17.2, CGRectGetMinY(frame) + 10.19)];
    [handPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 18.37, CGRectGetMinY(frame) + 8.32) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 17.37, CGRectGetMinY(frame) + 9.13) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 17.75, CGRectGetMinY(frame) + 8.62)];
    [handPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 20.74, CGRectGetMinY(frame) + 8.29) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 19.07, CGRectGetMinY(frame) + 7.98) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 19.93, CGRectGetMinY(frame) + 7.96)];
    [handPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 21.9, CGRectGetMinY(frame) + 10.02) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 21.45, CGRectGetMinY(frame) + 8.58) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 21.79, CGRectGetMinY(frame) + 9.22)];
    [handPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 22.05, CGRectGetMinY(frame) + 11.9) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 21.92, CGRectGetMinY(frame) + 10.21) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 22.05, CGRectGetMinY(frame) + 11.69)];
    [handPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 22.08, CGRectGetMinY(frame) + 15.58) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 22.03, CGRectGetMinY(frame) + 13.63) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 22.06, CGRectGetMinY(frame) + 14.67)];
    [handPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 22.11, CGRectGetMinY(frame) + 18.06) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 22.08, CGRectGetMinY(frame) + 15.97) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 22.08, CGRectGetMinY(frame) + 18.33)];
    [handPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 22.69, CGRectGetMinY(frame) + 11.39) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 22.21, CGRectGetMinY(frame) + 16.95) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 22.27, CGRectGetMinY(frame) + 12.66)];
    [handPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 24.03, CGRectGetMinY(frame) + 9.82) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 22.93, CGRectGetMinY(frame) + 10.66) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 23.37, CGRectGetMinY(frame) + 10.13)];
    [handPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 26.4, CGRectGetMinY(frame) + 10.23) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 24.75, CGRectGetMinY(frame) + 9.47) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 25.91, CGRectGetMinY(frame) + 9.7)];
    [handPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 27.21, CGRectGetMinY(frame) + 12.18) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 26.88, CGRectGetMinY(frame) + 10.74) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 27.15, CGRectGetMinY(frame) + 11.4)];
    [handPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 27.18, CGRectGetMinY(frame) + 14.29) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 27.26, CGRectGetMinY(frame) + 12.87) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 27.18, CGRectGetMinY(frame) + 13.7)];
    [handPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 27.11, CGRectGetMinY(frame) + 17.88) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 27.18, CGRectGetMinY(frame) + 15.75) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 27.14, CGRectGetMinY(frame) + 16.53)];
    [handPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 27.15, CGRectGetMinY(frame) + 18.19) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 27.11, CGRectGetMinY(frame) + 17.94) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 27.09, CGRectGetMinY(frame) + 18.38)];
    [handPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 27.6, CGRectGetMinY(frame) + 16.92) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 27.31, CGRectGetMinY(frame) + 17.71) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 27.47, CGRectGetMinY(frame) + 17.27)];
    [handPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 28.21, CGRectGetMinY(frame) + 15.47) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 27.68, CGRectGetMinY(frame) + 16.71) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 28.01, CGRectGetMinY(frame) + 15.88)];
    [handPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 28.91, CGRectGetMinY(frame) + 14.31) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 28.4, CGRectGetMinY(frame) + 15.07) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 28.56, CGRectGetMinY(frame) + 14.85)];
    [handPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 30.03, CGRectGetMinY(frame) + 13.36) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 29.24, CGRectGetMinY(frame) + 13.78) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 29.61, CGRectGetMinY(frame) + 13.55)];
    [handPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 32.23, CGRectGetMinY(frame) + 14.36) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 30.95, CGRectGetMinY(frame) + 12.96) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 31.91, CGRectGetMinY(frame) + 13.55)];
    [handPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 32.18, CGRectGetMinY(frame) + 16.23) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 32.38, CGRectGetMinY(frame) + 14.72) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 32.25, CGRectGetMinY(frame) + 15.56)];
    [handPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 31.59, CGRectGetMinY(frame) + 19.02) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 32.08, CGRectGetMinY(frame) + 17.32) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 31.75, CGRectGetMinY(frame) + 18.44)];
    [handPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 31.01, CGRectGetMinY(frame) + 21.73) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 31.37, CGRectGetMinY(frame) + 19.77) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 31.13, CGRectGetMinY(frame) + 21.11)];
    [handPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 30.41, CGRectGetMinY(frame) + 24.81) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 30.89, CGRectGetMinY(frame) + 22.39) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 30.62, CGRectGetMinY(frame) + 24.07)];
    [handPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 29.31, CGRectGetMinY(frame) + 27.15) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 30.26, CGRectGetMinY(frame) + 25.32) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 29.78, CGRectGetMinY(frame) + 26.46)];
    [handPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 27.3, CGRectGetMinY(frame) + 30.22) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 29.31, CGRectGetMinY(frame) + 27.15) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 27.5, CGRectGetMinY(frame) + 29.27)];
    [handPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 27.13, CGRectGetMinY(frame) + 31.85) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 27.1, CGRectGetMinY(frame) + 31.17) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 27.17, CGRectGetMinY(frame) + 31.18)];
    [handPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 27.33, CGRectGetMinY(frame) + 33.41) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 27.09, CGRectGetMinY(frame) + 32.53) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 27.33, CGRectGetMinY(frame) + 33.41)];
    [handPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 25.25, CGRectGetMinY(frame) + 33.47) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 27.33, CGRectGetMinY(frame) + 33.41) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 25.98, CGRectGetMinY(frame) + 33.59)];
    [handPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 23.56, CGRectGetMinY(frame) + 31.65) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 24.59, CGRectGetMinY(frame) + 33.37) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 23.77, CGRectGetMinY(frame) + 32.05)];
    [handPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 22.41, CGRectGetMinY(frame) + 31.61) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 23.27, CGRectGetMinY(frame) + 31.09) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 22.65, CGRectGetMinY(frame) + 31.2)];
    [handPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 20.64, CGRectGetMinY(frame) + 33.49) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 22.03, CGRectGetMinY(frame) + 32.26) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 21.21, CGRectGetMinY(frame) + 33.42)];
    [handPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 15.34, CGRectGetMinY(frame) + 33.52) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 19.51, CGRectGetMinY(frame) + 33.63) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 17.17, CGRectGetMinY(frame) + 33.54)];
    [handPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 14.96, CGRectGetMinY(frame) + 31.23) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 15.34, CGRectGetMinY(frame) + 33.52) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 15.65, CGRectGetMinY(frame) + 31.81)];
    [handPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 13.03, CGRectGetMinY(frame) + 29.43) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 14.44, CGRectGetMinY(frame) + 30.79) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 13.56, CGRectGetMinY(frame) + 29.9)];
    [handPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 11.62, CGRectGetMinY(frame) + 27.87)];
    [handPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 9.52, CGRectGetMinY(frame) + 24.51) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 11.14, CGRectGetMinY(frame) + 27.26) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 10.56, CGRectGetMinY(frame) + 26.02)];
    [handPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 7.36, CGRectGetMinY(frame) + 21.84) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 8.94, CGRectGetMinY(frame) + 23.66) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 7.79, CGRectGetMinY(frame) + 22.68)];
    [handPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 7.04, CGRectGetMinY(frame) + 19.6) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 6.98, CGRectGetMinY(frame) + 21.12) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 6.8, CGRectGetMinY(frame) + 20.23)];
    [handPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 9.34, CGRectGetMinY(frame) + 18.19) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 7.42, CGRectGetMinY(frame) + 18.59) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 8.18, CGRectGetMinY(frame) + 18.08)];
    [handPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 11.42, CGRectGetMinY(frame) + 19.1) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 10.21, CGRectGetMinY(frame) + 18.27) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 10.77, CGRectGetMinY(frame) + 18.54)];
    [handPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 12.69, CGRectGetMinY(frame) + 20.36) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 11.8, CGRectGetMinY(frame) + 19.42) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 12.39, CGRectGetMinY(frame) + 20)];
    [handPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 13.33, CGRectGetMinY(frame) + 21.23) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 12.97, CGRectGetMinY(frame) + 20.69) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 13.03, CGRectGetMinY(frame) + 20.83)];
    [handPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 13.69, CGRectGetMinY(frame) + 21.43) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 13.71, CGRectGetMinY(frame) + 21.75) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 13.84, CGRectGetMinY(frame) + 22)];
    [handPath closePath];
    handPath.miterLimit = 4;
    handPath.lineCapStyle = kCGLineCapRound;
    handPath.lineJoinStyle = kCGLineJoinRound;
    handPath.lineWidth = 1.0;
    
    
    //// Mark 1 Drawing
    UIBezierPath* mark1Path = [UIBezierPath bezierPath];
    [mark1Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 18.5, CGRectGetMinY(frame) + 22.5)];
    [mark1Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 18.5, CGRectGetMinY(frame) + 29)];
    
    
    //// Mark 2 Drawing
    UIBezierPath* mark2Path = [UIBezierPath bezierPath];
    [mark2Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 21.5, CGRectGetMinY(frame) + 22.5)];
    [mark2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 21.5, CGRectGetMinY(frame) + 29)];
    
    
    //// Mark 3 Drawing
    UIBezierPath* mark3Path = [UIBezierPath bezierPath];
    [mark3Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 24.5, CGRectGetMinY(frame) + 22.5)];
    [mark3Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 24.5, CGRectGetMinY(frame) + 29)];

    
    
    // clip the hand
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setFill];
    [handPath fill];
    CGContextSetBlendMode(context, kCGBlendModeNormal);

    [barelyWhite setFill];
    [handPath fill];

    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setStroke];
    [handPath stroke];
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    
    [darkerGreyBorder setStroke];
    handPath.lineWidth = 1.0;
    [handPath stroke];

    
    
    
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setStroke];
    [mark1Path stroke];
    [mark2Path stroke];
    [mark3Path stroke];
    CGContextSetBlendMode(context, kCGBlendModeNormal);

    [darkerGreyBorder setStroke];
    
    mark1Path.lineWidth = 1.0;
    [mark1Path stroke];
    
    mark2Path.lineWidth = 1.0;
    [mark2Path stroke];
    
    mark3Path.lineWidth = 1.0;
    [mark3Path stroke];
    
    [self drawDropshadowIfSelected];

    [super drawRect:rect];
}

@end
