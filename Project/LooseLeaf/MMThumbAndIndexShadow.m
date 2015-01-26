//
//  MMThumbAndIndexHelper.m
//  LooseLeaf
//
//  Created by Adam Wulf on 1/26/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMThumbAndIndexShadow.h"
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import <DrawKit-iOS/DrawKit-iOS.h>
#import "MMVector.h"

@implementation MMThumbAndIndexShadow{
    BOOL isRight;
    UIBezierPath* lastInterpolatedPath;
    CGPoint lastInterpolatedIndexFinger;
}

-(id) initForRightHand:(BOOL)_isRight{
    if(self = [super init]){
        isRight = _isRight;
        boundingBox = CGRectMake(0, 0, 200, 300);
        boundingBox = CGRectApplyAffineTransform(boundingBox, CGAffineTransformMakeScale(4, 4));
        
        [self initPaths];
        lastInterpolatedPath = openPath;
        
        if(isRight){
            [self flipPathAroundYAxis:openPath];
            [self flipPathAroundYAxis:closedPath];
            
            [self flipPathAroundYAxis:openThumbTipPath];
            [self flipPathAroundYAxis:openIndexFingerTipPath];
            [self flipPathAroundYAxis:closedThumbTipPath];
            [self flipPathAroundYAxis:closedThumbTipPath];
        }
    }
    return self;
}

-(CGPoint) avgPoint:(CGPoint)p1 withPoint:(CGPoint)p2 weight:(CGFloat)weight{
    return CGPointMake(p1.x*weight + p2.x*(1-weight),
                       p1.y*weight + p2.y*(1-weight));
}

-(UIBezierPath*) pathForTouches:(NSArray*)touches{
    return lastInterpolatedPath;
}

-(CGPoint) locationOfIndexFingerInPathBounds{
    return lastInterpolatedIndexFinger;
}

-(void) openTo:(CGFloat)openPercent{
    lastInterpolatedPath = [UIBezierPath bezierPath];
    
    lastInterpolatedIndexFinger = CGPointMake(openPercent * openIndexFingerTipPath.center.x + (1-openPercent) * closedThumbTipPath.center.x,
                                              openPercent * openIndexFingerTipPath.center.y + (1-openPercent) * closedThumbTipPath.center.y);
    CGPoint lastInterpolatedThumb = CGPointMake(openPercent * openThumbTipPath.center.x + (1-openPercent) * closedThumbTipPath.center.x,
                                                       openPercent * openThumbTipPath.center.y + (1-openPercent) * closedThumbTipPath.center.y);
    
    for(int i=0;i<[openPath elementCount];i++){
        CGPathElement openElement = [openPath elementAtIndex:i];
        CGPathElement closedElement = [closedPath elementAtIndex:i];
        
        if(openElement.type == kCGPathElementMoveToPoint){
            [lastInterpolatedPath moveToPoint:[self avgPoint:openElement.points[0]
                                                   withPoint:closedElement.points[0]
                                                      weight:openPercent]];
        }else if(openElement.type == kCGPathElementAddLineToPoint){
            [lastInterpolatedPath addLineToPoint:[self avgPoint:openElement.points[0]
                                                      withPoint:closedElement.points[0]
                                                         weight:openPercent]];
        }else if(openElement.type == kCGPathElementAddQuadCurveToPoint){
            CGPoint endPt = [self avgPoint:openElement.points[1]
                                 withPoint:closedElement.points[1]
                                    weight:openPercent];
            CGPoint ctrlPt = [self avgPoint:openElement.points[0]
                                  withPoint:closedElement.points[0]
                                     weight:openPercent];
            
            [lastInterpolatedPath addQuadCurveToPoint:endPt controlPoint:ctrlPt];
        }else if(openElement.type == kCGPathElementAddCurveToPoint){
            CGPoint endPt = [self avgPoint:openElement.points[2]
                                 withPoint:closedElement.points[2]
                                    weight:openPercent];
            CGPoint ctrlPt1 = [self avgPoint:openElement.points[0]
                                   withPoint:closedElement.points[0]
                                      weight:openPercent];
            CGPoint ctrlPt2 = [self avgPoint:openElement.points[1]
                                   withPoint:closedElement.points[1]
                                      weight:openPercent];
            
            [lastInterpolatedPath addCurveToPoint:endPt controlPoint1:ctrlPt1 controlPoint2:ctrlPt2];
        }else if(openElement.type == kCGPathElementCloseSubpath){
            [lastInterpolatedPath closePath];
        }
    }
    
    // this is the angle between the index finger and thumb assuming the user
    // has their hand at a perfect 90 deg to the screen
    MMVector* initialFingerAngle = [MMVector vectorWithPoint:lastInterpolatedIndexFinger andPoint:lastInterpolatedThumb];
    if(!isRight){
        initialFingerAngle = [initialFingerAngle flip];
    }
    // right hand: -.17 to -.33
    // left hand:  +.17 to +.33
    CGFloat theta = -initialFingerAngle.angle;
    CGPoint offset = lastInterpolatedIndexFinger;
    [lastInterpolatedPath applyTransform:CGAffineTransformTranslate(CGAffineTransformRotate(CGAffineTransformMakeTranslation(offset.x, offset.y), theta), -offset.x, -offset.y)];
}

