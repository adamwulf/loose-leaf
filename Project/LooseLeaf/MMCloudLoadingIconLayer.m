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

- (id)initWithFrame:(CGRect)frame {
    if (self = [super init]) {
        // setup our size
        self.bounds = CGRectMake(0, 0, frame.size.width, frame.size.height);

        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor].CGColor;

        UIBezierPath* cloudPath = [self cloudPathForRect:self.bounds];
        CAShapeLayer* cloudBorderLayer = [self cloudBorderLayerForPath:cloudPath];
        UIColor* borderColor = [UIColor colorWithRed:0.221 green:0.221 blue:0.219 alpha:1];
        UIColor* halfWhite = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.503];
        cloudBorderLayer.strokeColor = borderColor.CGColor;
        cloudBorderLayer.lineWidth = 1;
        cloudBorderLayer.fillColor = [UIColor clearColor].CGColor;

        CAShapeLayer* cloudMaskLayer = [self cloudBorderLayerForPath:cloudPath];
        CAGradientLayer* gradientLayer = [self animatingGradientLayer:cloudPath];
        gradientLayer.mask = cloudMaskLayer;

        [self addSublayer:gradientLayer];
        [self addSublayer:cloudBorderLayer];

        UIBezierPath* arrowsPath = [self arrowPathForRect:self.bounds];
        CAShapeLayer* animatingArrowsLayer = [self animatingArrowsLayer:arrowsPath];
        animatingArrowsLayer.strokeColor = borderColor.CGColor;
        animatingArrowsLayer.lineWidth = 1;
        animatingArrowsLayer.fillColor = halfWhite.CGColor;
        [self addSublayer:animatingArrowsLayer];

        // setup our location
        self.position = CGPointMake(frame.origin.x + frame.size.width / 2, frame.origin.y + frame.size.height / 2);
    }
    return self;
}

- (UIBezierPath*)arrowPathForRect:(CGRect)frame {
    //// CircleArrows Drawing
    UIBezierPath* circleArrowsPath = UIBezierPath.bezierPath;
    [circleArrowsPath moveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.56502 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24312 * CGRectGetHeight(frame))];
    [circleArrowsPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.58499 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.27222 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.57367 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.25177 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.58033 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26166 * CGRectGetHeight(frame))];
    [circleArrowsPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.60928 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26089 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.59862 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26586 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.60928 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26089 * CGRectGetHeight(frame))];
    [circleArrowsPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.59299 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.30565 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.60928 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26089 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.59948 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.28783 * CGRectGetHeight(frame))];
    [circleArrowsPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.59314 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31100 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.59309 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.30743 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.59314 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.30921 * CGRectGetHeight(frame))];
    [circleArrowsPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.59104 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31100 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.59314 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31100 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.59236 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31100 * CGRectGetHeight(frame))];
    [circleArrowsPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.58739 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.32103 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.58886 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31699 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.58739 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.32103 * CGRectGetHeight(frame))];
    [circleArrowsPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.52725 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.29914 * CGRectGetHeight(frame))];
    [circleArrowsPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.55597 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.28575 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.52725 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.29914 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.54029 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.29306 * CGRectGetHeight(frame))];
    [circleArrowsPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.54240 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26575 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.55285 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.27848 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.54833 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.27168 * CGRectGetHeight(frame))];
    [circleArrowsPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.45189 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26575 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.51740 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24075 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.47688 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24075 * CGRectGetHeight(frame))];
    [circleArrowsPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.43516 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.29500 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.44349 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.27414 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.43792 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.28428 * CGRectGetHeight(frame))];
    [circleArrowsPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.40248 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.29500 * CGRectGetHeight(frame))];
    [circleArrowsPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.42926 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24312 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.40567 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.27600 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.41460 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.25778 * CGRectGetHeight(frame))];
    [circleArrowsPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.56502 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24312 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.46675 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.20563 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.52753 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.20563 * CGRectGetHeight(frame))];
    [circleArrowsPath closePath];
    [circleArrowsPath moveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.40689 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.30097 * CGRectGetHeight(frame))];
    [circleArrowsPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.46703 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.32286 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.40689 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.30097 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.46703 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.32286 * CGRectGetHeight(frame))];
    [circleArrowsPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.43831 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.33625 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.46703 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.32286 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.45399 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.32894 * CGRectGetHeight(frame))];
    [circleArrowsPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.45189 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.35625 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.44143 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34352 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.44595 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.35032 * CGRectGetHeight(frame))];
    [circleArrowsPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.54240 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.35625 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.47688 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.38125 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.51740 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.38125 * CGRectGetHeight(frame))];
    [circleArrowsPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.55912 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.32700 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.55079 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34786 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.55636 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.33772 * CGRectGetHeight(frame))];
    [circleArrowsPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.59181 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.32700 * CGRectGetHeight(frame))];
    [circleArrowsPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.56502 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.37888 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.58861 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34600 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.57968 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.36422 * CGRectGetHeight(frame))];
    [circleArrowsPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.42926 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.37888 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.52753 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.41637 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.46675 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.41637 * CGRectGetHeight(frame))];
    [circleArrowsPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.40929 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34978 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.42061 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.37023 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.41395 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.36034 * CGRectGetHeight(frame))];
    [circleArrowsPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.38500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.36111 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.39566 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.35614 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.38500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.36111 * CGRectGetHeight(frame))];
    [circleArrowsPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.40129 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31635 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.38500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.36111 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.39480 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.33417 * CGRectGetHeight(frame))];
    [circleArrowsPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.40114 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31100 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.40119 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31457 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.40114 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31279 * CGRectGetHeight(frame))];
    [circleArrowsPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.40324 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31100 * CGRectGetHeight(frame))];
    [circleArrowsPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.40689 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.30097 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.40542 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.30501 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.40689 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.30097 * CGRectGetHeight(frame))];
    [circleArrowsPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.40689 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.30097 * CGRectGetHeight(frame))];
    [circleArrowsPath closePath];
    return circleArrowsPath;
}

