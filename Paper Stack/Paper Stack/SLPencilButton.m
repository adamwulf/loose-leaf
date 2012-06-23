//
//  SLPolylineButton.m
//  Paper Stack
//
//  Created by Adam Wulf on 6/21/12.
//  Copyright (c) 2012 Visere. All rights reserved.
//

#import "SLPencilButton.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"

@implementation SLPencilButton

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
    CGGradientRef pencilFillGradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)pencilFillGradientColors, pencilFillGradientLocations);

    //// Pencil Tip Drawing
    UIBezierPath* pencilTipPath = [UIBezierPath bezierPath];
    [pencilTipPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.4 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.6 * CGRectGetHeight(frame))];
    [pencilTipPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.34 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.59 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.35 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.56 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.34 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.59 * CGRectGetHeight(frame))];
    [pencilTipPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.31 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.69 * CGRectGetHeight(frame))];
    [pencilTipPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.44 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.66 * CGRectGetHeight(frame))];
    [pencilTipPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.4 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.6 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.44 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.66 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.45 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.64 * CGRectGetHeight(frame))];
    [pencilTipPath closePath];
 
    //// Pencil Outline Drawing
    UIBezierPath* pencilOutlinePath = [UIBezierPath bezierPath];
    [pencilOutlinePath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.76 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01 * CGRectGetHeight(frame))];
    [pencilOutlinePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.39 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.39 * CGRectGetHeight(frame))];
    [pencilOutlinePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.31 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.69 * CGRectGetHeight(frame))];
    [pencilOutlinePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.64 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.61 * CGRectGetHeight(frame))];
    [pencilOutlinePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.99 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26 * CGRectGetHeight(frame))];
    [pencilOutlinePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.76 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01 * CGRectGetHeight(frame))];
    [pencilOutlinePath closePath];
    
    //// Pencil Fill Drawing
    UIBezierPath* pencilFillPath = [UIBezierPath bezierPath];
    [pencilFillPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.76 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01 * CGRectGetHeight(frame))];
    [pencilFillPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.39 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.39 * CGRectGetHeight(frame))];
    [pencilFillPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.54 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.46 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.39 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.39 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.47 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.41 * CGRectGetHeight(frame))];
    [pencilFillPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.64 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.61 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.6 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.52 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.64 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.61 * CGRectGetHeight(frame))];
    [pencilFillPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.99 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26 * CGRectGetHeight(frame))];
    [pencilFillPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.76 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01 * CGRectGetHeight(frame))];
    [pencilFillPath closePath];
    pencilFillPath.lineJoinStyle = kCGLineJoinRound;

    
    // Fill Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.01) + 0.5, CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.01) + 0.5, floor(CGRectGetWidth(frame) * 0.97), floor(CGRectGetHeight(frame) * 0.97))];
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
    [pencilTipPath fill];
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
    [pencilFillRotatedPath release];
    CGContextRestoreGState(context);

    
    // stroke pencil
    [darkerGreyBorder setStroke];
    [pencilOutlinePath stroke];
    
    //// Pencil Shaving Drawing
    UIBezierPath* pencilShavingPath = [UIBezierPath bezierPath];
    [pencilShavingPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.39 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.39 * CGRectGetHeight(frame))];
    [pencilShavingPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.54 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.46 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.39 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.39 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.47 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.41 * CGRectGetHeight(frame))];
    [pencilShavingPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.64 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.61 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.6 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.52 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.64 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.61 * CGRectGetHeight(frame))];
    [darkerGreyBorder setStroke];
    pencilShavingPath.lineWidth = 1;
    [pencilShavingPath stroke];

    //// Pencil Tip Drawing
    [darkerGreyBorder setFill];
    [pencilTipPath fill];

    
    // clip end of pencil
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
