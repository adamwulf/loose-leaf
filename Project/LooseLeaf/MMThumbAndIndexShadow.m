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
    
    NSLog(@"open length: %d", (int)[openPath elementCount]);
    NSLog(@"closed length: %d", (int)[closedPath elementCount]);
    
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
    if(isnan(theta)){
        theta = 0;
    }
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
    
    openThumbTipPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + floor((CGRectGetWidth(frame) - 7) * 0.75311 + 0.15) + 0.35, CGRectGetMinY(frame) + floor((CGRectGetHeight(frame) - 7) * 0.33013 + 0.23) + 0.27, 7, 7)];
    openIndexFingerTipPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + floor((CGRectGetWidth(frame) - 7) * 0.48103 - 0.34) + 0.84, CGRectGetMinY(frame) + floor((CGRectGetHeight(frame) - 7) * 0.08532 + 0.5), 7, 7)];
    closedThumbTipPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + floor((CGRectGetWidth(frame) - 7) * 0.38885 + 0.45) + 0.05, CGRectGetMinY(frame) + floor((CGRectGetHeight(frame) - 7) * 0.16626 + 0.21) + 0.29, 7, 7)];
    closedIndexFingerTipPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + floor((CGRectGetWidth(frame) - 7) * 0.19771 + 0.34) + 0.16, CGRectGetMinY(frame) + floor((CGRectGetHeight(frame) - 7) * 0.13367 - 0.33) + 0.83, 7, 7)];
    
    openPath = UIBezierPath.bezierPath;
    [openPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.42901 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.88607 * CGRectGetHeight(frame))];
    [openPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.13953 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.88447 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.20570 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.68103 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.13953 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.88447 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.18895 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.71452 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.26790 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.52486 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.22244 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.64753 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.26312 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.54400 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.27029 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.48498 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.26790 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.52486 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.27986 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.49615 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.25447 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.45571 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.27029 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.48498 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.25771 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.46146 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.23397 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.40535 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.25124 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.44995 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.23397 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.42549 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.23937 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34492 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.23397 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.40535 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.24152 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.35140 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.24045 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.32910 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.23721 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.33845 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.23721 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.33485 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.24584 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.30608 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.24369 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.32334 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.24692 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31687 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.27605 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.27371 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.24476 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.29528 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.24800 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.27442 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.30087 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.28018 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.27605 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.27371 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.29224 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.27226 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.33433 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26363 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.30087 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.28018 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.31274 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26148 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.36141 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.27015 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.35591 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26579 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.35655 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26635 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.39352 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.23736 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.36242 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26457 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.36007 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24024 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.43360 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.25212 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.42697 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.23449 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.43000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24924 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.44762 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26076 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.43720 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.25501 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.43900 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.25860 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.46166 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24708 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.45626 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26291 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.45950 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.25212 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.46381 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.19457 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.46166 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24708 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.46597 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.21040 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.46705 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.10825 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.46166 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17875 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.46597 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.11760 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.48970 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.08235 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.46813 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09890 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.46381 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.08235 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.51884 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.11544 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.51560 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.08235 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.51787 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.10730 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.52855 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17875 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.51980 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.12358 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.52639 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17227 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.52746 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.21112 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.53070 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.18522 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.52746 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.20752 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.52962 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26867 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.52746 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.21471 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.52530 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26148 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.53286 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.29888 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.53395 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.27586 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.53179 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.29385 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.55767 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.35356 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.53395 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.30392 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.53502 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34852 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.59868 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.35068 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.58034 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.35859 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.58789 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.35283 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.70012 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.32046 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.60947 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34852 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.66559 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.32046 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.77457 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.33413 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.70012 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.32046 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.75839 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31183 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.76810 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34492 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.77457 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.33413 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.77997 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.33988 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.72494 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.35211 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.76810 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34492 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.73500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34844 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.70012 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.36218 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.71222 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.35569 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.70552 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.36003 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.65372 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.38161 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.69472 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.36435 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.66235 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.37873 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.60947 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.40463 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.64508 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.38449 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.61487 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.40103 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.56955 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.42621 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.60407 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.40823 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.59329 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.41758 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.47892 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.47585 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.54581 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.43484 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.49618 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.46793 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.46166 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.50318 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.47892 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.47585 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.46273 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.49671 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.44223 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.58448 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.46058 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.50966 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.44331 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.57512 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.42929 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.69166 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.44115 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.59383 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.42929 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.68375 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.42929 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.76648 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.42929 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.69958 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.42820 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.75784 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.42901 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.88607 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.43036 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.77511 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.42122 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.87475 * CGRectGetHeight(frame))];
    [openPath closePath];
    
    
    closedPath = UIBezierPath.bezierPath;
    [closedPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.55150 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.82672 * CGRectGetHeight(frame))];
    [closedPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.29752 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.81777 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.31712 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.70922 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.29752 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.81777 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.31955 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.71981 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.32374 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.62572 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.31469 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.69864 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.32339 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.62922 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.33614 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.53668 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.32409 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.62227 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.33741 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.54139 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.32444 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.49660 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.33486 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.53197 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.32212 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.50231 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.32827 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.47581 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.32676 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.49085 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.32827 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.47581 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.30499 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.44685 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.32827 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.47581 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.31332 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.45068 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.26957 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.42316 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.29665 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.44297 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.27444 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.42686 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.24594 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.40796 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.26806 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.42200 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.25046 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.41107 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.19521 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.37406 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.24317 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.40605 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.19822 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.37641 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.18161 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.36403 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.19289 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.37225 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.18719 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.36819 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.16846 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.35317 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.17578 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.35970 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.17008 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.35526 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.15518 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.33893 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.16637 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.35046 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.15684 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34559 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.17152 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31522 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.15210 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.32656 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.17152 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31522 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.17174 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.30361 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.17152 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31522 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.17159 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31052 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.17201 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.29252 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.17181 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.30032 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.17190 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.29654 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.17465 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24902 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.17249 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.27443 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.17335 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.25171 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.17919 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.20385 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.17686 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24447 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.17848 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.21081 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.18810 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.14952 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.17988 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.19689 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.18776 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.15302 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.19935 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.12443 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.18845 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.14606 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.18741 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.12156 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.23353 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.16668 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.21129 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.12731 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.23028 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.12931 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.23190 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.18289 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.23353 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.16668 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.23085 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17589 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.23931 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.23093 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.23294 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.18993 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.23827 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.22393 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.24105 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26593 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.24035 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.23797 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.24105 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26593 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.27998 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24322 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.24105 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26593 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.27129 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24285 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.31670 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.25997 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.28867 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24360 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.31184 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.25627 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.33292 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.27235 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.32157 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26368 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.33292 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.27235 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.34232 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.21343 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.33292 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.27235 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.33780 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.22368 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.39457 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.16222 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.34684 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.20314 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.35275 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.16152 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.40905 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17447 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.39457 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.16222 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.41022 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.16289 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.40546 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.21039 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.40790 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.18606 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.40453 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.20222 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.40604 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.23952 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.40639 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.21860 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.40847 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.23264 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.40325 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26735 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.40360 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24639 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.39897 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.25785 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.41275 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31197 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.40754 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.27685 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.41007 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.30372 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.43129 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.35356 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.41540 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.32022 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.42387 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34039 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.44414 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.39947 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.43870 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.36668 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.44345 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.38897 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.45352 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.42785 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.44484 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.41002 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.44946 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.41602 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.45351 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.48022 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.45757 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.43968 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.44969 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.46606 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.47379 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.55677 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.45734 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.49435 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.46647 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.54247 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.51502 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.68543 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.48108 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.57106 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.50934 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.67239 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.55150 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.82672 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.52069 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.69852 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.54895 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.79985 * CGRectGetHeight(frame))];
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
