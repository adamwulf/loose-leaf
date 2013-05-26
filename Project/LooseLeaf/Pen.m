//
//  Pen.m
//  jotuiexample
//
//  Created by Adam Wulf on 12/18/12.
//  Copyright (c) 2012 Adonit. All rights reserved.
//

#import "Pen.h"

static float clamp(min, max, value) { return fmaxf(min, fminf(max, value)); }

@implementation Pen

@synthesize shouldUseVelocity;

@synthesize minSize;
@synthesize maxSize;
@synthesize minAlpha;
@synthesize maxAlpha;
@synthesize velocity;

@synthesize color;

-(id) initWithMinSize:(CGFloat)_minSize andMaxSize:(CGFloat)_maxSize andMinAlpha:(CGFloat)_minAlpha andMaxAlpha:(CGFloat)_maxAlpha{
    if(self = [super init]){
        minSize = _minSize;
        maxSize = _maxSize;
        minAlpha = _minAlpha;
        maxAlpha = _maxAlpha;
        
        defaultMinSize = minSize;
        defaultMaxSize = maxSize;
        color = [UIColor blackColor];
    }
    return self;
}

-(id) init{
    return [self initWithMinSize:6.0 andMaxSize:15.0 andMinAlpha:0.9 andMaxAlpha:0.9];
}

-(UIImage*) texture{
    return [UIImage imageNamed:@"Circle.png"];
}

#pragma mark - Setters

-(void) setMinSize:(CGFloat)_minSize{
    if(_minSize < 1){
        _minSize = 1;
    }
    minSize = _minSize;
}

-(void) setMaxSize:(CGFloat)_maxSize{
    if(_maxSize < 1){
        _maxSize = 1;
    }
    maxSize = _maxSize;
}

#pragma mark - Private Helper


/**
 * helper method to calculate the velocity of the
 * input touch. it calculates the distance travelled
 * from the previous touch over the duration elapsed
 * between touches
 */
-(CGFloat) velocityForTouch:(JotTouch*)touch{
    //
    // first, find the current and previous location of the touch
    CGPoint l = [touch windowPosition];
    CGPoint previousPoint = [touch previousWindowPosition];
    // find how far we've travelled
    float distanceFromPrevious = sqrtf((l.x - previousPoint.x) * (l.x - previousPoint.x) + (l.y - previousPoint.y) * (l.y - previousPoint.y));
    // how long did it take?
    CGFloat duration = [[NSDate date] timeIntervalSinceDate:lastDate];
    // velocity is distance/time
    CGFloat velocityMagnitude = distanceFromPrevious/duration;
    
    // we need to make sure we keep velocity inside our min/max values
    float clampedVelocityMagnitude = clamp(VELOCITY_CLAMP_MIN, VELOCITY_CLAMP_MAX, velocityMagnitude);
    // now normalize it, so we return a value between 0 and 1
    float normalizedVelocity = (clampedVelocityMagnitude - VELOCITY_CLAMP_MIN) / (VELOCITY_CLAMP_MAX - VELOCITY_CLAMP_MIN);
    
    return normalizedVelocity;
}

#pragma mark - JotViewDelegate

/**
 * delegate method - a notification from the JotView
 * that a new touch is about to be processed. we should
 * reset all of our counters/etc to base values
 */
-(void) willBeginStrokeWithTouch:(JotTouch*)touch{
    velocity = 1;
    lastDate = [NSDate date];
    numberOfTouches = 1;
}

/**
 * notification that the JotView is about to ask for
 * alpha/width info for this touch. let's update
 * our velocity model and state info for this new touch
 */
-(void) willMoveStrokeWithTouch:(JotTouch*)touch{
    numberOfTouches ++;
    if(numberOfTouches > 4) numberOfTouches = 4;
    if([self velocityForTouch:touch]){
        velocity = [self velocityForTouch:touch];
    }else{
        // noop
    }
    lastDate = [NSDate date];
    lastLoc = [touch windowPosition];
}

/**
 * user is finished with a stroke. for our purposes
 * we don't need to do anything
 */
-(void) didEndStrokeWithTouch:(JotTouch*)touch{
    // noop
}

/**
 * the user cancelled the touch
 */
-(void) didCancelStrokeWithTouch:(JotTouch*)touch{
    // noop
}

/**
 * we'll adjust the alpha of the ink
 * based on pressure or velocity.
 *
 * we could also adjust the color here too,
 * but for our demo adjusting only the alpha
 * is the look we're going for.
 */
-(UIColor*) colorForTouch:(JotTouch*)touch{
    CGFloat width = [self widthForTouch:touch];
    if(shouldUseVelocity){
        CGFloat segmentAlpha = (velocity - 1);
        if(segmentAlpha > 0) segmentAlpha = 0;
        segmentAlpha = minAlpha + ABS(segmentAlpha) * (maxAlpha - minAlpha);
        return [color colorWithAlphaComponent:segmentAlpha/(width/5)];
    }else{
        CGFloat segmentAlpha = minAlpha + (maxAlpha-minAlpha) * touch.pressure / JOT_MAX_PRESSURE;
        if(segmentAlpha < minAlpha) segmentAlpha = minAlpha;
        return [color colorWithAlphaComponent:segmentAlpha];
        return [color colorWithAlphaComponent:segmentAlpha/(width/5)];
    }
}

/**
 * the user has moved to this new touch point, and we need
 * to specify the width of the stroke at this position
 *
 * we'll use pressure data to determine width if we can, otherwise
 * we'll fall back to use velocity data
 */
-(CGFloat) widthForTouch:(JotTouch*)touch{
    if(shouldUseVelocity){
        CGFloat width = (velocity - 1);
        if(width > 0) width = 0;
        width = minSize + ABS(width) * (maxSize - minSize);
        if(width < 1) width = 1;
        return width;
    }else{
        CGFloat newWidth = minSize + (maxSize-minSize) * touch.pressure / JOT_MAX_PRESSURE;
        return newWidth;
    }
}


/**
 * we'll keep this pen fairly smooth, and using 0.75 gives
 * a good effect.
 *
 * 0 will be as if we just connected with straight lines,
 * 1 is as curvey as we can get,
 * > 1 is loopy
 * < 0 is knotty
 */
-(CGFloat) smoothnessForTouch:(JotTouch *)touch{
    return 0.75;
}

/**
 * the pen is a circle, so rotation isn't very
 * important for this pen. just return 0
 * and don't have any rotation
 */
-(CGFloat) rotationForSegment:(AbstractBezierPathElement *)segment fromPreviousSegment:(AbstractBezierPathElement *)previousSegment{
    return 0;
}

@end
