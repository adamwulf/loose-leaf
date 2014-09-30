//
//  MMTrashIcon.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/30/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMTrashIcon.h"

@implementation MMTrashIcon

-(id) initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    //// Color Declarations
    UIColor* color = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.35];
    
    CGFloat trueWidth = 80;
    CGFloat lineWidth = trueWidth / 100.0 * 2.0;
    
    rect = CGRectInset(rect, 2, 2);

    //// Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetWidth(rect), CGRectGetHeight(rect))];
    [color setFill];
    [ovalPath fill];
    
    
    //// Bezier 6 Drawing
    UIBezierPath* bezier6Path = UIBezierPath.bezierPath;
    [bezier6Path moveToPoint: CGPointMake(CGRectGetMinX(rect) + 0.24000 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.22000 * CGRectGetHeight(rect))];
    [bezier6Path addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.45000 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.22000 * CGRectGetHeight(rect))];
    [bezier6Path addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.47000 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.20000 * CGRectGetHeight(rect))];
    [bezier6Path addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.53000 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.20000 * CGRectGetHeight(rect))];
    [bezier6Path addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.55000 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.22000 * CGRectGetHeight(rect))];
    [bezier6Path addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.78000 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.22000 * CGRectGetHeight(rect))];
    [bezier6Path addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.79000 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.25000 * CGRectGetHeight(rect))];
    [bezier6Path addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.23000 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.25000 * CGRectGetHeight(rect))];
    [bezier6Path addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.24000 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.22000 * CGRectGetHeight(rect))];
    [bezier6Path closePath];
    [UIColor.darkGrayColor setStroke];
    bezier6Path.lineWidth = lineWidth;
    [bezier6Path stroke];
    
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = UIBezierPath.bezierPath;
    [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(rect) + 0.27000 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.28000 * CGRectGetHeight(rect))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.34000 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.79000 * CGRectGetHeight(rect))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.67000 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.79000 * CGRectGetHeight(rect))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.74000 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.28000 * CGRectGetHeight(rect))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.70500 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.28000 * CGRectGetHeight(rect))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.64500 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.76000 * CGRectGetHeight(rect))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.36500 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.76000 * CGRectGetHeight(rect))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.30500 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.28000 * CGRectGetHeight(rect))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.27000 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.28000 * CGRectGetHeight(rect))];
    [bezierPath closePath];
    [UIColor.darkGrayColor setStroke];
    bezierPath.lineWidth = lineWidth;
    [bezierPath stroke];
    
    ovalPath.lineWidth = 2;
    [ovalPath stroke];
}


@end
