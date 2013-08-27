//
//  MMPolygonDebugView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/17/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMPolygonDebugView.h"
#import <TouchShape/TouchShape.h>
#import "DrawKit-iOS.h"
#import "UIColor+ColorWithHex.h"
#import "SYShape+Bezier.h"

@implementation MMPolygonDebugView{
    NSMutableArray* touches;
    NSMutableArray* shapePaths;
    NSArray* pathsFromIntersectingTouches;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        touches = [NSMutableArray array];
        shapePaths = [NSMutableArray array];
    }
    return self;
}

-(void) clear{
    [touches removeAllObjects];
    pathsFromIntersectingTouches = nil;
    [shapePaths removeAllObjects];
    [self setNeedsDisplay];
}

-(void) addTouchPoint:(CGPoint)point{
    [touches addObject:[NSValue valueWithCGPoint:point]];
    [self setNeedsDisplayInRect:CGRectMake(point.x - 10, point.y - 10, 20, 20)];
}


-(void) addPath:(UIBezierPath*)pathToDraw{
    if(!pathToDraw) return;
    [shapePaths addObject:[pathToDraw copy]];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    // This block will draw red dots
    // at al the touch points
    [[UIColor redColor] setFill];
    for(NSValue* val in touches){
        CGPoint point = [val CGPointValue];
        UIBezierPath* touchPoint = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(point.x - 3, point.y - 3, 6, 6)];
        [touchPoint fill];
    }
    
    // this block will draw a 1px line
    // with a random color for every
    // path that we've tried to create
    // a shape for. this connects the raw
    // points sent to a TCShapeController
    for(UIBezierPath* val in pathsFromIntersectingTouches){
        [[UIColor randomColor] setStroke];
        [val setLineWidth:1];
        [val stroke];
    }
    
    // this will draw the output from each
    // TCShapeController that produced a valid
    // shape
    if([shapePaths count]){
        NSLog(@"drawing %d shapes", [shapePaths count]);
        NSInteger width = [shapePaths count] * 2 + 2;
        for(UIBezierPath* shapePath in shapePaths){
            [[UIColor randomColor] setStroke];
            shapePath.lineWidth = width;
            [shapePath stroke];
            width -= 2;
            
            NSLog(@"origin: %f,%f", shapePath.bounds.origin.x, shapePath.bounds.origin.y);
            
            UIBezierPath* bounds = [UIBezierPath bezierPathWithRect:shapePath.bounds];
            bounds.lineWidth = 1;
            [bounds stroke];
        }
    }
    
    // this will draw circles at each point that we sent
    // to the TCShapeController
    for(UIBezierPath* val in pathsFromIntersectingTouches){
        [[UIColor randomColor] setFill];
        [val iteratePathWithBlock:^(CGPathElement element){
            CGPoint point = element.points[0];
            UIBezierPath* touchPoint = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(point.x - 3, point.y - 3, 6, 6)];
            [touchPoint fill];
        }];
    }
    
    
}

/**
 * returns an array of all bezier paths created
 */
-(NSArray*) complete{
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
    pathsFromIntersectingTouches = [pathOfAllTouchPoints pathsFromSelfIntersections];
    
    
    //
    // now we'll loop over each sub-path, and send all the points
    // to a new TCShapeController, so that we can interpret a shape
    // for each non-intersecting path.
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
                UIBezierPath* shapePath = [shape bezierPath];
                [shapePaths addObject:shapePath];
                NSLog(@"got shape");
            }else{
                NSLog(@"skipping unclosed shape");
            }
        }else{
            // why does this happen so often? it seems to have a problem
            // when the curve starts and stops on the exact same CGPoint
            NSLog(@"nil shape :(");
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
