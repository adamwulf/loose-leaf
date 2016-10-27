//
//  MMImageIconView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/26/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMPolaroidView.h"


@implementation MMPolaroidView


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (UIBezierPath*)boundingRectForFrame:(CGRect)rect withInset:(CGFloat)inset {
    //// Outside border Drawing
    return [UIBezierPath bezierPathWithRect:CGRectInset(CGRectMake(CGRectGetMinX(rect) + floor(CGRectGetWidth(rect) * 0.10000 + 0.5), CGRectGetMinY(rect) + floor(CGRectGetHeight(rect) * 0.03333 + 0.5), floor(CGRectGetWidth(rect) * 0.90000 + 0.5) - floor(CGRectGetWidth(rect) * 0.10000 + 0.5), floor(CGRectGetHeight(rect) * 0.96667 + 0.5) - floor(CGRectGetHeight(rect) * 0.03333 + 0.5)), inset, inset)];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();

    //// Color Declarations
    UIColor* darkGrey = [UIColor colorWithRed:0.62 green:0.62 blue:0.62 alpha:0.549];
    UIColor* halfWhite = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.498];
    UIColor* darkerGrey = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.25];

    //// Gradient Declarations
    CGFloat faceGradientLocations[] = {0, 0.71, 1};
    CGGradientRef faceGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) @[(id)darkerGrey.CGColor, (id)[UIColor colorWithRed:0.282 green:0.282 blue:0.282 alpha:0.341].CGColor, (id)darkGrey.CGColor], faceGradientLocations);

    //// Outside border Drawing
    UIBezierPath* outsideBorderPath = [self boundingRectForFrame:rect withInset:-1];
    [halfWhite setFill];
    [outsideBorderPath fill];

    outsideBorderPath = [self boundingRectForFrame:rect withInset:0];
    outsideBorderPath.lineWidth = 2;
    CGFloat outsideBorderPattern[] = {6, 2};
    [outsideBorderPath setLineDash:outsideBorderPattern count:2 phase:3];

    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setFill];
    [outsideBorderPath stroke];
    CGContextSetBlendMode(context, kCGBlendModeNormal);

    [darkGrey setStroke];
    [outsideBorderPath stroke];


    //// Inside border Drawing
    UIBezierPath* insideBorderPath = [UIBezierPath bezierPathWithRect:CGRectMake(CGRectGetMinX(rect) + floor(CGRectGetWidth(rect) * 0.18333 + 0.5), CGRectGetMinY(rect) + floor(CGRectGetHeight(rect) * 0.10833 + 0.5), floor(CGRectGetWidth(rect) * 0.81667 + 0.5) - floor(CGRectGetWidth(rect) * 0.18333 + 0.5), floor(CGRectGetHeight(rect) * 0.75833 + 0.5) - floor(CGRectGetHeight(rect) * 0.10833 + 0.5))];
    [halfWhite setFill];
    [insideBorderPath fill];
    insideBorderPath.lineWidth = 2;
    CGFloat insideBorderPattern[] = {6, 2};
    [insideBorderPath setLineDash:insideBorderPattern count:2 phase:0];

    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setFill];
    [insideBorderPath stroke];
    CGContextSetBlendMode(context, kCGBlendModeNormal);

    [darkGrey setStroke];
    [insideBorderPath stroke];


    //// Left face Drawing
    UIBezierPath* leftFacePath = UIBezierPath.bezierPath;
    [leftFacePath moveToPoint:CGPointMake(CGRectGetMinX(rect) + 0.37788 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.32990 * CGRectGetHeight(rect))];
    [leftFacePath addCurveToPoint:CGPointMake(CGRectGetMinX(rect) + 0.41247 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.33239 * CGRectGetHeight(rect)) controlPoint1:CGPointMake(CGRectGetMinX(rect) + 0.38819 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.33017 * CGRectGetHeight(rect)) controlPoint2:CGPointMake(CGRectGetMinX(rect) + 0.39854 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.32866 * CGRectGetHeight(rect))];
    [leftFacePath addCurveToPoint:CGPointMake(CGRectGetMinX(rect) + 0.45830 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.36960 * CGRectGetHeight(rect)) controlPoint1:CGPointMake(CGRectGetMinX(rect) + 0.43955 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.33962 * CGRectGetHeight(rect)) controlPoint2:CGPointMake(CGRectGetMinX(rect) + 0.45821 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.35287 * CGRectGetHeight(rect))];
    [leftFacePath addCurveToPoint:CGPointMake(CGRectGetMinX(rect) + 0.45414 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.49365 * CGRectGetHeight(rect)) controlPoint1:CGPointMake(CGRectGetMinX(rect) + 0.45839 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.38634 * CGRectGetHeight(rect)) controlPoint2:CGPointMake(CGRectGetMinX(rect) + 0.46634 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.47314 * CGRectGetHeight(rect))];
    [leftFacePath addCurveToPoint:CGPointMake(CGRectGetMinX(rect) + 0.42914 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.53914 * CGRectGetHeight(rect)) controlPoint1:CGPointMake(CGRectGetMinX(rect) + 0.44193 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.51417 * CGRectGetHeight(rect)) controlPoint2:CGPointMake(CGRectGetMinX(rect) + 0.43552 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.51618 * CGRectGetHeight(rect))];
    [leftFacePath addCurveToPoint:CGPointMake(CGRectGetMinX(rect) + 0.47497 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.58463 * CGRectGetHeight(rect)) controlPoint1:CGPointMake(CGRectGetMinX(rect) + 0.42276 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.56210 * CGRectGetHeight(rect)) controlPoint2:CGPointMake(CGRectGetMinX(rect) + 0.45281 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.56958 * CGRectGetHeight(rect))];
    [leftFacePath addCurveToPoint:CGPointMake(CGRectGetMinX(rect) + 0.52995 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.61408 * CGRectGetHeight(rect)) controlPoint1:CGPointMake(CGRectGetMinX(rect) + 0.48713 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.59289 * CGRectGetHeight(rect)) controlPoint2:CGPointMake(CGRectGetMinX(rect) + 0.50974 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.60340 * CGRectGetHeight(rect))];
    [leftFacePath addCurveToPoint:CGPointMake(CGRectGetMinX(rect) + 0.47082 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.65719 * CGRectGetHeight(rect)) controlPoint1:CGPointMake(CGRectGetMinX(rect) + 0.50301 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.62638 * CGRectGetHeight(rect)) controlPoint2:CGPointMake(CGRectGetMinX(rect) + 0.47101 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.64193 * CGRectGetHeight(rect))];
    [leftFacePath addCurveToPoint:CGPointMake(CGRectGetMinX(rect) + 0.47082 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.75417 * CGRectGetHeight(rect)) controlPoint1:CGPointMake(CGRectGetMinX(rect) + 0.47052 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.68073 * CGRectGetHeight(rect)) controlPoint2:CGPointMake(CGRectGetMinX(rect) + 0.47082 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.75417 * CGRectGetHeight(rect))];
    [leftFacePath addLineToPoint:CGPointMake(CGRectGetMinX(rect) + 0.19583 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.75417 * CGRectGetHeight(rect))];
    [leftFacePath addCurveToPoint:CGPointMake(CGRectGetMinX(rect) + 0.19583 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.64665 * CGRectGetHeight(rect)) controlPoint1:CGPointMake(CGRectGetMinX(rect) + 0.19583 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.75417 * CGRectGetHeight(rect)) controlPoint2:CGPointMake(CGRectGetMinX(rect) + 0.19550 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.67275 * CGRectGetHeight(rect))];
    [leftFacePath addCurveToPoint:CGPointMake(CGRectGetMinX(rect) + 0.29999 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.58049 * CGRectGetHeight(rect)) controlPoint1:CGPointMake(CGRectGetMinX(rect) + 0.19617 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.62056 * CGRectGetHeight(rect)) controlPoint2:CGPointMake(CGRectGetMinX(rect) + 0.28151 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.59374 * CGRectGetHeight(rect))];
    [leftFacePath addCurveToPoint:CGPointMake(CGRectGetMinX(rect) + 0.33748 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.53501 * CGRectGetHeight(rect)) controlPoint1:CGPointMake(CGRectGetMinX(rect) + 0.31846 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.56724 * CGRectGetHeight(rect)) controlPoint2:CGPointMake(CGRectGetMinX(rect) + 0.34384 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.54468 * CGRectGetHeight(rect))];
    [leftFacePath addCurveToPoint:CGPointMake(CGRectGetMinX(rect) + 0.30832 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.48952 * CGRectGetHeight(rect)) controlPoint1:CGPointMake(CGRectGetMinX(rect) + 0.33113 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.52534 * CGRectGetHeight(rect)) controlPoint2:CGPointMake(CGRectGetMinX(rect) + 0.31701 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.51221 * CGRectGetHeight(rect))];
    [leftFacePath addCurveToPoint:CGPointMake(CGRectGetMinX(rect) + 0.30832 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.37374 * CGRectGetHeight(rect)) controlPoint1:CGPointMake(CGRectGetMinX(rect) + 0.29963 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.46683 * CGRectGetHeight(rect)) controlPoint2:CGPointMake(CGRectGetMinX(rect) + 0.30694 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.39428 * CGRectGetHeight(rect))];
    [leftFacePath addCurveToPoint:CGPointMake(CGRectGetMinX(rect) + 0.34581 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.33239 * CGRectGetHeight(rect)) controlPoint1:CGPointMake(CGRectGetMinX(rect) + 0.30970 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.35320 * CGRectGetHeight(rect)) controlPoint2:CGPointMake(CGRectGetMinX(rect) + 0.31978 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.34272 * CGRectGetHeight(rect))];
    [leftFacePath addCurveToPoint:CGPointMake(CGRectGetMinX(rect) + 0.37788 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.32990 * CGRectGetHeight(rect)) controlPoint1:CGPointMake(CGRectGetMinX(rect) + 0.35846 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.32737 * CGRectGetHeight(rect)) controlPoint2:CGPointMake(CGRectGetMinX(rect) + 0.36815 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.32965 * CGRectGetHeight(rect))];
    [leftFacePath closePath];
    CGContextSaveGState(context);
    [leftFacePath addClip];
    UIBezierPath* leftFaceRotatedPath = [leftFacePath copy];
    CGAffineTransform leftFaceTransform = CGAffineTransformMakeRotation(-135 * (-M_PI / 180));
    [leftFaceRotatedPath applyTransform:leftFaceTransform];
    CGRect leftFaceBounds = CGPathGetPathBoundingBox(leftFaceRotatedPath.CGPath);
    leftFaceTransform = CGAffineTransformInvert(leftFaceTransform);

    CGContextDrawLinearGradient(context, faceGradient,
                                CGPointApplyAffineTransform(CGPointMake(CGRectGetMinX(leftFaceBounds), CGRectGetMidY(leftFaceBounds)), leftFaceTransform),
                                CGPointApplyAffineTransform(CGPointMake(CGRectGetMaxX(leftFaceBounds), CGRectGetMidY(leftFaceBounds)), leftFaceTransform),
                                0);
    CGContextRestoreGState(context);
    leftFacePath.lineWidth = 1;
    CGFloat leftFacePattern[] = {4, 2};
    [leftFacePath setLineDash:leftFacePattern count:2 phase:0];

    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setFill];
    [leftFacePath stroke];
    CGContextSetBlendMode(context, kCGBlendModeNormal);

    [darkerGrey setStroke];
    [leftFacePath stroke];


    //// Right face Drawing
    UIBezierPath* rightFacePath = UIBezierPath.bezierPath;
    [rightFacePath moveToPoint:CGPointMake(CGRectGetMinX(rect) + 0.47915 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.75417 * CGRectGetHeight(rect))];
    [rightFacePath addCurveToPoint:CGPointMake(CGRectGetMinX(rect) + 0.47915 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.65719 * CGRectGetHeight(rect)) controlPoint1:CGPointMake(CGRectGetMinX(rect) + 0.47915 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.75417 * CGRectGetHeight(rect)) controlPoint2:CGPointMake(CGRectGetMinX(rect) + 0.47885 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.68073 * CGRectGetHeight(rect))];
    [rightFacePath addCurveToPoint:CGPointMake(CGRectGetMinX(rect) + 0.57174 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.59752 * CGRectGetHeight(rect)) controlPoint1:CGPointMake(CGRectGetMinX(rect) + 0.47945 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.63366 * CGRectGetHeight(rect)) controlPoint2:CGPointMake(CGRectGetMinX(rect) + 0.55531 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.60947 * CGRectGetHeight(rect))];
    [rightFacePath addCurveToPoint:CGPointMake(CGRectGetMinX(rect) + 0.60507 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.55649 * CGRectGetHeight(rect)) controlPoint1:CGPointMake(CGRectGetMinX(rect) + 0.58816 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.58557 * CGRectGetHeight(rect)) controlPoint2:CGPointMake(CGRectGetMinX(rect) + 0.61072 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.56521 * CGRectGetHeight(rect))];
    [rightFacePath addCurveToPoint:CGPointMake(CGRectGetMinX(rect) + 0.57914 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.51547 * CGRectGetHeight(rect)) controlPoint1:CGPointMake(CGRectGetMinX(rect) + 0.59942 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.54777 * CGRectGetHeight(rect)) controlPoint2:CGPointMake(CGRectGetMinX(rect) + 0.58687 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.53594 * CGRectGetHeight(rect))];
    [rightFacePath addCurveToPoint:CGPointMake(CGRectGetMinX(rect) + 0.57914 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.41103 * CGRectGetHeight(rect)) controlPoint1:CGPointMake(CGRectGetMinX(rect) + 0.57142 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.49500 * CGRectGetHeight(rect)) controlPoint2:CGPointMake(CGRectGetMinX(rect) + 0.57791 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.42956 * CGRectGetHeight(rect))];
    [rightFacePath addCurveToPoint:CGPointMake(CGRectGetMinX(rect) + 0.61247 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.37374 * CGRectGetHeight(rect)) controlPoint1:CGPointMake(CGRectGetMinX(rect) + 0.58037 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.39251 * CGRectGetHeight(rect)) controlPoint2:CGPointMake(CGRectGetMinX(rect) + 0.58933 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.38306 * CGRectGetHeight(rect))];
    [rightFacePath addCurveToPoint:CGPointMake(CGRectGetMinX(rect) + 0.64098 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.37150 * CGRectGetHeight(rect)) controlPoint1:CGPointMake(CGRectGetMinX(rect) + 0.62371 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.36921 * CGRectGetHeight(rect)) controlPoint2:CGPointMake(CGRectGetMinX(rect) + 0.63233 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.37127 * CGRectGetHeight(rect))];
    [rightFacePath addCurveToPoint:CGPointMake(CGRectGetMinX(rect) + 0.67173 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.37374 * CGRectGetHeight(rect)) controlPoint1:CGPointMake(CGRectGetMinX(rect) + 0.65015 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.37174 * CGRectGetHeight(rect)) controlPoint2:CGPointMake(CGRectGetMinX(rect) + 0.65934 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.37038 * CGRectGetHeight(rect))];
    [rightFacePath addCurveToPoint:CGPointMake(CGRectGetMinX(rect) + 0.71247 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.40730 * CGRectGetHeight(rect)) controlPoint1:CGPointMake(CGRectGetMinX(rect) + 0.69580 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.38026 * CGRectGetHeight(rect)) controlPoint2:CGPointMake(CGRectGetMinX(rect) + 0.71239 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.39221 * CGRectGetHeight(rect))];
    [rightFacePath addCurveToPoint:CGPointMake(CGRectGetMinX(rect) + 0.70876 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.51920 * CGRectGetHeight(rect)) controlPoint1:CGPointMake(CGRectGetMinX(rect) + 0.71254 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.42240 * CGRectGetHeight(rect)) controlPoint2:CGPointMake(CGRectGetMinX(rect) + 0.71961 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.50069 * CGRectGetHeight(rect))];
    [rightFacePath addCurveToPoint:CGPointMake(CGRectGetMinX(rect) + 0.68654 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.56022 * CGRectGetHeight(rect)) controlPoint1:CGPointMake(CGRectGetMinX(rect) + 0.69791 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.53770 * CGRectGetHeight(rect)) controlPoint2:CGPointMake(CGRectGetMinX(rect) + 0.69222 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.53951 * CGRectGetHeight(rect))];
    [rightFacePath addCurveToPoint:CGPointMake(CGRectGetMinX(rect) + 0.72728 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.60125 * CGRectGetHeight(rect)) controlPoint1:CGPointMake(CGRectGetMinX(rect) + 0.68087 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.58093 * CGRectGetHeight(rect)) controlPoint2:CGPointMake(CGRectGetMinX(rect) + 0.70758 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.58768 * CGRectGetHeight(rect))];
    [rightFacePath addCurveToPoint:CGPointMake(CGRectGetMinX(rect) + 0.81246 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.65719 * CGRectGetHeight(rect)) controlPoint1:CGPointMake(CGRectGetMinX(rect) + 0.74976 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.61673 * CGRectGetHeight(rect)) controlPoint2:CGPointMake(CGRectGetMinX(rect) + 0.81232 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.64098 * CGRectGetHeight(rect))];
    [rightFacePath addCurveToPoint:CGPointMake(CGRectGetMinX(rect) + 0.81246 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.75417 * CGRectGetHeight(rect)) controlPoint1:CGPointMake(CGRectGetMinX(rect) + 0.81255 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.66822 * CGRectGetHeight(rect)) controlPoint2:CGPointMake(CGRectGetMinX(rect) + 0.81246 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.75417 * CGRectGetHeight(rect))];
    [rightFacePath addLineToPoint:CGPointMake(CGRectGetMinX(rect) + 0.47915 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.75417 * CGRectGetHeight(rect))];
    [rightFacePath closePath];
    CGContextSaveGState(context);
    [rightFacePath addClip];
    UIBezierPath* rightFaceRotatedPath = [rightFacePath copy];
    CGAffineTransform rightFaceTransform = CGAffineTransformMakeRotation(-135 * (-M_PI / 180));
    [rightFaceRotatedPath applyTransform:rightFaceTransform];
    CGRect rightFaceBounds = CGPathGetPathBoundingBox(rightFaceRotatedPath.CGPath);
    rightFaceTransform = CGAffineTransformInvert(rightFaceTransform);

    CGContextDrawLinearGradient(context, faceGradient,
                                CGPointApplyAffineTransform(CGPointMake(CGRectGetMinX(rightFaceBounds), CGRectGetMidY(rightFaceBounds)), rightFaceTransform),
                                CGPointApplyAffineTransform(CGPointMake(CGRectGetMaxX(rightFaceBounds), CGRectGetMidY(rightFaceBounds)), rightFaceTransform),
                                0);
    CGContextRestoreGState(context);

    rightFacePath.lineWidth = 1;
    CGFloat rightFacePattern[] = {4, 2};
    [rightFacePath setLineDash:rightFacePattern count:2 phase:0];

    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setFill];
    [rightFacePath stroke];
    CGContextSetBlendMode(context, kCGBlendModeNormal);

    [darkerGrey setStroke];
    [rightFacePath stroke];


    //// Cleanup
    CGGradientRelease(faceGradient);
    CGColorSpaceRelease(colorSpace);
}


@end
