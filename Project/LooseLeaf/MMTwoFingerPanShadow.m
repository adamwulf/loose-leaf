//
//  MMTwoFingerPanSilhouette.m
//  LooseLeaf
//
//  Created by Adam Wulf on 1/12/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMTwoFingerPanShadow.h"
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import <DrawKit-iOS/DrawKit-iOS.h>
#import "MMVector.h"

@implementation MMTwoFingerPanShadow{
    BOOL isRight;
    UIBezierPath* lastInterpolatedPath;
    CGPoint lastInterpolatedIndexFinger;
}

-(id) initForRightHand:(BOOL)_isRight{
    if(self = [super init]){
        isRight = _isRight;
        boundingBox = CGRectMake(0, 0, 100, 300);
        boundingBox = CGRectApplyAffineTransform(boundingBox, CGAffineTransformMakeScale(4, 4));

        [self initPaths];
        lastInterpolatedPath = openPath;
        
        if(isRight){
            [self flipPathAroundYAxis:openPath];
            [self flipPathAroundYAxis:closedPath];
            
            [self flipPathAroundYAxis:openMiddleFingerTipPath];
            [self flipPathAroundYAxis:openIndexFingerTipPath];
            [self flipPathAroundYAxis:closedMiddleFingerTipPath];
            [self flipPathAroundYAxis:closedIndexFingerTipPath];
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
    
    lastInterpolatedIndexFinger = CGPointMake(openPercent * openIndexFingerTipPath.center.x + (1-openPercent) * closedIndexFingerTipPath.center.x,
                                              openPercent * openIndexFingerTipPath.center.y + (1-openPercent) * closedIndexFingerTipPath.center.y);
    CGPoint lastInterpolatedMiddleFinger = CGPointMake(openPercent * openMiddleFingerTipPath.center.x + (1-openPercent) * closedMiddleFingerTipPath.center.x,
                                              openPercent * openMiddleFingerTipPath.center.y + (1-openPercent) * closedMiddleFingerTipPath.center.y);
    
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
    
    // this is the angle between the index finger and middle finger assuming the user
    // has their hand at a perfect 90 deg to the screen
    MMVector* initialFingerAngle = [MMVector vectorWithPoint:lastInterpolatedIndexFinger andPoint:lastInterpolatedMiddleFinger];
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
    CGFloat openDist = distance(openMiddleFingerTipPath.center, openIndexFingerTipPath.center);
    CGFloat closedDist = distance(closedMiddleFingerTipPath.center, closedIndexFingerTipPath.center);
    CGFloat perc = idealDistance / (openDist - closedDist);
    [self openTo:perc > 1 ? 1.0 : perc];
}



-(void) initPaths{
    
    CGRect frame = boundingBox;
    
    openMiddleFingerTipPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + floor((CGRectGetWidth(frame) - 7) * 0.34891 - 0.03) + 0.53, CGRectGetMinY(frame) + floor((CGRectGetHeight(frame) - 7) * 0.04132 - 0.39) + 0.89, 7, 7)];
    openIndexFingerTipPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + floor((CGRectGetWidth(frame) - 7) * 0.84662 - 0.43) + 0.93, CGRectGetMinY(frame) + floor((CGRectGetHeight(frame) - 7) * 0.07063 + 0.2) + 0.3, 7, 7)];
    closedMiddleFingerTipPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + floor((CGRectGetWidth(frame) - 7) * 0.53012 + 0.08) + 0.42, CGRectGetMinY(frame) + floor((CGRectGetHeight(frame) - 7) * 0.04172 - 0.28) + 0.78, 7, 7)];
    closedIndexFingerTipPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + floor((CGRectGetWidth(frame) - 7) * 0.71794 - 0.43) + 0.93, CGRectGetMinY(frame) + floor((CGRectGetHeight(frame) - 7) * 0.06205 - 0.32) + 0.82, 7, 7)];
    
    openPath = UIBezierPath.bezierPath;
    [openPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.66734 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.80639 * CGRectGetHeight(frame))];
    [openPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.12471 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.80639 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.23093 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.65868 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.12471 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.80639 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.21659 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.67498 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.28548 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.58002 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.24529 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.64239 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.27973 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.58868 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.29984 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.52727 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.29123 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.57139 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.30559 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.53398 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.25677 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.48989 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.29410 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.52056 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.27975 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.50043 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.18213 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.41889 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.23380 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.47931 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.19073 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.45056 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.15629 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.37381 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.17351 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.38723 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.15916 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.38052 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.16204 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.35560 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.15342 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.36710 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.16204 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.36231 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.15055 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.29514 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.16204 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34889 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.13621 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.30477 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.25677 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.28460 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.16489 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.28556 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.19935 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.27214 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.29984 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.23377 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.25677 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.28460 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.22519 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24048 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.40319 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.25777 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.37450 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.22706 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.40319 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.25777 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.36300 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.19348 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.40319 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.25777 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.38023 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.20885 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.33716 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.12731 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.34577 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17814 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.34002 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.13977 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.34290 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.03331 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.33430 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.11485 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.26252 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.03810 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.44340 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09085 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.42330 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.02852 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.44340 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09085 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.49794 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.16856 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.44340 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09085 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.49794 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.16281 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.54388 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24335 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.49794 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17431 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.52377 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24239 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.65873 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.20693 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.56398 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24431 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.62140 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24718 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.75347 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09948 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.69605 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.16664 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.74198 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.10810 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.83673 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.06114 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.76496 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09085 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.76783 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.05635 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.85969 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.12348 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.90563 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.06593 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.86256 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.11581 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.82525 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.18581 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.85683 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.13114 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.82811 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.18102 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.78218 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.23185 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.82238 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.19060 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.78505 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.22418 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.75347 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.32393 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.77931 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.23952 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.73625 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.30093 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.76209 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.39973 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.77069 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34698 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.77069 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.38723 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.74198 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.45439 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.75347 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.41218 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.74198 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.44768 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.73625 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.51768 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.74198 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.46110 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.74198 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.50618 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.67883 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.64239 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.73050 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.52918 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.69605 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.61648 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.66734 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.77956 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.66160 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.66827 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.66734 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.77089 * CGRectGetHeight(frame))];
    [openPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.66734 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.80639 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.66734 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.78818 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.66734 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.80639 * CGRectGetHeight(frame))];
    [openPath closePath];
    
    
    closedPath = closedPath = UIBezierPath.bezierPath;
    [closedPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.66734 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.80639 * CGRectGetHeight(frame))];
    [closedPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.12471 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.80639 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.23093 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.65868 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.12471 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.80639 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.21659 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.67498 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.28548 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.58002 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.24529 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.64239 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.27973 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.58868 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.29984 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.52727 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.29123 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.57139 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.30559 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.53398 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.25677 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.48989 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.29410 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.52056 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.27975 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.50043 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.18213 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.41889 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.23380 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.47931 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.19073 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.45056 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.15629 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.37381 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.17351 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.38723 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.15916 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.38052 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.16204 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.35560 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.15342 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.36710 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.16204 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.36231 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.15055 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.29514 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.16204 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34889 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.13621 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.30477 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.25677 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.28460 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.16489 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.28556 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.19935 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.27214 * CGRectGetHeight(frame))];
    [closedPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.29984 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.23377 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.25677 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.28460 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.22519 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24048 * CGRectGetHeight(frame))];
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
