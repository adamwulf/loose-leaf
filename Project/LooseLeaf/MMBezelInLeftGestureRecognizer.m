//
//  MMBezelInLeftGestureRecognizer.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/2/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMBezelInLeftGestureRecognizer.h"
#import <JotUI/JotUI.h>
#import "MMBezelInRightGestureRecognizer.h"

@implementation MMBezelInLeftGestureRecognizer
@synthesize panDirection;
@synthesize numberOfRepeatingBezels;

-(id) initWithTarget:(id)target action:(SEL)action{
    self = [super initWithTarget:target action:action];
    validTouches = [[NSMutableSet alloc] init];
    numberOfRepeatingBezels = 0;
    liftedRightFingerOffset = 0;
    dateOfLastBezelEnding = nil;
    return self;
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer{
    return YES;
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer{
    return [preventingGestureRecognizer isKindOfClass:[MMBezelInRightGestureRecognizer class]];
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
    for(UITouch* touch in validTouches){
        CGPoint ret2 = [touch locationInView:self.view];
        if(ret2.x < ret.x){
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
    for(UITouch* touch in validTouches){
        CGPoint ret2 = [touch locationInView:self.view];
        if(ret2.x > ret.x){
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
        CGPoint p = [self furthestRightTouchLocation];
        if(p.x == MAXFLOAT){
            // we don't have a furthest location,
            // so the translation is zero
            return CGPointZero;
        }
        return CGPointMake(p.x - firstKnownLocation.x - liftedRightFingerOffset, p.y - firstKnownLocation.y);
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
        if(point.x > kBezelInGestureWidth){
            // only accept touches on the right bezel
            [self ignoreTouch:touch forEvent:event];
        }else{
            [validTouches addObject:touch];
            foundValidTouch = YES;
        }
    }
    if(!foundValidTouch) return;
    
    panDirection = MMBezelDirectionNone;
    lastKnownLocation = [self furthestRightTouchLocation];
    
    // ok, a touch began, and we need to start the gesture
    // and increment our repeat count
    //
    // we have to manually track valid touches for this gesture
    //
    // the default for a gesture recognizer:
    //   after the recognizer is set to UIGestureRecognizerStateEnded,
    //   then all touches from that gesture are ignored for the rest
    //   of the life of that touch
    //
    // we want to support the user gesturing with two fingers into the bezel,
    // then gesturing both OR just one finger back off the bezel and repeating.
    //
    // since we want to effectively re-use a touch for the 2nd bezel gesture,
    // we'll keep the gesture alive and just increment the repeat count counter
    // instead of ending the gesture entirely.
    //
    if([validTouches count] >= 2){
        if(!dateOfLastBezelEnding || [dateOfLastBezelEnding timeIntervalSinceNow] > -.5){
            numberOfRepeatingBezels++;
        }else{
            numberOfRepeatingBezels = 1;
        }
        if(self.state == UIGestureRecognizerStatePossible){
            self.state = UIGestureRecognizerStateBegan;
            firstKnownLocation = [self furthestLeftTouchLocation];
            firstKnownLocation.x = 0;
        }
        // our gesture has began, so make sure to kill
        // any touches that are being used to draw
        //
        // the stroke manager is the definitive source for all strokes.
        // cancel through that manager, and it'll notify the appropriate
        // view if need be
        for(UITouch* touch in validTouches){
            [[JotStrokeManager sharedInstace] cancelStrokeForTouch:touch];
        }
        [dateOfLastBezelEnding release];
        dateOfLastBezelEnding = nil;
    }
}

/**
 * when the touch moves, track which direction the gesture
 * is moving and record it
 */
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    CGPoint p = [self furthestRightTouchLocation];
    if(p.x != lastKnownLocation.x){
        panDirection = MMBezelDirectionNone;
        if(p.x < lastKnownLocation.x){
            panDirection = panDirection | MMBezelDirectionLeft;
        }
        if(p.x > lastKnownLocation.x){
            panDirection = panDirection | MMBezelDirectionRight;
        }
        if(p.y > lastKnownLocation.y){
            panDirection = panDirection | MMBezelDirectionDown;
        }
        if(p.y < lastKnownLocation.y){
            panDirection = panDirection | MMBezelDirectionUp;
        }
        lastKnownLocation = p;
    }
    // some strokes are started after our gesture gets the
    // touchesBegan event, so we need to kill them here too
    //
    // the stroke manager is the definitive source for all strokes.
    // cancel through that manager, and it'll notify the appropriate
    // view if need be
    for(UITouch* touch in validTouches){
        [[JotStrokeManager sharedInstace] cancelStrokeForTouch:touch];
    }
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    BOOL didChangeTouchLoc = NO;
    CGPoint locationOfRight = [self furthestRightTouchLocation];
    for(UITouch* touch in touches){
        CGPoint touchLocation = [touch locationInView:self.view];
        [validTouches removeObject:touch];
        if(CGPointEqualToPoint(touchLocation, locationOfRight)){
            // this'll use the new left location
            if([self furthestRightTouchLocation].x != MAXFLOAT){
                liftedRightFingerOffset += [self furthestRightTouchLocation].x - touchLocation.x;
            }
            didChangeTouchLoc = YES;
        }
    }
    if([validTouches count] == 0 && self.state == UIGestureRecognizerStateChanged){
        self.state = UIGestureRecognizerStateEnded;
        [dateOfLastBezelEnding release];
        dateOfLastBezelEnding = [[NSDate date] retain];
    }else if(didChangeTouchLoc && self.state == UIGestureRecognizerStateChanged){
        self.state = UIGestureRecognizerStateChanged;
    }
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    if(self.state == UIGestureRecognizerStateChanged ||
       self.state == UIGestureRecognizerStateBegan){
        self.state = UIGestureRecognizerStateCancelled;
    }
    for(UITouch* touch in touches){
        [validTouches removeObject:touch];
    }
    if([validTouches count] == 0 && self.state == UIGestureRecognizerStateChanged){
        self.state = UIGestureRecognizerStateCancelled;
        [dateOfLastBezelEnding release];
        dateOfLastBezelEnding = [[NSDate date] retain];
    }
}
-(void)ignoreTouch:(UITouch *)touch forEvent:(UIEvent *)event{
    [super ignoreTouch:touch forEvent:event];
}
- (void)reset{
    [super reset];
    liftedRightFingerOffset = 0;
    panDirection = MMBezelDirectionNone;
    firstKnownLocation = CGPointZero;
    lastKnownLocation = CGPointZero;
    [validTouches removeAllObjects];
}
-(void) setState:(UIGestureRecognizerState)state{
    [super setState:state];
}
- (void) resetPageCount{
    numberOfRepeatingBezels = 0;
    [dateOfLastBezelEnding release];
    dateOfLastBezelEnding = nil;
}
@end
