//
//  UIBezierPath+MMShapes.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/27/18.
//  Copyright © 2018 Milestone Made, LLC. All rights reserved.
//

#import "UIBezierPath+MMShapes.h"


@implementation UIBezierPath (MMShapes)

+ (UIBezierPath*)pentagonPath {
    UIBezierPath* pentagonPath = [UIBezierPath bezierPath];
    [pentagonPath moveToPoint:CGPointMake(250.5, 0)];
    [pentagonPath addLineToPoint:CGPointMake(500.15, 181.38)];
    [pentagonPath addLineToPoint:CGPointMake(404.79, 474.87)];
    [pentagonPath addLineToPoint:CGPointMake(96.21, 474.87)];
    [pentagonPath addLineToPoint:CGPointMake(0.85, 181.38)];
    [pentagonPath closePath];

    return pentagonPath;
}

+ (UIBezierPath*)trianglePath {
    UIBezierPath* trianglePath = [UIBezierPath bezierPath];
    [trianglePath moveToPoint:CGPointMake(249.5, 0)];
    [trianglePath addLineToPoint:CGPointMake(497.62, 429.75)];
    [trianglePath addLineToPoint:CGPointMake(1.38, 429.75)];
    [trianglePath closePath];
    return trianglePath;
}

+ (UIBezierPath*)hexagonPath {
    UIBezierPath* hexagonPath = [UIBezierPath bezierPath];
    [hexagonPath moveToPoint:CGPointMake(217, 0)];
    [hexagonPath addLineToPoint:CGPointMake(433.51, 125)];
    [hexagonPath addLineToPoint:CGPointMake(433.51, 375)];
    [hexagonPath addLineToPoint:CGPointMake(217, 500)];
    [hexagonPath addLineToPoint:CGPointMake(0.49, 375)];
    [hexagonPath addLineToPoint:CGPointMake(0.49, 125)];
    [hexagonPath closePath];
    return hexagonPath;
}

+ (UIBezierPath*)octagonPath {
    UIBezierPath* octagonPath = [UIBezierPath bezierPath];
    [octagonPath moveToPoint:CGPointMake(154.33, 19.03)];
    [octagonPath addLineToPoint:CGPointMake(345.67, 19.03)];
    [octagonPath addLineToPoint:CGPointMake(480.97, 154.33)];
    [octagonPath addLineToPoint:CGPointMake(480.97, 345.67)];
    [octagonPath addLineToPoint:CGPointMake(345.67, 480.97)];
    [octagonPath addLineToPoint:CGPointMake(154.33, 480.97)];
    [octagonPath addLineToPoint:CGPointMake(19.03, 345.67)];
    [octagonPath addLineToPoint:CGPointMake(19.03, 154.33)];
    [octagonPath addLineToPoint:CGPointMake(154.33, 19.03)];
    [octagonPath closePath];
    return octagonPath;
}

+ (UIBezierPath*)rombusPath {
    UIBezierPath* rombusPath = [UIBezierPath bezierPath];
    [rombusPath moveToPoint:CGPointMake(350, 250)];
    [rombusPath addLineToPoint:CGPointMake(175, 500)];
    [rombusPath addLineToPoint:CGPointMake(0, 250)];
    [rombusPath addLineToPoint:CGPointMake(175.01, 0)];
    [rombusPath addLineToPoint:CGPointMake(350, 250)];
    [rombusPath closePath];
    return rombusPath;
}

+ (UIBezierPath*)starPath {
    UIBezierPath* starPath = [UIBezierPath bezierPath];
    [starPath moveToPoint:CGPointMake(250, 0)];
    [starPath addLineToPoint:CGPointMake(308.57, 169.38)];
    [starPath addLineToPoint:CGPointMake(487.76, 172.75)];
    [starPath addLineToPoint:CGPointMake(344.77, 280.79)];
    [starPath addLineToPoint:CGPointMake(396.95, 452.25)];
    [starPath addLineToPoint:CGPointMake(250, 349.65)];
    [starPath addLineToPoint:CGPointMake(103.05, 452.25)];
    [starPath addLineToPoint:CGPointMake(155.23, 280.79)];
    [starPath addLineToPoint:CGPointMake(12.24, 172.75)];
    [starPath addLineToPoint:CGPointMake(191.43, 169.38)];
    [starPath closePath];
    return starPath;
}