- (UIBezierPath*)cloudPathForRect:(CGRect)frame {
    UIBezierPath* cloudPath = UIBezierPath.bezierPath;
    [cloudPath moveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.28168 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.45133 * CGRectGetHeight(frame))];
    [cloudPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.20000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34489 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.28168 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.45133 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.19979 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.43804 * CGRectGetHeight(frame))];
    [cloudPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.27623 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24703 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.20018 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26589 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.27623 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24703 * CGRectGetHeight(frame))];
    [cloudPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.34811 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.16914 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.27623 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24703 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.27532 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17139 * CGRectGetHeight(frame))];
    [cloudPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.40012 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.18836 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.36631 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.16858 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.40012 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.18836 * CGRectGetHeight(frame))];
    [cloudPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.54737 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09001 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.40012 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.18836 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.44741 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.08877 * CGRectGetHeight(frame))];
    [cloudPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.70129 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.25766 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.70426 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09196 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.70129 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.25766 * CGRectGetHeight(frame))];
    [cloudPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.79500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.35854 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.70129 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.25766 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.79690 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26594 * CGRectGetHeight(frame))];
    [cloudPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.71059 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.45133 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.79309 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.45114 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.71059 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.45133 * CGRectGetHeight(frame))];
    [cloudPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.28168 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.45133 * CGRectGetHeight(frame))];
    [cloudPath closePath];
    return cloudPath;
}

- (CAShapeLayer*)cloudBorderLayerForPath:(UIBezierPath*)cloudPath {
    CAShapeLayer* cloudBorderLayer = [CAShapeLayer layer];
    cloudBorderLayer.bounds = self.bounds;
    cloudBorderLayer.path = cloudPath.CGPath;
    cloudBorderLayer.anchorPoint = CGPointMake(0, 0);
    cloudBorderLayer.position = CGPointMake(0, 0);
    return cloudBorderLayer;
}

- (CAShapeLayer*)animatingArrowsLayer:(UIBezierPath*)arrowPath {
    CAShapeLayer* arrowsLayer = [CAShapeLayer layer];
    CGRect pathBounds = [arrowPath bounds];
    arrowsLayer.bounds = pathBounds;
    //    arrowsLayer.anchorPoint = CGPointMake(.5, .5);
    arrowsLayer.position = CGPointMake(pathBounds.origin.x + pathBounds.size.width / 2, pathBounds.origin.y + pathBounds.size.height / 2);

    arrowsLayer.path = arrowPath.CGPath;

    CABasicAnimation* rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.fromValue = @(0);
    rotateAnimation.toValue = @(2 * M_PI);
    rotateAnimation.removedOnCompletion = NO;
    rotateAnimation.duration = 1.5f;
    rotateAnimation.repeatCount = HUGE_VALF; // repeat forever
    [arrowsLayer addAnimation:rotateAnimation forKey:@"rotateAnimation"];

    return arrowsLayer;
}

- (CAGradientLayer*)animatingGradientLayer:(UIBezierPath*)cloudPath {
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
    for (int i = 0; i < maxColors; i++) {
        CGFloat angle = cosf(i / (maxColors * 2) * M_PI);
        allColors = [allColors arrayByAddingObject:(id)[originalWhite colorWithAlphaComponent:minAlpha + angle * (maxAlpha - minAlpha)].CGColor];
    }

    cloudGradientLayer.colors = allColors;

    return cloudGradientLayer;
}


@end
