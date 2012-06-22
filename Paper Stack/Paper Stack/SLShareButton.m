//
//  SLPaperButton.m
//  Paper Stack
//
//  Created by Adam Wulf on 6/20/12.
//  Copyright (c) 2012 Visere. All rights reserved.
//

#import "SLShareButton.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"

@implementation SLShareButton

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

    //
    // Notes for this button
    //
    // the page border bezier has to be added to the oval bezier
    // paintcode keeps them separate
    //
    CGFloat smallest = MIN(self.bounds.size.width, self.bounds.size.height);
    CGRect frame = CGRectMake(0, 0, smallest, smallest);
    
    //// Color Declarations
    UIColor* darkerGreyBorder = [self borderColor];
    UIColor* halfGreyFill = [self backgroundColor];
        
    //// Box Drawing
    UIBezierPath* boxPath = [UIBezierPath bezierPath];
    [boxPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.55 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31 * CGRectGetHeight(frame))];
    [boxPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.24 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31 * CGRectGetHeight(frame))];
    [boxPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.24 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.71 * CGRectGetHeight(frame))];
    [boxPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.76 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.71 * CGRectGetHeight(frame))];
    [boxPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.76 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.56 * CGRectGetHeight(frame))];
    [boxPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.71 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.61 * CGRectGetHeight(frame))];
    [boxPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.71 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.66 * CGRectGetHeight(frame))];
    [boxPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.29 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.66 * CGRectGetHeight(frame))];
    [boxPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.29 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.36 * CGRectGetHeight(frame))];
    [boxPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.45 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.36 * CGRectGetHeight(frame))];
    [boxPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.55 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31 * CGRectGetHeight(frame))];
    [boxPath closePath];
    boxPath.lineJoinStyle = kCGLineJoinRound;
    
    
    //// Arrow Drawing
    UIBezierPath* arrowPath = [UIBezierPath bezierPath];
    [arrowPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.66 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.35 * CGRectGetHeight(frame))];
    [arrowPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.66 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24 * CGRectGetHeight(frame))];
    [arrowPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.84 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.41 * CGRectGetHeight(frame))];
    [arrowPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.66 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.59 * CGRectGetHeight(frame))];
    [arrowPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.66 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.47 * CGRectGetHeight(frame))];
    [arrowPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.64 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.47 * CGRectGetHeight(frame))];
    [arrowPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.46 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.54 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.64 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.47 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.51 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.5 * CGRectGetHeight(frame))];
    [arrowPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.36 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.61 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.41 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.57 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.36 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.61 * CGRectGetHeight(frame))];
    [arrowPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.46 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.42 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.36 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.61 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.4 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.48 * CGRectGetHeight(frame))];
    [arrowPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.64 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.35 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.52 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.37 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.64 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.35 * CGRectGetHeight(frame))];
    [arrowPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.66 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.35 * CGRectGetHeight(frame))];
    [arrowPath closePath];

    
    //// Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.01) + 0.5, CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.01) + 0.5, floor(CGRectGetWidth(frame) * 0.97), floor(CGRectGetHeight(frame) * 0.97))];
    ovalPath.lineWidth = 1;
    [darkerGreyBorder setStroke];
    [ovalPath stroke];
    [halfGreyFill setFill];
    [ovalPath fill];

    // clip end of pencil
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setFill];
    [arrowPath fill];
    [boxPath fill];
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    
    
    [darkerGreyBorder setStroke];
    boxPath.lineWidth = 1;
    [boxPath stroke];

    [darkerGreyBorder setStroke];
    arrowPath.lineWidth = 1;
    [arrowPath stroke];

}


@end
