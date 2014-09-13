//
//  MMBrokenCloudLayer.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/9/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMBrokenCloudLayer.h"

@implementation MMBrokenCloudLayer{
    CALayer* leftCloudContainer;
    CALayer* rightCloudContainer;
}

-(id) initWithFrame:(CGRect)frame{
    if(self = [super init]){
        // setup our size
        self.bounds = CGRectMake(0, 0, frame.size.width, frame.size.height);
        
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor].CGColor;
        
        UIColor* borderColor = [UIColor colorWithRed: 0.221 green: 0.221 blue: 0.219 alpha: 1];

        UIBezierPath* cloudPath = [self leftSidePathCloudPathForRect:self.bounds];
        CAShapeLayer* leftCloudBorderLayer = [self cloudBorderLayerForPath:cloudPath];
        leftCloudBorderLayer.strokeColor = borderColor.CGColor;
        leftCloudBorderLayer.lineWidth = 1;
        leftCloudBorderLayer.fillColor = [UIColor clearColor].CGColor;
        CAShapeLayer* leftCloudMaskLayer = [self cloudBorderLayerForPath:cloudPath];
        CAGradientLayer* leftGradientLayer = [self gradientLayer:cloudPath];
        leftGradientLayer.mask = leftCloudMaskLayer;
        
        
        [self addSublayer:leftGradientLayer];
        [self addSublayer:leftCloudBorderLayer];

        
        cloudPath = [self rightSidePathCloudPathForRect:self.bounds];
        CAShapeLayer* rightCloudBorderLayer = [self cloudBorderLayerForPath:cloudPath];
        rightCloudBorderLayer.strokeColor = borderColor.CGColor;
        rightCloudBorderLayer.lineWidth = 1;
        rightCloudBorderLayer.fillColor = [UIColor clearColor].CGColor;
        CAShapeLayer* rightCloudMaskLayer = [self cloudBorderLayerForPath:cloudPath];
        CAGradientLayer* rightGradientLayer = [self gradientLayer:cloudPath];
        rightGradientLayer.mask = rightCloudMaskLayer;
        
        
        leftCloudContainer = [CALayer layer];
        leftCloudContainer.bounds = self.bounds;
        leftCloudContainer.position = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        
        [leftCloudContainer addSublayer:leftGradientLayer];
        [leftCloudContainer addSublayer:leftCloudBorderLayer];
        [self addSublayer:leftCloudContainer];

        rightCloudContainer = [CALayer layer];
        rightCloudContainer.bounds = self.bounds;
        rightCloudContainer.position = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        
        [rightCloudContainer addSublayer:rightGradientLayer];
        [rightCloudContainer addSublayer:rightCloudBorderLayer];
        [self addSublayer:rightCloudContainer];

        // setup our location
        self.position = CGPointMake(frame.origin.x + frame.size.width/2, frame.origin.y + frame.size.height/2);
    }
    return self;
}


