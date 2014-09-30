//
//  MMDeletePageSidebar.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/29/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMDeletePageSidebarController.h"

@implementation MMDeletePageSidebarController{
    UIView* deleteSidebarBackground;
    UIView* deleteSidebarForeground;
}

@synthesize deleteSidebarBackground;
@synthesize deleteSidebarForeground;

-(id) initWithFrame:(CGRect)frame{
    if(self = [super init]){
        deleteSidebarBackground = [[UIView alloc] initWithFrame:frame];
        deleteSidebarBackground.backgroundColor = [UIColor whiteColor];
        deleteSidebarForeground = [[UIView alloc] initWithFrame:frame];
        deleteSidebarForeground.backgroundColor = [UIColor clearColor];
        [self showSidebarWithPercent:0];
        
        CGFloat thetaLarge = atan(512.0/20.0);
        CGFloat thetaSmall = M_PI - 2*thetaLarge;
        CGFloat radius = 512.0 / tan(thetaSmall);

        CGPoint center = CGPointMake(frame.size.width-radius, 512);

        UIBezierPath* circle = [UIBezierPath bezierPathWithArcCenter:center radius:radius - 4 startAngle:0 endAngle:2*M_PI clockwise:YES];
        [circle appendPath:[UIBezierPath bezierPathWithArcCenter:center radius:radius - 2 startAngle:0 endAngle:2*M_PI clockwise:YES]];
        [circle appendPath:[UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:0 endAngle:2*M_PI clockwise:YES]];
        circle.usesEvenOddFillRule = YES;
        
        CAShapeLayer* mask = [CAShapeLayer layer];
        mask.bounds = deleteSidebarBackground.bounds;
        mask.position = CGPointMake(frame.size.width/2, frame.size.height/2 - 200);
        mask.path = circle.CGPath;
        mask.fillRule = kCAFillRuleEvenOdd;
        deleteSidebarBackground.layer.mask = mask;
    }
    return self;
}

-(void) showSidebarWithPercent:(CGFloat)percent{
    CGRect fr = CGRectMake(-deleteSidebarForeground.bounds.size.width + 200 * percent, 0, deleteSidebarForeground.bounds.size.width, deleteSidebarForeground.bounds.size.height);
    deleteSidebarBackground.frame = fr;
    deleteSidebarForeground.frame = fr;
    
//    fr = deleteSidebarBackground.bounds;
//    deleteSidebarBackground.frame = fr;
//    deleteSidebarForeground.frame = fr;
}


@end
