//
//  MMBezelInGestureRecognizer.m
//  Loose Leaf
//
//  Created by Adam Wulf on 6/19/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "MMBezelInGestureRecognizer.h"
#import "MMTouchVelocityGestureRecognizer.h"
#import "Constants.h"
#import "NSMutableSet+Extras.h"
#import "MMBounceButton.h"
#import <JotUI/JotUI.h>

@implementation MMBezelInGestureRecognizer{
    NSMutableSet* ignoredTouches;
}

@synthesize panDirection;
@synthesize numberOfRepeatingBezels;
@synthesize panDelegate;
@synthesize subState;
@synthesize hasSeenSubstateBegin;
@synthesize gestureIsFromRightBezel;

-(id) initWithTarget:(id)target action:(SEL)action{
    self = [super initWithTarget:target action:action];
    validTouches = [[NSMutableSet alloc] init];
    ignoredTouches = [[NSMutableSet alloc] init];
    numberOfRepeatingBezels = 0;
    liftedFingerOffset = 0;
    dateOfLastBezelEnding = nil;
    self.cancelsTouchesInView = NO;
    self.delaysTouchesEnded = NO;
    self.delaysTouchesBegan = NO;
    self.delegate = self;
    return self;
}

//
// this will make sure that the substate transitions
// into a valid state and doesn't repeat a Began/End/Cancelled/etc
-(void) processSubStateForNextIteration{
    if(subState == UIGestureRecognizerStateEnded ||
       subState == UIGestureRecognizerStateCancelled ||
       subState == UIGestureRecognizerStateFailed){
        self.subState = UIGestureRecognizerStatePossible;
    }else if(subState == UIGestureRecognizerStateBegan){
        self.subState = UIGestureRecognizerStateChanged;
    }
}


