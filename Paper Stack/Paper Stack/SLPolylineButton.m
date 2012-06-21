//
//  SLPolylineButton.m
//  Paper Stack
//
//  Created by Adam Wulf on 6/21/12.
//  Copyright (c) 2012 Visere. All rights reserved.
//

#import "SLPolylineButton.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"

@implementation SLPolylineButton

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


    // define dots for graph
    UIBezierPath* dot1Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.15), CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.36) + 0.5, floor(CGRectGetWidth(frame) * 0.15), floor(CGRectGetHeight(frame) * 0.15))];
    UIBezierPath* dot2Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.69) + 0.5, CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.49) + 0.5, floor(CGRectGetWidth(frame) * 0.15), floor(CGRectGetHeight(frame) * 0.15))];
    UIBezierPath* dot3Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.49) + 0.5, CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.2), floor(CGRectGetWidth(frame) * 0.15), floor(CGRectGetHeight(frame) * 0.15))];
    UIBezierPath* dot4Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.34) + 0.5, CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.66) + 0.5, floor(CGRectGetWidth(frame) * 0.15), floor(CGRectGetHeight(frame) * 0.15))];

    
    // Fill Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.01) + 0.5, CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.01) + 0.5, floor(CGRectGetWidth(frame) * 0.97), floor(CGRectGetHeight(frame) * 0.97))];
    [ovalPath appendPath:dot1Path];
    [ovalPath appendPath:dot2Path];
    [ovalPath appendPath:dot3Path];
    [ovalPath appendPath:dot4Path];
    // line 1
    [ovalPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 9.5, CGRectGetMinY(frame) + 19.5)];
    [ovalPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 15.5, CGRectGetMinY(frame) + 28.5)];
    [ovalPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 16.5, CGRectGetMinY(frame) + 27.5)];
    [ovalPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 10.5, CGRectGetMinY(frame) + 18.5)];
    [ovalPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 9.5, CGRectGetMinY(frame) + 19.5)];
    // line 2
    [ovalPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.54 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.29 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.41 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.69 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.44 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.71 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.56 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.54 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.29 * CGRectGetHeight(frame))];
    // line 3
    [ovalPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.56 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.74 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.56 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.76 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.54 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.59 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.29 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.56 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31 * CGRectGetHeight(frame))];

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
