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

@implementation MMRulerView{
    CGPoint old_p1, old_p2;
    CGFloat initialDistance;
    
    UIBezierPath* path1;
    UIBezierPath* path2;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:.3];
    }
    return self;
}

/**
 * Draw our ruler
 */
- (void)drawRect:(CGRect)rect
{
    if(initialDistance > 0){
        // calculate the current distance
        CGFloat currentDistance = DistanceBetweenTwoPoints(old_p1, old_p2);
        
        // calculate the perpendicular normal
        MMVector* perpN = [[[MMVector vectorWithPoint:old_p1 andPoint:old_p2] perpendicular] normal];
        
        // calculate the four corners of our ruler
        CGPoint tl = [perpN pointFromPoint:old_p1 distance:40];
        CGPoint tr = [perpN pointFromPoint:old_p1 distance:-40];
        CGPoint bl = [perpN pointFromPoint:old_p2 distance:40];
        CGPoint br = [perpN pointFromPoint:old_p2 distance:-40];
        
        // Drawing code
        
        // draw lines to cap the ruler
        [[UIColor redColor] setStroke];
        UIBezierPath* path = [UIBezierPath bezierPath];
        [path moveToPoint:tl];
        [path addLineToPoint:tr];
        [path moveToPoint:bl];
        [path addLineToPoint:br];
        [path setLineWidth:2];
        [path stroke];
        
        // This is the distance between points that should result
        // in a 90 degree arc
        CGFloat nintyDistance = initialDistance * 3 / 5;
        // This is the distance between points that should result
        // in a 1 degree arc
        CGFloat oneDistance = initialDistance - 40;
        

        [[UIColor blueColor] setStroke];
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
            path1 = [self drawArcWithOriginalDistance:currentDistance * 5 / 3 currentDistance:currentDistance andPerpN:[perpN flip] withPoint1:tl andPoint2:bl andScale:scale];
            path2 = [self drawArcWithOriginalDistance:currentDistance * 5 / 3 currentDistance:currentDistance andPerpN:perpN withPoint1:br andPoint2:tr andScale:scale];
        }else if(currentDistance < oneDistance){
            // the user has pinched enough that we should
            // start to use an arc path between the points
            // instead of a straight line
            path1 = [self drawArcWithOriginalDistance:initialDistance currentDistance:currentDistance andPerpN:[perpN flip] withPoint1:tl andPoint2:bl andScale:1];
            path2 = [self drawArcWithOriginalDistance:initialDistance currentDistance:currentDistance andPerpN:perpN withPoint1:br andPoint2:tr andScale:1];
        }else{
            // draw lines for the edges
            path1 = [UIBezierPath bezierPath];
            path2 = [UIBezierPath bezierPath];
            [path1 moveToPoint:br];
            [path1 addLineToPoint:tr];
            [path2 moveToPoint:bl];
            [path2 addLineToPoint:tl];
        }
        [path1 setLineWidth:2];
        [path1 stroke];
        [path2 setLineWidth:2];
        [path2 stroke];
    }
}


/**
 * @param currentDistance: the distance between the two input points
 * @param perpN the normalized vector that is perpendicular to the segment between the input points, this points toward the center of the circle
 * @param tl and bl
 *
 * this method will draw an arc connecting the two input points
 */
-(UIBezierPath*) drawArcWithOriginalDistance:(CGFloat)originalDistance currentDistance:(CGFloat)currentDistance andPerpN:(MMVector*)perpN withPoint1:(CGPoint)point1 andPoint2:(CGPoint)point2 andScale:(CGFloat)scale{

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
    
//    NSLog(@"angle: %f %f   %f %f     %f", endAngle, startAngle, center.x, center.y, radius);
    
    // now draw the arc between the two points
    [[UIColor blueColor] setStroke];
    UIBezierPath* path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:endAngle endAngle:startAngle clockwise:NO];
    
    // now scale
    [path applyTransform:CGAffineTransformMakeTranslation(-center.x, -center.y)];
    [path applyTransform:CGAffineTransformRotate(CGAffineTransformIdentity, -[perpN angle])];
    [path applyTransform:CGAffineTransformScale(CGAffineTransformIdentity, scale, 1)];
    [path applyTransform:CGAffineTransformRotate(CGAffineTransformIdentity, [perpN angle])];
    [path applyTransform:CGAffineTransformMakeTranslation(center.x, center.y)];

    return path;
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


