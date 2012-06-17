//
//  SLPanGestureRecognizer.m
//  Paper Stack
//
//  Created by Adam Wulf on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SLPanGestureRecognizer.h"

@implementation SLPanGestureRecognizer

@synthesize scale;

CGFloat DistanceBetweenTwoPoints(CGPoint point1,CGPoint point2)
{
    CGFloat dx = point2.x - point1.x;
    CGFloat dy = point2.y - point1.y;
    return sqrt(dx*dx + dy*dy );
};

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer{
    return NO;
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer{
    return NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
}

-(CGFloat) distanceBetweenTouches:(NSSet*) touches{
    if([touches count] == 2){
        NSLog(@"began");
        NSEnumerator* enumerator = [touches objectEnumerator];
        UITouch* touch1 = [enumerator nextObject];
        UITouch* touch2 = [enumerator nextObject];
        CGPoint initialPoint1 = [touch1 locationInView:self.view.superview];
        CGPoint initialPoint2 = [touch2 locationInView:self.view.superview];
        return DistanceBetweenTwoPoints(initialPoint1, initialPoint2);
    }
    return 0;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
    if(self.state == UIGestureRecognizerStateBegan){
        initialDistance = 0;
    }
    if(self.numberOfTouches == 1){
        initialDistance = 0;
        scale = 1;
    }
    if([touches count] == 2 && !initialDistance){
        NSLog(@"began");
        initialDistance = [self distanceBetweenTouches:touches];
    }
    if([touches count] == 2 && initialDistance){
        scale = [self distanceBetweenTouches:touches] / initialDistance;
        NSLog(@"moved %f", scale);
    }
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    if(self.numberOfTouches == 1 && self.state == UIGestureRecognizerStateChanged){
        self.state = UIGestureRecognizerStatePossible;
    }
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesCancelled:touches withEvent:event];
    if(self.numberOfTouches == 1 && self.state == UIGestureRecognizerStateChanged){
        self.state = UIGestureRecognizerStatePossible;
    }
}
- (void)reset{
    [super reset];
    initialDistance = 0;
    scale = 1;
}

@end
