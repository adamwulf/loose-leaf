//
//  MMPlusButton.m
//  Loose Leaf
//
//  Created by Adam Wulf on 6/21/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "MMPlusButton.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"

@implementation MMPlusButton

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
    CGRect frame = CGRectMake(kWidthOfSidebarButtonBuffer, kWidthOfSidebarButtonBuffer, smallest - 2*kWidthOfSidebarButtonBuffer, smallest - 2*kWidthOfSidebarButtonBuffer);
    
    //// Color Declarations
    UIColor* darkerGreyBorder = [self borderColor];
    UIColor* halfGreyFill = [self backgroundColor];
    
    //// Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + 0.5, CGRectGetMinY(frame) + 0.5, floor(CGRectGetWidth(frame) - 1.0), floor(CGRectGetHeight(frame) - 1.0))];
    [ovalPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.4 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.2 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.4 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.4 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.2 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.4 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.2 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.6 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.4 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.6 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.4 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.8 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.6 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.8 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.6 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.6 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.8 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.6 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.8 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.4 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.6 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.4 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.6 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.2 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.4 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.2 * CGRectGetHeight(frame))];
    [ovalPath closePath];
    [halfGreyFill setFill];
    [ovalPath fill];
    [darkerGreyBorder setStroke];
    ovalPath.lineWidth = 1;
    [ovalPath stroke];
    
}


@end
