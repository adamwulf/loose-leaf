//
//  SLDrawingGestureRecognizer.m
//  Loose Leaf
//
//  Created by Adam Wulf on 10/20/12.
//
//

#import "SLDrawingGestureRecognizer.h"
#import "Constants.h"

@interface SLDrawingGestureRecognizer (Private)

- (void) sendPaintEventsToDelegate:(BOOL)lineEnded;

@end

@implementation SLDrawingGestureRecognizer

@synthesize startPoint;
@synthesize pathElement;
@synthesize fingerWidth;

-(id) initWithTarget:(id)target action:(SEL)action{
    if(self = [super initWithTarget:target action:action]){
        fingerWidth = 3 * kMaxPageResolution;
        pathElement.points = malloc(sizeof(CGPoint) * 4);
    }
    return self;
}

-(void) dealloc{
    free(pathElement.points);
    [super dealloc];
}


-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if(self.state == UIGestureRecognizerStateBegan ||
       self.state == UIGestureRecognizerStateChanged){
        for(UITouch* touch in touches){
            [self ignoreTouch:touch forEvent:event];
        }
        return;
    }
    
    [super touchesBegan:touches withEvent:event];
    if(self.state == UIGestureRecognizerStatePossible ||
       self.state == UIGestureRecognizerStateBegan ||
       self.state == UIGestureRecognizerStateChanged){
        UITouch *touch = [touches anyObject];
        CGFloat newFingerWidth = [[touch valueForKey:@"pathMajorRadius"] floatValue];
        if(newFingerWidth < 2) newFingerWidth = 2;
        if(abs(newFingerWidth - fingerWidth) > 1){
            if(newFingerWidth > fingerWidth) fingerWidth += 1;
            if(newFingerWidth < fingerWidth) fingerWidth -= 1;
        }
        fingerWidth = newFingerWidth * kMaxPageResolution;
        point0 = CGPointMake(-1, -1);
        point1 = CGPointMake(-1, -1); // previous previous point
        point2 = CGPointMake(-1, -1); // previous touch point
        point3 = [touch locationInView:self.view]; // current touch point
        [super touchesMoved:touches withEvent:event];
        [self sendPaintEventsToDelegate:NO];
    }
    self.state = UIGestureRecognizerStateBegan;
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
    if(self.state == UIGestureRecognizerStatePossible ||
       self.state == UIGestureRecognizerStateBegan ||
       self.state == UIGestureRecognizerStateChanged){
        UITouch *touch = [touches anyObject];
        CGFloat newFingerWidth = [[touch valueForKey:@"pathMajorRadius"] floatValue];
        if(newFingerWidth < 2) newFingerWidth = 2;
        if(abs(newFingerWidth - fingerWidth) > 1){
            if(newFingerWidth > fingerWidth) fingerWidth += 1;
            if(newFingerWidth < fingerWidth) fingerWidth -= 1;
        }
        fingerWidth = newFingerWidth * kMaxPageResolution;
        point0 = point1;
        point1 = point2;
        point2 = point3;
        point3 = [touch locationInView:self.view];
        [self sendPaintEventsToDelegate:NO];
    }
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGFloat newFingerWidth = [[touch valueForKey:@"pathMajorRadius"] floatValue];
    if(newFingerWidth < 2) newFingerWidth = 2;
    if(abs(newFingerWidth - fingerWidth) > 1){
        if(newFingerWidth > fingerWidth) fingerWidth += 1;
        if(newFingerWidth < fingerWidth) fingerWidth -= 1;
    }else{
        fingerWidth = newFingerWidth * kMaxPageResolution;
    }
    point0 = point1;
    point1 = point2;
    point2 = point3;
    point3 = [touch locationInView:self.view];
    [self sendPaintEventsToDelegate:YES];
    [super touchesEnded:touches withEvent:event];
}

-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [self touchesEnded:touches withEvent:event];
}



/**
 * the basic algorithm going on here takes the input
 * touch points from the user
 * and generates a cubic bezier curve that connects
 * from the last touched point.
 *
 * the result is that the line drawn looks like a smooth
 * nicely curved line instead of a series of single
 * lines stitched together
 *
 * code modified from: http://blog.effectiveui.com/?p=8105
 */
- (void) sendPaintEventsToDelegate:(BOOL)lineEnded {
    
    if(point1.x > -1){
        //
        // TODO
        // set a blend mode that lets me draw on top with alpha
        // and slowly darken a color. make it feel like ink/graphite
        double x0 = (point0.x > -1) ? point0.x : point1.x; //after 4 touches we should have a back anchor point, if not, use the current anchor point
        double y0 = (point0.y > -1) ? point0.y : point1.y; //after 4 touches we should have a back anchor point, if not, use the current anchor point
        double x1 = point1.x;
        double y1 = point1.y;
        double x2 = point2.x;
        double y2 = point2.y;
        double x3 = point3.x;
        double y3 = point3.y;
        // Assume we need to calculate the control
        // points between (x1,y1) and (x2,y2).
        // Then x0,y0 - the previous vertex,
        //      x3,y3 - the next one.
        
        double xc1 = (x0 + x1) / 2.0;
        double yc1 = (y0 + y1) / 2.0;
        double xc2 = (x1 + x2) / 2.0;
        double yc2 = (y1 + y2) / 2.0;
        double xc3 = (x2 + x3) / 2.0;
        double yc3 = (y2 + y3) / 2.0;
        
        double len1 = sqrt((x1-x0) * (x1-x0) + (y1-y0) * (y1-y0));
        double len2 = sqrt((x2-x1) * (x2-x1) + (y2-y1) * (y2-y1));
        double len3 = sqrt((x3-x2) * (x3-x2) + (y3-y2) * (y3-y2));
        
        double k1 = len1 / (len1 + len2);
        double k2 = len2 / (len2 + len3);
        
        double xm1 = xc1 + (xc2 - xc1) * k1;
        double ym1 = yc1 + (yc2 - yc1) * k1;
        
        double xm2 = xc2 + (xc3 - xc2) * k2;
        double ym2 = yc2 + (yc3 - yc2) * k2;
        double smooth_value = 0.8;
        // Resulting control points. Here smooth_value is mentioned
        // above coefficient K whose value should be in range [0...1].
        float ctrl1_x = xm1 + (xc2 - xm1) * smooth_value + x1 - xm1;
        float ctrl1_y = ym1 + (yc2 - ym1) * smooth_value + y1 - ym1;
        
        float ctrl2_x = xm2 + (xc2 - xm2) * smooth_value + x2 - xm2;
        float ctrl2_y = ym2 + (yc2 - ym2) * smooth_value + y2 - ym2;
        
        startPoint = point1;
        pathElement.type = kCGPathElementAddCurveToPoint;
        pathElement.points[2] = point2;
        pathElement.points[0] = CGPointMake(ctrl1_x, ctrl1_y);
        pathElement.points[1] = CGPointMake(ctrl2_x, ctrl2_y);
    }else if(point2.x == -1){
        startPoint = point3;
        pathElement.type = kCGPathElementMoveToPoint;
    }else if(point1.x == -1 && lineEnded){
        startPoint = point2;
        pathElement.type = kCGPathElementAddLineToPoint;
        pathElement.points[0] = point3;
    }
}



-(void) cancel{
    if(self.state == UIGestureRecognizerStateChanged){
        self.state = UIGestureRecognizerStateCancelled;
    }
}

@end
