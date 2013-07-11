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

@implementation MMRulerView{
    CGPoint old_p1, old_p2;
    CGFloat originalDistance;
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
    if(originalDistance > 0){
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
        CGFloat nintyDistance = originalDistance * 3 / 5;
        // This is the distance between points that should result
        // in a 1 degree arc
        CGFloat oneDistance = originalDistance * 7 / 8;
        

        if(currentDistance < nintyDistance){
            NSLog(@"squeeze");
        }else if(currentDistance < oneDistance){
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
            
            // calculate the midpoint of the ruler, and it's distance to
            // an edge
            CGPoint midPoint = CGPointMake((tl.x + bl.x)/2, (tl.y + bl.y)/2);
            CGFloat distanceToMidPoint = DistanceBetweenTwoPoints(tl, midPoint);
            
            // need to half the radian b/c the line from the midpoint
            // bisects the angle to create the right triangle
            CGFloat triangleScalingFactor = distanceToMidPoint / sinf(radian/2);
            CGFloat distanceToCenter = cosf(radian/2) * triangleScalingFactor;
            
            // calculate direction of center point
            CGPoint center = [[perpN flip] pointFromPoint:midPoint distance:distanceToCenter];

            // now we have a right triangle between
            // tl, midpoint, and centerpoint
            //
            UIBezierPath* path = [UIBezierPath bezierPath];
            [path moveToPoint:midPoint];
            [path addLineToPoint:center];
            [path setLineWidth:2];
            [path stroke];

            //
            // draw the straight edge ruler lines
            [[UIColor blueColor] setStroke];
            path = [UIBezierPath bezierPath];
            [path moveToPoint:br];
            [path addLineToPoint:tr];
            [path moveToPoint:bl];
            [path addLineToPoint:tl];
            [path setLineWidth:2];
            [path stroke];

            
            
            path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:0 endAngle:M_PI * 2 clockwise:NO];
            [path stroke];
            
            NSLog(@"arc %f %f %f", percent, radius, currentDistance);
        }else{
            NSLog(@"straight");
            
            
            
            // draw lines for the edges
            [[UIColor blueColor] setStroke];
            path = [UIBezierPath bezierPath];
            [path moveToPoint:br];
            [path addLineToPoint:tr];
            [path moveToPoint:bl];
            [path addLineToPoint:tl];
            [path setLineWidth:2];
            [path stroke];
            
        }
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
    originalDistance = distance;
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
    originalDistance = 0;
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
}

@end
