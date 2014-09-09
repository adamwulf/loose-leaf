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
    [cloudPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.28102 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.45384 * CGRectGetHeight(frame))];
    [cloudPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.19934 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34741 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.28102 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.45384 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.19912 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.44055 * CGRectGetHeight(frame))];
    [cloudPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.27556 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24955 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.19952 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26841 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.27556 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24955 * CGRectGetHeight(frame))];
    [cloudPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.34745 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17165 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.27556 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24955 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.27466 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17390 * CGRectGetHeight(frame))];
    [cloudPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.39946 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.19088 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.36565 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17109 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.39946 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.19088 * CGRectGetHeight(frame))];
    [cloudPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.54671 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09252 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.39946 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.19088 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.44675 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09128 * CGRectGetHeight(frame))];
    [cloudPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.70062 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26018 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.70360 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09447 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.70062 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26018 * CGRectGetHeight(frame))];
    [cloudPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.79433 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.36106 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.70062 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26018 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.79624 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26846 * CGRectGetHeight(frame))];
    [cloudPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.70993 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.45384 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.79243 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.45365 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.70993 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.45384 * CGRectGetHeight(frame))];
    [cloudPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.28102 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.45384 * CGRectGetHeight(frame))];
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
    
    cloudGradientLayer.colors = [adjustedColors firstObject];
    [cloudGradientLayer addAnimation:colorsAnimation forKey:@"colorAnimation"];
    

    return cloudGradientLayer;
}


@end
