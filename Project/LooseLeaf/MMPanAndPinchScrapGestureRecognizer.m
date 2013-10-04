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

#define kMaxSimultaneousTouchesAllowedToTrack 20
#define kNumberOfDirectionChangesToDetermineShake 3

struct TouchInterval{
    NSUInteger touchHash;
    NSTimeInterval lastTimestamp;
    float normalizedVelocity;
    CGPoint directionOfTouch;
    NSInteger numberOfDirectionChanges;
    BOOL hasProcessedShake;
    NSTimeInterval shakeBeganTimestamp;
    CGFloat avgNormalizedVelocity;
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
    
    NSMutableDictionary* shakeData;
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


NSInteger const  minimumNumberOfTouches = 2;
#define           SCRAP_VELOCITY_CLAMP_MIN 20
#define           SCRAP_VELOCITY_CLAMP_MAX 2000

static float clamp(min, max, value) { return fmaxf(min, fminf(max, value)); }


-(id) init{
    self = [super init];
    if(self){
        validTouches = [[NSMutableOrderedSet alloc] init];
        possibleTouches = [[NSMutableOrderedSet alloc] init];
        ignoredTouches = [[NSMutableSet alloc] init];
        for(int i=0;i<100;i++){
            touchIntervals[i].touchHash = 0;
        }
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
    if([validTouches count] >= minimumNumberOfTouches){
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
    for(UITouch* touch in touches){
        [self calculateVelocityForTouch:touch];
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
        
        if([validTouches count] >= minimumNumberOfTouches){
            
            [self prepareGestureToBeginFresh];
            
            didExitToBezel = MMBezelDirectionNone;

            self.state = UIGestureRecognizerStateBegan;
        }else if([validTouches count] < minimumNumberOfTouches){
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
    for(UITouch* t in touches){
        [self calculateVelocityForTouch:t];
    }
    NSMutableOrderedSet* validTouchesCurrentlyMoving = [validTouches mutableCopy];
    [validTouchesCurrentlyMoving intersectSet:touches];
    [validTouchesCurrentlyMoving minusSet:ignoredTouches];
    if([validTouchesCurrentlyMoving count] >= minimumNumberOfTouches){
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
        }
        self.state = UIGestureRecognizerStateChanged;
        

        int numberOfShakingTouches = 0;
        for(UITouch* touch in validTouches){
            for(int i=0;i<kMaxSimultaneousTouchesAllowedToTrack;i++){
                if(touchIntervals[i].touchHash == touch.hash){
                    if(touchIntervals[i].numberOfDirectionChanges >= kNumberOfDirectionChangesToDetermineShake &&
                       !touchIntervals[i].hasProcessedShake){
                        numberOfShakingTouches ++;
                    }
                    break;
                }
            }
        }
        if(numberOfShakingTouches >= minimumNumberOfTouches){
            NSLog(@"shake!!!!!!! %d", numberOfShakingTouches);
            for(UITouch* touch in validTouches){
                for(int i=0;i<kMaxSimultaneousTouchesAllowedToTrack;i++){
                    if(touchIntervals[i].touchHash == touch.hash){
                        touchIntervals[i].hasProcessedShake = YES;
                        break;
                    }
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
                for(int i=0;i<kMaxSimultaneousTouchesAllowedToTrack;i++){
                    if(touchIntervals[i].touchHash == touch.hash){
                        velocity = touchIntervals[i].normalizedVelocity;
                        break;
                    }
                }

                CGFloat pxVelocity = velocity * SCRAP_VELOCITY_CLAMP_MAX * .05; // velocity per fraction of a second
//                NSLog(@"velocity: %d %f    => %f", (int)touch, velocity, pxVelocity);
                
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
               ([validTouches count] - [validTouchesCurrentlyEnding count]) < minimumNumberOfTouches){
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
    if([validTouches count] >= minimumNumberOfTouches && [validTouchesCurrentlyEnding count]){
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


-(void) setState:(UIGestureRecognizerState)state{
    [super setState:state];
    if(self.state == UIGestureRecognizerStateBegan){
//        NSLog(@"began scrap pan");
        self.shouldReset = YES;
    }else if(self.state == UIGestureRecognizerStateEnded){
//        NSLog(@"ended scrap pan");
    }else if(self.state == UIGestureRecognizerStateCancelled){
//        NSLog(@"cancelled scrap pan");
    }else if(self.state == UIGestureRecognizerStateFailed){
//        NSLog(@"failed scrap pan");
    }else if(self.state == UIGestureRecognizerStateChanged){
//        NSLog(@"changed scrap pan");
    }else if(self.state == UIGestureRecognizerStatePossible){
//        NSLog(@"possible scrap pan");
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

/**
 * helper method to calculate the velocity of the
 * input touch. it calculates the distance travelled
 * from the previous touch over the duration elapsed
 * between touches
 */
-(int) calculateVelocityForTouch:(UITouch*)touch{
    //
    // first, find the current and previous location of the touch
    CGPoint l = [touch locationInView:nil];
    CGPoint previousPoint = [touch previousLocationInView:nil];
    CGPoint vectorOfMotion = CGPointMake((l.x - previousPoint.x), (l.y - previousPoint.y));
    // find how far we've travelled
    float distanceFromPrevious = sqrtf(vectorOfMotion.x * vectorOfMotion.x + vectorOfMotion.y * vectorOfMotion.y);
    // how long did it take?
    int indexOfTouchInCache;
    NSTimeInterval duration = [self durationForTouchBang:touch withIndex:&indexOfTouchInCache];
    // velocity is distance/time
    CGFloat velocityMagnitude = distanceFromPrevious/duration;
    
    // we need to make sure we keep velocity inside our min/max values
    float clampedVelocityMagnitude = clamp(SCRAP_VELOCITY_CLAMP_MIN, SCRAP_VELOCITY_CLAMP_MAX, velocityMagnitude);
    // now normalize it, so we return a value between 0 and 1
    float normalizedVelocity = (clampedVelocityMagnitude - SCRAP_VELOCITY_CLAMP_MIN) / (SCRAP_VELOCITY_CLAMP_MAX - SCRAP_VELOCITY_CLAMP_MIN);
    
    
    MMVector* currVec = [MMVector vectorWithX:vectorOfMotion.x andY:vectorOfMotion.y];
    //
    // this will low-pass filter our velocity data to give us an average velocity
    // over the past 10 touches
    touchIntervals[indexOfTouchInCache].avgNormalizedVelocity = .9*touchIntervals[indexOfTouchInCache].avgNormalizedVelocity + .1*normalizedVelocity;

    if([currVec magnitude] > 5){
        CGPoint oldVectorOfMotion = touchIntervals[indexOfTouchInCache].directionOfTouch;
        MMVector* oldVec = [MMVector vectorWithX:oldVectorOfMotion.x andY:oldVectorOfMotion.y];

        // find angle between current and previous directions.
        // the is normalized for (0,1). 0 means it's moving in the
        // exact same direction as last time, and 1 means it's in the
        // exact opposite direction.
        CGFloat deltaAngle = [currVec angleBetween:oldVec];
        deltaAngle = ABS(deltaAngle) / M_PI;
        
        if(touchIntervals[indexOfTouchInCache].avgNormalizedVelocity < 0.5 ||
           (deltaAngle >= 0.2 && deltaAngle <= 0.8)){
            // too slow
            // or angle too wide
            touchIntervals[indexOfTouchInCache].numberOfDirectionChanges = 0;
            touchIntervals[indexOfTouchInCache].shakeBeganTimestamp = touch.timestamp;
            touchIntervals[indexOfTouchInCache].hasProcessedShake = NO;
        }else if(deltaAngle < 0.2){
            // same direction
        }else if(deltaAngle > 0.8){
            // opposite direction
            touchIntervals[indexOfTouchInCache].numberOfDirectionChanges += 1;
        }
        touchIntervals[indexOfTouchInCache].directionOfTouch = vectorOfMotion;
    }
    
    touchIntervals[indexOfTouchInCache].normalizedVelocity = normalizedVelocity;
    
    return indexOfTouchInCache;
}

-(NSTimeInterval) durationForTouchBang:(UITouch*)touch withIndex:(int*)index{
    NSTimeInterval lastTime = 0;
    int indexOfTouch = -1;
    for(int i=0;i<kMaxSimultaneousTouchesAllowedToTrack;i++){
        if(indexOfTouch == -1 && touchIntervals[i].touchHash == 0){
            indexOfTouch = i;
        }else if(touchIntervals[i].touchHash == touch.hash){
            // touch matches
            lastTime = touchIntervals[i].lastTimestamp;
            indexOfTouch = i;
            break;
        }
    }

    NSTimeInterval currTime = touch.timestamp;
    if(indexOfTouch != -1){
        if(!touchIntervals[indexOfTouch].touchHash){
            touchIntervals[indexOfTouch].touchHash = touch.hash;
            touchIntervals[indexOfTouch].shakeBeganTimestamp = currTime;
        }
        touchIntervals[indexOfTouch].lastTimestamp = currTime;
    }
    index[0] = indexOfTouch;
    return currTime - lastTime;
}

-(void) clearCacheForTouch:(UITouch*)touch{
    for(int i=0;i<kMaxSimultaneousTouchesAllowedToTrack;i++){
        if(touchIntervals[i].touchHash == touch.hash){
            touchIntervals[i].touchHash = 0;
            touchIntervals[i].numberOfDirectionChanges = 0;
            touchIntervals[i].avgNormalizedVelocity = 0;
            touchIntervals[i].hasProcessedShake = NO;
            break;
        }
    }
}


@end
