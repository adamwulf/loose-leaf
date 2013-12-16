//
//  MMPanAndPinchScrapGestureRecognizer.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/25/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMPanAndPinchScrapGestureRecognizer.h"
#import "MMBezelInRightGestureRecognizer.h"
#import "MMBezelInLeftGestureRecognizer.h"
#import "MMVector.h"
#import "MMPanAndPinchGestureRecognizer.h"
#import "NSMutableSet+Extras.h"
#import "MMTouchVelocityGestureRecognizer.h"

#define kMaxSimultaneousTouchesAllowedToTrack 20
#define kNumberOfDirectionChangesToDetermineShake 2
#define kVelocityLowPass 0.7

struct TouchInterval{
    NSInteger numberOfDirectionChanges;
    BOOL hasProcessedShake;
};

@implementation MMPanAndPinchScrapGestureRecognizer{
    // the scrap being held
    __weak MMScrapView* scrap;
    // the initial vector between the two
    // gesture touches, helpful when determining
    // rotation
    MMVector* initialTouchVector;
    // the amount that the gesture has rotated
    CGFloat rotation;
    // the current scale of the gesture
    CGFloat scale;
    // the location that the gesture begins,
    // so that we can determine the translation
    CGPoint gestureLocationAtStart;
    // the amount the gesture has moved
    CGPoint translation;
    
    // helper properties so that the gesture's
    // delegate can see how the center/scale/etc
    // have changed during the gesture
    CGFloat preGestureScale;
    CGFloat preGesturePageScale;
    CGFloat preGestureRotation;
    CGPoint preGestureCenter;
    
    struct TouchInterval touchIntervals[kMaxSimultaneousTouchesAllowedToTrack];
    
    BOOL isShaking;
}


@synthesize scale;
@synthesize scrap;
@synthesize preGestureScale;
@synthesize preGesturePageScale;
@synthesize preGestureRotation;
@synthesize preGestureCenter;
@synthesize scrapDelegate;
@synthesize didExitToBezel;
@synthesize bezelDirectionMask;
@synthesize shouldReset;
@synthesize isShaking;


NSInteger const  mmMinimumNumberOfScrapTouches = 2;
#define           SCRAP_VELOCITY_CLAMP_MIN 20 // px / sec
#define           SCRAP_VELOCITY_CLAMP_MAX 2000 // px / sec


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

-(void) cancel{
    if(self.enabled){
        self.enabled = NO;
        self.enabled = YES;
    }
}

-(NSArray*)touches{
    return [validTouches array];
}

-(CGPoint) translation{
    return CGPointMake(translation.x, translation.y);
}

-(CGFloat) rotation{
    return rotation;
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
    if([validTouches count] >= mmMinimumNumberOfScrapTouches){
        CGPoint loc1 = [[validTouches firstObject] locationInView:view];
        CGPoint loc2 = [[validTouches objectAtIndex:1] locationInView:view];
        return CGPointMake((loc1.x + loc2.x) / 2, (loc1.y + loc2.y) / 2);
    }
    return [super locationInView:view];
}


-(void) blessTouches:(NSSet*)touches{
    NSMutableSet* newPossibleTouches = [NSMutableSet setWithSet:ignoredTouches];
    [newPossibleTouches intersectSet:touches];
    [possibleTouches addObjectsInSet:newPossibleTouches];
    [ignoredTouches removeObjectsInSet:newPossibleTouches];
    self.shouldReset = YES;
    [self touchesBegan:newPossibleTouches withEvent:nil];
}

