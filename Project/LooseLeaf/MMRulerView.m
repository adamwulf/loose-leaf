//
//  MMRulerView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/10/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMRulerView.h"
#import "Constants.h"
#import "MMVector.h"
#import <DrawKit-iOS/UIBezierPath+NSOSX.h>
#import <DrawKit-iOS/UIBezierPath+Editing.h>
#import <DrawKit-iOS/UIBezierPath+Ahmed.h>
#import <JotUI/JotUI.h>
#import <JotUI/AbstractBezierPathElement-Protected.h>
#import "UIDevice+PPI.h"

@interface MMPointAndVector : NSObject
@property (nonatomic) CGPoint point;
@property (nonatomic) MMVector* vector;
-(id) initWithPoint:(CGPoint)point andVector:(MMVector*)vector;
@end
@implementation MMPointAndVector{
    CGPoint point;
    MMVector* vector;
}
@synthesize point, vector;
-(id) initWithPoint:(CGPoint)_point andVector:(MMVector*)_vector{
    if(self = [super init]){
        self.point = _point;
        self.vector = _vector;
    }
    return self;
}
@end




@implementation MMRulerView{
    CGPoint old_p1, old_p2;
    CGFloat initialDistance;
    CGFloat unitLength;
    
    UIBezierPath* drawThisPath;
    UIBezierPath* ticks;
    UIBezierPath* path1;
    UIBezierPath* path2;
    UIBezierPath* path1Full;
    UIBezierPath* path2Full;
    
    BOOL nearestPathIsPath1;
    
    CGPoint lastEndPointOfStroke;
    JotView* jotView;
    
    
    UIBezierPath* pathSegmentFromNearestStart;
}

@synthesize jotView;

+(UIColor*) rulerColor{
    return [UIColor colorWithRed: 77.0/255.0 green: 187.0/255.0 blue: 1.0 alpha: 1];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
//        self.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:.3];
        self.backgroundColor = [UIColor clearColor];
        unitLength = [UIDevice ppc];
        pathSegmentFromNearestStart = [UIBezierPath bezierPath];
    }
    return self;
}

static NSDate* lastRender;

- (void)drawRect:(CGRect)rect
{
    // draw ticks
    lastRender = [NSDate date];
    [self drawRectHelper];
    [[MMRulerView rulerColor] setStroke];
    [drawThisPath setLineWidth:1];
    [drawThisPath stroke];
    
    [pathSegmentFromNearestStart setLineWidth:2];
    [[[UIColor blueColor] colorWithAlphaComponent:.5] setStroke];
    [pathSegmentFromNearestStart stroke];
}


/**
 * Draw our ruler
 */
