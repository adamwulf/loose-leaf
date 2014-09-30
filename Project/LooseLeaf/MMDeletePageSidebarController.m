//
//  MMDeletePageSidebar.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/29/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMDeletePageSidebarController.h"

#define kBorderWidth 3
#define kBorderSpacing 2
#define kStripeHeight 40.0

@implementation MMDeletePageSidebarController{
    UIView* deleteSidebarBackground;
    UIView* deleteSidebarForeground;
}

@synthesize deleteSidebarBackground;
@synthesize deleteSidebarForeground;

-(id) initWithFrame:(CGRect)frame{
    if(self = [super init]){
        CGFloat centerY = frame.size.height / 2;
        CGFloat curveSize = 20.0;
        
        UIColor* borderColor = [[UIColor whiteColor] colorWithAlphaComponent:.9];
        UIColor* stripeColorFore = [[UIColor whiteColor] colorWithAlphaComponent:.2];
        UIColor* stripeColorBack = [[UIColor whiteColor] colorWithAlphaComponent:.2];
        
        deleteSidebarBackground = [[UIView alloc] initWithFrame:frame];
        deleteSidebarBackground.backgroundColor = [UIColor clearColor];
        deleteSidebarForeground = [[UIView alloc] initWithFrame:frame];
        deleteSidebarForeground.backgroundColor = [UIColor clearColor];
        [self showSidebarWithPercent:0];
        
        CGFloat thetaLarge = atan(centerY/curveSize);
        CGFloat thetaSmall = M_PI - 2*thetaLarge;
        CGFloat radius = centerY / tan(thetaSmall);

        // border path
        CGPoint center = CGPointMake(frame.size.width-radius, frame.size.height/2);
        UIBezierPath* borderPath = [UIBezierPath bezierPathWithArcCenter:center radius:radius - kBorderWidth startAngle:0 endAngle:2*M_PI clockwise:YES];
        [borderPath appendPath:[UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:0 endAngle:2*M_PI clockwise:YES]];
        // right border layer and mask
        CALayer* rightBorder = [self giveLayerDefaultProperties:[CALayer layer]];
        rightBorder.backgroundColor = borderColor.CGColor;
        CAShapeLayer* rightBorderMask = [CAShapeLayer layer];
        rightBorderMask.backgroundColor = [UIColor whiteColor].CGColor;
        rightBorderMask.path = borderPath.CGPath;
        rightBorderMask.fillRule = kCAFillRuleEvenOdd;
        rightBorder.mask = rightBorderMask;
        
        
        // default fill w/o stripes
        UIBezierPath* fillPath = [UIBezierPath bezierPathWithArcCenter:center radius:radius - kBorderSpacing - kBorderWidth startAngle:0 endAngle:2*M_PI clockwise:YES];
        CALayer* trashBackground = [self giveLayerDefaultProperties:[CALayer layer]];
        trashBackground.backgroundColor = stripeColorBack.CGColor;
        CAShapeLayer* trashBackgroundMask = [CAShapeLayer layer];
        trashBackgroundMask.backgroundColor = [UIColor whiteColor].CGColor;
        trashBackgroundMask.path = fillPath.CGPath;
        trashBackground.mask = trashBackgroundMask;

        // now add the stripes to the fill
        UIBezierPath* stripePath = [UIBezierPath bezierPath];
        for(int i=0;i<ceil(frame.size.height / kStripeHeight);i++){
            [stripePath appendPath:[UIBezierPath bezierPathWithRect:CGRectMake(0, 2*i*kStripeHeight, 2*frame.size.width, kStripeHeight)]];
        }
        [stripePath applyTransform:CGAffineTransformMakeTranslation(0, -10*kStripeHeight)];
        [stripePath applyTransform:CGAffineTransformMakeTranslation(-frame.size.width/2, -frame.size.height/2)];
        [stripePath applyTransform:CGAffineTransformMakeRotation(-20.0 * M_PI / 180.0)];
        [stripePath applyTransform:CGAffineTransformMakeTranslation(frame.size.width/2, frame.size.height/2)];
        CALayer* trashStripes = [self giveLayerDefaultProperties:[CALayer layer]];
        trashStripes.backgroundColor = stripeColorFore.CGColor;
        CAShapeLayer* trashStripesMask = [CAShapeLayer layer];
        trashStripesMask.backgroundColor = [UIColor whiteColor].CGColor;
        trashStripesMask.path = stripePath.CGPath;
        trashStripes.mask = trashStripesMask;
        [trashBackground addSublayer:trashStripes];
        
        

        
//        CAShapeLayer* mask = [self giveLayerDefaultProperties:[CAShapeLayer layer]];
//        mask.path = circle.CGPath;
//        mask.fillRule = kCAFillRuleEvenOdd;
//        deleteSidebarBackground.layer.mask = mask;
        
        deleteSidebarBackground.layer.backgroundColor = [UIColor clearColor].CGColor;
        [deleteSidebarBackground.layer addSublayer:rightBorder];
        [deleteSidebarBackground.layer addSublayer:trashBackground];
        
    }
    return self;
}

-(id) giveLayerDefaultProperties:(CALayer*)layer{
    layer.bounds = deleteSidebarBackground.bounds;
    layer.position = CGPointMake(deleteSidebarBackground.frame.size.width/2, deleteSidebarBackground.frame.size.height/2);
    layer.backgroundColor = [UIColor whiteColor].CGColor;
    return layer;
}

-(UIBezierPath*) pathForSidebarBackground:(CGFloat)radius withFrame:(CGRect)frame{
    CGPoint center = CGPointMake(frame.size.width-radius, 512);
    
    UIBezierPath* circle = [UIBezierPath bezierPathWithArcCenter:center radius:radius - 4 startAngle:0 endAngle:2*M_PI clockwise:YES];
    [circle appendPath:[UIBezierPath bezierPathWithArcCenter:center radius:radius - 2 startAngle:0 endAngle:2*M_PI clockwise:YES]];
    [circle appendPath:[UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:0 endAngle:2*M_PI clockwise:YES]];
    circle.usesEvenOddFillRule = YES;
    
    
    
    return circle;
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
