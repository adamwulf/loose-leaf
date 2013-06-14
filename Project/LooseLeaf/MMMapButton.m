//
//  MMPaperButton.m
//  Loose Leaf
//
//  Created by Adam Wulf on 6/20/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "MMMapButton.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"

@implementation MMMapButton

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
    //
    // Notes for this button
    //
    // the page border bezier has to be added to the oval bezier
    // paintcode keeps them separate
    //
    CGRect frame = [self drawableFrame];
    
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* darkerGreyBorder = [self borderColor];
    UIColor* halfGreyFill = [self backgroundColor];
    UIColor* vertRoadColor = [UIColor colorWithRed: 0.57 green: 0.57 blue: 0.57 alpha: 0.35];
    UIColor* horizontalRoadColor = [UIColor colorWithRed: 0.45 green: 0.45 blue: 0.45 alpha: 0.35];
    UIColor* bottomOfSignColor = [UIColor colorWithRed: 0.91 green: 0.91 blue: 0.91 alpha: 0.6];
    UIColor* topOfSignColor = [UIColor colorWithRed: 0.28 green: 0.28 blue: 0.28 alpha: 0.45];
    UIColor* smallRoadColor = [UIColor colorWithRed: 0.66 green: 0.66 blue: 0.66 alpha: 0.4];

    

    // define paths
    // ============================================================
    //// Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + 0.5, CGRectGetMinY(frame) + 0.5, floor(CGRectGetWidth(frame) - 1.0), floor(CGRectGetHeight(frame) - 1.0))];
    ovalPath.lineWidth = 1;
    [halfGreyFill setFill];
    [ovalPath fill];
    
    // circle clip path
    UIBezierPath *circleClipPath = [UIBezierPath bezierPathWithRect:CGRectInfinite];
    [circleClipPath appendPath:ovalPath];
    circleClipPath.usesEvenOddFillRule = YES;
    
    //// Vert Road Drawing
    UIBezierPath* vertRoadPath = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.2), CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.03), floor(CGRectGetWidth(frame) * 0.12), floor(CGRectGetHeight(frame) * 0.97))];
    
    //// Horizontal Road Drawing
    UIBezierPath* horizontalRoadPath = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0), CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.25), floor(CGRectGetWidth(frame) * 1), floor(CGRectGetHeight(frame) * 0.15))];
    
    //// Sign Drawing
    UIBezierPath* signPath = [UIBezierPath bezierPath];
    [signPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.49 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09 * CGRectGetHeight(frame))];
    [signPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.57 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.14 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.49 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.5 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.14 * CGRectGetHeight(frame))];
    [signPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.68 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.65 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.14 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.68 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09 * CGRectGetHeight(frame))];
    [signPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.78 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.14 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.68 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.7 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.14 * CGRectGetHeight(frame))];
    [signPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.86 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.85 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.14 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.86 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09 * CGRectGetHeight(frame))];
    [signPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.91 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.25 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.86 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.91 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.15 * CGRectGetHeight(frame))];
    [signPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.68 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.46 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.91 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.35 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.8 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.46 * CGRectGetHeight(frame))];
    [signPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.44 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.25 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.55 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.46 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.44 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.35 * CGRectGetHeight(frame))];
    [signPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.49 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.44 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.15 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.49 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09 * CGRectGetHeight(frame))];
    [signPath closePath];

    UIBezierPath* bottomOfSignPath = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.4), CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.23), floor(CGRectGetWidth(frame) * 0.6), floor(CGRectGetHeight(frame) * 0.33))];
    UIBezierPath* topOfSignPath = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.4), CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.07), floor(CGRectGetWidth(frame) * 0.6), floor(CGRectGetHeight(frame) * 0.15))];


    // circle sign path
    UIBezierPath *signClipPath = [UIBezierPath bezierPathWithRect:CGRectInfinite];
    [signClipPath appendPath:signPath];
    signClipPath.usesEvenOddFillRule = YES;

    
    //// Road 1 Drawing
    UIBezierPath* road1Path = [UIBezierPath bezierPath];
    [road1Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.01 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.89 * CGRectGetHeight(frame))];
    [road1Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.29 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.89 * CGRectGetHeight(frame))];
    [road1Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.34 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.89 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.29 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.89 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.3 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.89 * CGRectGetHeight(frame))];
    [road1Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.39 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.81 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.38 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.89 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.39 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.81 * CGRectGetHeight(frame))];
    [road1Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.39 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.59 * CGRectGetHeight(frame))];
    [road1Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.51 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.49 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.39 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.59 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.42 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.49 * CGRectGetHeight(frame))];
    [road1Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.64 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.59 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.61 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.49 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.64 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.59 * CGRectGetHeight(frame))];
    [road1Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.64 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.81 * CGRectGetHeight(frame))];
    [road1Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.51 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.89 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.64 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.81 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.61 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.89 * CGRectGetHeight(frame))];
    [road1Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.39 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.81 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.42 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.89 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.39 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.81 * CGRectGetHeight(frame))];

    UIBezierPath* road2Path = [UIBezierPath bezierPath];
    [road2Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.81 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.86 * CGRectGetHeight(frame))];
    [road2Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.81 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.04 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.81 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.71 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.81 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.04 * CGRectGetHeight(frame))];

    // draw
    // ============================================================
    
    [smallRoadColor setStroke];
    road1Path.lineWidth = 2;
    [road1Path stroke];
    road2Path.lineWidth = 2;
    [road2Path stroke];
    
    // clip vert road
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setFill];
    [vertRoadPath fill];
    CGContextSetBlendMode(context, kCGBlendModeNormal);

    // fill vert road
    [vertRoadColor setFill];
    [vertRoadPath fill];

    // clip horizontal road
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setFill];
    [horizontalRoadPath fill];
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    
    // fill horizontal road
    [horizontalRoadColor setFill];
    [horizontalRoadPath fill];
    


    // draw sign
    // ============================================================
  
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
    context = UIGraphicsGetCurrentContext();

    // color sign
    [bottomOfSignColor setFill];
    [bottomOfSignPath fill];
    [topOfSignColor setFill];
    [topOfSignPath fill];
    
    // clip sign
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setFill];
    [signClipPath fill];
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    
    [darkerGreyBorder setStroke];
    [signPath stroke];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    context = UIGraphicsGetCurrentContext();

    
    // clip sign
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setFill];
    [signPath fill];
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    // draw sign
    [image drawAtPoint:CGPointZero];
    
    
    
    // clip to circle
    // ============================================================
   
    // clip end of roads / sign
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setFill];
    [circleClipPath fill];
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    
    // stroke circle
    [darkerGreyBorder setStroke];
    ovalPath.lineWidth = 1;
    [ovalPath stroke];
}


@end