- (void)drawRectHelper{
    if(CGPointEqualToPoint(old_p1, CGPointZero) || CGPointEqualToPoint(old_p2, CGPointZero)){
        return;
    }
    if(initialDistance > 0){
        // calculate the current distance
        CGFloat currentDistance = DistanceBetweenTwoPoints(old_p1, old_p2);
        
        // calculate the perpendicular normal
        MMVector* normal = [[MMVector vectorWithPoint:old_p1 andPoint:old_p2] normal];
        MMVector* perpN = [normal perpendicular];
        
        // calculate the four corners of our ruler
        CGPoint tl = [perpN pointFromPoint:old_p1 distance:kWidthOfRuler];
        CGPoint tr = [perpN pointFromPoint:old_p1 distance:-kWidthOfRuler];
        CGPoint bl = [perpN pointFromPoint:old_p2 distance:kWidthOfRuler];
        CGPoint br = [perpN pointFromPoint:old_p2 distance:-kWidthOfRuler];
        
        // Drawing code
        
        // This is the distance between points that should result
        // in a 90 degree arc
        CGFloat nintyDistance = initialDistance * 3 / 5;
        // This is the distance between points that should result
        // in a 1 degree arc
        CGFloat oneDistance = initialDistance - kRulerPinchBuffer;
        

        if(currentDistance < nintyDistance){
            // the user has pinched so that the arc
            // is now a semi circle.
            //
            // we should scale that semicircle so that it
            // stretches out into a thinner curve
            //
            // this will bounce the curve slightly near where
            // currentDistance == nintyDistance. this is where
            // the ruler makes a semicircle. instead we bounce
            // slightly out further, then bounce back to a
            // scale that will keep the curve's distance exactly
            // where it is at the semicircle
            //
            // our default scale to keep distance correct
            CGFloat scale = nintyDistance / currentDistance;
            // a squared scale to bounce toward
            CGFloat scale2 = scale * scale;
            // cap the scale at 2x (time is 1 < time < 2)
            CGFloat time = MIN(scale, 2);
            // get the inverse of the time
            // time is 0 < time < 1
            CGFloat invTime = (2 - time);
            // now quartic easing
            CGFloat easing = invTime*invTime*invTime*invTime;
            // now use the squared scale at the beginning, and
            // ease out to the normal scale
            scale = easing * scale2 + (1 - easing) * scale;
            ticks = [UIBezierPath bezierPath];
            [self drawArcWithOriginalDistance:currentDistance * 5 / 3 currentDistance:currentDistance andPerpN:[perpN flip] withPoint1:tl andPoint2:bl andScale:scale onComplete:^(UIBezierPath* clippedPath, UIBezierPath* circle, UIBezierPath* tickMarks){
                path1 = clippedPath;
                path1Full = circle;
                [ticks appendPath:tickMarks];
            }];
            [self drawArcWithOriginalDistance:currentDistance * 5 / 3 currentDistance:currentDistance andPerpN:perpN withPoint1:br andPoint2:tr andScale:scale onComplete:^(UIBezierPath* clippedPath, UIBezierPath* circle, UIBezierPath* tickMarks){
                path2 = clippedPath;
                path2Full = circle;
                [ticks appendPath:tickMarks];
            }];
        }else if(currentDistance < oneDistance){
            // the user has pinched enough that we should
            // start to use an arc path between the points
            // instead of a straight line
            ticks = [UIBezierPath bezierPath];
            [self drawArcWithOriginalDistance:initialDistance currentDistance:currentDistance andPerpN:[perpN flip] withPoint1:tl andPoint2:bl andScale:1 onComplete:^(UIBezierPath* clippedPath, UIBezierPath* circle, UIBezierPath* tickMarks){
                path1 = clippedPath;
                path1Full = circle;
                [ticks appendPath:tickMarks];
            }];
            [self drawArcWithOriginalDistance:initialDistance currentDistance:currentDistance andPerpN:perpN withPoint1:br andPoint2:tr andScale:1 onComplete:^(UIBezierPath* clippedPath, UIBezierPath* circle, UIBezierPath* tickMarks){
                path2 = clippedPath;
                path2Full = circle;
                [ticks appendPath:tickMarks];
            }];
        }else{
            CGFloat ratio =  initialDistance / currentDistance;
            ratio = MAX(ratio, 0.5);
            
            tl = [perpN pointFromPoint:old_p1 distance:kWidthOfRuler * ratio];
            tr = [perpN pointFromPoint:old_p1 distance:-kWidthOfRuler * ratio];
            bl = [perpN pointFromPoint:old_p2 distance:kWidthOfRuler * ratio];
            br = [perpN pointFromPoint:old_p2 distance:-kWidthOfRuler * ratio];
            
            CGFloat lengthOfRuler = DistanceBetweenTwoPoints(tl, bl);
            CGPoint leftMidPoint = [normal pointFromPoint:tl distance:lengthOfRuler/2];
            CGPoint rightMidPoint = [normal pointFromPoint:tr distance:lengthOfRuler/2];
            MMVector* flippedPerpN = [perpN flip];
            
            // this path will contain all the tick marks
            ticks = [UIBezierPath bezierPath];
            // center ticks first
            [ticks moveToPoint:leftMidPoint];
            [ticks addLineToPoint:[[perpN flip] pointFromPoint:leftMidPoint distance:10]];
            [ticks moveToPoint:rightMidPoint];
            [ticks addLineToPoint:[perpN pointFromPoint:rightMidPoint distance:10]];
            
            
            // very simple helper that'll add a tick mark
            // at the input point for the given length
            void(^addTick)(UIBezierPath* path, CGPoint point, MMVector* perpN, CGFloat width) = ^(UIBezierPath* path, CGPoint point, MMVector* perpN, CGFloat length){
                [path moveToPoint:point];
                [path addLineToPoint:[perpN pointFromPoint:point distance:length]];
            };
            
            // now we're going to loop until the end of the ruler and draw
            // all of the tick marks on both sides.
            NSArray* tickArray = [NSArray arrayWithObjects:[[MMPointAndVector alloc] initWithPoint:leftMidPoint andVector:flippedPerpN],
            [[MMPointAndVector alloc] initWithPoint:rightMidPoint andVector:perpN], nil];
            CGFloat drawnTickLengthSoFar = unitLength;
            do{
                for(MMPointAndVector* pointAndVector in tickArray){
                    if(drawnTickLengthSoFar < lengthOfRuler / 2){
                        addTick(ticks, [normal pointFromPoint:pointAndVector.point distance:drawnTickLengthSoFar], pointAndVector.vector, 10);
                        addTick(ticks, [normal pointFromPoint:pointAndVector.point distance:-drawnTickLengthSoFar], pointAndVector.vector, 10);
                    }
                    if(drawnTickLengthSoFar - unitLength / 2 < lengthOfRuler / 2){
                        addTick(ticks, [normal pointFromPoint:pointAndVector.point distance:drawnTickLengthSoFar - unitLength / 2], pointAndVector.vector, 7);
                        addTick(ticks, [normal pointFromPoint:pointAndVector.point distance:-drawnTickLengthSoFar + unitLength / 2], pointAndVector.vector, 7);
                    }
                    if(drawnTickLengthSoFar - unitLength / 4 < lengthOfRuler / 2){
                        addTick(ticks, [normal pointFromPoint:pointAndVector.point distance:drawnTickLengthSoFar - unitLength / 4], pointAndVector.vector, 5);
                        addTick(ticks, [normal pointFromPoint:pointAndVector.point distance:-drawnTickLengthSoFar + unitLength / 4], pointAndVector.vector, 5);
                    }
                    if(drawnTickLengthSoFar - unitLength * 3 / 4 < lengthOfRuler / 2){
                        addTick(ticks, [normal pointFromPoint:pointAndVector.point distance:drawnTickLengthSoFar - unitLength * 3 / 4], pointAndVector.vector, 5);
                        addTick(ticks, [normal pointFromPoint:pointAndVector.point distance:-drawnTickLengthSoFar + unitLength * 3 / 4], pointAndVector.vector, 5);
                    }
                }
                drawnTickLengthSoFar += unitLength;
                // we need to loop slightly longer than the length of the ruler,
                // so that if a partial unitLength needs to be drawn it will
            }while(drawnTickLengthSoFar < lengthOfRuler / 2 + unitLength);
            
            // draw lines for the edges of the ruler
            path1 = [UIBezierPath bezierPath];
            path2 = [UIBezierPath bezierPath];
            [path1 moveToPoint:bl];
            [path1 addLineToPoint:tl];
            [path2 moveToPoint:br];
            [path2 addLineToPoint:tr];
            
            path1Full = path1;
            path2Full = path2;
        }
        
        drawThisPath = [UIBezierPath bezierPath];
        [drawThisPath appendPath:path1];
        [drawThisPath appendPath:path2];
        [drawThisPath appendPath:ticks];
    }
}


