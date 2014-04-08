//
//  MMPaperButton.m
//  Loose Leaf
//
//  Created by Adam Wulf on 6/20/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "MMShareButton.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"

@implementation MMShareButton

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
    //
    // Notes for this button
    //
    // the page border bezier has to be added to the oval bezier
    // paintcode keeps them separate
    //
    
    //// Color Declarations
    UIColor* darkerGreyBorder = [self borderColor];
    UIColor* halfGreyFill = [self backgroundColor];
    
    CGRect frame = [self drawableFrame];
    
    //// Oval
    UIBezierPath* ovalPath = [self ovalPath];
    
    //// Oval Drawing
    ovalPath.lineWidth = 1;
    [darkerGreyBorder setStroke];
    [ovalPath stroke];
    [halfGreyFill setFill];
    [ovalPath fill];

    UIBezierPath* boxPath = [UIBezierPath bezierPath];
    [boxPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.42500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.38750 * CGRectGetHeight(frame))];
    [boxPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.32500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.38750 * CGRectGetHeight(frame))];
    [boxPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.32500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.73750 * CGRectGetHeight(frame))];
    [boxPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.67500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.73750 * CGRectGetHeight(frame))];
    [boxPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.67500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.38750 * CGRectGetHeight(frame))];
    [boxPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.57500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.38750 * CGRectGetHeight(frame))];
    [darkerGreyBorder setStroke];
    boxPath.lineWidth = 2;
    [boxPath stroke];
    
    
    //// arrow head Drawing
    UIBezierPath* arrowHeadPath = [UIBezierPath bezierPath];
    [arrowHeadPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.40000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.28750 * CGRectGetHeight(frame))];
    [arrowHeadPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.18750 * CGRectGetHeight(frame))];
    [arrowHeadPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.60000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.28750 * CGRectGetHeight(frame))];
    [darkerGreyBorder setStroke];
    arrowHeadPath.lineWidth = 2;
    [arrowHeadPath stroke];
    
    
    //// arrow body Drawing
    UIBezierPath* arrowBodyPath = [UIBezierPath bezierPath];
    [arrowBodyPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.56250 * CGRectGetHeight(frame))];
    [arrowBodyPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.21250 * CGRectGetHeight(frame))];
    [darkerGreyBorder setStroke];
    arrowBodyPath.lineWidth = 2;
    [arrowBodyPath stroke];
    
    

    [self drawDropshadowIfSelected];

    [super drawRect:rect];
}


@end
