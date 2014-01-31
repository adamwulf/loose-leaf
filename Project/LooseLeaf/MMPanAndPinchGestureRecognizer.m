//
//  MMPanAndPinchGestureRecognizer.m
//  Loose Leaf
//
//  Created by Adam Wulf on 6/8/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "MMPanAndPinchGestureRecognizer.h"
#import <QuartzCore/QuartzCore.h>
#import "MMBezelInRightGestureRecognizer.h"
#import "MMBezelInLeftGestureRecognizer.h"
#import "MMObjectSelectLongPressGestureRecognizer.h"
#import "MMPanAndPinchScrapGestureRecognizer.h"
#import "MMTouchVelocityGestureRecognizer.h"
#import "NSMutableSet+Extras.h"
#import "NSArray+MapReduce.h"
#import "MMShadowedView.h"
#import <JotUI/JotUI.h>
#import "MMVector.h"

#define kMinimumNumberOfTouches 2

@implementation MMPanAndPinchGestureRecognizer{
    CGPoint locationAdjustment;
    CGPoint lastLocationInView;
}

@synthesize scrapDelegate;
@synthesize scale;
@synthesize bezelDirectionMask;
@synthesize didExitToBezel;
@synthesize scaleDirection;


-(id) init{
    self = [super init];
    if(self){
        validTouches = [[NSMutableOrderedSet alloc] init];
        possibleTouches = [[NSMutableOrderedSet alloc] init];
        ignoredTouches = [[NSMutableSet alloc] init];
    }
    return self;
}

-(id) initWithTarget:(id)target action:(SEL)action{
    self = [super initWithTarget:target action:action];
    if(self){
        validTouches = [[NSMutableOrderedSet alloc] init];
        possibleTouches = [[NSMutableOrderedSet alloc] init];
        ignoredTouches = [[NSMutableSet alloc] init];
    }
    return self;
}