/**
 * the first touch of a gesture.
 * this touch may interrupt an animation on this frame, so set the frame
 * to match that of the animation.
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    isShaking = NO;
    for(UITouch* touch in touches){
        [self calculateShakesForTouch:touch];
    }
    if([self.scrapDelegate panScrapRequiresLongPress] && ![possibleTouches intersectsSet:touches]){
        [ignoredTouches addObjectsInSet:touches];
        return;
    }
    NSMutableOrderedSet* validTouchesCurrentlyBeginning = [NSMutableOrderedSet orderedSetWithSet:touches];
    // ignore all the touches that could be bezel touches
    if([validTouchesCurrentlyBeginning count]){
        
        NSArray* scrapsToLookAt;
        if(self.scrap){
            scrapsToLookAt = [NSArray arrayWithObject:scrap];
        }else{
            scrapsToLookAt = scrapDelegate.scraps;
        }
        
        
        [possibleTouches addObjectsFromArray:[validTouchesCurrentlyBeginning array]];
        [possibleTouches removeObjectsInSet:ignoredTouches];
        
        NSMutableSet* allPossibleTouches = [NSMutableSet setWithSet:[possibleTouches set]];
        // scraps are returned back to front, so we need to reverse
        // enumerate them so that we check front to back
        for(MMScrapView* _scrap in [scrapsToLookAt reverseObjectEnumerator]){
            NSSet* touchesInScrap = [_scrap matchingPairTouchesFrom:allPossibleTouches];
            if(self.scrap && ![touchesInScrap count]){
                for(UITouch* touch in possibleTouches){
                    if([scrap containsTouch:touch]){
                        // we only need to worry about sets with one object
                        // because if more than 1 possible touch matched,
                        // then the matchingTouchesFrom: would have returned them
                        touchesInScrap = [NSSet setWithObject:touch];
                    }
                }
            }
            if([touchesInScrap count]){
                // two+ possible touches match this scrap
                self.scrap = _scrap;
                [scrapDelegate ownershipOfTouches:touchesInScrap isGesture:self];
                [validTouches addObjectsInSet:touchesInScrap];
                [possibleTouches removeObjectsInSet:touchesInScrap];
                break;
            }else{
                // remove all touches from allPossibleTouches that match this scrap
                // since grabbing a scrap requires that it hit the visible portion of the scrap,
                // this will remove any touches that don't grab a scrap but do land in a scrap
                [allPossibleTouches removeObjectsInSet:[_scrap allMatchingTouchesFrom:allPossibleTouches]];
            }
        }
        
        if([validTouches count] >= mmMinimumNumberOfScrapTouches){
            
            [self prepareGestureToBeginFresh];
            
            didExitToBezel = MMBezelDirectionNone;

            self.state = UIGestureRecognizerStateBegan;
        }else if([validTouches count] < mmMinimumNumberOfScrapTouches){
            didExitToBezel = MMBezelDirectionNone;
            initialTouchVector = nil;
            //
            // ok, they just bezelled and brought their second
            // touch back into the screen. reset the flag
            secondToLastTouchDidBezel = NO;
        }
    }
    
//    NSLog(@"pan scrap valid: %d  possible: %d  ignored: %d", [validTouches count], [possibleTouches count], [ignoredTouches count]);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    isShaking = NO;
    for(UITouch* t in touches){
        [self calculateShakesForTouch:t];
    }
    NSMutableOrderedSet* validTouchesCurrentlyMoving = [validTouches mutableCopy];
    [validTouchesCurrentlyMoving intersectSet:touches];
    [validTouchesCurrentlyMoving minusSet:ignoredTouches];
    if([validTouchesCurrentlyMoving count] >= mmMinimumNumberOfScrapTouches){
        if(self.state == UIGestureRecognizerStateBegan){
            initialDistance = 0;
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
        if([validTouches count] >= 2 && !initialDistance){
            initialDistance = [self distanceBetweenTouches:validTouches];
        }
        if([validTouches count] >= 2 && initialDistance){
            CGFloat newScale = [self distanceBetweenTouches:validTouches] / initialDistance;
            if(newScale > scale){
                scaleDirection = MMScaleDirectionLarger;
            }else if(newScale < scale){
                scaleDirection = MMScaleDirectionSmaller;
            }
            scale = newScale;
        }
        if([validTouches count] >= 2){
            CGPoint p1 = [[validTouches firstObject] locationInView:self.view];
            CGPoint p2 = [[validTouches objectAtIndex:1] locationInView:self.view];
            MMVector* currentVector = [[MMVector alloc] initWithPoint:p1 andPoint:p2];
            CGFloat diff = [initialTouchVector angleBetween:currentVector];
            rotation += diff;
            initialTouchVector = currentVector;
            CGPoint locInView = [self locationInView:self.view];
            translation = CGPointMake(locInView.x - gestureLocationAtStart.x, locInView.y - gestureLocationAtStart.y);

            if(self.scrap){
                //
                // only calculate shaking if we're currently
                // holding a scrap
                //
                // our touch information includes the number of
                // times that a particular touch has been shaken.
                // this data ensures that the touch has changed direction
                // only back and forth, that it has kept a fast velocity,
                // and if we have ever actually processed that shake yet
                int numberOfShakingTouches = 0;
                for(UITouch* touch in validTouches){
                    int index = [[MMTouchVelocityGestureRecognizer sharedInstace] indexForTouchInCacheIfExists:touch];
                    if(index != -1){
                        if(touchIntervals[index].numberOfDirectionChanges >= kNumberOfDirectionChangesToDetermineShake &&
                           !touchIntervals[index].hasProcessedShake){
                            // only count shakes that have
                            // changed direction enough times, and
                            // that we haven't processed yet
                            //
                            // this counts touches that are shaking,
                            // i need two touches for 1 scrap shake
                            numberOfShakingTouches ++;
                        }
                    }
                }
                // check to see if we have enough touches
                // that are both being shaked + so far unprocessed
                if(numberOfShakingTouches >= mmMinimumNumberOfScrapTouches){
                    isShaking = YES;
                    // now we need to tell that we've processed the shakes
                    // so that we don't use this same shake gesture to
                    // repeat immediately
                    for(UITouch* touch in validTouches){
                        int index = [[MMTouchVelocityGestureRecognizer sharedInstace] indexForTouchInCacheIfExists:touch];
                        if(index != -1){
                            touchIntervals[index].hasProcessedShake = YES;
                        }
                    }
                }
            }
        }
        self.state = UIGestureRecognizerStateChanged;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    isShaking = NO;
    // pan and pinch and bezel
    BOOL cancelledFromBezel = NO;
    NSMutableOrderedSet* validTouchesCurrentlyEnding = [NSMutableOrderedSet orderedSetWithOrderedSet:validTouches];
    [validTouchesCurrentlyEnding intersectSet:touches];
    [validTouchesCurrentlyEnding minusSet:ignoredTouches];
    
    
    if(self.state == UIGestureRecognizerStateBegan ||
       self.state == UIGestureRecognizerStateChanged){
        //
        // make sure we've actually seen two fingers on the page
        // before we change state or worry about bezeling
        if([validTouchesCurrentlyEnding count]){
            for(UITouch* touch in validTouchesCurrentlyEnding){
                CGPoint point = [touch locationInView:self.view.superview];
                

                // we'll use the velocity of a touch to determine if
                // the user was "throwing" a scrap towards the bezel.
                //
                // the faster the user drags the scrap, the more forgiving
                // we'll be for if they end on a bezel.
                //
                // look up our velocity from our cache
                CGFloat velocity = 0;
                int indexOfTouch;
                struct DurationCacheObject cacheInfo = [[MMTouchVelocityGestureRecognizer sharedInstace] velocityInformationForTouch:touch withIndex:&indexOfTouch];
                velocity = cacheInfo.instantaneousNormalizedVelocity;
                // this uses instant velocity to calculate the extra bezel width to
                // use. if this ends up too finicky, then we can use average velocity
                // instead.
                CGFloat pxVelocity = velocity * SCRAP_VELOCITY_CLAMP_MAX * .05; // velocity per fraction of a second
                
                BOOL bezelDirHasLeft = ((bezelDirectionMask & MMBezelDirectionLeft) == MMBezelDirectionLeft);
                BOOL bezelDirHasRight = ((bezelDirectionMask & MMBezelDirectionRight) == MMBezelDirectionRight);
                BOOL bezelDirHasUp = ((bezelDirectionMask & MMBezelDirectionUp) == MMBezelDirectionUp);
                BOOL bezelDirHasDown = ((bezelDirectionMask & MMBezelDirectionDown) == MMBezelDirectionDown);
                if(point.x < kBezelInGestureWidth && bezelDirHasLeft){
                    didExitToBezel = didExitToBezel | MMBezelDirectionLeft;
                    cancelledFromBezel = YES;
                }else if(point.y < kBezelInGestureWidth && bezelDirHasUp){
                    didExitToBezel = didExitToBezel | MMBezelDirectionUp;
                    cancelledFromBezel = YES;
                }else if(point.x > self.view.superview.frame.size.width - kBezelInGestureWidth - pxVelocity && bezelDirHasRight){
                    didExitToBezel = didExitToBezel | MMBezelDirectionRight;
                    cancelledFromBezel = YES;
                }else if(point.y > self.view.superview.frame.size.height - kBezelInGestureWidth - pxVelocity && bezelDirHasDown){
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
               ([validTouches count] - [validTouchesCurrentlyEnding count]) < mmMinimumNumberOfScrapTouches){
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
           [possibleTouches count] == 0){
            self.state = UIGestureRecognizerStateEnded;
        }
    }else{
        //
        // only 1 finger during this gesture, and it's exited
        // so it doesn't count for bezeling or pan/pinch
        [validTouches minusOrderedSet:validTouchesCurrentlyEnding];
        [possibleTouches removeObjectsInSet:touches];
        [ignoredTouches removeObjectsInSet:touches];
        
        if(![validTouches count] && ![possibleTouches count] && ![ignoredTouches count]){
            self.state = UIGestureRecognizerStateFailed;
        }
    }
    if([validTouches count] >= mmMinimumNumberOfScrapTouchesmmMinimumNumberOfScrapTouches && [validTouchesCurrentlyEnding count]){
        // reset the location and the initial distance of the gesture
        // so that the new first two touches position won't immediatley
        // change where the page is or what its scale is
        [self setAnchorPoint:CGPointMake(.5, .5) forView:scrap];
        [self prepareGestureToBeginFresh];
    }
//    NSLog(@"pan scrap valid: %d  possible: %d  ignored: %d", [validTouches count], [possibleTouches count], [ignoredTouches count]);
    for(UITouch* touch in touches){
        [self clearCacheForTouch:touch];
    }
}



- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    NSMutableOrderedSet* validTouchesCurrentlyCancelling = [NSMutableOrderedSet orderedSetWithOrderedSet:validTouches];
    [validTouchesCurrentlyCancelling intersectSet:touches];
    [validTouchesCurrentlyCancelling minusSet:ignoredTouches];
    if([validTouchesCurrentlyCancelling count]){
        if(self.numberOfTouches == 1 && self.state == UIGestureRecognizerStateChanged){
            self.state = UIGestureRecognizerStatePossible;
        }else if([validTouches count] == 0 &&
                 [possibleTouches count] == 0 &&
                 [ignoredTouches count] == 0 &&
                 self.state == UIGestureRecognizerStateChanged){
            self.state = UIGestureRecognizerStateCancelled;
        }
        [validTouches minusOrderedSet:validTouchesCurrentlyCancelling];
    }
    [possibleTouches removeObjectsInSet:touches];
    [ignoredTouches removeObjectsInSet:touches];
//    NSLog(@"pan scrap valid: %d  possible: %d  ignored: %d", [validTouches count], [possibleTouches count], [ignoredTouches count]);

    for(UITouch* touch in touches){
        [self clearCacheForTouch:touch];
    }
}

/**
 * during the gesture, we allow the user
 * to lift fingers and effectively restart
 * the gesture
 *
 * this method will reset the state of the
 * gesture to whatever the top two touches
 * are in validTouches.
 *
 * this way, we can remove/change the two touches
 * that we're using to control the gesture, and
 * reset the state of our gesture to the beginning
 * without actually cycling the state of the gesture.
 *
 * this is important, b/c once the gesture state
 * ends or cancels, even if touches are still on screen
 * the gesture can't restart until *all* touches
 * end on the screen.
 *
 * this way we don't have to wait
 */
