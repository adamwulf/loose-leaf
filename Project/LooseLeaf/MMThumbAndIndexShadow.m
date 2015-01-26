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
    
    openThumbTipPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + floor((CGRectGetWidth(frame) - 7) * 0.75311 + 0.15) + 0.35, CGRectGetMinY(frame) + floor((CGRectGetHeight(frame) - 7) * 0.33013 + 0.23) + 0.27, 7, 7)];
    openIndexFingerTipPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + floor((CGRectGetWidth(frame) - 7) * 0.48103 - 0.34) + 0.84, CGRectGetMinY(frame) + floor((CGRectGetHeight(frame) - 7) * 0.08532 + 0.5), 7, 7)];
    closedThumbTipPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + floor((CGRectGetWidth(frame) - 7) * 0.71504 + 0.5) + 0, CGRectGetMinY(frame) + floor((CGRectGetHeight(frame) - 7) * 0.27838 + 0.07) + 0.43, 7, 7)];
    closedIndexFingerTipPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + floor((CGRectGetWidth(frame) - 7) * 0.67340 - 0.47) + 0.97, CGRectGetMinY(frame) + floor((CGRectGetHeight(frame) - 7) * 0.15062 - 0.37) + 0.87, 7, 7)];
    
    openPath = UIBezierPath.bezierPath;
    [openPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.42206 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.88578 * CGRectGetHeight(frame))];
    [openPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.13258 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.88419 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.19875 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.68407 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.13258 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.88419 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.18200 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.71757 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.26095 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.52457 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.21549 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.65058 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.25617 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.54371 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.26333 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.48470 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.26095 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.52457 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.27291 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.49586 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.24752 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.45542 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.26333 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.48470 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.25076 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.46118 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.22702 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.40506 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.24429 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.44966 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.22702 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.42521 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.23241 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34464 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.22702 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.40506 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.23457 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.35111 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.23350 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.32881 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.23026 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.33816 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.23026 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.33456 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.23889 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.30579 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.23673 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.32306 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.23997 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31658 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.26910 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.27342 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.23781 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.29500 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.24105 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.27414 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.29392 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.27989 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.26910 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.27342 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.28529 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.27198 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.32738 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26335 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.29392 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.27989 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.30579 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26119 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.35219 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26982 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.34896 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26551 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.35219 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26982 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.38025 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.23097 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.35219 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26982 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.34680 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.23385 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.42665 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.25184 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.41370 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.22810 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.42665 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.25184 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.44067 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26047 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.42665 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.25184 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.43205 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.25831 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.45471 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24680 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.44931 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26263 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.45255 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.25184 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.45686 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.19429 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.45471 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24680 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.45902 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.21011 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.46010 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.10796 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.45471 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17846 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.45902 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.11731 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.48275 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.08206 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.46118 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09861 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.45686 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.08206 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.51188 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.11516 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.50865 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.08206 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.51188 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.11516 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.52160 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17846 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.51188 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.11516 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.51944 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17199 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.52051 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.21083 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.52375 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.18494 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.52051 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.20724 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.52267 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26838 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.52051 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.21443 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.51835 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26119 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.52591 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.29860 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.52700 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.27558 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.52483 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.29356 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.55072 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.35327 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.52700 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.30363 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.52806 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34823 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.59173 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.35039 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.57339 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.35831 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.58093 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.35255 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.69316 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.32018 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.60251 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34823 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.65863 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.32018 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.76762 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.33385 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.69316 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.32018 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.75143 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31154 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.76115 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34464 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.76762 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.33385 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.77301 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.33960 * CGRectGetHeight(frame))];
    [openPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.71798 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.35183 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.69316 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.36190 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.71798 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.35183 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.69856 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.35974 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.64677 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.38132 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.68777 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.36406 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.65540 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.37845 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.60251 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.40434 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.63813 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.38420 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.60791 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.40075 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.56260 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.42593 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.59712 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.40794 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.58633 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.41729 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.47196 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.47556 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.53886 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.43456 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.48923 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.46765 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.45471 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.50290 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.47196 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.47556 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.45578 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.49642 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.43528 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.58419 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.45363 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.50937 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.43636 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.57484 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.42233 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.69138 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.43420 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.59354 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.42233 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.68346 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.42233 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.76619 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.42233 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.69929 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.42125 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.75756 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.42206 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.88578 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.42341 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.77482 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.41426 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.87446 * CGRectGetHeight(frame))];
    [openPath closePath];
    
    
    closedPath = UIBezierPath.bezierPath;
    [closedPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 136.75, CGRectGetMinY(frame) + 44.58)];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 128.59, CGRectGetMinY(frame) + 56.45) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 137.07, CGRectGetMinY(frame) + 47.1) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 138.27, CGRectGetMinY(frame) + 50.76)];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 124.11, CGRectGetMinY(frame) + 58.37) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 128.59, CGRectGetMinY(frame) + 56.45) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 125.88, CGRectGetMinY(frame) + 57.23)];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 111.96, CGRectGetMinY(frame) + 66.27) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 122.32, CGRectGetMinY(frame) + 59.52) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 113.73, CGRectGetMinY(frame) + 65.12)];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 102.77, CGRectGetMinY(frame) + 71.36) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 110.17, CGRectGetMinY(frame) + 67.42) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 102.77, CGRectGetMinY(frame) + 71.36)];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 112.39, CGRectGetMinY(frame) + 75.19) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 102.77, CGRectGetMinY(frame) + 71.36) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 111.69, CGRectGetMinY(frame) + 73.59)];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 111.26, CGRectGetMinY(frame) + 84.01) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 113.08, CGRectGetMinY(frame) + 76.78) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 111.81, CGRectGetMinY(frame) + 82.64)];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 109.44, CGRectGetMinY(frame) + 88.59) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 110.72, CGRectGetMinY(frame) + 85.39) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 109.44, CGRectGetMinY(frame) + 88.59)];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 126.03, CGRectGetMinY(frame) + 82.21) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 109.44, CGRectGetMinY(frame) + 88.59) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 122.88, CGRectGetMinY(frame) + 82.8)];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 144.46, CGRectGetMinY(frame) + 84.5) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 129.19, CGRectGetMinY(frame) + 81.6) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 140.84, CGRectGetMinY(frame) + 76.96)];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 142.51, CGRectGetMinY(frame) + 88.76) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 144.46, CGRectGetMinY(frame) + 84.5) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 145.71, CGRectGetMinY(frame) + 87.38)];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 132.6, CGRectGetMinY(frame) + 93.03) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 139.32, CGRectGetMinY(frame) + 90.13) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 134.69, CGRectGetMinY(frame) + 91.75)];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 124.87, CGRectGetMinY(frame) + 97.12) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 130.49, CGRectGetMinY(frame) + 94.32) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 126.93, CGRectGetMinY(frame) + 96.61)];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 117.19, CGRectGetMinY(frame) + 100.43) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 122.81, CGRectGetMinY(frame) + 97.62) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 119.33, CGRectGetMinY(frame) + 98.37)];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 106.14, CGRectGetMinY(frame) + 108.22) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 115.04, CGRectGetMinY(frame) + 102.49) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 108.1, CGRectGetMinY(frame) + 106.62)];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 96.73, CGRectGetMinY(frame) + 117.21) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 104.18, CGRectGetMinY(frame) + 109.83) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 99.57, CGRectGetMinY(frame) + 114.09)];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 85.64, CGRectGetMinY(frame) + 125.78) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 93.9, CGRectGetMinY(frame) + 120.33) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 88.38, CGRectGetMinY(frame) + 124.22)];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 82.16, CGRectGetMinY(frame) + 130.68) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 82.89, CGRectGetMinY(frame) + 127.35) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 84.95, CGRectGetMinY(frame) + 128.34)];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 80.33, CGRectGetMinY(frame) + 146.5) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 81.47, CGRectGetMinY(frame) + 131.26) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 79.94, CGRectGetMinY(frame) + 137.71)];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 80.05, CGRectGetMinY(frame) + 165.13) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 80.5, CGRectGetMinY(frame) + 150.23) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 78.88, CGRectGetMinY(frame) + 160.11)];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 87.03, CGRectGetMinY(frame) + 197.5) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 81.51, CGRectGetMinY(frame) + 169.42) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 85.9, CGRectGetMinY(frame) + 193.59)];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 94.33, CGRectGetMinY(frame) + 239.89) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 88.17, CGRectGetMinY(frame) + 201.43) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 93.82, CGRectGetMinY(frame) + 231.83)];
    [closedPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 43.54, CGRectGetMinY(frame) + 237.2)];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 47.45, CGRectGetMinY(frame) + 204.64) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 43.54, CGRectGetMinY(frame) + 237.2) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 47.94, CGRectGetMinY(frame) + 207.81)];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 48.78, CGRectGetMinY(frame) + 179.59) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 46.97, CGRectGetMinY(frame) + 201.46) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 48.71, CGRectGetMinY(frame) + 180.64)];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 49.1, CGRectGetMinY(frame) + 155.02) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 48.85, CGRectGetMinY(frame) + 178.55) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 49.35, CGRectGetMinY(frame) + 156.43)];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 48.92, CGRectGetMinY(frame) + 140.85) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 48.84, CGRectGetMinY(frame) + 153.61) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 48.46, CGRectGetMinY(frame) + 142.56)];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 49.68, CGRectGetMinY(frame) + 134.61) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 49.38, CGRectGetMinY(frame) + 139.13) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 49.68, CGRectGetMinY(frame) + 134.61)];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 51.04, CGRectGetMinY(frame) + 127.53) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 49.68, CGRectGetMinY(frame) + 134.61) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 51.38, CGRectGetMinY(frame) + 128.32)];
    [closedPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 54.14, CGRectGetMinY(frame) + 115.83)];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 54.69, CGRectGetMinY(frame) + 115.6) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 54.48, CGRectGetMinY(frame) + 115.69) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 54.69, CGRectGetMinY(frame) + 115.6)];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 60.3, CGRectGetMinY(frame) + 107.49) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 54.69, CGRectGetMinY(frame) + 115.6) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 60.04, CGRectGetMinY(frame) + 109.5)];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 69.85, CGRectGetMinY(frame) + 76.82) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 60.57, CGRectGetMinY(frame) + 105.48) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 69.31, CGRectGetMinY(frame) + 78.2)];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 75.45, CGRectGetMinY(frame) + 66.07) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 70.4, CGRectGetMinY(frame) + 75.45) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 72.2, CGRectGetMinY(frame) + 68.23)];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 83.27, CGRectGetMinY(frame) + 65.73) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 78.7, CGRectGetMinY(frame) + 63.91) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 83.27, CGRectGetMinY(frame) + 65.73)];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 101.23, CGRectGetMinY(frame) + 57.23) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 83.27, CGRectGetMinY(frame) + 65.73) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 99.82, CGRectGetMinY(frame) + 57.46)];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 113.71, CGRectGetMinY(frame) + 51.86) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 102.65, CGRectGetMinY(frame) + 57) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 111.78, CGRectGetMinY(frame) + 52.69)];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 129.03, CGRectGetMinY(frame) + 46.01) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 115.63, CGRectGetMinY(frame) + 51.03) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 128.06, CGRectGetMinY(frame) + 46.43)];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 134.24, CGRectGetMinY(frame) + 43.86) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 129.61, CGRectGetMinY(frame) + 45.76) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 132.21, CGRectGetMinY(frame) + 44.36)];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 136.75, CGRectGetMinY(frame) + 44.58) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 135.55, CGRectGetMinY(frame) + 43.54) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 136.62, CGRectGetMinY(frame) + 43.59)];
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
