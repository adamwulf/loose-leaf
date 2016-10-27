//
//  MMInboxButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/5/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMInboxButton.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"
#import "AVHexColor.h"


@implementation MMInboxButton

@synthesize arrowColor;
@synthesize topBgColor;
@synthesize bottomBgColor;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        bottomBgColor = [AVHexColor colorWithHexString:@"0E94FB"];
        topBgColor = [AVHexColor colorWithHexString:@"84C7fA"];
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
    }
    return self;
}

- (UIColor*)topBgColor {
    if (!topBgColor) {
        return [self backgroundColor];
    }
    return topBgColor;
}

- (UIColor*)bottomBgColor {
    if (!bottomBgColor) {
        return [self backgroundColor];
    }
    return bottomBgColor;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    //
    // Notes for this button
    //
    // the page border bezier has to be added to the oval bezier
    // paintcode keeps them separate
    //

    //// Color Declarations
    UIColor* darkerGreyBorder = [self borderColor];
    UIColor* strokeColor = darkerGreyBorder;
    if (arrowColor) {
        strokeColor = arrowColor;
    }

    //// Gradient Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSArray* faceGradientColors = [NSArray arrayWithObjects:
                                               (id)self.topBgColor.CGColor,
                                               (id)self.bottomBgColor.CGColor, nil];
    CGFloat faceGradientLocations[] = {.1, 1};
    CGGradientRef faceGradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)faceGradientColors, faceGradientLocations);


    CGRect frame = [self drawableFrame];

    //// Oval
    UIBezierPath* ovalPath = [self ovalPath];

    // fill background with gradient
    CGContextSaveGState(context);
    [ovalPath addClip];
    CGRect ovalBounds = CGPathGetPathBoundingBox(ovalPath.CGPath);
    CGContextDrawLinearGradient(context, faceGradient,
                                CGPointMake(CGRectGetMidX(ovalBounds), CGRectGetMinY(ovalBounds)),
                                CGPointMake(CGRectGetMidX(ovalBounds), CGRectGetMaxY(ovalBounds)),
                                0);
    CGContextRestoreGState(context);


    UIBezierPath* boxPath = [UIBezierPath bezierPath];
    [boxPath moveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.30000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.53750 * CGRectGetHeight(frame))];
    [boxPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.30000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.71250 * CGRectGetHeight(frame))];
    [boxPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.70000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.71250 * CGRectGetHeight(frame))];
    [boxPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.70000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.53750 * CGRectGetHeight(frame))];
    [strokeColor setStroke];
    boxPath.lineWidth = 2;


    //// arrow head Drawing
    UIBezierPath* arrowHeadPath = [UIBezierPath bezierPath];
    [arrowHeadPath moveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.40000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.48750 * CGRectGetHeight(frame))];
    [arrowHeadPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.50000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.58750 * CGRectGetHeight(frame))];
    [arrowHeadPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.60000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.48750 * CGRectGetHeight(frame))];
    arrowHeadPath.lineWidth = 2;


    UIBezierPath* arrowBodyPath = [UIBezierPath bezierPath];
    [arrowBodyPath moveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.50000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.21250 * CGRectGetHeight(frame))];
    [arrowBodyPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.50000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.56250 * CGRectGetHeight(frame))];
    arrowBodyPath.lineWidth = 2;

    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setFill];
    [boxPath stroke];
    [arrowHeadPath stroke];
    [arrowBodyPath stroke];
    CGContextSetBlendMode(context, kCGBlendModeNormal);


    [strokeColor setStroke];
    [boxPath stroke];
    [arrowHeadPath stroke];
    [arrowBodyPath stroke];

    //// Oval Drawing
    ovalPath.lineWidth = 1;
    [darkerGreyBorder setStroke];
    [ovalPath stroke];


    [self drawDropshadowIfSelected];

    [super drawRect:rect];
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(faceGradient);
}

@end
