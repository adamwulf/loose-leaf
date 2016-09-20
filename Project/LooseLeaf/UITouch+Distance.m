//
//  UITouch+Distance.m
//  LooseLeaf
//
//  Created by Adam Wulf on 1/15/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "UITouch+Distance.h"
#import <PerformanceBezier/PerformanceBezier.h>

@implementation UITouch (Distance)

-(CGFloat) distanceToTouch:(UITouch*)otherTouch{
    CGPoint p1 = [self locationInView:self.view.window];
    CGPoint p2 = [otherTouch locationInView:self.view.window];
    return distance(p1, p2);
}

@end