-(UIBezierPath*) rightSidePathCloudPathForRect:(CGRect)frame{
    UIBezierPath* rightSidePath = UIBezierPath.bezierPath;
    [rightSidePath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.54737 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09001 * CGRectGetHeight(frame))];
    [rightSidePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.70129 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.25766 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.70426 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09196 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.70129 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.25766 * CGRectGetHeight(frame))];
    [rightSidePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.79500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.35854 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.70129 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.25766 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.79690 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26594 * CGRectGetHeight(frame))];
    [rightSidePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.71059 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.45133 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.79309 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.45114 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.71059 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.45133 * CGRectGetHeight(frame))];
    [rightSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.51367 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.45133 * CGRectGetHeight(frame))];
    [rightSidePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.52750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.43750 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.51955 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.44545 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.52750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.43750 * CGRectGetHeight(frame))];
    [rightSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.42250 * CGRectGetHeight(frame))];
    [rightSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.51750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.41750 * CGRectGetHeight(frame))];
    [rightSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.40750 * CGRectGetHeight(frame))];
    [rightSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.51750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.40250 * CGRectGetHeight(frame))];
    [rightSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.39250 * CGRectGetHeight(frame))];
    [rightSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.51750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.38750 * CGRectGetHeight(frame))];
    [rightSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.51750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.37750 * CGRectGetHeight(frame))];
    [rightSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.36750 * CGRectGetHeight(frame))];
    [rightSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.52250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34250 * CGRectGetHeight(frame))];
    [rightSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34250 * CGRectGetHeight(frame))];
    [rightSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.33250 * CGRectGetHeight(frame))];
    [rightSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31750 * CGRectGetHeight(frame))];
    [rightSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.49250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31250 * CGRectGetHeight(frame))];
    [rightSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.30250 * CGRectGetHeight(frame))];
    [rightSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.29250 * CGRectGetHeight(frame))];
    [rightSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.51250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.28750 * CGRectGetHeight(frame))];
    [rightSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.49750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26750 * CGRectGetHeight(frame))];
    [rightSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.25750 * CGRectGetHeight(frame))];
    [rightSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.49250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24750 * CGRectGetHeight(frame))];
    [rightSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.23250 * CGRectGetHeight(frame))];
    [rightSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.51750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.22250 * CGRectGetHeight(frame))];
    [rightSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.21250 * CGRectGetHeight(frame))];
    [rightSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.51250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.20750 * CGRectGetHeight(frame))];
    [rightSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.49750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.19750 * CGRectGetHeight(frame))];
    [rightSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.18750 * CGRectGetHeight(frame))];
    [rightSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.49750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17250 * CGRectGetHeight(frame))];
    [rightSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.15250 * CGRectGetHeight(frame))];
    [rightSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.51750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.14250 * CGRectGetHeight(frame))];
    [rightSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.12750 * CGRectGetHeight(frame))];
    [rightSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.51750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.10750 * CGRectGetHeight(frame))];
    [rightSidePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50351 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09631 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.51750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.10750 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.51022 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.10167 * CGRectGetHeight(frame))];
    [rightSidePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.54737 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09001 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.51680 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09218 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.53142 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.08981 * CGRectGetHeight(frame))];
    [rightSidePath closePath];
    return rightSidePath;
}


-(UIBezierPath*) leftSidePathCloudPathForRect:(CGRect)frame{
    UIBezierPath* leftSidePath = UIBezierPath.bezierPath;
    [leftSidePath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50351 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09631 * CGRectGetHeight(frame))];
    [leftSidePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.51750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.10750 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.51022 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.10167 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.51750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.10750 * CGRectGetHeight(frame))];
    [leftSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.12750 * CGRectGetHeight(frame))];
    [leftSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.51750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.14250 * CGRectGetHeight(frame))];
    [leftSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.15250 * CGRectGetHeight(frame))];
    [leftSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.49750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17250 * CGRectGetHeight(frame))];
    [leftSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.18750 * CGRectGetHeight(frame))];
    [leftSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.49750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.19750 * CGRectGetHeight(frame))];
    [leftSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.51250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.20750 * CGRectGetHeight(frame))];
    [leftSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.21250 * CGRectGetHeight(frame))];
    [leftSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.51750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.22250 * CGRectGetHeight(frame))];
    [leftSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.23250 * CGRectGetHeight(frame))];
    [leftSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.49250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24750 * CGRectGetHeight(frame))];
    [leftSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.25750 * CGRectGetHeight(frame))];
    [leftSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.49750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26750 * CGRectGetHeight(frame))];
    [leftSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.51250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.28750 * CGRectGetHeight(frame))];
    [leftSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.29250 * CGRectGetHeight(frame))];
    [leftSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.30250 * CGRectGetHeight(frame))];
    [leftSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.49250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31250 * CGRectGetHeight(frame))];
    [leftSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31750 * CGRectGetHeight(frame))];
    [leftSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.33250 * CGRectGetHeight(frame))];
    [leftSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34250 * CGRectGetHeight(frame))];
    [leftSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.52250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34250 * CGRectGetHeight(frame))];
    [leftSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.36750 * CGRectGetHeight(frame))];
    [leftSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.51750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.37750 * CGRectGetHeight(frame))];
    [leftSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.51750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.38750 * CGRectGetHeight(frame))];
    [leftSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.39250 * CGRectGetHeight(frame))];
    [leftSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.51750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.40250 * CGRectGetHeight(frame))];
    [leftSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.40750 * CGRectGetHeight(frame))];
    [leftSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.51750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.41750 * CGRectGetHeight(frame))];
    [leftSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.42250 * CGRectGetHeight(frame))];
    [leftSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.52750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.43750 * CGRectGetHeight(frame))];
    [leftSidePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.51367 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.45133 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.52750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.43750 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.51955 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.44545 * CGRectGetHeight(frame))];
    [leftSidePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.28168 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.45133 * CGRectGetHeight(frame))];
    [leftSidePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.20000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34489 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.28168 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.45133 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.19979 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.43804 * CGRectGetHeight(frame))];
    [leftSidePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.27623 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24703 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.20018 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26589 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.27623 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24703 * CGRectGetHeight(frame))];
    [leftSidePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.34811 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.16914 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.27623 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24703 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.27532 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17139 * CGRectGetHeight(frame))];
    [leftSidePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.40012 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.18836 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.36631 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.16858 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.40012 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.18836 * CGRectGetHeight(frame))];
    [leftSidePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50351 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09631 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.40012 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.18836 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.43352 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.11802 * CGRectGetHeight(frame))];
    [leftSidePath closePath];
    return leftSidePath;
}

