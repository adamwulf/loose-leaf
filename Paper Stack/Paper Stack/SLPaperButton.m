//
//  SLPaperButton.m
//  Paper Stack
//
//  Created by Adam Wulf on 6/20/12.
//  Copyright (c) 2012 Visere. All rights reserved.
//

#import "SLPaperButton.h"
#import "SLPaperStackView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+MCDrawSubImage.h"
#import "Constants.h"

@implementation SLPaperButton

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
    CGFloat smallest = MIN(self.bounds.size.width, self.bounds.size.height);
    CGRect frame = CGRectMake(0, 0, smallest, smallest);
    
    //// Color Declarations
    UIColor* darkerGrey = [self backgroundColor];
    UIColor* halfGrey = [self borderColor];
    
    //// Bezier 2 Drawing
    UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.03 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.5 * CGRectGetHeight(frame))];
    [bezier2Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.5 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.03 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.03 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.22 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.25 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.03 * CGRectGetHeight(frame))];
    [bezier2Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.5 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.03 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.51 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.03 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.5 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.03 * CGRectGetHeight(frame))];
    [bezier2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.5 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.21 * CGRectGetHeight(frame))];
    [bezier2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.31 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.21 * CGRectGetHeight(frame))];
    [bezier2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.31 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.74 * CGRectGetHeight(frame))];
    [bezier2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.71 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.74 * CGRectGetHeight(frame))];
    [bezier2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.71 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34 * CGRectGetHeight(frame))];
    [bezier2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.59 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.21 * CGRectGetHeight(frame))];
    [bezier2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.5 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.21 * CGRectGetHeight(frame))];
    [bezier2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.5 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.03 * CGRectGetHeight(frame))];
    [bezier2Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.5 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.03 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.5 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.03 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.44 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.03 * CGRectGetHeight(frame))];
    [bezier2Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.97 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.47 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.75 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.03 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.97 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24 * CGRectGetHeight(frame))];
    [bezier2Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.5 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.97 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.79 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.75 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97 * CGRectGetHeight(frame))];
    [bezier2Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.03 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.5 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.25 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.03 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.79 * CGRectGetHeight(frame))];
    [bezier2Path closePath];
    [halfGrey setFill];
    [bezier2Path fill];
    
    
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.56 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.67 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.37 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.56 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.37 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.56 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26 * CGRectGetHeight(frame))];
    [bezierPath closePath];
    [darkerGrey setFill];
    [bezierPath fill];
    
    
    
    //// Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.01) + 0.5, CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.01) + 0.5, floor(CGRectGetWidth(frame) * 0.97), floor(CGRectGetHeight(frame) * 0.97))];
    [darkerGrey setStroke];
    ovalPath.lineWidth = 1;
    [ovalPath stroke];
    
    
    //// Bezier 3 Drawing
    UIBezierPath* bezier3Path = [UIBezierPath bezierPath];
    [bezier3Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.31 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.21 * CGRectGetHeight(frame))];
    [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.31 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.74 * CGRectGetHeight(frame))];
    [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.71 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.74 * CGRectGetHeight(frame))];
    [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.71 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34 * CGRectGetHeight(frame))];
    [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.59 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.21 * CGRectGetHeight(frame))];
    [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.31 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.21 * CGRectGetHeight(frame))];
    [bezier3Path closePath];
    [darkerGrey setStroke];
    bezier3Path.lineWidth = 1;
    [bezier3Path stroke];
    
}


@end
