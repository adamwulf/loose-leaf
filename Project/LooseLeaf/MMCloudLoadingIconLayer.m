//
//  MMCloudLoadingIconView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/9/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMCloudLoadingIconLayer.h"
#import "NSArray+Extras.h"
#import "NSArray+MapReduce.h"

@implementation MMCloudLoadingIconLayer

-(id) initWithFrame:(CGRect)frame{
    if(self = [super init]){
        // setup our size
        self.bounds = CGRectMake(0, 0, frame.size.width, frame.size.height);
        
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor].CGColor;

        UIBezierPath* cloudPath = [self cloudPathForRect:self.bounds];
        CAShapeLayer* cloudBorderLayer = [self cloudBorderLayerForPath:cloudPath];
        UIColor* borderColor = [UIColor colorWithRed: 0.221 green: 0.221 blue: 0.219 alpha: 1];
        cloudBorderLayer.strokeColor = borderColor.CGColor;
        cloudBorderLayer.lineWidth = 1;
        cloudBorderLayer.fillColor = [UIColor clearColor].CGColor;
        
        CAShapeLayer* cloudMaskLayer = [self cloudBorderLayerForPath:cloudPath];
        
        CAGradientLayer* gradientLayer = [self animatingGradientLayer:cloudPath];
        gradientLayer.mask = cloudMaskLayer;
        
        
        [self addSublayer:gradientLayer];
        [self addSublayer:cloudBorderLayer];
        
        // setup our location
        self.position = CGPointMake(frame.origin.x + frame.size.width/2, frame.origin.y + frame.size.height/2);
    }
    return self;
}



-(UIBezierPath*) cloudPathForRect:(CGRect)frame{
    UIBezierPath* cloudPath = UIBezierPath.bezierPath;
    [cloudPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.28168 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.45133 * CGRectGetHeight(frame))];
    [cloudPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.20000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34489 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.28168 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.45133 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.19979 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.43804 * CGRectGetHeight(frame))];
    [cloudPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.27623 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24703 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.20018 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26589 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.27623 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24703 * CGRectGetHeight(frame))];
    [cloudPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.34811 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.16914 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.27623 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24703 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.27532 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17139 * CGRectGetHeight(frame))];
    [cloudPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.40012 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.18836 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.36631 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.16858 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.40012 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.18836 * CGRectGetHeight(frame))];
    [cloudPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.54737 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09001 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.40012 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.18836 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.44741 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.08877 * CGRectGetHeight(frame))];
    [cloudPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.70129 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.25766 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.70426 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09196 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.70129 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.25766 * CGRectGetHeight(frame))];
    [cloudPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.79500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.35854 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.70129 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.25766 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.79690 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26594 * CGRectGetHeight(frame))];
    [cloudPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.71059 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.45133 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.79309 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.45114 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.71059 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.45133 * CGRectGetHeight(frame))];
    [cloudPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.28168 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.45133 * CGRectGetHeight(frame))];
    [cloudPath closePath];
    return cloudPath;
}

-(CAShapeLayer*) cloudBorderLayerForPath:(UIBezierPath*)cloudPath{
    CAShapeLayer* cloudBorderLayer = [CAShapeLayer layer];
    cloudBorderLayer.bounds = self.bounds;
    cloudBorderLayer.path = cloudPath.CGPath;
    cloudBorderLayer.anchorPoint = CGPointMake(0, 0);
    cloudBorderLayer.position = CGPointMake(0, 0);
    return cloudBorderLayer;
}

-(CAGradientLayer*)animatingGradientLayer:(UIBezierPath*)cloudPath{
    CAGradientLayer* cloudGradientLayer = [CAGradientLayer layer];
    cloudGradientLayer.bounds = [cloudPath bounds];
    cloudGradientLayer.anchorPoint = CGPointMake(0, 0);
    cloudGradientLayer.position = [cloudPath bounds].origin;

    //// Gradient Declarations
    CGFloat maxAlpha = .5;
    CGFloat minAlpha = .2;
    NSArray* allColors = @[];
    CGFloat maxColors = 10;
    UIColor* originalWhite = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    for (int i=0;i<maxColors*2;i++) {
        CGFloat angle = sinf(i / (maxColors*2) * M_PI);
        allColors = [allColors arrayByAddingObject:(id)[originalWhite colorWithAlphaComponent:minAlpha + angle*(maxAlpha - minAlpha)].CGColor];
    }
    
    NSArray* steppedColors = @[];
    for(int i=0;i<maxColors*2;i++){
        steppedColors = [steppedColors arrayByAddingObject:allColors];
        UIColor* movedColor = [allColors firstObject];
        allColors = [allColors subarrayWithRange:NSMakeRange(1, maxColors*2 - 1)];
        allColors = [allColors arrayByAddingObject:movedColor];
    }
    
    NSArray* adjustedColors = @[];
    for (NSArray* colors in steppedColors) {
        adjustedColors = [adjustedColors arrayByAddingObject:colors];
    }
    
    NSArray* keyTimes = @[];
    for (int i=0; i<maxColors*2; i++) {
        keyTimes = [keyTimes arrayByAddingObject:[NSNumber numberWithFloat:(i/(maxColors*2))]];
    }
    
    adjustedColors = [adjustedColors arrayByAddingObject:[adjustedColors firstObject]];
    keyTimes = [keyTimes arrayByAddingObject:@(1.0)];
    
    adjustedColors = [adjustedColors map:^id(id obj, NSUInteger index) {
        return [obj reversedArray];
    }];

    CAKeyframeAnimation *colorsAnimation = [CAKeyframeAnimation animationWithKeyPath:@"colors"];
    colorsAnimation.values = adjustedColors;
    colorsAnimation.keyTimes = keyTimes;
    colorsAnimation.calculationMode = kCAAnimationLinear;
    colorsAnimation.removedOnCompletion = NO;
    colorsAnimation.duration = 1.5f;
    colorsAnimation.repeatCount = HUGE_VALF; // repeat forever
    [cloudGradientLayer addAnimation:colorsAnimation forKey:@"colorAnimation"];
    
    cloudGradientLayer.colors = [adjustedColors firstObject];

    return cloudGradientLayer;
}


@end