#pragma mark - adjust stroke to elements

-(NSArray*) adjustElement:(AbstractBezierPathElement*)element{
    

    if(path1){
        AbstractBezierPathElement* newElement;
        
        //
        // TODO: #21
        // this is finding the nearest point to any element inside the stroke.
        // i need to find the nearest point to every element in a stroke (?)
        // and then filter them by distance to find the actual shortest point.
        //
        // then i should do the same on path2, and find out which path the
        // user is drawing closest to.
        //
        // then i can use elementHitByPoint: to find the t value on the element
        // that was hit, and use that to split the curve into the exact pieces.
        // then use those pieces to build an array of elements to return.
        //
        CGPoint pointNearTheCurve = element.startPoint;
        CGPoint nearestStart; // = [path1 nearestPointToPoint:pointNearTheCurve tolerance:1000];
        CGPoint nearestEnd;
        
        nearestStart = [path1 closestPointOnPathTo:pointNearTheCurve];
        
        if([element isKindOfClass:[LineToPathElement class]]){
            nearestEnd = [(LineToPathElement*)element lineTo];
            nearestEnd = [path1 closestPointOnPathTo:nearestEnd];
            newElement = [CurveToPathElement elementWithStart:nearestStart andCurveTo:nearestEnd andControl1:nearestStart andControl2:nearestEnd];
            newElement.color = element.color;
            newElement.width = element.width;
            newElement.rotation = element.rotation;
        }else if([element isKindOfClass:[MoveToPathElement class]]){
            nearestEnd = [(MoveToPathElement*)element startPoint];
            newElement = [MoveToPathElement elementWithMoveTo:nearestStart];
            newElement.color = element.color;
            newElement.width = element.width;
            newElement.rotation = element.rotation;
        }else if([element isKindOfClass:[CurveToPathElement class]]){
            nearestEnd = [(CurveToPathElement*)element curveTo];
            nearestEnd = [path1 closestPointOnPathTo:nearestEnd];
            newElement = [CurveToPathElement elementWithStart:nearestStart andCurveTo:nearestEnd andControl1:nearestStart andControl2:nearestEnd];
            newElement.color = element.color;
            newElement.width = element.width;
            newElement.rotation = element.rotation;
        }
        return [NSArray arrayWithObject:newElement];
    }
    
    return [NSArray arrayWithObject:element];
}

-(NSArray*) willAddElementsToStroke:(NSArray *)elements{
    NSMutableArray* output = [NSMutableArray array];
    for(AbstractBezierPathElement* element in elements){
        [output addObjectsFromArray:[self adjustElement:element]];
    }
    return output;
}



#pragma mark - Private Helpers

/**
 * this setNeedsDisplay in a rectangle that contains both the the
 * new ruler dimentions (input) and the old ruler dimensions
 * (old points).
 */
-(void) updateRectForPoint:(CGPoint)p1 andPoint:(CGPoint)p2{
    CGPoint minP = CGPointMake(MIN(MIN(MIN(p1.x, p2.x), old_p1.x), old_p2.x), MIN(MIN(MIN(p1.y, p2.y), old_p1.y), old_p2.y));
    CGPoint maxP = CGPointMake(MAX(MAX(MAX(p1.x, p2.x), old_p1.x), old_p2.x), MAX(MAX(MAX(p1.y, p2.y), old_p1.y), old_p2.y));
    CGRect needsDisp = CGRectMake(minP.x, minP.y, maxP.x - minP.x, maxP.y - minP.y);
    needsDisp = CGRectInset(needsDisp, -80, -80);
    [self setNeedsDisplayInRect:needsDisp];
    [self setNeedsDisplay];
}

@end