-(NSArray*)touches{
    return [validTouches array];
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer{
    return NO;
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer{
    return [preventingGestureRecognizer isKindOfClass:[MMBezelInRightGestureRecognizer class]] ||
           [preventingGestureRecognizer isKindOfClass:[MMBezelInLeftGestureRecognizer class]];
}

-(BOOL) containsTouch:(UITouch*)touch{
    return [validTouches containsObject:touch];
}

-(void) ownershipOfTouches:(NSSet*)touches isGesture:(UIGestureRecognizer*)gesture{
    if(gesture != self){
        [possibleTouches removeObjectsInSet:touches];
        [ignoredTouches addObjectsInSet:touches];
    }
}



-(CGPoint)locationInView:(UIView *)view{
    if([validTouches count] >= kMinimumNumberOfTouches){
        CGPoint loc1 = [[validTouches firstObject] locationInView:self.view];
        CGPoint loc2 = [[validTouches objectAtIndex:1] locationInView:self.view];
        lastLocationInView = CGPointMake((loc1.x + loc2.x) / 2 - locationAdjustment.x, (loc1.y + loc2.y) / 2 - locationAdjustment.y);
    }
    return [self.view convertPoint:lastLocationInView toView:view];
}


/**
 * the first touch of a gesture.
 * this touch may interrupt an animation on this frame, so set the frame
 * to match that of the animation.
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSMutableOrderedSet* validTouchesCurrentlyBeginning = [NSMutableOrderedSet orderedSetWithSet:touches];
    BOOL isBeginning = [validTouches count] < kMinimumNumberOfTouches;
    // ignore all the touches that could be bezel touches
    if([validTouchesCurrentlyBeginning count]){
        // look at the presentation of the view (as would be seen during animation)
        // (the layer will include the shadow, but our frame won't, since it's a shadow'd layer
        CGRect lFrame = [MMShadowedView contractFrame:[self.view.layer.presentationLayer frame]];
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
        

        [possibleTouches addObjectsFromArray:[validTouchesCurrentlyBeginning array]];
        [possibleTouches removeObjectsInSet:ignoredTouches];
        
        [self processPossibleTouches];

        if([validTouches count] >= kMinimumNumberOfTouches && isBeginning){
            self.state = UIGestureRecognizerStateBegan;
            initialDistance = 0;
            scale = 1;
            secondToLastTouchDidBezel = NO;
            didExitToBezel = MMBezelDirectionNone;
        }else if([validTouches count] <= kMinimumNumberOfTouches){
            didExitToBezel = MMBezelDirectionNone;
            //
            // ok, they just bezelled and brought their second
            // touch back into the screen. reset the flag
            secondToLastTouchDidBezel = NO;
        }
    }
//    NSLog(@"pan page valid: %d  possible: %d  ignored: %d", [validTouches count], [possibleTouches count], [ignoredTouches count]);
}

-(void) processPossibleTouches{
    if([possibleTouches count]){
        NSMutableSet* allPossibleTouches = [NSMutableSet setWithSet:[possibleTouches set]];
        for(MMScrapView* _scrap in [scrapDelegate.scraps reverseObjectEnumerator]){
            NSSet* touchesInScrap = [_scrap matchingPairTouchesFrom:allPossibleTouches];
            if([touchesInScrap count]){
                // two+ possible touches match this scrap
                [ignoredTouches addObjectsInSet:touchesInScrap];
                [possibleTouches removeObjectsInSet:touchesInScrap];
            }else{
                // remove all touches from allPossibleTouches that match this scrap
                // since grabbing a scrap requires that it hit the visible portion of the scrap,
                // this will remove any touches that don't grab a scrap but do land in a scrap
                [allPossibleTouches removeObjectsInSet:[_scrap allMatchingTouchesFrom:allPossibleTouches]];
            }
        }
        
        if([possibleTouches count] >= kMinimumNumberOfTouches){
            [scrapDelegate ownershipOfTouches:[possibleTouches set] isGesture:self];
            [validTouches addObjectsInSet:[possibleTouches set]];
            [possibleTouches removeAllObjects];
        }
    }
}


/**
 * calculates the pixel velocity
 * per fraction of a second (1/20)
 * to helper determine how wide to make
 * the bezel
 */
-(CGFloat) pxVelocity{
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
    CGFloat pxVelocity = averageVelocity.x * [MMTouchVelocityGestureRecognizer maxVelocity] * 0.05; // velocity per fraction of a second
    return pxVelocity;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    NSMutableOrderedSet* validTouchesCurrentlyMoving = [NSMutableOrderedSet orderedSetWithOrderedSet:validTouches];
    [validTouchesCurrentlyMoving intersectSet:touches];
    [validTouchesCurrentlyMoving minusSet:ignoredTouches];
    
    if([validTouchesCurrentlyMoving count]){
        if(self.state == UIGestureRecognizerStateBegan){
            initialDistance = 0;
            self.state = UIGestureRecognizerStateChanged;
        }
        if(self.numberOfTouches == 1){
            initialDistance = 0;
            if(scale < 1){
                scaleDirection = MMScaleDirectionLarger;
            }else if(scale > 1){
                scaleDirection = MMScaleDirectionSmaller;
            }
            scale = 1;
        }
        BOOL adjustInitialDistance = NO;
        if([validTouches count] >= 2 && !initialDistance){
            initialDistance = [self distanceBetweenTouches:validTouches];
            // if we've just adjusted our initial distance, then
            // we need to flag it in case we also have a finger
            // near the bezel, which would reduce our accuracy
            // of the gesture's initial scale
            adjustInitialDistance = YES;
        }
        if([validTouches count] >= 2 && initialDistance){
            BOOL tooCloseHuh = NO;

            CGFloat pxVelocity = [self pxVelocity];
            for(UITouch* touch in validTouches){
                CGPoint point = [touch locationInView:self.view.superview];
                if(point.x < kBezelInGestureWidth + pxVelocity ||
                   point.y < kBezelInGestureWidth ||
                   point.x > self.view.superview.frame.size.width - kBezelInGestureWidth - pxVelocity ||
                   point.y > self.view.superview.frame.size.height - kBezelInGestureWidth){
                    // at least one of the touches is very close
                    // to the bezel, which will reduce our accuracy.
                    // so flag that here
                    tooCloseHuh = YES;
                }
            }
            if(!tooCloseHuh){
                // only allow scale change if the touches are
                // not on the edge of the screen. This is because
                // the location of the touch on the edge isn't very accurate
                // which messes up our scale accuracy
                CGFloat newScale = [self distanceBetweenTouches:validTouches] / initialDistance;
                if(initialDistance < 130){
                    // don't alow scaling if the original pinch was very close together
                    newScale = 1.0;
                }
                if(newScale > scale){
                    scaleDirection = MMScaleDirectionLarger;
                }else if(newScale < scale){
                    scaleDirection = MMScaleDirectionSmaller;
                }
                scale = newScale;
            }else{
                // the finger is too close to the edge,
                // which changes the accuracy of the touch location
                if(adjustInitialDistance){
                    // if we're beginning the gesture by pulling
                    // a finger in from the bezel, then the
                    // initial distance is artificially too small
                    // because the lack of accuracy in the touch
                    // location. so adjust by the bezel width to
                    // get closer to truth
                    initialDistance += kBezelInGestureWidth;
                }
            }
        }
    }
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    // pan and pinch and bezel
    BOOL cancelledFromBezel = NO;
    NSMutableOrderedSet* validTouchesCurrentlyEnding = [NSMutableOrderedSet orderedSetWithOrderedSet:validTouches];
    [validTouchesCurrentlyEnding intersectSet:touches];
    [validTouchesCurrentlyEnding minusSet:ignoredTouches];
    
    
    CGPoint originalLocationInView = [self locationInView:self.view];

    if(self.state == UIGestureRecognizerStateBegan ||
       self.state == UIGestureRecognizerStateChanged){
        //
        // make sure we've actually seen two fingers on the page
        // before we change state or worry about bezeling
        if([validTouchesCurrentlyEnding count]){
            // looking at the velocity and then adding a fraction
            // of a second to the bezel width will help determine if
            // we're bezelling the gesture or not
            
            CGFloat pxVelocity = [self pxVelocity];
            for(UITouch* touch in validTouchesCurrentlyEnding){
                CGPoint point = [touch locationInView:self.view.superview];
                BOOL bezelDirHasLeft = ((self.bezelDirectionMask & MMBezelDirectionLeft) == MMBezelDirectionLeft);
                BOOL bezelDirHasRight = ((self.bezelDirectionMask & MMBezelDirectionRight) == MMBezelDirectionRight);
                BOOL bezelDirHasUp = ((self.bezelDirectionMask & MMBezelDirectionUp) == MMBezelDirectionUp);
                BOOL bezelDirHasDown = ((self.bezelDirectionMask & MMBezelDirectionDown) == MMBezelDirectionDown);
                if(point.x < kBezelInGestureWidth + pxVelocity && bezelDirHasLeft){
                    didExitToBezel = didExitToBezel | MMBezelDirectionLeft;
                    cancelledFromBezel = YES;
                }else if(point.y < kBezelInGestureWidth && bezelDirHasUp){
                    didExitToBezel = didExitToBezel | MMBezelDirectionUp;
                    cancelledFromBezel = YES;
                }else if(point.x > self.view.superview.frame.size.width - kBezelInGestureWidth - pxVelocity && bezelDirHasRight){
                    didExitToBezel = didExitToBezel | MMBezelDirectionRight;
                    cancelledFromBezel = YES;
                }else if(point.y > self.view.superview.frame.size.height - kBezelInGestureWidth && bezelDirHasDown){
                    didExitToBezel = didExitToBezel | MMBezelDirectionDown;
                    cancelledFromBezel = YES;
                }
            }
            //
            // ok, we need to increment the number of times the user has exited the
            // bezel. only do it if the touch as exited bezel and if we're not
            // double counting the last two touches.
            if(didExitToBezel != MMBezelDirectionNone &&
               !secondToLastTouchDidBezel &&
               ([validTouches count] - [validTouchesCurrentlyEnding count]) < kMinimumNumberOfTouches){
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
        }
        [validTouches minusOrderedSet:validTouchesCurrentlyEnding];
        [possibleTouches removeObjectsInSet:touches];
        [ignoredTouches removeObjectsInSet:touches];
        if([validTouches count] == 1){
            [possibleTouches addObjectsInSet:[validTouches set]];
            [validTouches removeAllObjects];
        }
        if([validTouches count] == 0 &&
           [possibleTouches count] == 0 &&
           [ignoredTouches count] == 0 &&
           (self.state == UIGestureRecognizerStateChanged ||
            self.state == UIGestureRecognizerStateBegan)){
            if(cancelledFromBezel){
                self.state = UIGestureRecognizerStateCancelled;
            }else{
                self.state = UIGestureRecognizerStateEnded;
            }
        }
    }else{
        //
        // only 1 finger during this gesture, and it's exited
        // so it doesn't count for bezeling or pan/pinch
        [validTouches minusOrderedSet:validTouchesCurrentlyEnding];
        [possibleTouches removeObjectsInSet:touches];
        [ignoredTouches removeObjectsInSet:touches];
    }
    if(![validTouches count] && ![possibleTouches count]){
        //
        // i need to better handle the case where i have ignored touches
        // but valid touches are released. the gesture should "end"
        // but should stay alive just like the scrap pan gesture.
        //
        if(![ignoredTouches count]){
            self.state = UIGestureRecognizerStateFailed;
        }else{
            // need to reset to initial state
            // soft reset. keep the touches that we know
            // about, but reset everything else
            initialDistance = 0;
            scale = 0;
            didExitToBezel = MMBezelDirectionNone;
            scaleDirection = MMScaleDirectionNone;
            secondToLastTouchDidBezel = NO;
            locationAdjustment = CGPointZero;
            lastLocationInView = CGPointZero;
        }
    }
    [self processPossibleTouches];

    if([validTouches count] >= kMinimumNumberOfTouches){
        // reset the location and the initial distance of the gesture
        // so that the new first two touches position won't immediatley
        // change where the page is or what its scale is
        CGPoint newLocationInView = [self locationInView:self.view];
        locationAdjustment = CGPointMake(locationAdjustment.x + (newLocationInView.x - originalLocationInView.x),
                                         locationAdjustment.y + (newLocationInView.y - originalLocationInView.y));
        initialDistance = [self distanceBetweenTouches:validTouches] / scale;
    }
//    NSLog(@"end pan page valid: %d  possible: %d  ignored: %d", [validTouches count], [possibleTouches count], [ignoredTouches count]);
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    NSMutableOrderedSet* validTouchesCurrentlyCancelling = [NSMutableOrderedSet orderedSetWithOrderedSet:validTouches];
    [validTouchesCurrentlyCancelling intersectSet:touches];
    [validTouchesCurrentlyCancelling minusSet:ignoredTouches];
    
//    NSLog(@"pan cancelled touches %d vs %d", [validTouchesCurrentlyCancelling count], [touches count]);
    if([validTouchesCurrentlyCancelling count]){
        if(self.numberOfTouches == 1 && (self.state == UIGestureRecognizerStateChanged || self.state == UIGestureRecognizerStateBegan)){
            self.state = UIGestureRecognizerStatePossible;
        }else if([validTouches count] == [validTouchesCurrentlyCancelling count] && (self.state == UIGestureRecognizerStateChanged || self.state == UIGestureRecognizerStateBegan)){
            self.state = UIGestureRecognizerStateCancelled;
        }
        [validTouches minusOrderedSet:validTouchesCurrentlyCancelling];
    }
    [possibleTouches removeObjectsInSet:touches];
    [ignoredTouches removeObjectsInSet:touches];
    
    if([validTouches count] == 0 && [possibleTouches count] == 0){
        if((self.state == UIGestureRecognizerStateChanged || self.state == UIGestureRecognizerStateBegan)){
            // if we've just lifted our last touch, and we don't have any
            // touches left on screen that could revive this gesture,
            // then set us to cancelled.
            //
            // this may happen if:
            // - valid gesture w/ 2 touches
            // - end 1 touch
            // - cancel last 1 touch
            self.state = UIGestureRecognizerStateCancelled;
        }
    }
//    NSLog(@"cancel pan page valid: %d  possible: %d  ignored: %d", [validTouches count], [possibleTouches count], [ignoredTouches count]);
}
-(void)ignoreTouch:(UITouch *)touch forEvent:(UIEvent *)event{
    [ignoredTouches addObject:touch];
    [super ignoreTouch:touch forEvent:event];
}

- (void)reset{
    [super reset];
    initialDistance = 0;
    scale = 1;
    [validTouches removeAllObjects];
    [possibleTouches removeAllObjects];
    [ignoredTouches removeAllObjects];
    didExitToBezel = MMBezelDirectionNone;
    scaleDirection = MMScaleDirectionNone;
    secondToLastTouchDidBezel = NO;
    locationAdjustment = CGPointZero;
    lastLocationInView = CGPointZero;
}

-(void) cancel{
    if(self.enabled){
        self.enabled = NO;
        self.enabled = YES;
    }
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


@end
