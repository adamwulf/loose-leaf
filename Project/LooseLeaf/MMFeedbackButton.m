//
//  MMFeedbackButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/26/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMFeedbackButton.h"
#import "UIView+Animations.h"
#import "Constants.h"


@implementation MMFeedbackButton

- (void)bounceButton:(id)sender {
    if (self.enabled) {
        self.center = self.center;
        [self bounceWithTransform:[self rotationTransform] stepOne:kMaxButtonBounceHeight / 2 stepTwo:kMinButtonBounceHeight / 2];
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();

    //// Color Declarations
    UIColor* darkerGreyBorder = [self borderColor];
    UIColor* halfGreyFill = [self backgroundColor];
    UIColor* barelyWhite = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.25];

    CGRect frame = [self drawableFrame];

    //// Oval
    UIBezierPath* ovalPath = [self ovalPath];
    [halfGreyFill setFill];
    [ovalPath fill];

    // oval clip
    UIBezierPath* circleClipPath = [UIBezierPath bezierPathWithRect:CGRectInfinite];
    [circleClipPath appendPath:ovalPath];
    circleClipPath.usesEvenOddFillRule = YES;


    //// speech bubble Drawing
    UIBezierPath* speechBubblePath = [UIBezierPath bezierPath];
    [speechBubblePath moveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.76250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.42500 * CGRectGetHeight(frame))];
    [speechBubblePath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.76250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.52500 * CGRectGetHeight(frame))];
    [speechBubblePath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.68932 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.62136 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.76250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.57094 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.73152 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.60964 * CGRectGetHeight(frame))];
    [speechBubblePath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.70000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.66250 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.69095 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.63285 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.69407 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.64767 * CGRectGetHeight(frame))];
    [speechBubblePath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.73750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.72500 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.71250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.69375 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.73750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.72500 * CGRectGetHeight(frame))];
    [speechBubblePath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.55750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.62500 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.73750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.72500 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.62316 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.66148 * CGRectGetHeight(frame))];
    [speechBubblePath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.33750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.62500 * CGRectGetHeight(frame))];
    [speechBubblePath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.23750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.52500 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.28227 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.62500 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.23750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.58023 * CGRectGetHeight(frame))];
    [speechBubblePath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.23750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.42500 * CGRectGetHeight(frame))];
    [speechBubblePath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.33750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.32500 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.23750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.36977 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.28227 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.32500 * CGRectGetHeight(frame))];
    [speechBubblePath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.66250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.32500 * CGRectGetHeight(frame))];
    [speechBubblePath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.76250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.42500 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.71773 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.32500 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.76250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.36977 * CGRectGetHeight(frame))];
    [speechBubblePath closePath];
    speechBubblePath.lineJoinStyle = kCGLineJoinBevel;
    speechBubblePath.lineWidth = 1;


    // hand
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setFill];
    [speechBubblePath fill];
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    [barelyWhite setFill];
    [speechBubblePath fill];
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setStroke];
    [speechBubblePath stroke];
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    [darkerGreyBorder setStroke];
    [speechBubblePath stroke];


    // stroke circle
    [darkerGreyBorder setStroke];
    ovalPath.lineWidth = 1;
    [ovalPath stroke];


    [self drawDropshadowIfSelected];

    [super drawRect:rect];
}

@end
