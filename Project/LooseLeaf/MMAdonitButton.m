//
//  MMAdonitButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/3/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMAdonitButton.h"


@implementation MMAdonitButton

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

    CGRect frame = [self drawableFrame];

    //// Oval
    UIBezierPath* ovalPath = [self ovalPath];
    [halfGreyFill setFill];
    [ovalPath fill];

    // oval clip
    UIBezierPath* circleClipPath = [UIBezierPath bezierPathWithRect:CGRectInfinite];
    [circleClipPath appendPath:ovalPath];
    circleClipPath.usesEvenOddFillRule = YES;


    //// Triangle Drawing
    UIBezierPath* trianglePath = [UIBezierPath bezierPath];
    [trianglePath moveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.82500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.70000 * CGRectGetHeight(frame))];
    [trianglePath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.17500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.70000 * CGRectGetHeight(frame))];
    [trianglePath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.50000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.15000 * CGRectGetHeight(frame))];
    [trianglePath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.82500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.70000 * CGRectGetHeight(frame))];
    [trianglePath closePath];
    trianglePath.lineJoinStyle = kCGLineJoinBevel;
    trianglePath.lineWidth = 2;


    //// edge1 Drawing
    UIBezierPath* edge1Path = [UIBezierPath bezierPath];
    [edge1Path moveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.41250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.53750 * CGRectGetHeight(frame))];
    [edge1Path addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.82500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.70000 * CGRectGetHeight(frame))];
    edge1Path.lineWidth = 1;


    //// edge2 Drawing
    UIBezierPath* edge2Path = [UIBezierPath bezierPath];
    [edge2Path moveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.17500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.70000 * CGRectGetHeight(frame))];
    [edge2Path addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.41250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.53750 * CGRectGetHeight(frame))];
    edge2Path.lineWidth = 1;


    //// edge3 Drawing
    UIBezierPath* edge3Path = [UIBezierPath bezierPath];
    [edge3Path moveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.41250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.53750 * CGRectGetHeight(frame))];
    [edge3Path addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.50000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.15000 * CGRectGetHeight(frame))];
    edge3Path.lineWidth = 1;


    // hand
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setFill];
    [trianglePath fill];
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    [barelyWhite setFill];
    [trianglePath fill];
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setStroke];
    [trianglePath stroke];
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    [darkerGreyBorder setStroke];
    [trianglePath stroke];


    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setStroke];
    [edge1Path stroke];
    [edge2Path stroke];
    [edge3Path stroke];
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    [darkerGreyBorder setStroke];
    [edge1Path stroke];
    [edge2Path stroke];
    [edge3Path stroke];


    // stroke circle
    [darkerGreyBorder setStroke];
    ovalPath.lineWidth = 1;
    [ovalPath stroke];


    [self drawDropshadowIfSelected];

    [super drawRect:rect];
}
@end