+ (UIBezierPath*)star2Path {
    UIBezierPath* star2Path = [UIBezierPath bezierPath];
    [star2Path moveToPoint:CGPointMake(250, 0)];
    [star2Path addLineToPoint:CGPointMake(307.28, 111.71)];
    [star2Path addLineToPoint:CGPointMake(426.78, 73.22)];
    [star2Path addLineToPoint:CGPointMake(388.29, 192.72)];
    [star2Path addLineToPoint:CGPointMake(500, 250)];
    [star2Path addLineToPoint:CGPointMake(388.29, 307.28)];
    [star2Path addLineToPoint:CGPointMake(426.78, 426.78)];
    [star2Path addLineToPoint:CGPointMake(307.28, 388.29)];
    [star2Path addLineToPoint:CGPointMake(250, 500)];
    [star2Path addLineToPoint:CGPointMake(192.72, 388.29)];
    [star2Path addLineToPoint:CGPointMake(73.22, 426.78)];
    [star2Path addLineToPoint:CGPointMake(111.71, 307.28)];
    [star2Path addLineToPoint:CGPointMake(0, 250)];
    [star2Path addLineToPoint:CGPointMake(111.71, 192.72)];
    [star2Path addLineToPoint:CGPointMake(73.22, 73.22)];
    [star2Path addLineToPoint:CGPointMake(192.72, 111.71)];
    [star2Path closePath];
    return star2Path;
}

+ (UIBezierPath*)star3Path {
    UIBezierPath* star3Path = [UIBezierPath bezierPath];
    [star3Path moveToPoint:CGPointMake(250, 0)];
    [star3Path addLineToPoint:CGPointMake(320.98, 179.02)];
    [star3Path addLineToPoint:CGPointMake(500, 250)];
    [star3Path addLineToPoint:CGPointMake(320.98, 320.98)];
    [star3Path addLineToPoint:CGPointMake(250, 500)];
    [star3Path addLineToPoint:CGPointMake(179.02, 320.98)];
    [star3Path addLineToPoint:CGPointMake(0, 250)];
    [star3Path addLineToPoint:CGPointMake(179.02, 179.02)];
    [star3Path closePath];
    return star3Path;
}

+ (UIBezierPath*)trekPath {
    UIBezierPath* trekPath = [UIBezierPath bezierPath];
    [trekPath moveToPoint:CGPointMake(147, 0)];
    [trekPath addLineToPoint:CGPointMake(0, 450)];
    [trekPath addLineToPoint:CGPointMake(147, 347)];
    [trekPath addLineToPoint:CGPointMake(294, 450)];
    [trekPath addLineToPoint:CGPointMake(147, 0)];
    [trekPath closePath];
    return trekPath;
}

+ (UIBezierPath*)locationPath {
    UIBezierPath* locationPath = [UIBezierPath bezierPath];
    [locationPath moveToPoint:CGPointMake(265, 135.32)];
    [locationPath addCurveToPoint:CGPointMake(253.77, 189.15) controlPoint1:CGPointMake(265, 154.49) controlPoint2:CGPointMake(261.11, 172.7)];
    [locationPath addCurveToPoint:CGPointMake(132.52, 493) controlPoint1:CGPointMake(253.77, 189.15) controlPoint2:CGPointMake(133.89, 489.55)];
    [locationPath addCurveToPoint:CGPointMake(11.42, 189.15) controlPoint1:CGPointMake(132.5, 493.04) controlPoint2:CGPointMake(11.42, 189.15)];
    [locationPath addCurveToPoint:CGPointMake(0, 135.32) controlPoint1:CGPointMake(4.08, 172.71) controlPoint2:CGPointMake(0, 154.49)];
    [locationPath addCurveToPoint:CGPointMake(23.56, 59.98) controlPoint1:CGPointMake(0, 107.33) controlPoint2:CGPointMake(8.71, 81.36)];
    [locationPath addCurveToPoint:CGPointMake(132.5, 3) controlPoint1:CGPointMake(47.49, 25.55) controlPoint2:CGPointMake(87.36, 3)];
    [locationPath addCurveToPoint:CGPointMake(265, 135.32) controlPoint1:CGPointMake(205.68, 3) controlPoint2:CGPointMake(265, 62.24)];
    [locationPath closePath];
    return locationPath;
}