/**
 * @param currentDistance: the distance between the two input points
 * @param perpN the normalized vector that is perpendicular to the segment between the input points, this points toward the center of the circle
 * @param tl and bl
 *
 * this method will draw an arc connecting the two input points
 */
-(void) drawArcWithOriginalDistance:(CGFloat)originalDistance currentDistance:(CGFloat)currentDistance andPerpN:(MMVector*)perpN withPoint1:(CGPoint)point1 andPoint2:(CGPoint)point2 andScale:(CGFloat)scale onComplete:(void(^)(UIBezierPath* clippedPath, UIBezierPath* fullCirclePath, UIBezierPath* tickMarks))onComplete{
    
    CGFloat nintyDistance = originalDistance * 3 / 5;
    // This is the distance between points that should result
    // in a 1 degree arc
    CGFloat oneDistance = originalDistance - 40;
    
    //
    // in this section, we need to show an arc of a circle
    // that will connect the two end points. starting from a near
    // flat line when currentDistance == oneDistance,
    // and showing a semicircle when currentDistance = nintyDistance
    //
    // what's the difference in distance when we start
    // the arc and when we'd end the arc?
    CGFloat span = nintyDistance - oneDistance;
    // now how far are we currently through that 1->90 degree span?
    // 0% == we are mostly a straight line,
    // 100% == we should show a semicircle
    CGFloat percent = 1 - (nintyDistance - currentDistance) / span;
    // what is the angle that we should be for the given percent?
    // 0 is flat, and M_PI is the semi circle
    CGFloat radian = percent * M_PI;
    // now calculate the radius of the circle that's needed
    // to show the arc between the two points
    // math from http://math.stackexchange.com/questions/225323/length-of-arc-connecting-2-points-in-n-dimensions
    //            angle θ=2arcsin(d/(2r))
    //            so that means that radius = d/(2sin(θ/2))
    CGFloat radius = currentDistance / (2 * sinf(radian / 2));
    // this will determine the total length of the visible arc
    CGFloat arcLength = radian * radius;
    
    // calculate the midpoint of the ruler, and it's distance
    // from one of the two ruler corners that it splits
    CGPoint midPoint = CGPointMake((point1.x + point2.x)/2, (point1.y + point2.y)/2);
    CGFloat distanceToMidPoint = DistanceBetweenTwoPoints(point1, midPoint);
    
    // now we have a right triangle between a ruler corner, the midpoint
    // of the line, and the center of the triangle.
    // we also know the angle of the circle that we want to create.
    // splitting that angle in half will be the small angle of the
    // right triangle. the distance between the midpoint and endpoint
    // is the sin of that angle. the cos is the distance from the
    // midpoint to the center.
    //
    // then we take the vector from the midpoint to the center of the
    // circle with the distance that we just calculated. that'll give
    // us the location of the circle center point.
    
    // need to half the radian b/c the line from the midpoint
    // bisects the angle to create the right triangle
    CGFloat triangleScalingFactor = distanceToMidPoint / sinf(radian/2);
    CGFloat distanceToCenter = cosf(radian/2) * triangleScalingFactor;
    
    // calculate direction of center point
    CGPoint center = [perpN pointFromPoint:midPoint distance:distanceToCenter];
    
    // this method will calculate the angle on the unit circle for the
    // input point given the circle's input center
    CGFloat(^calculateAngle)(CGPoint, CGPoint) = ^CGFloat(CGPoint pointOnCircle, CGPoint center){
        CGFloat theta = atanf((pointOnCircle.y - center.y) / (pointOnCircle.x - center.x));
        BOOL isYNeg = (pointOnCircle.y - center.y) < 0;
        BOOL isXNeg = (pointOnCircle.x - center.x) < 0;
        
        // adjust the angle depending on which quadrant it's in
        if(isYNeg && isXNeg){
            theta -= M_PI;
        }else if(!isYNeg && isXNeg){
            theta += M_PI;
        }
        return theta;
    };
    
    //
    // now we have the center of the circle, its arc in radians, its radius,
    // and two points that we want to connect on its circumference.
    //
    // to do that, we need to know the angle of each of the two points
    // for the unit circle
    CGFloat endAngle = calculateAngle(point1, center);
    CGFloat startAngle = calculateAngle(point2, center);
    
    // now draw the arc between the two points
    UIBezierPath* path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:endAngle endAngle:startAngle clockwise:NO];
    UIBezierPath* circle = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:0 endAngle:M_PI*2 clockwise:NO];
    UIBezierPath* tickMarks = [UIBezierPath bezierPath];

    //
    // calculate the vectors that will point
    // to the start, and mid point of our
    // circle
    MMVector* midVector = [perpN flip];

    // find the circumference
    CGFloat circum = (M_PI * radius * 2);
    CGFloat unitAngleRatio = (unitLength / circum);
    // now find the angle we need to rotate
    // to travel one unitlength along the circumference
    CGFloat unitAngle = unitAngleRatio * M_PI * 2;
    
    
    //
    // check to see if we need to draw tick marks for an arc
    // instead of a sqeezed bezier
    if(scale == 1){
        // this will find the center of the semicircle stroke, and the vector
        // that points to it from the center of the circle
        midPoint = [midVector pointFromPoint:center distance:radius];
        [tickMarks moveToPoint:midPoint];
        [tickMarks addLineToPoint:[[midVector flip] pointFromPoint:midPoint distance:10]];
        
        // this will track how far we've drawn our ticks along the arc
        CGFloat drawnLength = 0;
        CGFloat rotatedAngle = 0;
        do{
            // unit angle is the unit length / circumference
            // this lets us rotate the centerVector by unitAngle
            // to get the tick marks for each unitlength along the
            // the circumference
            drawnLength += unitLength;
            rotatedAngle += unitAngle;
            
            
            // now draw the ticks that will fit inside the visible arc
            MMVector* nextVector;
            CGPoint nextPoint;
            
            // now check to see which ticks inside this unitLength
            // segment should be drawn along the arc
            if(drawnLength < arcLength / 2){
                nextVector = [[midVector rotateBy:rotatedAngle] normal];
                nextPoint = [nextVector pointFromPoint:center distance:radius];
                [tickMarks moveToPoint:nextPoint];
                [tickMarks addLineToPoint:[[nextVector flip] pointFromPoint:nextPoint distance:10]];
                
                nextVector = [[midVector rotateBy:-rotatedAngle] normal];
                nextPoint = [nextVector pointFromPoint:center distance:radius];
                [tickMarks moveToPoint:nextPoint];
                [tickMarks addLineToPoint:[[nextVector flip] pointFromPoint:nextPoint distance:10]];
            }
            if(drawnLength - unitLength / 2 < arcLength / 2){
                nextVector = [[midVector rotateBy:rotatedAngle - unitAngle / 2] normal];
                nextPoint = [nextVector pointFromPoint:center distance:radius];
                [tickMarks moveToPoint:nextPoint];
                [tickMarks addLineToPoint:[[nextVector flip] pointFromPoint:nextPoint distance:7]];
                
                nextVector = [[midVector rotateBy:-rotatedAngle + unitAngle / 2] normal];
                nextPoint = [nextVector pointFromPoint:center distance:radius];
                [tickMarks moveToPoint:nextPoint];
                [tickMarks addLineToPoint:[[nextVector flip] pointFromPoint:nextPoint distance:7]];
            }
            if(drawnLength - unitLength / 4 < arcLength / 2){
                nextVector = [[midVector rotateBy:rotatedAngle - unitAngle / 4] normal];
                nextPoint = [nextVector pointFromPoint:center distance:radius];
                [tickMarks moveToPoint:nextPoint];
                [tickMarks addLineToPoint:[[nextVector flip] pointFromPoint:nextPoint distance:5]];
                
                nextVector = [[midVector rotateBy:-rotatedAngle + unitAngle / 4] normal];
                nextPoint = [nextVector pointFromPoint:center distance:radius];
                [tickMarks moveToPoint:nextPoint];
                [tickMarks addLineToPoint:[[nextVector flip] pointFromPoint:nextPoint distance:5]];
            }
            if(drawnLength - unitLength * 3 / 4 < arcLength / 2){
                nextVector = [[midVector rotateBy:rotatedAngle - unitAngle * 3 / 4] normal];
                nextPoint = [nextVector pointFromPoint:center distance:radius];
                [tickMarks moveToPoint:nextPoint];
                [tickMarks addLineToPoint:[[nextVector flip] pointFromPoint:nextPoint distance:5]];
                
                nextVector = [[midVector rotateBy:-rotatedAngle + unitAngle * 3 / 4] normal];
                nextPoint = [nextVector pointFromPoint:center distance:radius];
                [tickMarks moveToPoint:nextPoint];
                [tickMarks addLineToPoint:[[nextVector flip] pointFromPoint:nextPoint distance:5]];
            }
        }while(drawnLength < arcLength / 2 + unitLength);
    }
    
    
    //
    // these transforms will scale the semicircle if needed
    // so that it things up when the user pinches their fingers
    CGAffineTransform transform = CGAffineTransformMakeTranslation(-center.x, -center.y);
    transform = CGAffineTransformConcat(transform, CGAffineTransformRotate(CGAffineTransformIdentity, -[perpN angle]));
    transform = CGAffineTransformConcat(transform, CGAffineTransformScale(CGAffineTransformIdentity, scale, 1));
    transform = CGAffineTransformConcat(transform, CGAffineTransformRotate(CGAffineTransformIdentity, [perpN angle]));
    transform = CGAffineTransformConcat(transform, CGAffineTransformMakeTranslation(center.x, center.y));
    
    [path applyTransform:transform];
    [circle applyTransform:transform];


    //
    // check if we need to draw tick marks for a squeezed beizer
    // instead of an arc
    if(scale > 1){
        // the transforms won't work for the tick marks,
        // we need to draw those in manually
        //
        // now draw the tick marks if the circle is squeezed
        // we could use this algorithm for the arc ticks as well, instead of
        // the above scale == 1 do loop, but this uses slightly more CPU
        // than the arc calculations above. so we'll keep them separate since
        // the arc will save some CPU cycles.
        CGFloat lengthOfPath = [path length];
        
        // first, draw the tick mark in the exact center of the arc
        UIBezierPath* trimmedToCenter = [path bezierPathByTrimmingFromLength:lengthOfPath / 2];
        CGFloat centerTangent = [trimmedToCenter tangentAtStartOfSubpath:0];
        MMVector* centerTickVector = [[[MMVector vectorWithAngle:centerTangent] perpendicular] normal];
        [tickMarks moveToPoint:[trimmedToCenter firstPoint]];
        [tickMarks addLineToPoint:[centerTickVector pointFromPoint:[trimmedToCenter firstPoint] distance:10]];
        
        // now we'll draw all the ticks from the center to the edge
        CGFloat drawnLength = 0;
        
        // chop the path in half
        UIBezierPath* pathFromMidPoint = [path bezierPathByTrimmingFromLength:(lengthOfPath / 2)];

        do{
            drawnLength += unitLength;
            
            // check for the ticks at the unitLength distance
            if(lengthOfPath / 2 > drawnLength){
                UIBezierPath* trimmed = [pathFromMidPoint bezierPathByTrimmingToLength:drawnLength withMaximumError:.5];
                CGFloat startTangent = [trimmed tangentAtEnd];
                MMVector* tickVector = [[[[MMVector vectorWithAngle:startTangent] perpendicular] normal] flip];
                
                // first tick
                [tickMarks moveToPoint:[trimmed lastPoint]];
                [tickMarks addLineToPoint:[tickVector pointFromPoint:[trimmed lastPoint] distance:10]];
                
                // now find the location of the 2nd tick
                // by refelcting the point across the center point line
                CGPoint lastPointPrime = [centerTickVector mirrorPoint:[trimmed lastPoint] aroundPoint:center];
                // the slope for the tick is a mirror of the other side's slope too
                tickVector = [[tickVector mirrorAround:centerTickVector] flip];
                
                // now add the 2nd tick
                [tickMarks moveToPoint:lastPointPrime];
                [tickMarks addLineToPoint:[tickVector pointFromPoint:lastPointPrime distance:10]];
            }
            if(lengthOfPath / 2 > drawnLength - unitLength / 2){
                UIBezierPath* trimmed = [pathFromMidPoint bezierPathByTrimmingToLength:drawnLength - unitLength / 2 withMaximumError:.5];
                CGFloat startTangent = [trimmed tangentAtEnd];
                MMVector* tickVector = [[[[MMVector vectorWithAngle:startTangent] perpendicular] normal] flip];
                
                [tickMarks moveToPoint:[trimmed lastPoint]];
                [tickMarks addLineToPoint:[tickVector pointFromPoint:[trimmed lastPoint] distance:7]];
                
                CGPoint lastPointPrime = [centerTickVector mirrorPoint:[trimmed lastPoint] aroundPoint:center];
                tickVector = [[tickVector mirrorAround:centerTickVector] flip];
                
                [tickMarks moveToPoint:lastPointPrime];
                [tickMarks addLineToPoint:[tickVector pointFromPoint:lastPointPrime distance:7]];
            }
            if(lengthOfPath / 2 > drawnLength - unitLength / 4){
                UIBezierPath* trimmed = [pathFromMidPoint bezierPathByTrimmingToLength:drawnLength - unitLength / 4 withMaximumError:.5];
                CGFloat startTangent = [trimmed tangentAtEnd];
                MMVector* tickVector = [[[[MMVector vectorWithAngle:startTangent] perpendicular] normal] flip];
                
                [tickMarks moveToPoint:[trimmed lastPoint]];
                [tickMarks addLineToPoint:[tickVector pointFromPoint:[trimmed lastPoint] distance:5]];
                
                CGPoint lastPointPrime = [centerTickVector mirrorPoint:[trimmed lastPoint] aroundPoint:center];
                tickVector = [[tickVector mirrorAround:centerTickVector] flip];
                
                [tickMarks moveToPoint:lastPointPrime];
                [tickMarks addLineToPoint:[tickVector pointFromPoint:lastPointPrime distance:5]];
            }
            if(lengthOfPath / 2 > drawnLength - unitLength * 3 / 4){
                UIBezierPath* trimmed = [pathFromMidPoint bezierPathByTrimmingToLength:drawnLength - unitLength * 3 / 4 withMaximumError:.5];
                CGFloat startTangent = [trimmed tangentAtEnd];
                MMVector* tickVector = [[[[MMVector vectorWithAngle:startTangent] perpendicular] normal] flip];
                
                [tickMarks moveToPoint:[trimmed lastPoint]];
                [tickMarks addLineToPoint:[tickVector pointFromPoint:[trimmed lastPoint] distance:5]];
                
                CGPoint lastPointPrime = [centerTickVector mirrorPoint:[trimmed lastPoint] aroundPoint:center];
                tickVector = [[tickVector mirrorAround:centerTickVector] flip];
                
                [tickMarks moveToPoint:lastPointPrime];
                [tickMarks addLineToPoint:[tickVector pointFromPoint:lastPointPrime distance:5]];
            }
        }while(drawnLength < lengthOfPath / 2 + unitLength);
    }
    
    if(onComplete){
        onComplete(path, circle, tickMarks);
    }
}

