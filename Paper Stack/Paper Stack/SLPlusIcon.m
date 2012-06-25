//
//  SLPlusIcon.m
//  Paper Stack
//
//  Created by Adam Wulf on 6/19/12.
//  Copyright (c) 2012 Visere. All rights reserved.
//

#import "SLPlusIcon.h"
#import "UIFont+UIBezierCurve.h"

@implementation SLPlusIcon

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
    CGFloat smallest = MIN(self.bounds.size.width, self.bounds.size.height);
    CGRect frame = CGRectMake(0, 0, smallest, smallest);
    
    
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* darkerGrey = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.33];
    UIColor* halfWhite = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.36];
    
    //// Gradient Declarations
    NSArray* frontOfPaperColors = [NSArray arrayWithObjects: 
                                   (id)darkerGrey.CGColor, 
                                   (id)[UIColor colorWithRed: 0.57 green: 0.57 blue: 0.57 alpha: 0.34].CGColor, 
                                   (id)halfWhite.CGColor, nil];
    CGFloat frontOfPaperLocations[] = {0.94, 0.67, 0.06};
    CGGradientRef frontOfPaper = CGGradientCreateWithColors(colorSpace, (CFArrayRef)frontOfPaperColors, frontOfPaperLocations);
    
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.34 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.5)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.34 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.5, CGRectGetMinY(frame) + 0.34 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.5, CGRectGetMinY(frame) + 0.66 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.34 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.66 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.34 * CGRectGetWidth(frame), CGRectGetMaxY(frame) - 0.5)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.66 * CGRectGetWidth(frame), CGRectGetMaxY(frame) - 0.5)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.66 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.66 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMaxX(frame) - 0.5, CGRectGetMinY(frame) + 0.66 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMaxX(frame) - 0.5, CGRectGetMinY(frame) + 0.34 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.66 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.66 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.5)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.34 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.5)];
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
    
    [[UIColor blackColor] setStroke];
    bezierPath.lineWidth = 1;
    [bezierPath stroke];
    
    //// Cleanup
    CGGradientRelease(frontOfPaper);
    CGColorSpaceRelease(colorSpace);
}

@end