+ (UIBezierPath*)tetrisPath {
    return [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 125, 500)];
}

+ (UIBezierPath*)lPath {
    UIBezierPath* lPath = [UIBezierPath bezierPath];
    [lPath moveToPoint:CGPointMake(166.5, 333.33)];
    [lPath addLineToPoint:CGPointMake(333, 333.33)];
    [lPath addLineToPoint:CGPointMake(333, 500)];
    [lPath addLineToPoint:CGPointMake(0, 500)];
    [lPath addLineToPoint:CGPointMake(0, 0)];
    [lPath addLineToPoint:CGPointMake(166.5, 0)];
    [lPath addCurveToPoint:CGPointMake(166.5, 333.33) controlPoint1:CGPointMake(166.5, 0) controlPoint2:CGPointMake(166.5, 187.91)];
    [lPath closePath];
    return lPath;
}

+ (UIBezierPath*)reverseLPath {
    UIBezierPath* reverseLPath = [UIBezierPath bezierPath];
    [reverseLPath moveToPoint:CGPointMake(166.5, 333.33)];
    [reverseLPath addLineToPoint:CGPointMake(0, 333.33)];
    [reverseLPath addLineToPoint:CGPointMake(0, 500)];
    [reverseLPath addLineToPoint:CGPointMake(333, 500)];
    [reverseLPath addLineToPoint:CGPointMake(333, 0)];
    [reverseLPath addLineToPoint:CGPointMake(166.5, 0)];
    [reverseLPath addCurveToPoint:CGPointMake(166.5, 333.33) controlPoint1:CGPointMake(166.5, 0) controlPoint2:CGPointMake(166.5, 187.91)];
    [reverseLPath closePath];
    return reverseLPath;
}

+ (UIBezierPath*)sPath {
    UIBezierPath* sPath = [UIBezierPath bezierPath];
    [sPath moveToPoint:CGPointMake(500, 0)];
    [sPath addLineToPoint:CGPointMake(500, 166.5)];
    [sPath addLineToPoint:CGPointMake(333.33, 166.5)];
    [sPath addLineToPoint:CGPointMake(333.33, 333)];
    [sPath addLineToPoint:CGPointMake(0, 333)];
    [sPath addLineToPoint:CGPointMake(0, 166.5)];
    [sPath addLineToPoint:CGPointMake(166.67, 166.5)];
    [sPath addLineToPoint:CGPointMake(166.67, 0)];
    [sPath addLineToPoint:CGPointMake(500, 0)];
    [sPath closePath];
    return sPath;
}

+ (UIBezierPath*)zPath {
    UIBezierPath* zPath = [UIBezierPath bezierPath];
    [zPath moveToPoint:CGPointMake(0, 0)];
    [zPath addLineToPoint:CGPointMake(0, 166.5)];
    [zPath addLineToPoint:CGPointMake(166.67, 166.5)];
    [zPath addLineToPoint:CGPointMake(166.67, 333)];
    [zPath addLineToPoint:CGPointMake(500, 333)];
    [zPath addLineToPoint:CGPointMake(500, 166.5)];
    [zPath addLineToPoint:CGPointMake(333.33, 166.5)];
    [zPath addLineToPoint:CGPointMake(333.33, 0)];
    [zPath addLineToPoint:CGPointMake(0, 0)];
    [zPath closePath];
    return zPath;
}