#pragma mark - Public Interface

/**
 * the ruler is being moved around on the screen between the
 * two input points p1 and p2, and the user had originally
 * started the ruler between start1 and start2
 */
-(void) updateLineAt:(CGPoint)p1 to:(CGPoint)p2 startingDistance:(CGFloat)distance{
    [self updateRectForPoint:p1 andPoint:p2];
    
    old_p1 = p1;
    old_p2 = p2;

    MMVector* normal = [[MMVector vectorWithPoint:old_p1 andPoint:old_p2] normal];
    
    // check if we're within 4 degrees of a straight angle
    if(ABS(ABS(normal.angle) - M_PI_2) < kRulerSnapAngle){
        old_p1.x = (old_p1.x + old_p2.x) / 2;
        old_p2.x = old_p1.x;
    }else if(ABS(normal.angle) < kRulerSnapAngle || ABS(normal.angle - M_PI) < kRulerSnapAngle){
        old_p1.y = (old_p1.y + old_p2.y) / 2;
        old_p2.y = old_p1.y;
    }

    initialDistance = distance;
}

/**
 * the ruler gesture has ended
 */
-(void) liftRuler{
    // set needs display in our current ruler
    [self updateRectForPoint:old_p1 andPoint:old_p2];
    
    // zero everything out.
    // this will cause our drawRect to
    // display nothing
    old_p1 = CGPointZero;
    old_p2 = CGPointZero;
    initialDistance = 0;
    
    path1 = nil;
    path2 = nil;
    path1Full = nil;
    path2Full = nil;
    ticks = nil;
    drawThisPath = nil;
}


