//
//  SLPlusButton.m
//  Paper Stack
//
//  Created by Adam Wulf on 6/21/12.
//  Copyright (c) 2012 Visere. All rights reserved.
//

#import "SLPlusButton.h"
#import "Constants.h"
#import <QuartzCore/QuartzCore.h>

@implementation SLPlusButton

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
    CGFloat smallest2 = MIN([self.layer.presentationLayer frame].size.width, [self.layer.presentationLayer frame ].size.height);
    debug_NSLog(@"size: %f vs %f", smallest, smallest2);
    CGRect frame = CGRectMake(0, 0, smallest, smallest);
    
    //// Color Declarations
    UIColor* darkerGrey = [UIColor colorWithRed: 0.26 green: 0.26 blue: 0.26 alpha: 0.25];
    UIColor* halfGrey = [UIColor colorWithRed: 0.84 green: 0.84 blue: 0.84 alpha: 0.3];
    
    
    //// Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.01) + 0.5, CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.01) + 0.5, floor(CGRectGetWidth(frame) * 0.97), floor(CGRectGetHeight(frame) * 0.97))];
    [darkerGrey setStroke];
    ovalPath.lineWidth = 1;
    [ovalPath stroke];
    
    
    //// Bezier 2 Drawing
    UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.03 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.5 * CGRectGetHeight(frame))];
    [bezier2Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.5 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.03 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.03 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.22 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.25 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.03 * CGRectGetHeight(frame))];
    [bezier2Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.5 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.03 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.51 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.03 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.5 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.03 * CGRectGetHeight(frame))];
    [bezier2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.5 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24 * CGRectGetHeight(frame))];
    [bezier2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.41 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24 * CGRectGetHeight(frame))];
    [bezier2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 16.5, CGRectGetMinY(frame) + 17)];
    [bezier2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 9, CGRectGetMinY(frame) + 17)];
    [bezier2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 9, CGRectGetMinY(frame) + 24)];
    [bezier2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 16.5, CGRectGetMinY(frame) + 24)];
    [bezier2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.41 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.79 * CGRectGetHeight(frame))];
    [bezier2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.59 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.79 * CGRectGetHeight(frame))];
    [bezier2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 23.5, CGRectGetMinY(frame) + 24)];
    [bezier2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 31, CGRectGetMinY(frame) + 24)];
    [bezier2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 31, CGRectGetMinY(frame) + 17)];
    [bezier2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 23.5, CGRectGetMinY(frame) + 17)];
    [bezier2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.59 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24 * CGRectGetHeight(frame))];
    [bezier2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.5 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24 * CGRectGetHeight(frame))];
    [bezier2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.5 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.03 * CGRectGetHeight(frame))];
    [bezier2Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.5 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.03 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.5 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.03 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.44 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.03 * CGRectGetHeight(frame))];
    [bezier2Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.97 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.47 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.75 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.03 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.97 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24 * CGRectGetHeight(frame))];
    [bezier2Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.5 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.97 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.79 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.75 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97 * CGRectGetHeight(frame))];
    [bezier2Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.03 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.5 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.25 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.03 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.79 * CGRectGetHeight(frame))];
    [bezier2Path closePath];
    [halfGrey setFill];
    [bezier2Path fill];
    
}


@end
