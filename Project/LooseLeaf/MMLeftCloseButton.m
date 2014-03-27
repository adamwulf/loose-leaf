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
    CGContextRef context = UIGraphicsGetCurrentContext();

    //// Color Declarations
    UIColor* darkerGreyBorder = [self borderColor];
    UIColor* halfGreyFill = [self backgroundColor];
    
    CGRect frame = [self drawableFrame];
    
    //// Oval
    UIBezierPath* ovalPath = [self ovalPath];
    [halfGreyFill setFill];
    [ovalPath fill];
    [darkerGreyBorder setStroke];
    ovalPath.lineWidth = 1;
    [ovalPath stroke];
    
    
    
    UIBezierPath* leftArrowIconPath = [UIBezierPath bezierPath];
    [leftArrowIconPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.43750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.21250 * CGRectGetHeight(frame))];
    [leftArrowIconPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.22500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.50000 * CGRectGetHeight(frame))];
    [leftArrowIconPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.43750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.78750 * CGRectGetHeight(frame))];
    [leftArrowIconPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.68750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.78750 * CGRectGetHeight(frame))];
    [leftArrowIconPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.43750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.50000 * CGRectGetHeight(frame))];
    [leftArrowIconPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.68750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.21250 * CGRectGetHeight(frame))];
    [leftArrowIconPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.43750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.21250 * CGRectGetHeight(frame))];
    [leftArrowIconPath closePath];

    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setFill];
    [leftArrowIconPath fill];
    CGContextSetBlendMode(context, kCGBlendModeNormal);

    leftArrowIconPath.lineWidth = 1;
    [darkerGreyBorder setStroke];
    [leftArrowIconPath stroke];
    
    
    [self drawDropshadowIfSelected];
    
    [super drawRect:rect];
}

@end
