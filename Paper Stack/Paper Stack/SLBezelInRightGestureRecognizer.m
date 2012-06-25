//
//  SLBezelGestureRecognizer.m
//  Paper Stack
//
//  Created by Adam Wulf on 6/19/12.
//  Copyright (c) 2012 Visere. All rights reserved.
//

#import "SLBezelInRightGestureRecognizer.h"
#import "Constants.h"

@implementation SLBezelInRightGestureRecognizer
@synthesize panDirection;
@synthesize numberOfRepeatingBezels;

-(id) initWithTarget:(id)target action:(SEL)action{
    self = [super initWithTarget:target action:action];
    ignoredTouches = [[NSMutableSet alloc] init];
    validTouches = [[NSMutableSet alloc] init];
    numberOfRepeatingBezels = 0;
    dateOfLastBezelEnding = nil;
    return self;
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer{
    return YES;
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer{
    return NO;
}

/**
 * finds the touch that is furthest left
 *
 * right now, this gesture is effectively hard coded to
 * allow for bezeling in from the right.
 *
 * it would need a refactor to support gesturing from
 * other sides, despite what its API looks like
 */
-(CGPoint) furthestLeftTouchLocation{
    CGPoint ret = CGPointMake(CGFLOAT_MAX, CGFLOAT_MAX);
    for(int i=0;i<[self numberOfTouches];i++){
        CGPoint ret2 = [self locationOfTouch:i inView:self.view];
        BOOL isIgnoredTouchLocation = NO;
        if([self numberOfTouches] > 2){
            for(UITouch* touch in ignoredTouches){
                CGPoint igLoc = [touch locationInView:self.view];
                isIgnoredTouchLocation = isIgnoredTouchLocation || CGPointEqualToPoint(ret2, igLoc);
            }
        }
        if(!isIgnoredTouchLocation && ret2.x < ret.x){
            ret = ret2;
        }
    }
    return ret;
}
/**
 * returns the furthest right touch point of the gesture
 */
-(CGPoint) furthestRightTouchLocation{
    CGPoint ret = CGPointZero;
    for(int i=0;i<[self numberOfTouches];i++){
        CGPoint ret2 = [self locationOfTouch:i inView:self.view];
        BOOL isIgnoredTouchLocation = NO;
        if([self numberOfTouches] > 2){
            for(UITouch* touch in ignoredTouches){
                CGPoint igLoc = [touch locationInView:self.view];
                isIgnoredTouchLocation = isIgnoredTouchLocation || CGPointEqualToPoint(ret2, igLoc);
            }
        }
        if(!isIgnoredTouchLocation && ret2.x > ret.x){
            ret = ret2;
        }
    }
    return ret;
}

/**
 * returns the furthest point of the gesture if possible,
 * otherwise returns default behavior.
 *
 * this is so that the translation isn't an average of
 * touch locations but will follow the lead finger in
 * the gesture.
 */
-(CGPoint) translationInView:(UIView *)view{
    if(self.view){
        CGPoint p = [self furthestLeftTouchLocation];
        return p;
    }
    return CGPointZero;
}

/**
 * the first touch of a gesture.
 * this touch may interrupt an animation on this frame, so set the frame
 * to match that of the animation.
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    BOOL foundValidTouch = NO;
    for(UITouch* touch in touches){
        CGPoint point = [touch locationInView:self.view];
        if(point.x < self.view.frame.size.width - kBezelInGestureWidth){
            // only accept touches on the right bezel
            [self ignoreTouch:touch forEvent:event];
            debug_NSLog(@"ignore :(  %f", point.x);
        }else{
            [validTouches addObject:touch];
            foundValidTouch = YES;
            debug_NSLog(@"found touch");
        }
    }
    if(!foundValidTouch) return;
    
    panDirection = SLBezelDirectionNone;
    lastKnownLocation = [self furthestLeftTouchLocation];
//    debug_NSLog(@"points: %d %d", self.numberOfTouches, [validTouches count]);
    
    // ok, a touch began, and we don't current have anything
    // recognized
    if([validTouches count] >= 2){
        
        if(!dateOfLastBezelEnding || [dateOfLastBezelEnding timeIntervalSinceNow] > -.5){
            numberOfRepeatingBezels++;
//            debug_NSLog(@"add one! %d", numberOfRepeatingBezels);
        }else{
//            debug_NSLog(@"reset to one!");
            numberOfRepeatingBezels = 1;
        }
        if(self.state != UIGestureRecognizerStateBegan){
            self.state = UIGestureRecognizerStateBegan;
        }
        [dateOfLastBezelEnding release];
        dateOfLastBezelEnding = nil;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    CGPoint p = [self furthestLeftTouchLocation];
    if(p.x != lastKnownLocation.x){
        panDirection = SLBezelDirectionNone;
        if(p.x < lastKnownLocation.x){
            panDirection = panDirection | SLBezelDirectionLeft;
        }
        if(p.x > lastKnownLocation.x){
            panDirection = panDirection | SLBezelDirectionRight;
        }
        if(p.y > lastKnownLocation.y){
            panDirection = panDirection | SLBezelDirectionDown;
        }
        if(p.y < lastKnownLocation.y){
            panDirection = panDirection | SLBezelDirectionUp;
        }
        lastKnownLocation = p;
    }
    if(self.state == UIGestureRecognizerStateBegan){
        firstKnownLocation = [self furthestRightTouchLocation];
    }
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    for(UITouch* touch in touches){
        [ignoredTouches removeObject:touch];
        [validTouches removeObject:touch];
    }
    if([validTouches count] == 0 && self.state == UIGestureRecognizerStateChanged){
        self.state = UIGestureRecognizerStateEnded;
        [dateOfLastBezelEnding release];
        dateOfLastBezelEnding = [[NSDate date] retain];
    }
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    if(self.state == UIGestureRecognizerStateChanged ||
       self.state == UIGestureRecognizerStateBegan){
        self.state = UIGestureRecognizerStateCancelled;
    }
    for(UITouch* touch in touches){
        [ignoredTouches removeObject:touch];
        [validTouches removeObject:touch];
    }
    if([validTouches count] == 0 && self.state == UIGestureRecognizerStateChanged){
        self.state = UIGestureRecognizerStateCancelled;
        [dateOfLastBezelEnding release];
        dateOfLastBezelEnding = [[NSDate date] retain];
    }
}
-(void)ignoreTouch:(UITouch *)touch forEvent:(UIEvent *)event{
    [ignoredTouches addObject:touch];
    [super ignoreTouch:touch forEvent:event];
}
- (void)reset{
    [super reset];
    panDirection = SLBezelDirectionNone;
    [ignoredTouches removeAllObjects];
}
- (void) resetPageCount{
    numberOfRepeatingBezels = 0;
    [dateOfLastBezelEnding release];
    dateOfLastBezelEnding = nil;
}
@end
