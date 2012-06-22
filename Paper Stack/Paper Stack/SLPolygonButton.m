//
//  SLPolylineButton.m
//  Paper Stack
//
//  Created by Adam Wulf on 6/21/12.
//  Copyright (c) 2012 Visere. All rights reserved.
//

#import "SLPolygonButton.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"

@implementation SLPolygonButton

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
    CGRect frame = CGRectMake(kWidthOfSidebarButtonBuffer, kWidthOfSidebarButtonBuffer, smallest - 2*kWidthOfSidebarButtonBuffer, smallest - 2*kWidthOfSidebarButtonBuffer);
    
    //// Color Declarations
    UIColor* darkerGreyBorder = [self borderColor];
    UIColor* halfGreyFill = [self backgroundColor];
    
    
    // define dots for graph
    UIBezierPath* dot1Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.21) + 0.5, CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.64) + 0.5, floor(CGRectGetWidth(frame) * 0.15), floor(CGRectGetHeight(frame) * 0.15))];
    UIBezierPath* dot2Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.69) + 0.5, CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.31) + 0.5, floor(CGRectGetWidth(frame) * 0.15), floor(CGRectGetHeight(frame) * 0.15))];
    UIBezierPath* dot3Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.24) + 0.5, CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.2), floor(CGRectGetWidth(frame) * 0.15), floor(CGRectGetHeight(frame) * 0.15))];
    UIBezierPath* dot4Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.61) + 0.5, CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.64) + 0.5, floor(CGRectGetWidth(frame) * 0.15), floor(CGRectGetHeight(frame) * 0.15))];
    
    
    // Fill Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.01) + 0.5, CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.01) + 0.5, floor(CGRectGetWidth(frame) * 0.97), floor(CGRectGetHeight(frame) * 0.97))];
    [ovalPath appendPath:dot1Path];
    [ovalPath appendPath:dot2Path];
    [ovalPath appendPath:dot3Path];
    [ovalPath appendPath:dot4Path];
    // line 1
    [ovalPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.29 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.72 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.69 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.72 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.69 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.7 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.29 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.7 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.29 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.72 * CGRectGetHeight(frame))];
    // line 2
    [ovalPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.3 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.29 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.28 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.69 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.3 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.71 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.33 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.29 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.3 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.29 * CGRectGetHeight(frame))];
    // line 3
    [ovalPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.31 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.29 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.71 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.39 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.74 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.36 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.34 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.31 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.29 * CGRectGetHeight(frame))];
    // line 4
    [ovalPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.75 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.39 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.68 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.71 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.7 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.74 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.78 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.39 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.75 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.39 * CGRectGetHeight(frame))];

    [ovalPath closePath];
    [halfGreyFill setFill];
    [ovalPath fill];
    
    // draw lines
    
    // cut circles out
    // and stroke
    
    [darkerGreyBorder setStroke];
    ovalPath.lineWidth = 1;
    [ovalPath stroke];
    
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setFill];
    [dot1Path fill];
    [dot2Path fill];
    [dot3Path fill];
    [dot4Path fill];
    
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    
}


@end
