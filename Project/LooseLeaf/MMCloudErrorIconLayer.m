//
//  MMCloudErrorIconLayer.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/12/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMCloudErrorIconLayer.h"
#import "NSArray+Extras.h"
#import "NSArray+MapReduce.h"

@implementation MMCloudErrorIconLayer

-(id) initWithFrame:(CGRect)frame{
    if(self = [super init]){
        // setup our size
        self.bounds = CGRectMake(0, 0, frame.size.width, frame.size.height);
        
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor].CGColor;
        
        UIBezierPath* cloudPath = [self cloudPathForRect:self.bounds];
        CAShapeLayer* cloudBorderLayer = [self cloudBorderLayerForPath:cloudPath];
        UIColor* borderColor = [UIColor colorWithRed: 0.221 green: 0.221 blue: 0.219 alpha: 1];
        UIColor* halfWhite = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.503];
        cloudBorderLayer.strokeColor = borderColor.CGColor;
        cloudBorderLayer.lineWidth = 1;
        cloudBorderLayer.fillColor = [UIColor clearColor].CGColor;
        
        CAShapeLayer* cloudMaskLayer = [self cloudBorderLayerForPath:cloudPath];
        CAGradientLayer* gradientLayer = [self animatingGradientLayer:cloudPath];
        gradientLayer.mask = cloudMaskLayer;
        
        [self addSublayer:gradientLayer];
        [self addSublayer:cloudBorderLayer];
        
        UIBezierPath* noSignPath = [self noSignForRect:self.bounds];
        // translation to align with cloud
        CGFloat scale = self.bounds.size.width / 200.0;
        CGFloat yDiff = -scale * 35;
        [noSignPath applyTransform:CGAffineTransformMakeTranslation(0, yDiff)];
        
        CAShapeLayer* animatingArrowsLayer = [self noSignLayer:noSignPath];
        animatingArrowsLayer.strokeColor = borderColor.CGColor;
        animatingArrowsLayer.lineWidth = 1;
        animatingArrowsLayer.fillColor = halfWhite.CGColor;
        [self addSublayer:animatingArrowsLayer];
        
        // setup our location
        self.position = CGPointMake(frame.origin.x + frame.size.width/2, frame.origin.y + frame.size.height/2);
    }
    return self;
}

-(CGPoint) centerOfErrorCircle{
    UIBezierPath* noSignPath = [self noSignForRect:self.bounds];
    CGFloat scale = self.bounds.size.width / 200.0;
    CGFloat yDiff = -scale * 35;
    [noSignPath applyTransform:CGAffineTransformMakeTranslation(0, yDiff)];
    CGRect pathBounds = noSignPath.bounds;
    return CGPointMake(pathBounds.origin.x + pathBounds.size.width/2, pathBounds.origin.y + pathBounds.size.height/2);
}

-(UIBezierPath*) noSignForRect:(CGRect)frame{
    //// CircleArrows Drawing
    UIBezierPath* noSignPath = UIBezierPath.bezierPath;
    [noSignPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.27207 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26707 * CGRectGetHeight(frame))];
    [noSignPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.24996 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.70349 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.15267 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.38648 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.14529 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.57549 * CGRectGetHeight(frame))];
    [noSignPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.70849 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24496 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.30888 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.64457 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.63767 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31578 * CGRectGetHeight(frame))];
    [noSignPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.27207 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26707 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.58049 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.14029 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.39148 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.14767 * CGRectGetHeight(frame))];
    [noSignPath closePath];
    [noSignPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.75504 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.29151 * CGRectGetHeight(frame))];
    [noSignPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.29651 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.75004 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.68422 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.36233 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.35543 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.69112 * CGRectGetHeight(frame))];
    [noSignPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.73293 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.72793 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.42451 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.85471 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.61352 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.84733 * CGRectGetHeight(frame))];
    [noSignPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.75504 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.29151 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.85233 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.60852 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.85971 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.41951 * CGRectGetHeight(frame))];
    [noSignPath closePath];
    [noSignPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.78181 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.21819 * CGRectGetHeight(frame))];
    [noSignPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.78181 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.77681 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.93606 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.37245 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.93606 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.62255 * CGRectGetHeight(frame))];
    [noSignPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.22319 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.77681 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.62755 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.93106 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.37745 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.93106 * CGRectGetHeight(frame))];
    [noSignPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.22319 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.21819 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.06894 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.62255 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.06894 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.37245 * CGRectGetHeight(frame))];
    [noSignPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.78181 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.21819 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.37745 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.06394 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.62755 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.06394 * CGRectGetHeight(frame))];
    [noSignPath closePath];
    return noSignPath;
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

-(CAShapeLayer*) noSignLayer:(UIBezierPath*)arrowPath{
    CAShapeLayer* arrowsLayer = [CAShapeLayer layer];
    CGRect pathBounds = [arrowPath bounds];
    arrowsLayer.bounds = pathBounds;
    arrowsLayer.position = CGPointMake(pathBounds.origin.x + pathBounds.size.width/2, pathBounds.origin.y + pathBounds.size.height/2);
    
    arrowsLayer.path = arrowPath.CGPath;
    
    return arrowsLayer;
}

-(CAGradientLayer*)animatingGradientLayer:(UIBezierPath*)cloudPath{
    CAGradientLayer* cloudGradientLayer = [CAGradientLayer layer];
    cloudGradientLayer.bounds = [cloudPath bounds];
    cloudGradientLayer.anchorPoint = CGPointMake(0, 0);
    cloudGradientLayer.position = [cloudPath bounds].origin;
    
    //// Gradient Declarations
    CGFloat maxAlpha = .67;
    CGFloat minAlpha = .22;
    NSArray* allColors = @[];
    CGFloat maxColors = 10;
    UIColor* originalWhite = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    for (int i=0;i<maxColors;i++) {
        CGFloat angle = cosf(i / (maxColors*2) * M_PI);
        allColors = [allColors arrayByAddingObject:(id)[originalWhite colorWithAlphaComponent:minAlpha + angle*(maxAlpha - minAlpha)].CGColor];
    }
    
    cloudGradientLayer.colors = allColors;
    
    return cloudGradientLayer;
}

@end
