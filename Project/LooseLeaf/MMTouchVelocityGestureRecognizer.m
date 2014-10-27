//
//  MMTouchVelocityGestureRecognizer.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/13/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMTouchVelocityGestureRecognizer.h"
#import "MMVector.h"
#import "MMScrapPaperStackView.h"
#import "MMPageCacheManager.h"
#import "MMUntouchableView.h"


#define  kVelocityLowPass 0.7
#define  kDurationTouchHashSize 20
#define  VELOCITY_CLAMP_MIN 20
#define  VELOCITY_CLAMP_MAX 800

static float clamp(min, max, value) { return fmaxf(min, fminf(max, value)); }


@implementation MMTouchVelocityGestureRecognizer{
    struct DurationCacheObject durationCache[kDurationTouchHashSize];
    NSTimer* debugTimer;
    NSMutableSet* notifyTheseWhenTouchDies;
}

#pragma mark - Properties

@synthesize stackView;

+(int) cacheSize{
    return kDurationTouchHashSize;
}

+(int) maxVelocity{
    return VELOCITY_CLAMP_MAX;
}

#pragma mark - Singleton and Init

static MMTouchVelocityGestureRecognizer* _instance = nil;

-(id) init{
    if(_instance) return _instance;
    if((self = [super init])){
        _instance = self;
        self.delaysTouchesBegan = NO;
        self.delaysTouchesEnded = NO;
        self.cancelsTouchesInView = NO;
        notifyTheseWhenTouchDies = [NSMutableSet set];
    }
    return _instance;
}

+(MMTouchVelocityGestureRecognizer*) sharedInstance{
    if(!_instance){
        _instance = [[MMTouchVelocityGestureRecognizer alloc]init];
        _instance.delegate = _instance;
    }
    return _instance;
}

#pragma mark - Notify When Touches Die

-(void) pleaseNotifyMeWhenTouchesDie:(UIGestureRecognizer<MMTouchLifeCycleDelegate>*)obj{
//    DebugLog(@"%@ asked to be notified of touch lifecycle", obj);
    [notifyTheseWhenTouchDies addObject:obj];
}

-(void) stopNotifyingMeWhenTouchesDie:(UIGestureRecognizer<MMTouchLifeCycleDelegate>*)obj{
//    DebugLog(@"%@ asked to NOT be notified of touch lifecycle", obj);
    [notifyTheseWhenTouchDies removeObject:obj];
}


#pragma mark - Public Methods

-(CGFloat) normalizedVelocityForTouch:(UITouch*)touch{
    int indexOfTouch = [self indexForTouchInCacheIfExists:touch];
    if(indexOfTouch == -1){
        return 1;
    }
    return durationCache[indexOfTouch].instantaneousNormalizedVelocity;
}

-(struct DurationCacheObject) velocityInformationForTouch:(UITouch*)touch withIndex:(int*)index{
    int indexOfTouch = [self indexForTouchInCacheIfExists:touch];
    if(indexOfTouch == -1){
        struct DurationCacheObject empty;
        empty.hash = -1;
        if(index){
            index[0] = -1;
        }
        return empty;
    }
    if(index){
        index[0] = indexOfTouch;
    }
    return durationCache[indexOfTouch];
}


#pragma mark - Touch Methods

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self killTimer];
    for(UITouch* touch in touches){
        // initialize values for touch
        int indexOfTouch = [self indexForTouchInCache:touch];
        durationCache[indexOfTouch].instantaneousNormalizedVelocity = 1;
        durationCache[indexOfTouch].lastTimestamp = touch.timestamp;
        durationCache[indexOfTouch].totalDistance = 0;
    }
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [self updateStateInformationForTouches:touches];
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self updateStateInformationForTouches:touches];
    NSSet* touchesToKill = [NSSet setWithSet:touches];
    dispatch_async(dispatch_get_main_queue(),^{
        @autoreleasepool {
            [self killStateInformationForTouches:touchesToKill];
        }
    });
    for (UIGestureRecognizer<MMTouchLifeCycleDelegate>* gesture in [notifyTheseWhenTouchDies copy]) {
        [gesture touchesDidDie:touches];
    }
}

-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [self touchesEnded:touches withEvent:event];
}

