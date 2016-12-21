//
//  MMCollapseButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 12/21/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMCollapseButton.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"


@implementation MMCollapseButton

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
    //
    // Notes for this button
    //
    // the page border bezier has to be added to the oval bezier
    // paintcode keeps them separate
    //

    //// Color Declarations
    UIColor* darkerGreyBorder = [self borderColor];
    UIColor* strokeColor = darkerGreyBorder;

    //// Gradient Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorSpace;
    colorSpace = CGColorSpaceCreateDeviceRGB();

    NSArray* faceGradientColors = [NSArray arrayWithObjects:
                                               (id)[self backgroundColor].CGColor,
                                               (id)[self backgroundColor].CGColor, nil];
    CGFloat faceGradientLocations[] = {0, 1};
    CGGradientRef faceGradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)faceGradientColors, faceGradientLocations);

    CGBlendMode normalBlendMode = kCGBlendModeNormal;

    CGRect frame = [self drawableFrame];

    //// Oval
    UIBezierPath* ovalPath = [self ovalPath];

    //// Oval Drawing
    ovalPath.lineWidth = 1;
    [darkerGreyBorder setStroke];
    [ovalPath stroke];

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
    [boxPath moveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.42500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.38750 * CGRectGetHeight(frame))];
    [boxPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.32500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.38750 * CGRectGetHeight(frame))];
    [boxPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.32500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.73750 * CGRectGetHeight(frame))];
    [boxPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.67500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.73750 * CGRectGetHeight(frame))];
    [boxPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.67500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.38750 * CGRectGetHeight(frame))];
    [boxPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.57500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.38750 * CGRectGetHeight(frame))];
    [strokeColor setStroke];
    boxPath.lineWidth = 2;

    //// arrow head Drawing
    UIBezierPath* arrowHeadPath = [UIBezierPath bezierPath];
    [arrowHeadPath moveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.40000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31250 * CGRectGetHeight(frame))];
    [arrowHeadPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.50000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.21250 * CGRectGetHeight(frame))];
    [arrowHeadPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.60000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31250 * CGRectGetHeight(frame))];
    [arrowHeadPath moveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.30000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.73750 * CGRectGetHeight(frame))];
    [arrowHeadPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.70000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.73750 * CGRectGetHeight(frame))];
    [arrowHeadPath moveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.30000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.43750 * CGRectGetHeight(frame))];
    [arrowHeadPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.70000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.43750 * CGRectGetHeight(frame))];
    [arrowHeadPath moveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.30000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.58750 * CGRectGetHeight(frame))];
    [arrowHeadPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.70000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.58750 * CGRectGetHeight(frame))];
    [darkerGreyBorder setStroke];
    arrowHeadPath.lineWidth = 2;

    // clear the path from the bg
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setFill];
    [arrowHeadPath stroke];
    CGContextSetBlendMode(context, normalBlendMode);

    // stroke
    [darkerGreyBorder setStroke];
    [arrowHeadPath stroke];


    [self drawDropshadowIfSelected];

    [super drawRect:rect];
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(faceGradient);
}

@end