+ (UIBezierPath*)eggPath {
    UIBezierPath* eggPath = [UIBezierPath bezierPath];
    [eggPath moveToPoint:CGPointMake(370, 292.9)];
    [eggPath addCurveToPoint:CGPointMake(185, 500) controlPoint1:CGPointMake(370, 430.98) controlPoint2:CGPointMake(286.26, 500)];
    [eggPath addCurveToPoint:CGPointMake(0, 292.9) controlPoint1:CGPointMake(83.74, 500) controlPoint2:CGPointMake(0, 430.98)];
    [eggPath addCurveToPoint:CGPointMake(185, 0) controlPoint1:CGPointMake(0, 154.83) controlPoint2:CGPointMake(83.74, 0)];
    [eggPath addCurveToPoint:CGPointMake(370, 292.9) controlPoint1:CGPointMake(286.26, 0) controlPoint2:CGPointMake(370, 154.83)];
    [eggPath closePath];
    return eggPath;
}

+ (UIBezierPath*)plusPath {
    UIBezierPath* plusPath = [UIBezierPath bezierPath];
    [plusPath moveToPoint:CGPointMake(333, 166)];
    [plusPath addLineToPoint:CGPointMake(500, 166)];
    [plusPath addLineToPoint:CGPointMake(500, 333)];
    [plusPath addLineToPoint:CGPointMake(333, 333)];
    [plusPath addLineToPoint:CGPointMake(333, 500)];
    [plusPath addLineToPoint:CGPointMake(166, 500)];
    [plusPath addLineToPoint:CGPointMake(166, 333)];
    [plusPath addLineToPoint:CGPointMake(0, 333)];
    [plusPath addLineToPoint:CGPointMake(0, 166)];
    [plusPath addLineToPoint:CGPointMake(166, 166)];
    [plusPath addLineToPoint:CGPointMake(166, 0)];
    [plusPath addLineToPoint:CGPointMake(333, 0)];
    [plusPath addLineToPoint:CGPointMake(333, 166)];
    [plusPath closePath];
    return plusPath;
}

+ (UIBezierPath*)diamondPath {
    UIBezierPath* diamondPath = [UIBezierPath bezierPath];
    [diamondPath moveToPoint:CGPointMake(388.39, 0)];
    [diamondPath addLineToPoint:CGPointMake(479.88, 99.48)];
    [diamondPath addLineToPoint:CGPointMake(239.94, 419.91)];
    [diamondPath addLineToPoint:CGPointMake(-0, 99.48)];
    [diamondPath addLineToPoint:CGPointMake(91.49, 0)];
    [diamondPath addLineToPoint:CGPointMake(388.39, 0)];
    [diamondPath addLineToPoint:CGPointMake(388.39, 0)];
    [diamondPath closePath];
    return diamondPath;
}