-(CAShapeLayer*) cloudBorderLayerForPath:(UIBezierPath*)cloudPath{
    CAShapeLayer* cloudBorderLayer = [CAShapeLayer layer];
    cloudBorderLayer.bounds = self.bounds;
    cloudBorderLayer.path = cloudPath.CGPath;
    cloudBorderLayer.anchorPoint = CGPointMake(0, 0);
    cloudBorderLayer.position = CGPointMake(0, 0);
    return cloudBorderLayer;
}

-(CAGradientLayer*)gradientLayer:(UIBezierPath*)cloudPath{
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
    
    cloudGradientLayer.colors = [adjustedColors firstObject];
    
    return cloudGradientLayer;
}


-(void) animatePiecesApart{
    CGPoint startPos = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    CGPoint leftEndPos = CGPointMake(self.bounds.size.width/2 - 10, self.bounds.size.height/2 + 5);
    CABasicAnimation* leftPositionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    leftPositionAnimation.fromValue = [NSValue valueWithCGPoint:startPos];
    leftPositionAnimation.toValue = [NSValue valueWithCGPoint:leftEndPos];
    
    CGPoint rightEndPos = CGPointMake(self.bounds.size.width/2 + 13, self.bounds.size.height/2 +3);
    CABasicAnimation* rightPositionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    rightPositionAnimation.fromValue = [NSValue valueWithCGPoint:startPos];
    rightPositionAnimation.toValue = [NSValue valueWithCGPoint:rightEndPos];
    
    
    CABasicAnimation* leftRotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    leftRotationAnimation.fromValue = @(0);
    leftRotationAnimation.toValue = @(-4 * M_PI / 180);
    
    CABasicAnimation* rightRotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rightRotationAnimation.fromValue = @(0);
    rightRotationAnimation.toValue = @(7 * M_PI / 180);
    
    
    leftCloudContainer.position = leftEndPos;
    leftCloudContainer.transform = CATransform3DMakeRotation([leftRotationAnimation.toValue floatValue], 0, 0, 1);
    rightCloudContainer.position = rightEndPos;
    rightCloudContainer.transform = CATransform3DMakeRotation([rightRotationAnimation.toValue floatValue], 0, 0, 1);
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:.4];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [leftCloudContainer addAnimation:leftPositionAnimation forKey:@"positionz"];
    [rightCloudContainer addAnimation:rightPositionAnimation forKey:@"positionz"];

    [leftCloudContainer addAnimation:leftRotationAnimation forKey:@"rotatez"];
    [rightCloudContainer addAnimation:rightRotationAnimation forKey:@"rotatez"];
    [CATransaction commit];
}



@end
