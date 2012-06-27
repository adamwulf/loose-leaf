//
//  SLPanGestureRecognizer.m
//  Paper Stack
//
//  Created by Adam Wulf on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SLPanAndPinchGestureRecognizer.h"
#import <QuartzCore/QuartzCore.h>
#import "SLBezelInRightGestureRecognizer.h"
#import "NSMutableSet+Extras.h"
#import "NSArray+MapReduce.h"

@implementation SLPanAndPinchGestureRecognizer

@synthesize scale;
@synthesize bezelDirectionMask;
@synthesize didExitToBezel;
@synthesize minimumNumberOfTouches;
@synthesize velocity = _averageVelocity;
@synthesize numberOfRepeatingBezels;

-(id) init{
    self = [super init];
    if(self){
        validTouches = [[NSMutableOrderedSet alloc] init];
        ignoredTouches = [[NSMutableSet alloc] init];
        velocities = [[NSMutableArray alloc] init];
    }
    return self;
}

-(id) initWithTarget:(id)target action:(SEL)action{
    self = [super initWithTarget:target action:action];
    if(self){
        validTouches = [[NSMutableOrderedSet alloc] init];
        ignoredTouches = [[NSMutableSet alloc] init];
        velocities = [[NSMutableArray alloc] init];
    }
    return self;
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer{
    return NO;
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer{
    return [preventingGestureRecognizer isKindOfClass:[SLBezelInRightGestureRecognizer class]];
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
        CGPoint p = [self locationInView:view];
        return CGPointMake(p.x - firstKnownLocation.x, p.y - firstKnownLocation.y);
    }
    return CGPointZero;
}

/**
 * the first touch of a gesture.
 * this touch may interrupt an animation on this frame, so set the frame
 * to match that of the animation.
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSMutableOrderedSet* validTouchesCurrentlyBeginning = [NSMutableOrderedSet orderedSetWithSet:touches];
    // ignore all the touches that could be bezel touches
    if([validTouchesCurrentlyBeginning count]){
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

        [validTouches addObjectsFromArray:[validTouchesCurrentlyBeginning array]];
        if([validTouches count] >= self.minimumNumberOfTouches && self.state == UIGestureRecognizerStatePossible){
            self.state = UIGestureRecognizerStateBegan;
            // used for velocity
            firstKnownLocation = [self locationInView:self.view.superview];
        }else if([validTouches count] == self.minimumNumberOfTouches){
            didExitToBezel = SLBezelDirectionNone;
            //
            // ok, they just bezelled and brought their second
            // touch back into the screen. reset the flag
            secondToLastTouchDidBezel = NO;
        }
    }
    [self calculateVelocity];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    NSMutableOrderedSet* validTouchesCurrentlyMoving = [NSMutableOrderedSet orderedSetWithOrderedSet:validTouches];
    [validTouchesCurrentlyMoving intersectSet:touches];
    if([validTouchesCurrentlyMoving count]){
        if(self.state == UIGestureRecognizerStateBegan){
            initialDistance = 0;
        }
        if(self.numberOfTouches == 1){
            initialDistance = 0;
            scale = 1;
        }
        if([validTouches count] >= 2 && !initialDistance){
            initialDistance = [self distanceBetweenTouches:validTouches];
        }
        if([validTouches count] >= 2 && initialDistance){
            scale = [self distanceBetweenTouches:validTouches] / initialDistance;
        }
    }
    [self calculateVelocity];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    // pan and pinch and bezel
    BOOL cancelledFromBezel = NO;
    NSMutableOrderedSet* validTouchesCurrentlyEnding = [NSMutableOrderedSet orderedSetWithOrderedSet:validTouches];
    [validTouchesCurrentlyEnding intersectSet:touches];
    if([validTouchesCurrentlyEnding count]){
        for(UITouch* touch in validTouchesCurrentlyEnding){
            CGPoint point = [touch locationInView:self.view.superview];
            BOOL bezelDirHasLeft = ((self.bezelDirectionMask & SLBezelDirectionLeft) == SLBezelDirectionLeft);
            BOOL bezelDirHasRight = ((self.bezelDirectionMask & SLBezelDirectionRight) == SLBezelDirectionRight);
            BOOL bezelDirHasUp = ((self.bezelDirectionMask & SLBezelDirectionUp) == SLBezelDirectionUp);
            BOOL bezelDirHasDown = ((self.bezelDirectionMask & SLBezelDirectionDown) == SLBezelDirectionDown);
            if(point.x < kBezelInGestureWidth && bezelDirHasLeft){
                didExitToBezel = didExitToBezel | SLBezelDirectionLeft;
                cancelledFromBezel = YES;
            }else if(point.y < kBezelInGestureWidth && bezelDirHasUp){
                didExitToBezel = didExitToBezel | SLBezelDirectionUp;
                cancelledFromBezel = YES;
            }else if(point.x > self.view.superview.frame.size.width - kBezelInGestureWidth && bezelDirHasRight){
                didExitToBezel = didExitToBezel | SLBezelDirectionRight;
                cancelledFromBezel = YES;
            }else if(point.y > self.view.superview.frame.size.height - kBezelInGestureWidth && bezelDirHasDown){
                didExitToBezel = didExitToBezel | SLBezelDirectionDown;
                cancelledFromBezel = YES;
            }
        }
        //
        // ok, we need to increment the number of times the user has exited the
        // bezel. only do it if the touch as exited bezel and if we're not
        // double counting the last two touches.
        if(didExitToBezel != SLBezelDirectionNone &&
           !secondToLastTouchDidBezel &&
           ([validTouches count] - [validTouchesCurrentlyEnding count]) < self.minimumNumberOfTouches){
            numberOfRepeatingBezels ++;
            if([validTouches count] - [validTouchesCurrentlyEnding count] == 1){
                // that was the 2nd to last touch!
                // set this flag so we don't double count it when the last
                // touch ends
                secondToLastTouchDidBezel = YES;
            }
        }
        if(self.numberOfTouches == 1 && self.state == UIGestureRecognizerStateChanged){
            self.state = UIGestureRecognizerStatePossible;
        }
        [validTouches minusOrderedSet:validTouchesCurrentlyEnding];
        [ignoredTouches removeObjectsInSet:touches];
    }
    if([validTouches count] == 0 && self.state == UIGestureRecognizerStateChanged){
        if(cancelledFromBezel){
            self.state = UIGestureRecognizerStateCancelled;
        }else{
            self.state = UIGestureRecognizerStateEnded;
        }
    }
    [self calculateVelocity];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    NSMutableOrderedSet* validTouchesCurrentlyCancelling = [NSMutableOrderedSet orderedSetWithOrderedSet:validTouches];
    [validTouchesCurrentlyCancelling intersectSet:touches];
    if([validTouchesCurrentlyCancelling count]){
        if(self.numberOfTouches == 1 && self.state == UIGestureRecognizerStateChanged){
            self.state = UIGestureRecognizerStatePossible;
        }else if([validTouches count] == 0 && self.state == UIGestureRecognizerStateChanged){
            self.state = UIGestureRecognizerStateCancelled;
        }
        [validTouches minusOrderedSet:validTouchesCurrentlyCancelling];
        [ignoredTouches removeObjectsInSet:touches];
    }
    [self calculateVelocity];
}
-(void)ignoreTouch:(UITouch *)touch forEvent:(UIEvent *)event{
    [ignoredTouches addObject:touch];
    [super ignoreTouch:touch forEvent:event];
}
- (void)reset{
    [super reset];
    initialDistance = 0;
    scale = 1;
    numberOfRepeatingBezels = 0;
    [validTouches removeAllObjects];
    [ignoredTouches removeAllObjects];
    didExitToBezel = SLBezelDirectionNone;
    [velocities removeAllObjects];
    secondToLastTouchDidBezel = NO;
}

-(void) cancel{
    self.enabled = NO;
    self.enabled = YES;
}

-(CGFloat) distanceBetweenTouches:(NSOrderedSet*) touches{
    if([touches count] >= 2){
        UITouch* touch1 = [touches objectAtIndex:0];
        UITouch* touch2 = [touches objectAtIndex:1];
        CGPoint initialPoint1 = [touch1 locationInView:self.view.superview];
        CGPoint initialPoint2 = [touch2 locationInView:self.view.superview];
        return DistanceBetweenTwoPoints(initialPoint1, initialPoint2);
    }
    return 0;
}

/**
 * this function processes each step of the pan gesture, and uses
 * it to caclulate the velocity when the user lifts their finger.
 *
 * we use this to have the paper slide when the user swipes quickly
 */
- (CGPoint)calculateVelocity{
    CGPoint translate = [self locationInView:self.view.superview];
    static NSTimeInterval lastTime;
    static NSTimeInterval currTime;
    static CGPoint currTranslate;
    static CGPoint lastTranslate;
    
    if (self.state == UIGestureRecognizerStateBegan)
    {
        currTime = [NSDate timeIntervalSinceReferenceDate];
        currTranslate = translate;
    }
    else if (self.state == UIGestureRecognizerStateChanged)
    {
        lastTime = currTime;
        lastTranslate = currTranslate;
        currTime = [NSDate timeIntervalSinceReferenceDate];
        currTranslate = translate;
        //
        // calculate the current velocity for this moment,
        // add add it to the velocities array. we'll average
        // them later
        NSTimeInterval seconds = [NSDate timeIntervalSinceReferenceDate] - lastTime;
        CGPoint currVel = CGPointMake((translate.x - lastTranslate.x) / seconds, (translate.y - lastTranslate.y) / seconds);
        [velocities addObject:[NSValue valueWithCGPoint:currVel]];
        if([velocities count] > 10){
            [velocities removeObjectAtIndex:0];
        }
    }
    if ([velocities count] > 1)
    {
        //
        // calculate the average velocity
        CGPoint avgVel = [[velocities reduce:^id(id obj, NSUInteger index, id accum){
            CGPoint avgVel = [accum CGPointValue];
            CGPoint curVel = [obj CGPointValue];
            avgVel.x = (avgVel.x * index + curVel.x) / (index + 1);
            avgVel.y = (avgVel.y * index + curVel.y) / (index + 1);
            return [NSValue valueWithCGPoint:avgVel];
        }] CGPointValue];
        _averageVelocity = avgVel;
        return avgVel;
    }
    /*
     // let's calculate where that flick would take us this far in the future
     float inertiaSeconds = 1.0;
     CGPoint final = CGPointMake(translate.x + swipeVelocity.x * inertiaSeconds, translate.y + swipeVelocity.y * inertiaSeconds);
     */
    return CGPointZero;
}

@end