#pragma mark - Ignore Touches

/**
 * these two methods make sure that the ruler view
 * can never intercept any touch input. instead it will
 * effectively pass through this view to the views behind it
 */
-(UIView*) hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    return nil;
}

-(BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    return NO;
}


#pragma mark - Adjust Stroke To Align To Ruler

/**
 * this method is called to give us a chance
 * to realign all the input elements to the ruler
 */
-(NSArray*) willAddElementsToStroke:(NSArray *)elements{
    NSMutableArray* output = [NSMutableArray array];
    for(AbstractBezierPathElement* element in elements){
        [output addObjectsFromArray:[self adjustElement:element]];
    }
    return output;
}

/**
 * we need to take this input point and decide
 * which side of the ruler the user is drawing on.
 * then we'll set our nearestPathIsPath1 flag,
 * which we'll use when adjusting all of the elements
 * of the stroke
 */
-(void) willBeginStrokeAt:(CGPoint)point{
    if(path1){
        pathSegmentFromNearestStart = [UIBezierPath bezierPath];
        //
        // we need to flip the coordinates of the path because
        // OpenGL and CoreGraphics have swapped coordinates
        UIBezierPath* flippedPath1 = [path1Full copy];
        [flippedPath1 applyTransform:CGAffineTransformMake(1, 0, 0, -1, 0, self.frame.size.height)];
        
        UIBezierPath* flippedPath2 = [path2Full copy];
        [flippedPath2 applyTransform:CGAffineTransformMake(1, 0, 0, -1, 0, self.frame.size.height)];
        
        CGPoint flippedPoint = CGPointApplyAffineTransform(point, CGAffineTransformMake(1, 0, 0, -1, 0, self.frame.size.height));
        
        // now find the closest points from the input to each path
        CGPoint nearestStart1 = [path1 closestPointOnPathTo:point];
        CGPoint nearestStart2 = [path2 closestPointOnPathTo:point];
        // pick the one that's closest
        CGFloat path1Dist = DistanceBetweenTwoPoints(nearestStart1, point);
        CGFloat path2Dist = DistanceBetweenTwoPoints(nearestStart2, point);
        
        if(path1Dist < path2Dist){
            nearestPathIsPath1 = YES;
            lastEndPointOfStroke = [flippedPath1 closestPointOnPathTo:flippedPoint];
        }else{
            nearestPathIsPath1 = NO;
            lastEndPointOfStroke = [flippedPath2 closestPointOnPathTo:flippedPoint];
        }
    }
}

