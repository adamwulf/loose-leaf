//
//  SLObjectSelectLongPressGestureRecognizer.m
//  scratchpaper
//
//  Created by Adam Wulf on 10/19/12.
//
//

#import "SLObjectSelectLongPressGestureRecognizer.h"
#import "SLPanAndPinchGestureRecognizer.h"
#import "Constants.h"

@interface SLObjectSelectLongPressGestureRecognizer (Private)

/**
 * track the locations of each touch in this gesture
 */
@property (nonatomic, readonly) NSMutableDictionary* touchLocations;

@end

@implementation SLObjectSelectLongPressGestureRecognizer

-(NSMutableDictionary*)touchLocations{
    if(!touchLocations){
        touchLocations = [[NSMutableDictionary alloc] init];
    }
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
    [super touchesBegan:touches withEvent:event];
    for(UITouch* touch in touches){
        [self.touchLocations setObject:[NSValue valueWithCGPoint:[touch locationInView:self.view]]
                                forKey:[NSNumber numberWithInteger:[touch hash]]];
    }
    NSLog(@"long press touch began: %d", [self.touchLocations count]);
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
            CGPoint initialLocation = [[self.touchLocations objectForKey:[NSNumber numberWithInteger:[touch hash]]] CGPointValue];
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
    NSLog(@"long press touch moved: %d", [self.touchLocations count]);
}

/**
 * if a touch is cancelled, remove it from our cache of locations.
 */
-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesCancelled:touches withEvent:event];
    for(UITouch* touch in touches){
        [self.touchLocations removeObjectForKey:[NSNumber numberWithInteger:[touch hash]]];
    }
    NSLog(@"long press touch cancelled: %d", [self.touchLocations count]);
}

/**
 * if a touch is ended, remove it from our cache of locations.
 */
-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    for(UITouch* touch in touches){
        [self.touchLocations removeObjectForKey:[NSNumber numberWithInteger:[touch hash]]];
    }
    NSLog(@"long press touch ended: %d", [self.touchLocations count]);
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
    }
}

@end
