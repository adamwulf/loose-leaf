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
#import "SLBezelInGestureRecognizer.h"
#import "NSMutableSet+Extras.h"

@implementation SLPanAndPinchGestureRecognizer

@synthesize scale;

-(id) init{
    self = [super init];
    if(self){
        validTouchesOnly = [[NSMutableSet alloc] init];
    }
    return self;
}

-(id) initWithTarget:(id)target action:(SEL)action{
    self = [super initWithTarget:target action:action];
    if(self){
        validTouchesOnly = [[NSMutableSet alloc] init];
    }
    return self;
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer{
    return NO;
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer{
    return [preventingGestureRecognizer isKindOfClass:[SLBezelInGestureRecognizer class]];
}

/**
 * the first touch of a gesture.
 * this touch may interrupt an animation on this frame, so set the frame
 * to match that of the animation.
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSMutableSet* validTouches = [NSMutableSet setWithSet:touches];
    // ignore all the touches that could be bezel touches
    for(UITouch* touch in touches){
        CGPoint point = [touch locationInView:self.view.superview];
        if(point.x < 10){
            [self ignoreTouch:touch forEvent:event];
            [validTouches removeObject:touch];
        }else if(point.y < 10){
            [self ignoreTouch:touch forEvent:event];
            [validTouches removeObject:touch];
        }else if(point.x > self.view.frame.size.width - 10){
            [self ignoreTouch:touch forEvent:event];
            [validTouches removeObject:touch];
        }else if(point.y > self.view.frame.size.height - 10){
            [self ignoreTouch:touch forEvent:event];
            [validTouches removeObject:touch];
        }else{
//            debug_NSLog(@"point for panandpinch: %f %f", point.x, point.y);
        }
    }
    if([validTouches count]){
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
        [super touchesBegan:validTouches withEvent:event];
        [lastTouchTime release];
        lastTouchTime = [[NSDate date] retain];
        [validTouchesOnly addObjectsFromArray:[validTouches allObjects]];
        if([validTouchesOnly count] >= self.minimumNumberOfTouches && self.state == UIGestureRecognizerStatePossible){
            self.state = UIGestureRecognizerStateBegan;
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    NSMutableSet* validTouches = [NSMutableSet setWithSet:validTouchesOnly];
    [validTouches intersectSet:touches];
    if([validTouches count]){
        [super touchesMoved:validTouches withEvent:event];
        if(self.state == UIGestureRecognizerStateBegan){
            initialDistance = 0;
        }
        if(self.numberOfTouches == 1){
            initialDistance = 0;
            scale = 1;
        }
        if([validTouches count] == 2 && !initialDistance){
            initialDistance = [self distanceBetweenTouches:validTouches];
        }
        if([validTouches count] == 2 && initialDistance){
            NSTimeInterval interval = [lastTouchTime timeIntervalSinceNow];
            if(interval < -.03){
                scale = [self distanceBetweenTouches:touches] / initialDistance;
                [lastTouchTime release];
                lastTouchTime = [[NSDate date] retain];
            }
        }
    }
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSMutableSet* validTouches = [NSMutableSet setWithSet:validTouchesOnly];
    [validTouches intersectSet:touches];
    if([validTouches count]){
        for(UITouch* touch in validTouches){
            CGPoint point = [touch locationInView:self.view.superview];
            if(point.x < 10){
                [super touchesCancelled:[NSSet setWithObject:touch] withEvent:event];
            }else if(point.y < 10){
                [super touchesCancelled:[NSSet setWithObject:touch] withEvent:event];
            }else if(point.x > self.view.frame.size.width - 10){
                [super touchesCancelled:[NSSet setWithObject:touch] withEvent:event];
            }else if(point.y > self.view.frame.size.height - 10){
                [super touchesCancelled:[NSSet setWithObject:touch] withEvent:event];
            }else{
                [super touchesEnded:touches withEvent:event];
            }
        }
        if(self.numberOfTouches == 1 && self.state == UIGestureRecognizerStateChanged){
            self.state = UIGestureRecognizerStatePossible;
        }
        [validTouchesOnly removeObjectsInSet:validTouches];
    }
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    NSMutableSet* validTouches = [NSMutableSet setWithSet:validTouchesOnly];
    [validTouches intersectSet:touches];
    if([validTouches count]){
        [super touchesCancelled:touches withEvent:event];
        if(self.numberOfTouches == 1 && self.state == UIGestureRecognizerStateChanged){
            self.state = UIGestureRecognizerStatePossible;
        }
        [validTouchesOnly removeObjectsInSet:validTouches];
    }
}
- (void)reset{
    [super reset];
    initialDistance = 0;
    scale = 1;
    [validTouchesOnly removeAllObjects];
}

-(void) cancel{
    self.enabled = NO;
    self.enabled = YES;
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


@end
