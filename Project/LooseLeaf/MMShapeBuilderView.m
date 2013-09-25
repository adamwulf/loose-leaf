//
//  MMPolygonDebugView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/17/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMShapeBuilderView.h"
#import <TouchShape/TouchShape.h>
#import "DrawKit-iOS.h"
#import "UIColor+ColorWithHex.h"
#import "SYShape+Bezier.h"
#import "Constants.h"

@implementation MMShapeBuilderView{
    
    // the array of touches used to build
    // the dashed path
    NSMutableArray* touches;
    
    // the dashed path
    UIBezierPath* dottedPath;
    
    // phrase track where the dotted line will
    // start, so that it looks like it's
    // following your finger
    CGFloat phase;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        touches = [NSMutableArray array];
    }
    return self;
}

-(void) clear{
    [touches removeAllObjects];
    dottedPath = nil;
    [self setNeedsDisplay];
    phase = 0;
}

/**
 * add the touch point to the shape
 * that the user is drawing
 *
 * return if the user has drawn a self intersecting
 * shape.
 */
-(BOOL) addTouchPoint:(CGPoint)point{
    __block BOOL didIntersectSelf = NO;
    CGFloat distTravelled = 0;
    
    if(![touches count]){
        dottedPath = [UIBezierPath bezierPath];
        [dottedPath moveToPoint:point];
    }else{
        CGPoint lastTouchPoint = [[touches lastObject] CGPointValue];
        CGPoint p1 = lastTouchPoint;
        CGPoint p2 = point;
        __block CGPoint p3, p4;
        p3 = CGPointZero;
        p4 = CGPointZero;
        
        /**
         * this will look at the most recent line segment
         * that the user drew, and will check to see if it
         * intersects any of the other line segments
         */
        [dottedPath iteratePathWithBlock:^(CGPathElement element){
            // track the point from the previous element
            // and look to see if it intersects with the
            // last drawn element.
            //
            // we know that points[0] is the endpoint, since
            // all of our segments are line segments or move to.
            p4 = element.points[0];
            
            if(!CGPointEqualToPoint(p3, CGPointZero)){
                // we have a p3 and a p4
                CGPoint result = Intersection3(p1,p2,p4,p3);
                if(!CGPointEqualToPoint(result, CGNotFoundPoint)){
                    if(CGPointEqualToPoint(result, p1) ||
                       CGPointEqualToPoint(result, p3)){
                        // noop
                    }else{
                        didIntersectSelf = YES;
                        // we self intersected! let our
                        // caller know so it can stop
                        // recognition if need be
                    }
                }
            }
            p3 = p4;
        }];
        
        distTravelled = MIN(DistanceBetweenTwoPoints(lastTouchPoint, point), 50);
        if(distTravelled > 2){
            // only add a line if it's more than 2pts drawn,
            // otherwise it's a mess and would self intersect
            // way too soon
            [dottedPath addLineToPoint:point];
        }
        [self setNeedsDisplayInRect:CGRectInset(dottedPath.bounds, -10, -10)];
    }
    [touches addObject:[NSValue valueWithCGPoint:point]];
    phase += distTravelled / 15;

    return didIntersectSelf;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    //
    // this draws a white and black dashed line
    CGFloat dash[3];
    dash[0] = 12;
    dash[1] = 10;
    dottedPath.lineWidth = 3;
    
    [dottedPath setLineDash:nil count:0 phase:0];
    [[UIColor whiteColor] setStroke];
    [dottedPath stroke];

    NSInteger phaseInt = ((int)phase) % 22;
    [dottedPath setLineDash:dash count:2 phase:22 - phaseInt];
    [[UIColor blackColor] setStroke];
    [dottedPath stroke];

}

/**
 * returns an array of all bezier paths created
 */
-(NSArray*) completeAndGenerateShapes{
    if(![touches count]) return nil;
    
    //
    //
    // at this point, all touch points from the user
    // are stored in the _touches_ array.
    //
    // this method will send these points into the
    // TCShapeController to get shape output.
    //
    // first we'll do a bit of preprocessing on these
    // points. if the user draws a line that intersects
    // itself, then we'll split it into two lines that
    // don't intersect. this way, drawing a "figure 8"
    // will generate two paths, one for each o of the 8.
    
    
    
    // first, create a single bezier path that connects
    // all of the touch points from start to finish
    UIBezierPath* pathOfAllTouchPoints = [UIBezierPath bezierPath];
    CGPoint firstPoint = [[touches objectAtIndex:0] CGPointValue];
    [pathOfAllTouchPoints moveToPoint:firstPoint];
    for(int i=1;i < [touches count];i++){
        CGPoint point = [[touches objectAtIndex:i] CGPointValue];
        [pathOfAllTouchPoints addLineToPoint:point];
    }
    
    
    //
    // now pathOfAllTouchPoints is a single line connecting all the touches.
    // from here, split the path into multiple paths at each
    // intersection point.
    NSArray* pathsFromIntersectingTouches = [pathOfAllTouchPoints pathsFromSelfIntersections];
    

    //
    // now we'll loop over each sub-path, and send all the points
    // to a new TCShapeController, so that we can interpret a shape
    // for each non-intersecting path.
    NSMutableArray* shapePaths = [NSMutableArray array];
    for(UIBezierPath* singlePath in pathsFromIntersectingTouches){
        TCShapeController* shapeMaker = [[TCShapeController alloc] init];
        __block CGPoint prevPoint = CGPointZero;
        __block NSInteger index = 0;
        NSInteger count = [singlePath elementCount];
        [singlePath iteratePathWithBlock:^(CGPathElement element){
            // our path is only made of line-to segments
            if(element.type == kCGPathElementAddLineToPoint){
                if(index == count - 1){
                }else if(index == count - 2){
                    // this is the last element of the path, so tell our
                    // shape controller
                    [shapeMaker addLastPoint:element.points[0]];
                }else{
                    // this is a point inside the path, so tell the
                    // shape controller about the previous point and this point
                    [shapeMaker addPoint:prevPoint andPoint:element.points[0]];
                }
            }
            prevPoint = element.points[0];
            index++;
        }];
        // the shape controller knows about all the points in this subpath,
        // so see if it can recognize a shape
        SYShape* shape = [shapeMaker getFigurePaintedWithTolerance:0.0000001 andContinuity:0];
        if(shape){
            if(shape.closeCurve){
                // shape is a closed path,
                // so create a scrap from it
                UIBezierPath* shapePath = [shape bezierPath];
                [shapePaths addObject:shapePath];
            }else{
                // shape is unclosed, so don't add
                // it as a scrap
            }
        }else{
            // this is more rare than it used to be. this will
            // trigger when we can't determine any shape from a path,
            // usually when the user draws an unclosed path that's
            // not close enough to self-close
        }
    }
    [self setNeedsDisplay];
    
    return [NSArray arrayWithArray:shapePaths];
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

@end
