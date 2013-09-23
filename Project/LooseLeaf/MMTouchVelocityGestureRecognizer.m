//
//  MMTouchVelocityGestureRecognizer.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/13/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMTouchVelocityGestureRecognizer.h"

static float clamp(min, max, value) { return fmaxf(min, fminf(max, value)); }

struct DurationCacheObject{
    NSUInteger hash;
    NSTimeInterval timestamp;
    CGFloat normalizedVelocity;
};

#define kDurationTouchHashSize 20
#define           VELOCITY_CLAMP_MIN 20
#define           VELOCITY_CLAMP_MAX 1000


@implementation MMTouchVelocityGestureRecognizer{
    struct DurationCacheObject durationCache[kDurationTouchHashSize];
}


#pragma mark - Singleton

static MMTouchVelocityGestureRecognizer* _instance = nil;

-(id) init{
    if(_instance) return _instance;
    if((self = [super init])){
        _instance = self;
        self.delaysTouchesBegan = NO;
        self.delaysTouchesEnded = NO;
        self.cancelsTouchesInView = NO;
    }
    return _instance;
}

+(MMTouchVelocityGestureRecognizer*) sharedInstace{
    if(!_instance){
        _instance = [[MMTouchVelocityGestureRecognizer alloc]init];
        _instance.delegate = _instance;
    }
    return _instance;
}


-(BOOL) canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer{
    return NO;
}

-(BOOL) shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return NO;
}


#pragma mark - Public Methods

-(CGFloat) normalizedVelocityForTouch:(UITouch*)touch{
    int indexOfTouch = [self indexForTouchInCacheWithoutInitializing:touch];
    if(indexOfTouch == -1){
        return 1;
    }
    return durationCache[indexOfTouch].normalizedVelocity;
}


#pragma mark - Touch Methods

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    for(UITouch* touch in touches){
        // initialize values for touch
        int indexOfTouch = [self indexForTouchInCache:touch];
        durationCache[indexOfTouch].normalizedVelocity = 1;
        durationCache[indexOfTouch].timestamp = touch.timestamp;
    }
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [self updateStateInformationForTouches:touches];
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self updateStateInformationForTouches:touches];
    NSSet* touchesToKill = [NSSet setWithSet:touches];
    dispatch_async(dispatch_get_main_queue(),^{
        [self killStateInformationForTouches:touchesToKill];
    });
}

-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [self updateStateInformationForTouches:touches];
    NSSet* touchesToKill = [NSSet setWithSet:touches];
    dispatch_async(dispatch_get_main_queue(),^{
        [self killStateInformationForTouches:touchesToKill];
    });
}


-(void) updateStateInformationForTouches:(NSSet*)touches{
    for(UITouch* touch in touches){
        int indexOfTouch = [self indexForTouchInCache:touch];
        // calc duration
        NSTimeInterval currTime = touch.timestamp;
        NSTimeInterval lastTime = durationCache[indexOfTouch].timestamp;
        NSTimeInterval duration = currTime - lastTime;
        // calc velocity
        CGFloat normalizedVelocity = [self velocityForTouch:touch givenDuration:duration];
        
        // update our state
        durationCache[indexOfTouch].timestamp = currTime;
        durationCache[indexOfTouch].normalizedVelocity = normalizedVelocity;
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
    NSLog(@"still %d in cache", c);
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
        NSLog(@"what3");
    }
    durationCache[firstFreeSlot].hash = touchHash;
    durationCache[firstFreeSlot].normalizedVelocity = 0;
    durationCache[firstFreeSlot].timestamp = 0;
    return firstFreeSlot;
}

/**
 * fetch the index for the input touch.
 *
 * if we don't have the touch in cache yet,
 * then create it and init it's values to
 * zero.
 */
-(int) indexForTouchInCacheWithoutInitializing:(UITouch*)touch{
    NSUInteger touchHash = touch.hash;
    for(int i=0;i<kDurationTouchHashSize;i++){
        if(durationCache[i].hash == touchHash){
            return i;
        }
    }
    return -1;
}


/**
 * helper method to calculate the velocity of the
 * input touch. it calculates the distance travelled
 * from the previous touch over the duration elapsed
 * between touches
 */
-(CGFloat) velocityForTouch:(UITouch*)touch givenDuration:(NSTimeInterval)duration{
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
    float normalizedVelocity = (clampedVelocityMagnitude - VELOCITY_CLAMP_MIN) / (VELOCITY_CLAMP_MAX - VELOCITY_CLAMP_MIN);
    
    return normalizedVelocity;
}

/**
 * this will return the previous duration of a touch
 * AND will set our cache to the touch's current timestamp.
 *
 * this means that if you call this function twice w/o the touch
 * having been udpated, this method will start to return 0!
 *
 * the Bang in the method name signifies this
 * (from using ! in function names with side effects in Scheme...)
 */
-(NSTimeInterval) durationForTouchBang:(UITouch*)touch{
    int indexOfTouch = [self indexForTouchInCache:touch];
    if(indexOfTouch == -1){
        return 0;
    }
    // get the two values
    NSTimeInterval currTime = touch.timestamp;
    NSTimeInterval lastTime = durationCache[indexOfTouch].timestamp;
    // now update
    durationCache[indexOfTouch].timestamp = currTime;
    // done
    return currTime - lastTime;
}

-(void) removeCacheFor:(UITouch*)touch{
    int indexOfTouch = [self indexForTouchInCache:touch];
    if(indexOfTouch != -1){
        durationCache[indexOfTouch].hash = 0;
    }
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

@end