-(void) setFingerDistance:(CGFloat)idealDistance{
    idealDistance -= 80; // adjust for width of fingers (?)
    CGFloat openDist = distance(openThumbTipPath.center, openIndexFingerTipPath.center);
    CGFloat closedDist = distance(closedThumbTipPath.center, closedThumbTipPath.center);
    CGFloat perc = idealDistance / (openDist - closedDist);
    [self openTo:perc > 1 ? 1.0 : perc];
}



-(void) initPaths{
    
    CGRect frame = boundingBox;
    
    openThumbTipPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + floor((CGRectGetWidth(frame) - 7) * 0.27322 + 0.03) + 0.47, CGRectGetMinY(frame) + floor((CGRectGetHeight(frame) - 7) * 0.04833 - 0.34) + 0.84, 7, 7)];
    openIndexFingerTipPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + floor((CGRectGetWidth(frame) - 7) * 0.87880 - 0.43) + 0.93, CGRectGetMinY(frame) + floor((CGRectGetHeight(frame) - 7) * 0.07405 + 0.2) + 0.3, 7, 7)];
    closedThumbTipPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + floor((CGRectGetWidth(frame) - 7) * 0.53012 + 0.08) + 0.42, CGRectGetMinY(frame) + floor((CGRectGetHeight(frame) - 7) * 0.04172 - 0.28) + 0.78, 7, 7)];
    closedThumbTipPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + floor((CGRectGetWidth(frame) - 7) * 0.71794 - 0.43) + 0.93, CGRectGetMinY(frame) + floor((CGRectGetHeight(frame) - 7) * 0.06205 - 0.32) + 0.82, 7, 7)];
    
    openPath = UIBezierPath.bezierPath;
    [openPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.61863 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.81132 * CGRectGetHeight(frame))];
    [openPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.07600 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.81132 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.18222 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.66361 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.07600 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.81132 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.16788 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.67990 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.23677 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.58495 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.19658 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.64732 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.23103 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.59361 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.25113 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.53220 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.24252 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.57632 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.25688 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.53890 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.20806 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.48815 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.24539 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.52549 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.23104 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.49870 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.13342 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.41715 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.18509 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.47757 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.14203 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.44882 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.10758 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.37207 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.12480 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.38549 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.11045 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.37878 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.11333 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.35386 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.10471 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.36536 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.11333 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.36057 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.10184 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.29340 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.11333 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34715 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.08750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.30303 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.20806 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.27953 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.11618 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.28382 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.15064 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26707 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.25113 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.23870 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.20806 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.27953 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.17649 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24540 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.35449 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26270 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.32579 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.23199 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.35449 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26270 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.30431 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.19840 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.35449 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26270 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.32155 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.21378 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.26849 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.13224 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.28709 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.18307 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.27136 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.14470 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.27424 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.03824 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.26563 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.11978 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.19386 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.04303 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.37474 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09578 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.35464 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.03345 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.37474 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09578 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.43926 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17349 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.37474 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09578 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.43926 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.16774 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.49517 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24828 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.43926 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17924 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.47506 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24732 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.62998 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.21186 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.51527 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24924 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.59265 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.25211 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.76463 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.10440 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.66730 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17157 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.75314 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.11303 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.86784 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.06607 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.77611 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09578 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.79894 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.06128 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.87085 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.12840 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.93674 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.07086 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.87372 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.12074 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.81146 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.19074 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.86798 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.13607 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.81766 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.18553 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.75343 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.23678 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.80540 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.19583 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.75630 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.22911 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.70476 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.32886 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.75056 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24445 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.68754 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.30586 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.71338 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.40465 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.72198 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.35190 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.72198 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.39215 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.69327 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.45932 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.70476 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.41711 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.69327 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.45261 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.68754 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.52261 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.69327 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.46603 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.69327 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.51111 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.63012 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.64732 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.68179 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.53411 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.64734 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.62140 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.61863 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.78449 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.61289 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.67320 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.61863 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.77582 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.61863 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.81132 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.61863 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.79311 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.61863 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.81132 * CGRectGetHeight(frame))];
    [openPath closePath];
    
    
    closedPath = UIBezierPath.bezierPath;
    [closedPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.66734 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.80639 * CGRectGetHeight(frame))];
    [closedPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.12471 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.80639 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.23093 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.65868 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.12471 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.80639 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.21659 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.67498 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.28548 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.58002 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.24529 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.64239 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.27973 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.58868 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.29984 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.52060 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.29123 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.57139 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.30559 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.52731 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.25677 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.48323 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.29410 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.51389 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.27975 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.49377 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.18213 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.41223 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.23380 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.47264 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.19073 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.44389 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.15629 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.36714 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.17351 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.38056 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.15916 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.37385 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.16204 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34893 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.15342 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.36043 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.16204 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.35564 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.15055 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.28848 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.16204 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34223 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.13621 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.29810 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.25677 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.27460 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.16489 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.27889 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.19935 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26214 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.29984 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.23377 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.25677 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.27460 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.22519 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24048 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.40319 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.25777 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.37450 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.22706 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.40319 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.25777 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.43513 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.19348 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.40319 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.25777 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.43460 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.21097 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.45597 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.12755 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.43368 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17724 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.45884 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.14001 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.53184 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.03464 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.45311 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.11509 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.44680 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.03580 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.57650 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09085 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.60583 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.03461 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.57650 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09085 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.56803 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.16790 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.57650 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09085 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.56803 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.16215 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.55202 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24392 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.56803 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17365 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.53192 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24296 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.61527 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.20703 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.57213 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24488 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.57794 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24728 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.64537 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09723 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.63124 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.16731 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.64161 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.10726 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.71147 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.05276 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.64913 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.08721 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.63836 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.05435 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.75319 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.10818 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.77438 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.05294 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.75605 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.10052 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.75008 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17559 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.75032 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.11585 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.75295 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17080 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.74075 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.22895 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.74721 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.18038 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.74362 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.22129 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.74349 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.32393 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.73788 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.23662 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.73625 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.30093 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.76209 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.39973 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.76072 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34698 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.76072 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.38723 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.74198 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.45439 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.75347 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.41218 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.74198 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.44768 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.73625 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.51768 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.74198 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.46110 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.74198 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.50618 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.67883 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.64239 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.73050 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.52918 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.69605 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.61648 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.66734 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.77956 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.66160 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.66827 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.66734 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.77089 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.66734 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.80639 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.66734 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.78818 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.66734 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.80639 * CGRectGetHeight(frame))];
    [closedPath closePath];
}


#pragma mark - CALayer Helper

-(void) preventCALayerImplicitAnimation:(void(^)(void))block{
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    block();
    [CATransaction commit];
}



-(void) flipPathAroundYAxis:(UIBezierPath*)path{
    [path applyTransform:CGAffineTransformMakeTranslation(-boundingBox.size.width/2 - boundingBox.origin.x, 0)];
    [path applyTransform:CGAffineTransformMakeScale(-1, 1)];
    [path applyTransform:CGAffineTransformMakeTranslation(boundingBox.size.width/2 + boundingBox.origin.x, 0)];
    
}



@end
