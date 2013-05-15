//
//  MMPaperIcon.m
//  Loose Leaf
//
//  Created by Adam Wulf on 6/18/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "MMPaperIcon.h"

@implementation MMPaperIcon

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
    // Drawing code
    //// Frames
    CGFloat largest = MAX(self.bounds.size.width, self.bounds.size.height);
    CGRect frame = CGRectMake(0, 0, largest * 38 / 45, largest);
    
    
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* darkerGrey = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.33];
    UIColor* halfWhite = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.36];
    UIColor* strokeColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 1];
    
    //// Gradient Declarations
    NSArray* frontOfPaperColors = [NSArray arrayWithObjects: 
                                   (id)darkerGrey.CGColor, 
                                   (id)[UIColor colorWithRed: 0.57 green: 0.57 blue: 0.57 alpha: 0.34].CGColor, 
                                   (id)halfWhite.CGColor, nil];
    CGFloat frontOfPaperLocations[] = {0.98, 0.74, 0.09};
    CGGradientRef frontOfPaper = CGGradientCreateWithColors(colorSpace, (CFArrayRef)frontOfPaperColors, frontOfPaperLocations);
    
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.49 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.09 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.01 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.01 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.08 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.01 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.92 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.01 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.99 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.09 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.99 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.91 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.99 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.99 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.99 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.99 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.92 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.99 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.41 * CGRectGetHeight(frame))];
    [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.98 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.37 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.99 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.41 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.99 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.39 * CGRectGetHeight(frame))];
    [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.93 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.32 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.97 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.93 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.32 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.62 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.06 * CGRectGetHeight(frame))];
    [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.57 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.02 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.62 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.06 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.59 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.03 * CGRectGetHeight(frame))];
    [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.49 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.54 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.49 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01 * CGRectGetHeight(frame))];
    [bezierPath closePath];
    CGContextSaveGState(context);
    [bezierPath addClip];
    UIBezierPath* bezierRotatedPath = [bezierPath copy];
    CGAffineTransform bezierTransform = CGAffineTransformMakeRotation(115/(-2*M_PI));
    [bezierRotatedPath applyTransform: bezierTransform];
    CGRect bezierBounds = bezierRotatedPath.bounds;
    bezierTransform = CGAffineTransformInvert(bezierTransform);
    
    CGContextDrawLinearGradient(context, frontOfPaper,
                                CGPointApplyAffineTransform(CGPointMake(CGRectGetMinX(bezierBounds), CGRectGetMidY(bezierBounds)), bezierTransform),
                                CGPointApplyAffineTransform(CGPointMake(CGRectGetMaxX(bezierBounds), CGRectGetMidY(bezierBounds)), bezierTransform),
                                0);
    [bezierRotatedPath release];
    CGContextRestoreGState(context);
    
    [strokeColor setStroke];
    bezierPath.lineWidth = 1;
    [bezierPath stroke];
    
    
    //// Bezier 2 Drawing
    UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.99 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.39 * CGRectGetHeight(frame))];
    [bezier2Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.62 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.85 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.29 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.62 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34 * CGRectGetHeight(frame))];
    [bezier2Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.54 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.62 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.67 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.03 * CGRectGetHeight(frame))];
    [halfWhite setFill];
    [bezier2Path fill];
    
    [strokeColor setStroke];
    bezier2Path.lineWidth = 1;
    [bezier2Path stroke];
    
    //// Cleanup
    CGGradientRelease(frontOfPaper);
    CGColorSpaceRelease(colorSpace);
}


@end