+ (UIBezierPath*)infinityPath {
    UIBezierPath* infinityPath = [UIBezierPath bezierPath];
    [infinityPath moveToPoint:CGPointMake(500, 125)];
    [infinityPath addCurveToPoint:CGPointMake(374.25, 250) controlPoint1:CGPointMake(500, 194.04) controlPoint2:CGPointMake(443.7, 250)];
    [infinityPath addCurveToPoint:CGPointMake(291.33, 218.98) controlPoint1:CGPointMake(342.48, 250) controlPoint2:CGPointMake(313.47, 238.29)];
    [infinityPath addCurveToPoint:CGPointMake(291.1, 219.22) controlPoint1:CGPointMake(291.18, 219.14) controlPoint2:CGPointMake(291.1, 219.22)];
    [infinityPath addCurveToPoint:CGPointMake(249.58, 177.95) controlPoint1:CGPointMake(291.1, 219.22) controlPoint2:CGPointMake(272.75, 200.98)];
    [infinityPath addCurveToPoint:CGPointMake(222.47, 204.9) controlPoint1:CGPointMake(239.22, 188.25) controlPoint2:CGPointMake(229.79, 197.63)];
    [infinityPath addCurveToPoint:CGPointMake(125.75, 250) controlPoint1:CGPointMake(199.4, 232.46) controlPoint2:CGPointMake(164.64, 250)];
    [infinityPath addCurveToPoint:CGPointMake(0, 125) controlPoint1:CGPointMake(56.3, 250) controlPoint2:CGPointMake(0, 194.04)];
    [infinityPath addCurveToPoint:CGPointMake(46.47, 27.96) controlPoint1:CGPointMake(0, 85.84) controlPoint2:CGPointMake(18.12, 50.88)];
    [infinityPath addCurveToPoint:CGPointMake(50.04, 25.19) controlPoint1:CGPointMake(47.64, 27.02) controlPoint2:CGPointMake(48.83, 26.09)];
    [infinityPath addCurveToPoint:CGPointMake(68.37, 13.74) controlPoint1:CGPointMake(55.78, 20.88) controlPoint2:CGPointMake(61.91, 17.04)];
    [infinityPath addCurveToPoint:CGPointMake(125.75, 0) controlPoint1:CGPointMake(85.57, 4.96) controlPoint2:CGPointMake(105.08, 0)];
    [infinityPath addCurveToPoint:CGPointMake(221.59, 44.06) controlPoint1:CGPointMake(164.15, 0) controlPoint2:CGPointMake(198.53, 17.1)];
    [infinityPath addCurveToPoint:CGPointMake(249.58, 71.88) controlPoint1:CGPointMake(221.6, 44.07) controlPoint2:CGPointMake(249.58, 71.88)];
    [infinityPath addCurveToPoint:CGPointMake(289.08, 32.62) controlPoint1:CGPointMake(271.79, 49.8) controlPoint2:CGPointMake(289.08, 32.62)];
    [infinityPath addCurveToPoint:CGPointMake(289.3, 32.83) controlPoint1:CGPointMake(289.08, 32.62) controlPoint2:CGPointMake(289.16, 32.69)];
    [infinityPath addCurveToPoint:CGPointMake(298.53, 25.19) controlPoint1:CGPointMake(292.25, 30.14) controlPoint2:CGPointMake(295.33, 27.59)];
    [infinityPath addCurveToPoint:CGPointMake(374.25, 0) controlPoint1:CGPointMake(319.59, 9.38) controlPoint2:CGPointMake(345.82, 0)];
    [infinityPath addCurveToPoint:CGPointMake(500, 125) controlPoint1:CGPointMake(443.7, 0) controlPoint2:CGPointMake(500, 55.96)];
    [infinityPath closePath];
    [infinityPath moveToPoint:CGPointMake(374.25, 75)];
    [infinityPath addCurveToPoint:CGPointMake(357.54, 77.82) controlPoint1:CGPointMake(368.39, 75) controlPoint2:CGPointMake(362.76, 76)];
    [infinityPath addCurveToPoint:CGPointMake(333.87, 94.01) controlPoint1:CGPointMake(348.27, 81.07) controlPoint2:CGPointMake(339.75, 86.43)];
    [infinityPath addCurveToPoint:CGPointMake(303.32, 125) controlPoint1:CGPointMake(332.55, 95.29) controlPoint2:CGPointMake(303.32, 125)];
    [infinityPath addCurveToPoint:CGPointMake(333.56, 156.73) controlPoint1:CGPointMake(303.32, 125) controlPoint2:CGPointMake(332.22, 155.43)];
    [infinityPath addCurveToPoint:CGPointMake(374.25, 175) controlPoint1:CGPointMake(344.45, 167.27) controlPoint2:CGPointMake(358.12, 175)];
    [infinityPath addCurveToPoint:CGPointMake(424.55, 125) controlPoint1:CGPointMake(402.03, 175) controlPoint2:CGPointMake(424.55, 152.61)];
    [infinityPath addCurveToPoint:CGPointMake(374.25, 75) controlPoint1:CGPointMake(424.55, 97.39) controlPoint2:CGPointMake(402.03, 75)];
    [infinityPath closePath];
    [infinityPath moveToPoint:CGPointMake(125.75, 75)];
    [infinityPath addCurveToPoint:CGPointMake(109.05, 77.82) controlPoint1:CGPointMake(119.9, 75) controlPoint2:CGPointMake(114.27, 76)];
    [infinityPath addCurveToPoint:CGPointMake(75.45, 125) controlPoint1:CGPointMake(89.48, 84.67) controlPoint2:CGPointMake(75.45, 103.21)];
    [infinityPath addCurveToPoint:CGPointMake(125.75, 175) controlPoint1:CGPointMake(75.45, 152.61) controlPoint2:CGPointMake(97.97, 175)];
    [infinityPath addCurveToPoint:CGPointMake(155.79, 165.11) controlPoint1:CGPointMake(137.01, 175) controlPoint2:CGPointMake(147.41, 171.32)];
    [infinityPath addCurveToPoint:CGPointMake(196.13, 124.83) controlPoint1:CGPointMake(157.81, 163.1) controlPoint2:CGPointMake(196.13, 124.83)];
    [infinityPath addCurveToPoint:CGPointMake(156.34, 85.27) controlPoint1:CGPointMake(196.13, 124.83) controlPoint2:CGPointMake(159.11, 88.02)];
    [infinityPath addCurveToPoint:CGPointMake(125.75, 75) controlPoint1:CGPointMake(147.85, 78.84) controlPoint2:CGPointMake(137.25, 75)];
    [infinityPath closePath];
    return infinityPath;
}

