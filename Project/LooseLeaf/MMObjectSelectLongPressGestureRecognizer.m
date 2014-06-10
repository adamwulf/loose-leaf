//
//  MMObjectSelectLongPressGestureRecognizer.m
//  Loose Leaf
//
//  Created by Adam Wulf on 10/19/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "MMObjectSelectLongPressGestureRecognizer.h"
#import "MMPanAndPinchGestureRecognizer.h"
#import "Constants.h"
#import "NSMutableSet+Extras.h"
#import <JotUI/JotUI.h>

@interface MMObjectSelectLongPressGestureRecognizer (Private)

/**
 * track the locations of each touch in this gesture
 */
@property (nonatomic, readonly) NSMutableDictionary* touchLocations;
@property (nonatomic, readonly) NSMutableSet* activeTouches;

@end

@implementation MMObjectSelectLongPressGestureRecognizer{
    NSMutableDictionary* touchLocations;
    NSMutableSet* activeTouches;
}

-(id) init{
    if(self = [super init]){
        activeTouches = [[NSMutableSet alloc] init];
        touchLocations = [[NSMutableDictionary alloc] init];
        self.delegate = self;
    }
    return self;
}

-(id) initWithTarget:(id)target action:(SEL)action{
    if(self = [super initWithTarget:target action:action]){
        activeTouches = [[NSMutableSet alloc] init];
        touchLocations = [[NSMutableDictionary alloc] init];
        self.delegate = self;
    }
    return self;
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer{
    return NO;
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer{
    return NO;
}

-(NSSet*) activeTouches{
    return activeTouches;
}

-(NSMutableDictionary*)touchLocations{
    return touchLocations;
}

/**
 * when a touch begins, we need to save it's initial location
 * in our view. that way we can later determine how far that
 * touch has moved.
 *
 * we use the hash of the touch because the touch itself does
 * not conform to NSCopying
 */
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    for(UITouch* touch in touches){
        [self.touchLocations setObject:[NSValue valueWithCGPoint:[touch locationInView:self.view]]
                                forKey:@([touch hash])];
    }
    [activeTouches addObjectsInSet:touches];
    [super touchesBegan:touches withEvent:event];
}

/**
 * when a touch moves, determine if it has moved more than
 * allowableDistance from its initial point. If so, and if
 * the gesture is still in Possible state, then mark
 * the gesture as Failed.
 *
 * We check multiple times for the Possible state for performance
 * and to confirm we only change the state once during this method call
 */
-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    BOOL didChangeState = NO;
    if(self.state == UIGestureRecognizerStatePossible){
        for(UITouch* touch in touches){
            CGPoint initialLocation = [[self.touchLocations objectForKey:@([touch hash])] CGPointValue];
            CGPoint currentLocation = [touch locationInView:self.view];
            CGFloat distance = DistanceBetweenTwoPoints(initialLocation, currentLocation);
            if(distance > self.allowableMovement && self.state == UIGestureRecognizerStatePossible){
                self.state = UIGestureRecognizerStateFailed;
                didChangeState = YES;
            }
        }
    }
    if(!didChangeState){
        [super touchesMoved:touches withEvent:event];
    }
}

/**
 * if a touch is cancelled, remove it from our cache of locations.
 */
-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    for(UITouch* touch in touches){
        [self.touchLocations removeObjectForKey:@([touch hash])];
    }
    [activeTouches removeObjectsInSet:touches];
    [super touchesCancelled:touches withEvent:event];
}

/**
 * if a touch is ended, remove it from our cache of locations.
 */
-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    for(UITouch* touch in touches){
        [self.touchLocations removeObjectForKey:@([touch hash])];
    }
    [activeTouches removeObjectsInSet:touches];
    [super touchesEnded:touches withEvent:event];
}

/**
 * if our gesture ends, then remove all our cached locations. these
 * locations only matter during the Possible state, and aren't used
 * elsewhere
 */
-(void) setState:(UIGestureRecognizerState)state{
    [super setState:state];
    if(state == UIGestureRecognizerStateEnded ||
       state == UIGestureRecognizerStateFailed ||
       state == UIGestureRecognizerStateCancelled){
        [self.touchLocations removeAllObjects];
        [activeTouches removeAllObjects];
    }
}

-(void)reset{
    [super reset];
    [self.touchLocations removeAllObjects];
    [activeTouches removeAllObjects];
}

-(void) setEnabled:(BOOL)enabled{
    if(!enabled || (!self.enabled && enabled)){
        [activeTouches removeAllObjects];
    }
    [super setEnabled:enabled];
}


#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // Disallow recognition of tap gestures in the segmented control.
    if ([touch.view isKindOfClass:[UIControl class]]) {
        NSLog(@"ignore touch in %@", NSStringFromClass([self class]));
        return NO;
    }
    return YES;
}

@end