/**
 * this will make sure we fire the begin stroke
 * before we render the ruler if the ruler + stroke
 * happen in the same touch event - ie, put three fingers
 * down at the same time
 */
-(void) willMoveStrokeAt:(CGPoint)point{
    if(path1 && CGPointEqualToPoint(lastEndPointOfStroke, CGPointZero)){
        [self willBeginStrokeAt:point];
    }
}


#pragma mark - Private Helpers

-(UIBezierPath*) findPathSegmentsForElement:(AbstractBezierPathElement*)element withNearestStart:(CGPoint)nearestStart andNearestEnd:(CGPoint)nearestEnd{
    UIBezierPath* flippedPath;
    
    if(nearestPathIsPath1){
        flippedPath = [path1Full copy];
        [flippedPath applyTransform:CGAffineTransformMake(1, 0, 0, -1, 0, self.frame.size.height)];
    }else{
        flippedPath = [path2Full copy];
        [flippedPath applyTransform:CGAffineTransformMake(1, 0, 0, -1, 0, self.frame.size.height)];
    }
    UIBezierPath* newPath = [flippedPath bezierPathByTrimmingFromClosestPointOnPathFrom:nearestStart to:nearestEnd];
    if(newPath){
        // this transform is so that we can draw it in core graphics correctly.
        // for opengl we shouldn't do this last flip
        [newPath applyTransform:CGAffineTransformMake(1, 0, 0, -1, 0, self.frame.size.height)];
        [pathSegmentFromNearestStart appendPath:newPath];
    }
    return newPath;
}

