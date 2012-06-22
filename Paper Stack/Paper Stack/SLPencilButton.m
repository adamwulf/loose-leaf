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
    
    //Make sure the remove the anti-alias effect from circle
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetShouldAntialias(context, true);
    
    CGFloat smallest = MIN(self.bounds.size.width, self.bounds.size.height);
    CGFloat smallest2 = MIN([self.layer.presentationLayer frame].size.width, [self.layer.presentationLayer frame ].size.height);
    debug_NSLog(@"size: %f vs %f", smallest, smallest2);
    CGRect frame = CGRectMake(0, 0, smallest, smallest);
    
    //// Color Declarations
    UIColor* darkerGreyBorder = [self borderColor];
    UIColor* halfGreyFill = [self backgroundColor];
    
    
    //// Pencil Outline Drawing
    UIBezierPath* pencilOutlinePath = [UIBezierPath bezierPath];
    [pencilOutlinePath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.76 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01 * CGRectGetHeight(frame))];
    [pencilOutlinePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.39 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.39 * CGRectGetHeight(frame))];
    [pencilOutlinePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.31 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.69 * CGRectGetHeight(frame))];
    [pencilOutlinePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.64 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.61 * CGRectGetHeight(frame))];
    [pencilOutlinePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.99 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26 * CGRectGetHeight(frame))];
    [pencilOutlinePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.76 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01 * CGRectGetHeight(frame))];
    [pencilOutlinePath closePath];
    
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
    
    // stroke pencil
    [darkerGreyBorder setStroke];
    [pencilOutlinePath stroke];
    
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
