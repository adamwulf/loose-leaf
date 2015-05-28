//
//  MMScissorButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 6/7/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMScissorButton.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"

@implementation MMScissorButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();

    //// Color Declarations
    UIColor* darkerGreyBorder = [self borderColor];
    UIColor* halfGreyFill = [self backgroundColor];
    
    CGRect frame = [self drawableFrame];
    
    //// Oval
    UIBezierPath* ovalPath = [self ovalPath];
    [halfGreyFill setFill];
    [ovalPath fill];
    [darkerGreyBorder setStroke];
    ovalPath.lineWidth = 1;
    [ovalPath stroke];
    
    //// Scissors Drawing
    UIBezierPath* scissorsPath = [UIBezierPath bezierPath];
    [scissorsPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.81850 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.58087 * CGRectGetHeight(frame))];
    [scissorsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.78605 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.60143 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.80763 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.59029 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.79681 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.59715 * CGRectGetHeight(frame))];
    [scissorsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.75083 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.60786 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.77529 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.60572 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.76355 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.60786 * CGRectGetHeight(frame))];
    [scissorsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.65349 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.58697 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.73232 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.60786 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.69987 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.60090 * CGRectGetHeight(frame))];
    [scissorsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.45654 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.51916 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.60710 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.57304 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.54145 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.55044 * CGRectGetHeight(frame))];
    [scissorsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.36545 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.54535 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.42693 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.53094 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.39657 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.53967 * CGRectGetHeight(frame))];
    [scissorsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.31877 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.55772 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.33433 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.55103 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.31877 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.55515 * CGRectGetHeight(frame))];
    [scissorsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.31895 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.55965 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.31877 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.55858 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.31883 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.55922 * CGRectGetHeight(frame))];
    [scissorsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.31947 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.56062 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.31906 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.56008 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.31923 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.56040 * CGRectGetHeight(frame))];
    [scissorsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.32866 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.58119 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.32363 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.56790 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.32670 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.57476 * CGRectGetHeight(frame))];
    [scissorsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.33161 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.60015 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.33063 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.58761 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.33161 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.59394 * CGRectGetHeight(frame))];
    [scissorsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.31027 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.64466 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.33161 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.61793 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.32450 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.63277 * CGRectGetHeight(frame))];
    [scissorsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.25631 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.66250 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.29604 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.65655 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.27805 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.66250 * CGRectGetHeight(frame))];
    [scissorsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.20200 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.64354 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.23410 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.66250 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.21599 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.65618 * CGRectGetHeight(frame))];
    [scissorsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.18100 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.59469 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.18800 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.63090 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.18100 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.61461 * CGRectGetHeight(frame))];
    [scissorsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.20755 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.54632 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.18100 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.57369 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.18985 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.55756 * CGRectGetHeight(frame))];
    [scissorsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.28407 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.52944 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.22525 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.53507 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.25075 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.52944 * CGRectGetHeight(frame))];
    [scissorsPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.31218 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.52944 * CGRectGetHeight(frame))];
    [scissorsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.37933 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.52012 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.34318 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.52944 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.36556 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.52634 * CGRectGetHeight(frame))];
    [scissorsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.40831 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.48734 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.39310 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.51391 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.40275 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.50298 * CGRectGetHeight(frame))];
    [scissorsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.37933 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.45472 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.40299 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.47191 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.39333 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.46104 * CGRectGetHeight(frame))];
    [scissorsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.31218 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.44524 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.36533 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.44840 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.34295 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.44524 * CGRectGetHeight(frame))];
    [scissorsPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.28407 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.44524 * CGRectGetHeight(frame))];
    [scissorsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.20755 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.42852 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.25075 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.44524 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.22525 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.43967 * CGRectGetHeight(frame))];
    [scissorsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.18100 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.38031 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.18985 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.41738 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.18100 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.40131 * CGRectGetHeight(frame))];
    [scissorsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.20200 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.33146 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.18100 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.36039 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.18800 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34410 * CGRectGetHeight(frame))];
    [scissorsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.25631 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31250 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.21599 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31882 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.23410 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31250 * CGRectGetHeight(frame))];
    [scissorsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.31027 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.33034 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.27805 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31250 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.29604 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31845 * CGRectGetHeight(frame))];
    [scissorsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.33161 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.37485 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.32450 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34223 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.33161 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.35707 * CGRectGetHeight(frame))];
    [scissorsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.32866 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.39381 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.33161 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.38106 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.33063 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.38739 * CGRectGetHeight(frame))];
    [scissorsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.31947 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.41438 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.32670 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.40024 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.32363 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.40710 * CGRectGetHeight(frame))];
    [scissorsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.31895 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.41567 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.31923 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.41481 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.31906 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.41524 * CGRectGetHeight(frame))];
    [scissorsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.31877 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.41695 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.31883 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.41610 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.31877 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.41653 * CGRectGetHeight(frame))];
    [scissorsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.36545 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.42965 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.31877 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.41974 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.33433 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.42397 * CGRectGetHeight(frame))];
    [scissorsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.45654 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.45584 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.39657 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.43533 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.42693 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.44406 * CGRectGetHeight(frame))];
    [scissorsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.65591 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.38739 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.54446 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.42370 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.61092 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.40088 * CGRectGetHeight(frame))];
    [scissorsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.75083 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.36714 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.70091 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.37389 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.73255 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.36714 * CGRectGetHeight(frame))];
    [scissorsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.78605 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.37357 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.76332 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.36714 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.77506 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.36928 * CGRectGetHeight(frame))];
    [scissorsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.81850 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.39413 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.79704 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.37785 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.80786 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.38471 * CGRectGetHeight(frame))];
    [scissorsPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.54816 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.48734 * CGRectGetHeight(frame))];
    [scissorsPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.81850 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.58087 * CGRectGetHeight(frame))];
    [scissorsPath closePath];
    [scissorsPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.30871 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.37871 * CGRectGetHeight(frame))];
    [scissorsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.29379 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34641 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.30871 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.36585 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.30373 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.35508 * CGRectGetHeight(frame))];
    [scissorsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.25631 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.33339 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.28384 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.33773 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.27134 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.33339 * CGRectGetHeight(frame))];
    [scissorsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.21865 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34576 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.24081 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.33339 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.22825 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.33752 * CGRectGetHeight(frame))];
    [scissorsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.20425 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.37742 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.20905 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.35401 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.20425 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.36457 * CGRectGetHeight(frame))];
    [scissorsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.21952 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.41069 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.20425 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.39092 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.20934 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.40201 * CGRectGetHeight(frame))];
    [scissorsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.25908 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.42370 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.22970 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.41936 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.24289 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.42370 * CGRectGetHeight(frame))];
    [scissorsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.29500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.41117 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.27389 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.42370 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.28586 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.41952 * CGRectGetHeight(frame))];
    [scissorsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.30871 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.37871 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.30414 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.40281 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.30871 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.39199 * CGRectGetHeight(frame))];
    [scissorsPath closePath];
    [scissorsPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.30871 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.59597 * CGRectGetHeight(frame))];
    [scissorsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.29483 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.56383 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.30871 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.58290 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.30408 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.57219 * CGRectGetHeight(frame))];
    [scissorsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.25908 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.55130 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.28557 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.55548 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.27366 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.55130 * CGRectGetHeight(frame))];
    [scissorsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.21987 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.56447 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.24335 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.55130 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.23028 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.55569 * CGRectGetHeight(frame))];
    [scissorsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.20425 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.59726 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.20946 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.57326 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.20425 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.58419 * CGRectGetHeight(frame))];
    [scissorsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.21865 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.62924 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.20425 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.61033 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.20905 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.62099 * CGRectGetHeight(frame))];
    [scissorsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.25631 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.64161 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.22825 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.63748 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.24081 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.64161 * CGRectGetHeight(frame))];
    [scissorsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.29379 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.62859 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.27134 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.64161 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.28384 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.63727 * CGRectGetHeight(frame))];
    [scissorsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.30871 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.59597 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.30373 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.61992 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.30871 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.60904 * CGRectGetHeight(frame))];
    [scissorsPath closePath];

    [darkerGreyBorder setStroke];
    scissorsPath.lineWidth = 1;
    [scissorsPath stroke];

    //
    // clear the arrow and box, then fill with
    // border color
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setFill];
    [scissorsPath fill];
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    
    [darkerGreyBorder setFill];
    [scissorsPath fill];

//    [self drawDropshadowIfSelected];

    [super drawRect:rect];
}

@end
