//
//  MMStretchGestureRecognizer3.m
//  ShapeShifter
//
//  Created by Adam Wulf on 2/28/14.
//  Copyright (c) 2014 Adam Wulf. All rights reserved.
//

#import "MMStretchGestureRecognizer3.h"
#import "Constants.h"
#import "NSMutableSet+Extras.h"
#import "MMVector.h"

@interface MMStretchGestureRecognizer2 (Private)

-(Quadrilateral) getRawQuad;
-(Quadrilateral) generateAverageQuadFor:(Quadrilateral)q;
-(void) checkStatus;

@end

@implementation MMStretchGestureRecognizer3{
    MMVector* startHVector;
    MMVector* startVVector;
}


//
//
// like the 2 gesture, but the lengths of each side should be determined by the ratio of distances
// between those touches.
//
// this way, the constraint that the quad always be a convex and never concave will be maintained,
// and some of the difference in width between touches is still involved in the resulting quad


-(Quadrilateral) generateAverageQuadFor:(Quadrilateral)q{
    Quadrilateral currQuad = [super generateAverageQuadFor:q];
    
    MMVector* currHVector = [self vectorHForQuad:q];
    MMVector* currVVector = [self vectorVForQuad:q];

    CGFloat angleHRotation = [startHVector angleBetween:currHVector];
    CGFloat angleVRotation = [startVVector angleBetween:currVVector];
    CGFloat angleAvg = (angleHRotation + angleVRotation) / 2;
    
    // chose the angle with the most change
    angleAvg = ABS(angleHRotation) > ABS(angleVRotation) ? angleHRotation : angleVRotation;
//    NSLog(@"angle rotation: %f  and %f  avg: %f", angleHRotation, angleVRotation, angle);
//    NSLog(@"ah:  %f  av: %f", angleHRotation, angleVRotation);
//    NSLog(@"cos: %f  and %f", cosf(angleHRotation), cosf(angleVRotation));
//    NSLog(@"sin: %f  and %f", sinf(angleHRotation), sinf(angleVRotation));
    NSLog(@"%f + %f = %f     cos: %f  sin: %f", angleHRotation, angleVRotation, angleAvg, cosf(angleAvg), sinf(angleAvg));
    
    
    
    Quadrilateral ret;
    if(sinf(angleAvg) > 0){
        ret.upperLeft = [self mixPoints:currQuad.upperLeft with:currQuad.upperRight for:angleAvg];
        ret.upperRight = [self mixPoints:currQuad.upperRight with:currQuad.lowerRight for:angleAvg];
        ret.lowerLeft = [self mixPoints:currQuad.lowerLeft with:currQuad.upperLeft for:angleAvg];
        ret.lowerRight = [self mixPoints:currQuad.lowerRight with:currQuad.lowerLeft for:angleAvg];
    }else{
        // rotate opposite direction
        ret.upperLeft = [self mixPoints:currQuad.upperLeft with:currQuad.lowerLeft for:angleAvg];
        ret.upperRight = [self mixPoints:currQuad.upperRight with:currQuad.upperLeft for:angleAvg];
        ret.lowerLeft = [self mixPoints:currQuad.lowerLeft with:currQuad.lowerRight for:angleAvg];
        ret.lowerRight = [self mixPoints:currQuad.lowerRight with:currQuad.upperRight for:angleAvg];
    }
    
    return ret;
}

-(void) checkStatus{
    [super checkStatus];

    if(self.state == UIGestureRecognizerStateBegan){
        Quadrilateral currQuad = [self getRawQuad];
        startHVector = [self vectorHForQuad:currQuad];
        startVVector = [self vectorVForQuad:currQuad];
    }
}


-(CGPoint) mixPoints:(CGPoint)p1 with:(CGPoint)p2 for:(CGFloat)a1{
    CGPoint retP = CGPointMake(p1.x * cosf(a1) + p2.x * (1-cosf(a1)),
                       p1.y * cosf(a1) + p2.y * (1-cosf(a1)));
//    NSLog(@"mixed %f with %f using %f and %f got %f", p1.x, p2.x, cosf(a1), (1-cosf(a1)), retP.x);
    return retP;
}


-(MMVector*) vectorHForQuad:(Quadrilateral)q{
    CGPoint midLeft = CGPointMake((q.upperLeft.x + q.lowerLeft.x)/2, (q.upperLeft.y + q.lowerLeft.y)/2);
    CGPoint midRight = CGPointMake((q.upperRight.x + q.lowerRight.x)/2, (q.upperRight.y + q.lowerRight.y)/2);
    return [MMVector vectorWithPoint:midLeft andPoint:midRight];
}

-(MMVector*) vectorVForQuad:(Quadrilateral)q{
    CGPoint midTop = CGPointMake((q.upperLeft.x + q.upperRight.x)/2, (q.upperLeft.y + q.upperRight.y)/2);
    CGPoint midLow = CGPointMake((q.lowerLeft.x + q.lowerRight.x)/2, (q.lowerLeft.y + q.lowerRight.y)/2);
    return [MMVector vectorWithPoint:midTop andPoint:midLow];
}

@end
