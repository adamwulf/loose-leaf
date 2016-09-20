//
//  MMLeftArrow.m
//  Loose Leaf
//
//  Created by Adam Wulf on 6/19/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "MMLeftArrow.h"


@implementation MMLeftArrow

- (id)initWithFrame:(CGRect)frame {
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
- (void)drawRect:(CGRect)rect {
    // Drawing code
    //// Frames
    CGFloat smallest = MIN(self.bounds.size.width, self.bounds.size.height);
    CGRect frame = CGRectMake(0, 0, smallest, smallest);


    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();

    //// Color Declarations
    UIColor* darkerGrey = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.33];
    UIColor* halfWhite = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.36];

    //// Gradient Declarations
    NSArray* frontOfPaperColors = [NSArray arrayWithObjects:
                                               (id)darkerGrey.CGColor,
                                               (id)[UIColor colorWithRed:0.57 green:0.57 blue:0.57 alpha:0.34].CGColor,
                                               (id)halfWhite.CGColor, nil];
    CGFloat frontOfPaperLocations[] = {0.94, 0.67, 0.06};
    CGGradientRef frontOfPaper = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)frontOfPaperColors, frontOfPaperLocations);

    //// Bezier 2 Drawing
    UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint:CGPointMake(CGRectGetMinX(frame) + 45.5, CGRectGetMinY(frame) + 15.5)];
    [bezier2Path addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 22.5, CGRectGetMinY(frame) + 15.5)];
    [bezier2Path addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 22.5, CGRectGetMinY(frame) + 1.5)];
    [bezier2Path addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.5, CGRectGetMinY(frame) + 23.5)];
    [bezier2Path addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 22.5, CGRectGetMinY(frame) + 45.5)];
    [bezier2Path addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 22.5, CGRectGetMinY(frame) + 31.5)];
    [bezier2Path addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 45.5, CGRectGetMinY(frame) + 31.5)];
    [bezier2Path addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 45.5, CGRectGetMinY(frame) + 15.5)];
    [bezier2Path closePath];
    CGContextSaveGState(context);
    [bezier2Path addClip];
    UIBezierPath* bezier2RotatedPath = [bezier2Path copy];
    CGAffineTransform bezier2Transform = CGAffineTransformMakeRotation(115 / (-2 * M_PI));
    [bezier2RotatedPath applyTransform:bezier2Transform];
    CGRect bezier2Bounds = bezier2RotatedPath.bounds;
    bezier2Transform = CGAffineTransformInvert(bezier2Transform);

    CGContextDrawLinearGradient(context, frontOfPaper,
                                CGPointApplyAffineTransform(CGPointMake(CGRectGetMinX(bezier2Bounds), CGRectGetMidY(bezier2Bounds)), bezier2Transform),
                                CGPointApplyAffineTransform(CGPointMake(CGRectGetMaxX(bezier2Bounds), CGRectGetMidY(bezier2Bounds)), bezier2Transform),
                                0);
    CGContextRestoreGState(context);

    [[UIColor blackColor] setStroke];
    bezier2Path.lineWidth = 1;
    [bezier2Path stroke];

    //// Cleanup
    CGGradientRelease(frontOfPaper);
    CGColorSpaceRelease(colorSpace);
}

@end
