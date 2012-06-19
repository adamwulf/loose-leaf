//
//  SLPanGestureRecognizer.m
//  Paper Stack
//
//  Created by Adam Wulf on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SLPanAndPinchGestureRecognizer.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"
#import "SLBezelGestureRecognizer.h"

@implementation SLPanAndPinchGestureRecognizer

@synthesize scale;


- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer{
    return NO;
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer{
    return [preventingGestureRecognizer isKindOfClass:[SLBezelGestureRecognizer class]];
}

/**
 * the first touch of a gesture.
 * this touch may interrupt an animation on this frame, so set the frame
 * to match that of the animation.
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    // look at the presentation of the view (as would be seen during animation)
    CGRect lFrame = [self.view.layer.presentationLayer frame];
    // look at the view frame to compare
    CGRect vFrame = self.view.frame;
    if(!CGRectEqualToRect(lFrame, vFrame)){
        // if they're not equal, then remove all animations
        // and set the frame to the presentation layer's frame
        // so that the gesture will pick up in the middle
        // of the animation instead of immediately reset to
        // its end state
        self.view.frame = lFrame;
    }
    [self.view.layer removeAllAnimations];
    [super touchesBegan:touches withEvent:event];
    [lastTouchTime release];
    lastTouchTime = [[NSDate date] retain];
}

-(CGFloat) distanceBetweenTouches:(NSSet*) touches{
    if([touches count] == 2){
        NSArray* arr = [touches allObjects];
        UITouch* touch1 = [arr objectAtIndex:0];
        UITouch* touch2 = [arr objectAtIndex:1];
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
        initialDistance = [self distanceBetweenTouches:touches];
    }
    if([touches count] == 2 && initialDistance){
        NSTimeInterval interval = [lastTouchTime timeIntervalSinceNow];
        if(interval < -.03){
            scale = [self distanceBetweenTouches:touches] / initialDistance;
            [lastTouchTime release];
            lastTouchTime = [[NSDate date] retain];
        }
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