#pragma mark - State Methods

-(void) updateStateInformationForTouches:(NSSet*)touches{
    for(UITouch* touch in touches){
        int indexOfTouch = [self indexForTouchInCache:touch];
        // calc duration
        NSTimeInterval currTime = touch.timestamp;
        NSTimeInterval lastTime = durationCache[indexOfTouch].lastTimestamp;
        NSTimeInterval duration = currTime - lastTime;
        
        // calc velocity
        //
        // first, find the current and previous location of the touch
        CGPoint l = [touch locationInView:nil];
        CGPoint previousPoint = [touch previousLocationInView:nil];
        // find how far we've travelled
        float distanceFromPrevious = sqrtf((l.x - previousPoint.x) * (l.x - previousPoint.x) + (l.y - previousPoint.y) * (l.y - previousPoint.y));
        // how long did it take?
        // velocity is distance/time
        CGFloat velocityMagnitude = distanceFromPrevious/duration;
        // we need to make sure we keep velocity inside our min/max values
        float clampedVelocityMagnitude = clamp(VELOCITY_CLAMP_MIN, VELOCITY_CLAMP_MAX, velocityMagnitude);
        // now normalize it, so we return a value between 0 and 1
        CGFloat normalizedVelocity = (clampedVelocityMagnitude - VELOCITY_CLAMP_MIN) / (VELOCITY_CLAMP_MAX - VELOCITY_CLAMP_MIN);
        
        // the direction last touch:
        CGPoint oldVectorOfMotion = durationCache[indexOfTouch].directionOfTouch;
        MMVector* oldVec = [MMVector vectorWithX:oldVectorOfMotion.x andY:oldVectorOfMotion.y];
        
        // calc current direction
        CGPoint vectorOfMotion = CGPointMake((l.x - previousPoint.x), (l.y - previousPoint.y));
        MMVector* currVec = [MMVector vectorWithX:vectorOfMotion.x andY:vectorOfMotion.y];
        if(distanceFromPrevious > 5){
            // only update the direction if our magnitude is high enough.
            // this way very small adjustments don't radically change
            // our direction
            MMVector* normalDirectionVec = [currVec normal];
            durationCache[indexOfTouch].directionOfTouch = [normalDirectionVec asCGPoint];
            
            // find angle between current and previous directions.
            // the is normalized for (0,1). 0 means it's moving in the
            // exact same direction as last time, and 1 means it's in the
            // exact opposite direction.
            CGFloat deltaAngle = [currVec angleBetween:oldVec];
            durationCache[indexOfTouch].deltaAngle = ABS(deltaAngle) / M_PI;
        }
        
        // distance
        durationCache[indexOfTouch].distanceFromPrevious = distanceFromPrevious;
        durationCache[indexOfTouch].totalDistance += distanceFromPrevious;
        
        // average velocity
        durationCache[indexOfTouch].avgNormalizedVelocity = kVelocityLowPass*durationCache[indexOfTouch].avgNormalizedVelocity + (1-kVelocityLowPass)*normalizedVelocity;
        
        // update our state
        durationCache[indexOfTouch].lastTimestamp = currTime;
        durationCache[indexOfTouch].instantaneousNormalizedVelocity = normalizedVelocity;
    }
}

-(void) killStateInformationForTouches:(NSSet*)touches{
    for(UITouch* touch in touches){
        [self removeCacheFor:touch];
    }
    
    int c = 0;
    for(int i=0;i<kDurationTouchHashSize;i++){
        if(durationCache[i].hash != 0){
            c++;
        }
    }
    [self setupDebugTimer];
}

/**
 * fetch the index for the input touch.
 *
 * if we don't have the touch in cache yet,
 * then create it and init it's values to
 * zero.
 */
-(int) indexForTouchInCache:(UITouch*)touch{
    int firstFreeSlot = -1;
    NSUInteger touchHash = touch.hash;
    for(int i=0;i<kDurationTouchHashSize;i++){
        if(durationCache[i].hash == touchHash){
            return i;
        }
        if(firstFreeSlot == -1 && durationCache[i].hash == 0){
            firstFreeSlot = i;
        }
    }
    if(firstFreeSlot == -1){
        DebugLog(@"what3");
    }
    durationCache[firstFreeSlot].hash = touchHash;
    durationCache[firstFreeSlot].instantaneousNormalizedVelocity = 0;
    durationCache[firstFreeSlot].lastTimestamp = 0;
    return firstFreeSlot;
}

