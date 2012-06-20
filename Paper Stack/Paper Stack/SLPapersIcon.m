//
//  SLPapersIcon.m
//  Paper Stack
//
//  Created by Adam Wulf on 6/19/12.
//  Copyright (c) 2012 Visere. All rights reserved.
//

#import "SLPapersIcon.h"

@implementation SLPapersIcon

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
    CGRect frame = CGRectMake(0, 0, largest * 42 / 49, largest);
    
    
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
    [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.11 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.11 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.56 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01 * CGRectGetHeight(frame))];
    [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.61 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.02 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.56 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.58 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01 * CGRectGetHeight(frame))];
    [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.65 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.05 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.63 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.03 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.65 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.05 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.94 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.3 * CGRectGetHeight(frame))];
    [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.99 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.36 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.94 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.3 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.97 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.33 * CGRectGetHeight(frame))];
    [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.99 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.44 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 1 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.39 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.99 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.44 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.99 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.91 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.89 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.91 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.89 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.48 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.89 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.44 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.89 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.42 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.56 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.13 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.51 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.11 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09 * CGRectGetHeight(frame))];
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
    
    
    //// Back Page Curl Drawing
    UIBezierPath* backPageCurlPath = [UIBezierPath bezierPath];
    [backPageCurlPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.99 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.36 * CGRectGetHeight(frame))];
    [backPageCurlPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.77 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.92 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.84 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.3 * CGRectGetHeight(frame))];
    [backPageCurlPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.73 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.28 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.74 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.73 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.28 * CGRectGetHeight(frame))];
    [backPageCurlPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.67 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.21 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.73 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.28 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.66 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.23 * CGRectGetHeight(frame))];
    [backPageCurlPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.58 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.68 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.66 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.02 * CGRectGetHeight(frame))];
    [halfWhite setFill];
    [backPageCurlPath fill];
    
    [strokeColor setStroke];
    backPageCurlPath.lineWidth = 1;
    [backPageCurlPath stroke];
    
    
    //// Front Page Drawing
    UIBezierPath* frontPagePath = [UIBezierPath bezierPath];
    [frontPagePath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.44 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09 * CGRectGetHeight(frame))];
    [frontPagePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.08 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09 * CGRectGetHeight(frame))];
    [frontPagePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.01 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09 * CGRectGetHeight(frame))];
    [frontPagePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.01 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.15 * CGRectGetHeight(frame))];
    [frontPagePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.01 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.93 * CGRectGetHeight(frame))];
    [frontPagePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.01 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.99 * CGRectGetHeight(frame))];
    [frontPagePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.08 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.99 * CGRectGetHeight(frame))];
    [frontPagePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.82 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.99 * CGRectGetHeight(frame))];
    [frontPagePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.89 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.99 * CGRectGetHeight(frame))];
    [frontPagePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.89 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.93 * CGRectGetHeight(frame))];
    [frontPagePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.89 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.46 * CGRectGetHeight(frame))];
    [frontPagePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.89 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.42 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.89 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.46 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.9 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.44 * CGRectGetHeight(frame))];
    [frontPagePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.85 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.38 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.87 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.4 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.85 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.38 * CGRectGetHeight(frame))];
    [frontPagePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.56 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.13 * CGRectGetHeight(frame))];
    [frontPagePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.51 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.1 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.56 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.13 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.54 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.11 * CGRectGetHeight(frame))];
    [frontPagePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.44 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.49 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.44 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09 * CGRectGetHeight(frame))];
    [frontPagePath closePath];
    CGContextSaveGState(context);
    [frontPagePath addClip];
    UIBezierPath* frontPageRotatedPath = [frontPagePath copy];
    CGAffineTransform frontPageTransform = CGAffineTransformMakeRotation(115/(-2*M_PI));
    [frontPageRotatedPath applyTransform: frontPageTransform];
    CGRect frontPageBounds = frontPageRotatedPath.bounds;
    frontPageTransform = CGAffineTransformInvert(frontPageTransform);
    
    CGContextDrawLinearGradient(context, frontOfPaper,
                                CGPointApplyAffineTransform(CGPointMake(CGRectGetMinX(frontPageBounds), CGRectGetMidY(frontPageBounds)), frontPageTransform),
                                CGPointApplyAffineTransform(CGPointMake(CGRectGetMaxX(frontPageBounds), CGRectGetMidY(frontPageBounds)), frontPageTransform),
                                0);
    [frontPageRotatedPath release];
    CGContextRestoreGState(context);
    
    [strokeColor setStroke];
    frontPagePath.lineWidth = 1;
    [frontPagePath stroke];
    
    
    //// Front Page Curl Drawing
    UIBezierPath* frontPageCurlPath = [UIBezierPath bezierPath];
    [frontPageCurlPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.89 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.44 * CGRectGetHeight(frame))];
    [frontPageCurlPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.56 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.4 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.77 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.35 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.56 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.4 * CGRectGetHeight(frame))];
    [frontPageCurlPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.49 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.56 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.4 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.61 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.11 * CGRectGetHeight(frame))];
    [halfWhite setFill];
    [frontPageCurlPath fill];
    
    [strokeColor setStroke];
    frontPageCurlPath.lineWidth = 1;
    [frontPageCurlPath stroke];
    
    //// Cleanup
    CGGradientRelease(frontOfPaper);
    CGColorSpaceRelease(colorSpace);
}

@end
