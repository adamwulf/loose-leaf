//
//  MMLeftCloseButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/27/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMLeftCloseButton.h"

@implementation MMLeftCloseButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(UIColor*) borderColor{
    return [UIColor colorWithRed: 0.26 green: 0.26 blue: 0.26 alpha: 0.8];
}

-(UIColor*) backgroundColor{
    return [UIColor colorWithRed: 0.84 green: 0.84 blue: 0.84 alpha: 0.5];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    //// Color Declarations
    UIColor* darkerGreyBorder = [self borderColor];
    UIColor* halfGreyFill = [self backgroundColor];
    
    CGRect frame = [self drawableFrame];
    
    //// Oval
    UIBezierPath* ovalPath = [self ovalPath];
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
    
    [self drawDropshadowIfSelected];
    
    [super drawRect:rect];
}

@end