-(void) setSubState:(UIGestureRecognizerState)_subState{
    subState = _subState;
    if(subState == UIGestureRecognizerStateBegan){
        debug_NSLog(@"%@ substate began", [self description]);
    }else if(subState == UIGestureRecognizerStateCancelled){
        debug_NSLog(@"%@ substate cancelled", [self description]);
    }else if(subState == UIGestureRecognizerStateEnded){
        debug_NSLog(@"%@ substate ended", [self description]);
    }else if(subState == UIGestureRecognizerStateFailed){
        debug_NSLog(@"%@ substate failed", [self description]);
    }
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer{
    return subState != UIGestureRecognizerStatePossible && [preventedGestureRecognizer isKindOfClass:[MMBezelInGestureRecognizer class]];
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer{
    return [preventingGestureRecognizer isKindOfClass:[MMBezelInGestureRecognizer class]];
}

-(NSArray*)touches{
    return [validTouches allObjects];
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
 * returns the furthest point of the gesture if possible,
 * otherwise returns default behavior.
 *
 * this is so that the translation isn't an average of
 * touch locations but will follow the lead finger in
 * the gesture.
 */
-(CGPoint) translationInView:(UIView *)view{
    if(self.view){
        CGPoint p;
        if(gestureIsFromRightBezel){
            p = [self furthestLeftTouchLocation];
            if(p.x == MAXFLOAT){
                // we don't have a furthest location,
                // so the translation is zero
                return CGPointZero;
            }

        }else{
            p = [self furthestRightTouchLocation];
            if(p.x == 0){
                // we don't have a furthest location,
                // so the translation is zero
                return CGPointZero;
            }

        }
        return CGPointMake(p.x - firstKnownLocation.x - liftedFingerOffset, p.y - firstKnownLocation.y);
    }
    return CGPointZero;
}

/**
 * the first touch of a gesture.
 * this touch may interrupt an animation on this frame, so set the frame
 * to match that of the animation.
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self processSubStateForNextIteration];

    NSLog(@"%@: %i touches began", [self description], [touches count]);

    BOOL foundValidTouch = NO;
    for(UITouch* touch in touches){
        CGPoint point = [touch locationInView:self.view];
        if(!gestureIsFromRightBezel && point.x > kBezelInGestureWidth){
            // only accept touches on the right bezel
            [ignoredTouches addObject:touch];
        }else if(gestureIsFromRightBezel && point.x < self.view.frame.size.width - kBezelInGestureWidth){
            // only accept touches on the right bezel
            [ignoredTouches addObject:touch];
        }else{
            [validTouches addObject:touch];
            foundValidTouch = YES;
        }
    }
    
    panDirection = MMBezelDirectionNone;
    if(gestureIsFromRightBezel){
        lastKnownLocation = [self furthestLeftTouchLocation];
    }else{
        lastKnownLocation = [self furthestRightTouchLocation];
    }
    
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
    if([validTouches count] >= 2 && foundValidTouch){
        if(!dateOfLastBezelEnding || [dateOfLastBezelEnding timeIntervalSinceNow] > -.5){
            numberOfRepeatingBezels++;
        }else{
            numberOfRepeatingBezels = 1;
        }
        if(subState == UIGestureRecognizerStatePossible){
            [self.panDelegate ownershipOfTouches:validTouches isGesture:self];
            hasSeenSubstateBegin = NO;
            self.subState = UIGestureRecognizerStateBegan;
            firstKnownLocation = [self furthestRightTouchLocation];
            if(gestureIsFromRightBezel){
                firstKnownLocation.x = self.view.bounds.size.width;
            }else{
                firstKnownLocation.x = 0;
            }
        }
        [dateOfLastBezelEnding release];
        dateOfLastBezelEnding = nil;
    }
    if(self.state == UIGestureRecognizerStatePossible){
        self.state = UIGestureRecognizerStateBegan;
    }else{
        self.state = UIGestureRecognizerStateChanged;
    }
}

/**
 * when the touch moves, track which direction the gesture
 * is moving and record it
 */
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [self processSubStateForNextIteration];
    CGFloat xDirection = [self directionOfTouchesInXAxis];
    CGPoint p;
    if(gestureIsFromRightBezel){
        p = [self furthestLeftTouchLocation];
    }else{
        p = [self furthestRightTouchLocation];
    }
    if(p.x != lastKnownLocation.x){
        panDirection = MMBezelDirectionNone;
        if(xDirection < 0){
            panDirection = panDirection | MMBezelDirectionLeft;
        }
        if(xDirection > 0){
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
    if(self.state != UIGestureRecognizerStatePossible){
        self.state = UIGestureRecognizerStateChanged;
    }
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{

    NSLog(@"%@: %i touches ended", [self description], [touches count]);

    [self processSubStateForNextIteration];
    [ignoredTouches removeObjectsInSet:touches];
    [validTouches removeObjectsInSet:touches];
    BOOL didChangeTouchLoc = NO;
    if(gestureIsFromRightBezel){
        CGPoint locationOfLeft = [self furthestLeftTouchLocation];
        for(UITouch* touch in touches){
            CGPoint touchLocation = [touch locationInView:self.view];
            if(CGPointEqualToPoint(touchLocation, locationOfLeft)){
                // this'll use the new left location
                if([self furthestLeftTouchLocation].x != MAXFLOAT){
                    liftedFingerOffset += [self furthestLeftTouchLocation].x - touchLocation.x;
                }
                didChangeTouchLoc = YES;
            }
        }
    }else{
        CGPoint locationOfRight = [self furthestRightTouchLocation];
        for(UITouch* touch in touches){
            CGPoint touchLocation = [touch locationInView:self.view];
            if(CGPointEqualToPoint(touchLocation, locationOfRight)){
                // this'll use the new right location
                if([self furthestRightTouchLocation].x != MAXFLOAT){
                    liftedFingerOffset += [self furthestRightTouchLocation].x - touchLocation.x;
                }
                didChangeTouchLoc = YES;
            }
        }
    }
    
    // track date of last bezel, if there was one
    if([validTouches count] == 0 && subState == UIGestureRecognizerStateChanged){
        [dateOfLastBezelEnding release];
        dateOfLastBezelEnding = [[NSDate date] retain];
    }
    
    // case: valid touches are empty + other touches
    // case: valid touches empty + no other touches
    // case: still valid touches
    if([validTouches count]){
        self.subState = UIGestureRecognizerStateChanged;
        self.state = UIGestureRecognizerStateChanged;
    }else{
        // no valid touches. do we have others?
        if([ignoredTouches count]){
            // other touches are still alive
            if(subState == UIGestureRecognizerStateChanged){
                self.subState = UIGestureRecognizerStateEnded;
            }else{
                self.subState = UIGestureRecognizerStateFailed;
            }
            self.state = UIGestureRecognizerStateChanged;
        }else{
            // no touches on screen
            if(subState == UIGestureRecognizerStateChanged){
                self.subState = UIGestureRecognizerStateEnded;
            }else{
                self.subState = UIGestureRecognizerStateFailed;
            }
            self.state = UIGestureRecognizerStateEnded;
        }
    }
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [self touchesEnded:touches withEvent:event];
}


- (void)reset{
    [super reset];
    self.subState = UIGestureRecognizerStatePossible;
    liftedFingerOffset = 0;
    panDirection = MMBezelDirectionNone;
    firstKnownLocation = CGPointZero;
    lastKnownLocation = CGPointZero;
    [validTouches removeAllObjects];
    [ignoredTouches removeAllObjects];
}
-(void) setState:(UIGestureRecognizerState)state{
    [super setState:state];
}
- (void) resetPageCount{
    numberOfRepeatingBezels = 0;
    [dateOfLastBezelEnding release];
    dateOfLastBezelEnding = nil;
}



/**
 * calculates the pixel velocity
 * per fraction of a second (1/20)
 * to helper determine how wide to make
 * the bezel
 *
 * since directionOfTouch is only updated
 * if the touch moves significantly, this
 * helps filter out very small direction changes
 */
-(CGFloat) directionOfTouchesInXAxis{
    // calculate the average X direction velocity
    // so we can determine how wide to make the bezel
    // exit of the gesture. this helps us work with
    // really fast bezelling without accidentally zooming
    // into list view or missing the bezel altogether
    int count = 0;
    CGPoint averageVelocity = CGPointZero;
    for(UITouch* touch in validTouches){
        struct DurationCacheObject cache = [[MMTouchVelocityGestureRecognizer sharedInstace] velocityInformationForTouch:touch withIndex:nil];
        averageVelocity.x = averageVelocity.x * count + cache.directionOfTouch.x;
        count += 1;
        averageVelocity.x /= count;
    }
    // calculate the pixels moved per 20th of a second
    // and add that to the bezel that we'll allow
    return averageVelocity.x; // velocity per fraction of a second
}



#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return subState == UIGestureRecognizerStatePossible;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return subState != UIGestureRecognizerStatePossible;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // Disallow recognition of tap gestures in the segmented control.
    if ([touch.view isKindOfClass:[UIControl class]]) {
        NSLog(@"shouldn't receive touch in %@", [self description]);
        return NO;
    }
    return YES;
}

-(BOOL) isActivelyBezeling{
    return (self.state == UIGestureRecognizerStateBegan ||
    self.state == UIGestureRecognizerStateChanged) &&
    (self.subState == UIGestureRecognizerStateBegan ||
     self.subState == UIGestureRecognizerStateChanged);
}

-(NSString*) description{
    return [NSString stringWithFormat:@"[%@ %@ %p]", NSStringFromClass([self class]), gestureIsFromRightBezel ? @"right" : @"left", self];
}

@end
