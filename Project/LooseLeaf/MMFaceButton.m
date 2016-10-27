//
//  MMFaceButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 4/9/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMFaceButton.h"
#import "AVHexColor.h"


@implementation MMFaceButton

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
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();

    //// Color Declarations
    UIColor* darkerGreyBorder = [self borderColor];
    UIColor* barelyWhite = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.25];
    UIColor* mostlyWhite = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.65];
    UIColor* lightBlue = [AVHexColor colorWithHexString:@"0E94FB"];
    UIColor* lighterBlue = [AVHexColor colorWithHexString:@"84C7fA"];


    //// Gradient Declarations
    NSArray* blueGradientColors = [NSArray arrayWithObjects:
                                               (id)lightBlue.CGColor,
                                               (id)lighterBlue.CGColor, nil];
    CGFloat blueGradientLocations[] = {0, 1};
    CGGradientRef blueGradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)blueGradientColors, blueGradientLocations);

    //// Gradient Declarations
    NSArray* faceGradientColors = [NSArray arrayWithObjects:
                                               (id)mostlyWhite.CGColor,
                                               (id)[UIColor colorWithRed:1 green:1 blue:1 alpha:0.449].CGColor,
                                               (id)barelyWhite.CGColor, nil];
    CGFloat faceGradientLocations[] = {0, 0.71, 1};
    CGGradientRef faceGradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)faceGradientColors, faceGradientLocations);

    CGRect frame = [self drawableFrame];

    //// Oval
    UIBezierPath* ovalPath = [self ovalPath];
    //    [halfGreyFill setFill];
    //    [ovalPath fill];

    // fill face with gradient
    CGContextSaveGState(context);
    [ovalPath addClip];
    CGRect ovalBounds = CGPathGetPathBoundingBox(ovalPath.CGPath);
    CGContextDrawLinearGradient(context, blueGradient,
                                CGPointMake(CGRectGetMidX(ovalBounds), CGRectGetMinY(ovalBounds)),
                                CGPointMake(CGRectGetMidX(ovalBounds), CGRectGetMaxY(ovalBounds)),
                                0);
    CGContextRestoreGState(context);


    // oval clip
    UIBezierPath* circleClipPath = [UIBezierPath bezierPathWithRect:CGRectInfinite];
    [circleClipPath appendPath:ovalPath];
    circleClipPath.usesEvenOddFillRule = YES;


    //// face Drawing
    UIBezierPath* facePath = [UIBezierPath bezierPath];
    [facePath moveToPoint:CGPointMake(7.5, 62.5)];
    [facePath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.12500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.81148 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(7.5, 62.5) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.12433 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.86320 * CGRectGetHeight(frame))];
    [facePath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.33333 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.68033 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.12567 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.75975 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.29638 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.70659 * CGRectGetHeight(frame))];
    [facePath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.40833 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.59016 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.37029 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.65406 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.42104 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.60933 * CGRectGetHeight(frame))];
    [facePath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.35000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.50000 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.39562 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.57100 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.36738 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.54499 * CGRectGetHeight(frame))];
    [facePath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.35000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.27049 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.33262 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.45501 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.34723 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31121 * CGRectGetHeight(frame))];
    [facePath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.42500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.18852 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.35277 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.22978 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.37292 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.20902 * CGRectGetHeight(frame))];
    [facePath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.48915 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.18360 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.45029 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17858 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.46968 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.18310 * CGRectGetHeight(frame))];
    [facePath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.55833 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.18852 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.50977 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.18413 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.53047 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.18114 * CGRectGetHeight(frame))];
    [facePath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.65000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26230 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.61250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.20287 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.64983 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.22912 * CGRectGetHeight(frame))];
    [facePath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.64167 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.50820 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.65017 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.29547 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.66608 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.46753 * CGRectGetHeight(frame))];
    [facePath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.59167 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.59836 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.61725 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.54886 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.60443 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.55285 * CGRectGetHeight(frame))];
    [facePath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.68333 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.68852 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.57890 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.64387 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.63901 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.65870 * CGRectGetHeight(frame))];
    [facePath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.87500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.81148 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.73392 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.72255 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.87470 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.77584 * CGRectGetHeight(frame))];
    [facePath addCurveToPoint:CGPointMake(52.5, 62.5) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.87521 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.83570 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(52.5, 62.5)];
    [facePath addLineToPoint:CGPointMake(7.5, 62.5)];
    [facePath closePath];

    // fill face with gradient
    CGContextSaveGState(context);
    [facePath addClip];
    CGRect faceBounds = CGPathGetPathBoundingBox(facePath.CGPath);
    CGContextDrawLinearGradient(context, faceGradient,
                                CGPointMake(CGRectGetMidX(faceBounds), CGRectGetMinY(faceBounds)),
                                CGPointMake(CGRectGetMidX(faceBounds), CGRectGetMaxY(faceBounds)),
                                0);
    CGContextRestoreGState(context);


    // cut the stroke out so it's crisp
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setStroke];
    [facePath stroke];
    CGContextSetBlendMode(context, kCGBlendModeNormal);

    [darkerGreyBorder setStroke];
    [facePath stroke];


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

    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(blueGradient);
    CGGradientRelease(faceGradient);
}

@end