-(void) prepareGestureToBeginFresh{
    // set the anchor point so that it
    // rotates around the point that we're
    // gesturing
    CGPoint p = [self locationInView:scrap];
    // the frame size includes the translation, but the locationInView does not
    // and neither does the bounds. so we need to use bounds.size, not frame.size
    // to determine where to set the anchor point
    p = CGPointMake(p.x / scrap.bounds.size.width, p.y / scrap.bounds.size.height);
    [self setAnchorPoint:p forView:scrap];

    CGPoint p1 = [[validTouches firstObject] locationInView:self.view];
    CGPoint p2 = [[validTouches objectAtIndex:1] locationInView:self.view];
    initialTouchVector = [[MMVector alloc] initWithPoint:p1 andPoint:p2];
    rotation = 0;
    gestureLocationAtStart = [self locationInView:self.view];
    initialDistance = [self distanceBetweenTouches:validTouches];
    translation = CGPointZero;
    scale = 1;
    self.shouldReset = YES;
}

/**
 * since we are adjusting the anchor point of the scrap
 * during the gesture, this method should be called by
 * our delegate after the gesture is complete. this gives us
 * the opportunity to fix the anchor point of the scrap
 * without having to expose anchor point methods
 */
-(void) giveUpScrap{
    [self setAnchorPoint:CGPointMake(.5, .5) forView:self.scrap];
    scrap = nil;
}