-(NSArray*) adjustElement:(AbstractBezierPathElement*)element{
    
    if(path1){
        UIBezierPath* flippedPath;
        CGPoint nearestStart;
        
        if(nearestPathIsPath1){
            flippedPath = [path1Full copy];
            [flippedPath applyTransform:CGAffineTransformMake(1, 0, 0, -1, 0, self.frame.size.height)];
            nearestStart = [flippedPath closestPointOnPathTo:element.startPoint];
        }else{
            flippedPath = [path2Full copy];
            [flippedPath applyTransform:CGAffineTransformMake(1, 0, 0, -1, 0, self.frame.size.height)];
            nearestStart = [flippedPath closestPointOnPathTo:element.startPoint];
        }
        
        
        AbstractBezierPathElement* newElement;
        
        //
        // TODO: #21
        // then i should do the same on path2, and find out which path the
        // user is drawing closest to.
        //
        // then i can use elementHitByPoint: to find the t value on the element
        // that was hit, and use that to split the curve into the exact pieces.
        // then use those pieces to build an array of elements to return.
        //
        CGPoint nearestEnd;
        
        nearestStart = lastEndPointOfStroke;
        
        if([element isKindOfClass:[LineToPathElement class]]){
            nearestEnd = [(LineToPathElement*)element lineTo];
            nearestEnd = [flippedPath closestPointOnPathTo:nearestEnd];
            newElement = [CurveToPathElement elementWithStart:nearestStart andCurveTo:nearestEnd andControl1:nearestStart andControl2:nearestEnd];
            newElement.color = element.color;
            newElement.width = element.width;
            newElement.rotation = element.rotation;
        }else if([element isKindOfClass:[MoveToPathElement class]]){
            nearestEnd = nearestStart;
            newElement = [MoveToPathElement elementWithMoveTo:nearestStart];
            newElement.color = element.color;
            newElement.width = element.width;
            newElement.rotation = element.rotation;
        }else if([element isKindOfClass:[CurveToPathElement class]]){
            nearestEnd = [(CurveToPathElement*)element curveTo];
            nearestEnd = [flippedPath closestPointOnPathTo:nearestEnd];
            newElement = [CurveToPathElement elementWithStart:nearestStart andCurveTo:nearestEnd andControl1:nearestStart andControl2:nearestEnd];
            newElement.color = element.color;
            newElement.width = element.width;
            newElement.rotation = element.rotation;
        }
        
        [self findPathSegmentsForElement:element withNearestStart:nearestStart andNearestEnd:nearestEnd];
        

        lastEndPointOfStroke = nearestEnd;
        return [NSArray arrayWithObject:newElement];
    }
    
    return [NSArray arrayWithObject:element];
}