+ (UIBezierPath*)heartPath {
    UIBezierPath* heartPath = [UIBezierPath bezierPath];
    [heartPath moveToPoint:CGPointMake(500, 125)];
    [heartPath addCurveToPoint:CGPointMake(454.91, 221.13) controlPoint1:CGPointMake(500, 163.65) controlPoint2:CGPointMake(480, 195)];
    [heartPath addCurveToPoint:CGPointMake(250, 431) controlPoint1:CGPointMake(410, 267.12) controlPoint2:CGPointMake(250, 431)];
    [heartPath addCurveToPoint:CGPointMake(45.08, 221.12) controlPoint1:CGPointMake(250, 431) controlPoint2:CGPointMake(81.25, 258.81)];
    [heartPath addCurveToPoint:CGPointMake(0, 125) controlPoint1:CGPointMake(20.5, 195.5) controlPoint2:CGPointMake(0, 163.64)];
    [heartPath addCurveToPoint:CGPointMake(49.74, 25.19) controlPoint1:CGPointMake(0, 84.22) controlPoint2:CGPointMake(19.52, 48.01)];
    [heartPath addCurveToPoint:CGPointMake(125, 0) controlPoint1:CGPointMake(70.67, 9.38) controlPoint2:CGPointMake(96.74, 0)];
    [heartPath addCurveToPoint:CGPointMake(251, 107) controlPoint1:CGPointMake(194.04, 0) controlPoint2:CGPointMake(251.5, 57)];
    [heartPath addCurveToPoint:CGPointMake(375, 0) controlPoint1:CGPointMake(252, 57) controlPoint2:CGPointMake(305.96, 0)];
    [heartPath addCurveToPoint:CGPointMake(500, 125) controlPoint1:CGPointMake(444.04, 0) controlPoint2:CGPointMake(500, 55.96)];
    [heartPath closePath];
    return heartPath;
}

+ (UIBezierPath*)arrowPath {
    UIBezierPath* arrowPath = [UIBezierPath bezierPath];
    [arrowPath moveToPoint:CGPointMake(275, 350)];
    [arrowPath addLineToPoint:CGPointMake(275, 250.78)];
    [arrowPath addLineToPoint:CGPointMake(0, 250.78)];
    [arrowPath addLineToPoint:CGPointMake(0, 99.22)];
    [arrowPath addLineToPoint:CGPointMake(275, 99.22)];
    [arrowPath addLineToPoint:CGPointMake(275, 0)];
    [arrowPath addLineToPoint:CGPointMake(500, 175)];
    [arrowPath addLineToPoint:CGPointMake(275, 350)];
    [arrowPath closePath];
    return arrowPath;
}

@end
