//
//  MMPencilEraserButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 5/28/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMPencilEraserButton.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"


@implementation MMPencilEraserButton


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        
        self.layer.shadowPath = [[UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + 0.5, CGRectGetMinY(frame) + 0.5, floor(CGRectGetWidth(frame) - 0.5), floor(CGRectGetHeight(frame) - 0.5))] CGPath];
        self.layer.shadowColor = [[UIColor blueColor] CGColor];
        self.layer.shadowRadius = 2;
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
    
    CGFloat smallest = MIN(self.bounds.size.width, self.bounds.size.height);
    CGRect frame = CGRectMake(kWidthOfSidebarButtonBuffer, kWidthOfSidebarButtonBuffer, smallest - 2*kWidthOfSidebarButtonBuffer, smallest - 2*kWidthOfSidebarButtonBuffer);
    
    //// Color Declarations
    UIColor* darkerGreyBorder = [self borderColor];
    UIColor* halfGreyFill = [self backgroundColor];
    UIColor* pencilShadow = [UIColor colorWithRed: 0.57 green: 0.57 blue: 0.57 alpha: 0.35];
    UIColor* barelyWhite = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.25];
    
    UIColor* selectedBlueFill = [UIColor colorWithRed: 167.0/255.0 green: 203.0/255.0 blue: 1.0 alpha: 0.5];
    
    //// Gradient Declarations
    NSArray* pencilFillGradientColors = [NSArray arrayWithObjects:
                                         (id)halfGreyFill.CGColor,
                                         (id)[UIColor colorWithRed: 0.71 green: 0.71 blue: 0.71 alpha: 0.42].CGColor,
                                         (id)pencilShadow.CGColor,
                                         (id)[UIColor colorWithRed: 0.71 green: 0.71 blue: 0.71 alpha: 0.42].CGColor,
                                         (id)halfGreyFill.CGColor,
                                         (id)[UIColor colorWithRed: 0.71 green: 0.71 blue: 0.71 alpha: 0.42].CGColor,
                                         (id)pencilShadow.CGColor,
                                         (id)halfGreyFill.CGColor,
                                         (id)[UIColor colorWithRed: 0.71 green: 0.71 blue: 0.71 alpha: 0.42].CGColor,
                                         (id)pencilShadow.CGColor, nil];
    CGFloat pencilFillGradientLocations[] = {0, 0.26, 0.33, 0.33, 0.33, 0.5, 0.65, 0.66, 0.75, 0.93};
    CGGradientRef pencilFillGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)pencilFillGradientColors, pencilFillGradientLocations);
    
    
    //// Oval
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + 0.5, CGRectGetMinY(frame) + 0.5, floor(CGRectGetWidth(frame) - 1.0), floor(CGRectGetHeight(frame) - 1.0))];
    [ovalPath closePath];
    
    //// Pencil Fill Drawing
    UIBezierPath* pencilFillPath = [UIBezierPath bezierPath];
    [pencilFillPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.76250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01250 * CGRectGetHeight(frame))];
    [pencilFillPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.38750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.38750 * CGRectGetHeight(frame))];
    [pencilFillPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.53750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.46250 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.38750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.38750 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.47494 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.40836 * CGRectGetHeight(frame))];
    [pencilFillPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.63750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.61250 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.60142 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.51782 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.63750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.61250 * CGRectGetHeight(frame))];
    [pencilFillPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.98750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26250 * CGRectGetHeight(frame))];
    [pencilFillPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.76250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01250 * CGRectGetHeight(frame))];
    [pencilFillPath closePath];

    //// Pencil Outline Drawing
    UIBezierPath* pencilOutlinePath = [UIBezierPath bezierPath];
    [pencilOutlinePath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 35, CGRectGetMinY(frame) + 5.5)];
    [pencilOutlinePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.76250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01250 * CGRectGetHeight(frame))];
    [pencilOutlinePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.28750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.48750 * CGRectGetHeight(frame))];
    [pencilOutlinePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 14.5, CGRectGetMinY(frame) + 26) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.28750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.48750 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 11.11, CGRectGetMinY(frame) + 22.76)];
    [pencilOutlinePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 21.5, CGRectGetMinY(frame) + 28.5) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 18.23, CGRectGetMinY(frame) + 29.56) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 21.5, CGRectGetMinY(frame) + 28.5)];
    [pencilOutlinePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.98750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26250 * CGRectGetHeight(frame))];
    [pencilOutlinePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 35, CGRectGetMinY(frame) + 5.5)];
    [pencilOutlinePath closePath];
    pencilOutlinePath.lineCapStyle = kCGLineCapRound;
    
    pencilOutlinePath.lineJoinStyle = kCGLineJoinBevel;

    
    //// Eraser shadow Drawing
    UIBezierPath* eraserShadowPath = [UIBezierPath bezierPath];
    [eraserShadowPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.36250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.48750 * CGRectGetHeight(frame))];
    [eraserShadowPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.47500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.53750 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.36250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.48750 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.41250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.48250 * CGRectGetHeight(frame))];
    [eraserShadowPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.53750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.65000 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.53750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.59250 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.53750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.65000 * CGRectGetHeight(frame))];

    
    //// Metal Band
    
        //// Band 1 Drawing
        UIBezierPath* band1Path = [UIBezierPath bezierPath];
        [band1Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.41250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.36250 * CGRectGetHeight(frame))];
        [band1Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.56250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.43750 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.41250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.36250 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.50000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.38250 * CGRectGetHeight(frame))];
        [band1Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.66250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.58750 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.62500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.49250 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.66250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.58750 * CGRectGetHeight(frame))];
        
        //// Band 2 Drawing
        UIBezierPath* band2Path = [UIBezierPath bezierPath];
        [band2Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.43750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.33750 * CGRectGetHeight(frame))];
        [band2Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.58750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.41250 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.43750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.33750 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.52500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.35750 * CGRectGetHeight(frame))];
        [band2Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.68750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.56250 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.65000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.46750 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.68750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.56250 * CGRectGetHeight(frame))];
        
        //// Band 3 Drawing
        UIBezierPath* band3Path = [UIBezierPath bezierPath];
        [band3Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.46250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31250 * CGRectGetHeight(frame))];
        [band3Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.61250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.38750 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.46250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31250 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.55000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.33250 * CGRectGetHeight(frame))];
        [band3Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.71250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.53750 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.67500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.44250 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.71250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.53750 * CGRectGetHeight(frame))];
        
        //// Band 4 Drawing
        UIBezierPath* band4Path = [UIBezierPath bezierPath];
        [band4Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.48750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.28750 * CGRectGetHeight(frame))];
        [band4Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.63750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.36250 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.48750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.28750 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.57500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.30750 * CGRectGetHeight(frame))];
        [band4Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.73750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.51250 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.70000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.41750 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.73750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.51250 * CGRectGetHeight(frame))];
    

    // Fill Oval Drawing
    [halfGreyFill setFill];
    [selectedBlueFill setFill];
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
    
    // cut pencil out
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setFill];
    [pencilOutlinePath fill];
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    
    // fill pencil tip
    [barelyWhite setFill];
    [pencilOutlinePath fill];
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setFill];
    [pencilFillPath fill];
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    
    
    // fill pencil body
    CGContextSaveGState(context);
    [pencilFillPath addClip];
    UIBezierPath* pencilFillRotatedPath = [pencilFillPath copy];
    CGAffineTransform pencilFillTransform = CGAffineTransformMakeRotation(-45 * M_PI/180);
    [pencilFillRotatedPath applyTransform: pencilFillTransform];
    CGRect pencilFillBounds = pencilFillRotatedPath.bounds;
    pencilFillTransform = CGAffineTransformInvert(pencilFillTransform);
    
    CGContextDrawLinearGradient(context, pencilFillGradient,
                                CGPointApplyAffineTransform(CGPointMake(CGRectGetMinX(pencilFillBounds), CGRectGetMidY(pencilFillBounds)), pencilFillTransform),
                                CGPointApplyAffineTransform(CGPointMake(CGRectGetMaxX(pencilFillBounds), CGRectGetMidY(pencilFillBounds)), pencilFillTransform),
                                0);
    CGContextRestoreGState(context);
    
    
    // stroke pencil
    [darkerGreyBorder setStroke];
    [pencilOutlinePath stroke];
    
    
    //// Pencil Shaving Drawing
    [pencilShadow setStroke];
    band1Path.lineWidth = 1;
    [band1Path stroke];
    band2Path.lineWidth = 1;
    [band2Path stroke];
    band3Path.lineWidth = 1;
    [band3Path stroke];
    band4Path.lineWidth = 1;
    [band4Path stroke];

    eraserShadowPath.lineWidth = 1;
    [eraserShadowPath stroke];

    //// Pencil Tip Drawing
    [darkerGreyBorder setFill];
    
    // clip end of pencil
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setFill];
    [circleClipPath fill];
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    
    
    
    //
    // possible drop shadow
//    
//    UIColor* gradientColor = [UIColor blueColor];
//    UIColor* fillColor = [UIColor clearColor];
//    NSArray* gradientColors = [NSArray arrayWithObjects:
//                               (id)gradientColor.CGColor,
//                               (id)[UIColor blueColor].CGColor,
//                               (id)[[UIColor blueColor] colorWithAlphaComponent:.3].CGColor,
//                               (id)fillColor.CGColor, nil];
//    CGFloat gradientLocations[] = {0, 0.65, .9, 1};
//    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColors, gradientLocations);
//    CGContextSaveGState(context);
//
//    UIBezierPath* clipPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), floor(CGRectGetWidth(frame)), floor(CGRectGetHeight(frame)))];
//    [clipPath appendPath:[UIBezierPath bezierPathWithRect:CGRectInfinite]];
//    clipPath.usesEvenOddFillRule = YES;
//    [clipPath addClip];
//    
//    CGContextDrawRadialGradient(context, gradient,
//                                CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame)), 1,
//                                CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame)), 24.5,
//                                kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
//    CGContextRestoreGState(context);
//    
//    

    // stroke circle
    [darkerGreyBorder setStroke];
    ovalPath.lineWidth = 1;
    [ovalPath stroke];

    
}


@end