-(int) numberOfActiveTouches{
    int count = 0;
    for(int i=0;i<kDurationTouchHashSize;i++){
        if(durationCache[i].hash == 0){
            count++;
        }
    }
    return kDurationTouchHashSize - count;
}

/**
 * fetch the index for the input touch.
 */
-(int) indexForTouchInCacheIfExists:(UITouch*)touch{
    NSUInteger touchHash = touch.hash;
    for(int i=0;i<kDurationTouchHashSize;i++){
        if(durationCache[i].hash == touchHash){
            return i;
        }
    }
    return -1;
}


-(void) removeCacheFor:(UITouch*)touch{
    int indexOfTouch = [self indexForTouchInCache:touch];
    if(indexOfTouch != -1){
        durationCache[indexOfTouch].hash = 0;
    }
}

#pragma mark - UIGestureRecognizer Subclass

-(BOOL) canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer{
    return NO;
}

-(BOOL) shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return NO;
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
//        DebugLog(@"ignore touch in %@", NSStringFromClass([self class]));
        return NO;
    }
    return YES;
}


#pragma mark - Debug Timer

-(void) killTimer{
    if(debugTimer){
        [debugTimer invalidate];
        debugTimer = nil;
    }
}

-(void) setupDebugTimer{
//    return;
//    if([self numberOfActiveTouches] == 0){
//        [self killTimer];
//        debugTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(timerDidFire:) userInfo:nil repeats:NO];
//        [[NSThread mainThread] performBlock:^{
//            DebugLog(@"***************************************************************************");
//            DebugLog(@"***************************************************************************");
//        } afterDelay:.01];
//    }
}

-(void) timerDidFire:(NSTimer*)timer{
    DebugLog(@"Velocity Update");
    DebugLog(@"gestures: %@", [stackView activeGestureSummary]);
    
    [[NSThread mainThread] performBlock:^{
        [stackView cancelAllGestures];
        MMPaperView* topPage = [stackView.visibleStackHolder peekSubview];
        [topPage cancelAllGestures];
        [[stackView.visibleStackHolder getPageBelow:topPage] cancelAllGestures];
        
        MMPaperView* topHiddenPage = [stackView.hiddenStackHolder peekSubview];
        [topHiddenPage cancelAllGestures];
        [[stackView.visibleStackHolder getPageBelow:topHiddenPage] cancelAllGestures];
        
        if([stackView.bezelStackHolder.subviews count]){
            DebugLog(@"uh oh! view in bezel!");
        }
        
        NSArray* allGesturesAndTopTwoPages = [NSArray arrayWithArray:[[MMPageCacheManager sharedInstance] drawableView].gestureRecognizers];
        allGesturesAndTopTwoPages = [allGesturesAndTopTwoPages arrayByAddingObjectsFromArray:[[UIApplication sharedApplication] keyWindow].gestureRecognizers];
        for (UIGestureRecognizer* gesture in allGesturesAndTopTwoPages) {
            if([gesture respondsToSelector:@selector(cancel)]){
                DebugLog(@"trying to cancel: %@ %d", NSStringFromClass([gesture class]),(int) gesture.state);
                [gesture performSelector:@selector(cancel)];
            }else{
                DebugLog(@"couldn't cancel: %@ %d", NSStringFromClass([gesture class]),(int) gesture.state);
                if(gesture.enabled){
                    gesture.enabled = NO;
                    gesture.enabled = YES;
                    DebugLog(@"manually cancelled: %@ %d", NSStringFromClass([gesture class]),(int) gesture.state);
                }else{
                    DebugLog(@"was disabled: %@ %d", NSStringFromClass([gesture class]),(int) gesture.state);
                }
            }
        }
        
        
        DebugLog(@"cancelled gestures");
        [[NSThread mainThread] performBlock:^{
            DebugLog(@"gestures: %@", [stackView activeGestureSummary]);
        } afterDelay:1];
    } afterDelay:1];
}




@end