-(void)ignoreTouch:(UITouch *)touch forEvent:(UIEvent *)event{
    [ignoredTouches addObject:touch];
    [self clearCacheForTouch:touch];
    [super ignoreTouch:touch forEvent:event];
}
- (void)reset{
    [super reset];
    initialDistance = 0;
    scale = 1;
    [validTouches removeAllObjects];
    [ignoredTouches removeAllObjects];
    [possibleTouches removeAllObjects];
    didExitToBezel = MMBezelDirectionNone;
    scaleDirection = MMScaleDirectionNone;
    secondToLastTouchDidBezel = NO;
    scrap = nil;
    gestureLocationAtStart = CGPointZero;
    translation = CGPointZero;
    self.shouldReset = NO;
}

/**
 * helper to calculate distance between input touches
 * to help us track initial vs moving scale
 */
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
 * this will set the anchor point for a scrap, so that it rotates
 * underneath the gesture realistically, instead of always from
 * it's center
 */
-(void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view
{
    CGPoint newPoint = CGPointMake(view.bounds.size.width * anchorPoint.x, view.bounds.size.height * anchorPoint.y);
    CGPoint oldPoint = CGPointMake(view.bounds.size.width * view.layer.anchorPoint.x, view.bounds.size.height * view.layer.anchorPoint.y);
    
    newPoint = CGPointApplyAffineTransform(newPoint, view.transform);
    oldPoint = CGPointApplyAffineTransform(oldPoint, view.transform);
    
    CGPoint position = view.layer.position;
    
    position.x -= oldPoint.x;
    position.x += newPoint.x;
    
    position.y -= oldPoint.y;
    position.y += newPoint.y;
    
    view.layer.position = position;
    view.layer.anchorPoint = anchorPoint;
}


#pragma mark - Shake Helpers

-(void) calculateShakesForTouch:(UITouch*)touch{
    int indexOfTouchInformation = -1;
    struct DurationCacheObject cache = [[MMTouchVelocityGestureRecognizer sharedInstace] velocityInformationForTouch:touch withIndex:&indexOfTouchInformation];
    if(indexOfTouchInformation != -1){
        // we have velocity information for this touch
        
        if(cache.distanceFromPrevious > 5){
            if(cache.avgNormalizedVelocity < 0.5 ||
               (cache.deltaAngle >= 0.2 && cache.deltaAngle <= 0.8)){
                // too slow
                // or angle too wide
                touchIntervals[indexOfTouchInformation].numberOfDirectionChanges = 0;
                touchIntervals[indexOfTouchInformation].hasProcessedShake = NO;
            }else if(cache.deltaAngle < 0.2){
                // same direction
            }else if(cache.deltaAngle > 0.8){
                // opposite direction
                touchIntervals[indexOfTouchInformation].numberOfDirectionChanges += 1;
            }
        }
    }else{
        // we don't have velocity information for this touch
    }
}

-(void) clearCacheForTouch:(UITouch*)touch{
    int index = [[MMTouchVelocityGestureRecognizer sharedInstace] indexForTouchInCacheIfExists:touch];
    if(index != -1){
        touchIntervals[index].numberOfDirectionChanges = 0;
        touchIntervals[index].hasProcessedShake = NO;
    }
}


@end
