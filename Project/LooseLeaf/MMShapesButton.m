//
//  MMShapesButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/18/18.
//  Copyright © 2018 Milestone Made, LLC. All rights reserved.
//

#import "MMShapesButton.h"
#import "UIColor+RHInterpolationAdditions.h"


@implementation MMShapesButton

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
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
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    UIColor* darkerGreyBorder = [self borderColor];
    UIColor* barelyWhite = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
    UIColor* strokeColor = darkerGreyBorder;
    UIColor* redSquareColorLight = [UIColor colorWithRed:0.967 green:0.62 blue:0.516 alpha:1];
    UIColor* redSquareColor = [UIColor colorWithRed:0.933 green:0.239 blue:0.031 alpha:1];
    UIColor* greenTriangleColorLight = [UIColor colorWithRed:0.741 green:0.935 blue:0.516 alpha:1];
    UIColor* greenTriangleColor = [UIColor colorWithRed:0.482 green:0.869 blue:0.032 alpha:1];
    UIColor* blueCircleColorLight = [UIColor colorWithRed:0.612 green:0.612 blue:0.988 alpha:1];
    UIColor* blueCircleColor = [UIColor colorWithRed:0.224 green:0.224 blue:0.976 alpha:1];

    //// Gradient Declarations
    CGFloat blueGradientLocations[] = {0, 0.52, 0.99};
    CGGradientRef blueGradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef) @[(id)blueCircleColorLight.CGColor, (id)[blueCircleColorLight blendedColorWithFraction:0.5 ofColor:blueCircleColor].CGColor, (id)blueCircleColor.CGColor], blueGradientLocations);
    CGFloat greenGradientLocations[] = {0, 0.7, 1};
    CGGradientRef greenGradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef) @[(id)greenTriangleColor.CGColor, (id)[greenTriangleColor blendedColorWithFraction:0.5 ofColor:greenTriangleColorLight].CGColor, (id)greenTriangleColorLight.CGColor], greenGradientLocations);
    CGFloat redGradientLocations[] = {0, 0.61, 0.99};
    CGGradientRef redGradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef) @[(id)redSquareColor.CGColor, (id)[redSquareColor blendedColorWithFraction:0.5 ofColor:redSquareColorLight].CGColor, (id)redSquareColorLight.CGColor], redGradientLocations);

    //// Gradient Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect frame = [self drawableFrame];

    //// Oval
    UIBezierPath* ovalPath = [self ovalPath];

    // fill background with gradient
    CGContextSaveGState(context);
    [ovalPath addClip];
    CGRect ovalBounds = CGPathGetPathBoundingBox(ovalPath.CGPath);
    [barelyWhite setFill];
    [[UIBezierPath bezierPathWithRect:CGRectInfinite] fill];
    CGContextRestoreGState(context);


    //// squarePath Drawing
    CGRect squarePathRect = CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.16250) + 0.5, CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.16250) + 0.5, floor(CGRectGetWidth(frame) * 0.81250) - floor(CGRectGetWidth(frame) * 0.16250), floor(CGRectGetHeight(frame) * 0.83750) - floor(CGRectGetHeight(frame) * 0.16250));
    UIBezierPath* squarePathPath = [UIBezierPath bezierPathWithRect:squarePathRect];

    CGContextSaveGState(context);
    [squarePathPath addClip];
    CGContextDrawLinearGradient(context, redGradient,
                                CGPointMake(CGRectGetMidX(squarePathRect), CGRectGetMinY(squarePathRect)),
                                CGPointMake(CGRectGetMidX(squarePathRect), CGRectGetMaxY(squarePathRect)),
                                0);
    CGContextRestoreGState(context);

    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setStroke];
    [squarePathPath stroke];
    CGContextSetBlendMode(context, kCGBlendModeNormal);

    [strokeColor setStroke];
    [squarePathPath stroke];

    //// circlePath Drawing
    CGRect circlePathRect = CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.33750) + 0.5, CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * -0.03750) + 0.5, floor(CGRectGetWidth(frame) * 1.01250) - floor(CGRectGetWidth(frame) * 0.33750), floor(CGRectGetHeight(frame) * 0.63750) - floor(CGRectGetHeight(frame) * -0.03750));
    UIBezierPath* circlePathPath = [UIBezierPath bezierPathWithOvalInRect:circlePathRect];

    CGContextSaveGState(context);
    [circlePathPath addClip];
    CGContextDrawLinearGradient(context, blueGradient,
                                CGPointMake(CGRectGetMidX(circlePathRect), CGRectGetMinY(circlePathRect)),
                                CGPointMake(CGRectGetMidX(circlePathRect), CGRectGetMaxY(circlePathRect)),
                                0);
    CGContextRestoreGState(context);

    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setStroke];
    [circlePathPath stroke];
    CGContextSetBlendMode(context, kCGBlendModeNormal);

    [strokeColor setStroke];
    [circlePathPath stroke];


    //// trianglePath Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMinX(frame) + 0.67500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.70000 * CGRectGetHeight(frame));

    UIBezierPath* trianglePathPath = [UIBezierPath bezierPath];
    [trianglePathPath moveToPoint:CGPointMake(0, -16.5)];
    [trianglePathPath addLineToPoint:CGPointMake(14.29, 8.25)];
    [trianglePathPath addLineToPoint:CGPointMake(-14.29, 8.25)];
    [trianglePathPath closePath];

    CGContextSaveGState(context);
    [trianglePathPath addClip];
    CGRect trianglePathBounds = CGPathGetPathBoundingBox(trianglePathPath.CGPath);
    CGContextDrawLinearGradient(context, greenGradient,
                                CGPointMake(CGRectGetMidX(trianglePathBounds), CGRectGetMinY(trianglePathBounds)),
                                CGPointMake(CGRectGetMidX(trianglePathBounds), CGRectGetMaxY(trianglePathBounds)),
                                0);
    CGContextRestoreGState(context);

    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setStroke];
    [trianglePathPath stroke];
    CGContextSetBlendMode(context, kCGBlendModeNormal);

    [strokeColor setStroke];
    [trianglePathPath stroke];

    CGContextRestoreGState(context);

    //// Oval Drawing

    CGContextSetBlendMode(context, kCGBlendModeClear);
    UIBezierPath* everything = [UIBezierPath bezierPathWithRect:CGRectInfinite];
    [everything appendPath:[ovalPath bezierPathByReversingPath]];
    [[UIColor whiteColor] setFill];
    [everything fill];
    CGContextSetBlendMode(context, kCGBlendModeNormal);

    ovalPath.lineWidth = 1;
    [darkerGreyBorder setStroke];
    [ovalPath stroke];

    [self drawDropshadowIfSelected];

    [super drawRect:rect];
    CGColorSpaceRelease(colorSpace);
}

@end