/**
 * this setNeedsDisplay in a rectangle that contains both the the
 * new ruler dimentions (input) and the old ruler dimensions
 * (old points).
 */
-(void) updateRectForPoint:(CGPoint)p1 andPoint:(CGPoint)p2{
    CGPoint minP = CGPointMake(MIN(MIN(MIN(p1.x, p2.x), old_p1.x), old_p2.x), MIN(MIN(MIN(p1.y, p2.y), old_p1.y), old_p2.y));
    CGPoint maxP = CGPointMake(MAX(MAX(MAX(p1.x, p2.x), old_p1.x), old_p2.x), MAX(MAX(MAX(p1.y, p2.y), old_p1.y), old_p2.y));
    CGRect needsDisp = CGRectMake(minP.x, minP.y, maxP.x - minP.x, maxP.y - minP.y);
    needsDisp = CGRectUnion(needsDisp, [path1 bounds]);
    needsDisp = CGRectUnion(needsDisp, [path2 bounds]);
    needsDisp = CGRectInset(needsDisp, -80, -80);
    [self setNeedsDisplayInRect:needsDisp];
    // TODO: remove setNeedsDisplay
    [self setNeedsDisplay];
    NSTimeInterval lastRenderStamp = [lastRender timeIntervalSinceNow];
    if(lastRenderStamp < -.03){
//        NSLog(@"dropped frames %f", lastRenderStamp);
        [jotView slowDownFPS];
    }else{
        [jotView speedUpFPS];
    }
}

@end
