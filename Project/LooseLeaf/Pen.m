//
//  Pen.m
//  jotuiexample
//
//  Created by Adam Wulf on 12/18/12.
//  Copyright (c) 2012 Adonit. All rights reserved.
//

#import "Pen.h"
#import "Constants.h"
#import "TestFlight.h"
#import <JotUI/JotUI.h>
#import "MMTouchVelocityGestureRecognizer.h"

#define           VELOCITY_CLAMP_MIN 20
#define           VELOCITY_CLAMP_MAX 1000


@implementation Pen

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

-(void) setColor:(UIColor *)_color{
    color = [_color colorWithAlphaComponent:1];
}

-(id) init{
    return [self initWithMinSize:4.0 andMaxSize:8.0 andMinAlpha:0.75 andMaxAlpha:0.9];
}

-(UIImage*) texture{
    return [UIImage imageNamed:@"Circle.png"];
}

-(BOOL) shouldUseVelocity{
    if([[JotStylusManager sharedInstance] enabled] && [[JotStylusManager sharedInstance] isStylusConnected]){
        return NO;
    }
    return YES;
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

#pragma mark - JotViewDelegate

/**
 * delegate method - a notification from the JotView
 * that a new touch is about to be processed. we should
 * reset all of our counters/etc to base values
 */
-(BOOL) willBeginStrokeWithTouch:(JotTouch*)touch{
    velocity = 1;
    return YES;
}

/**
 * notification that the JotView is about to ask for
 * alpha/width info for this touch. let's update
 * our velocity model and state info for this new touch
 */
-(void) willMoveStrokeWithTouch:(JotTouch*)touch{
    velocity = [[MMTouchVelocityGestureRecognizer sharedInstace] normalizedVelocityForTouch:touch.touch];
}

-(void) willEndStrokeWithTouch:(JotTouch*)touch{
    // noop
}

/**
 * user is finished with a stroke. for our purposes
 * we don't need to do anything
 */
-(void) didEndStrokeWithTouch:(JotTouch*)touch{
    // noop
}

-(void) willCancelStroke:(JotStroke*)stroke withTouch:(JotTouch*)touch{
    // noop
}

/**
 * the user cancelled the touch
 */
-(void) didCancelStroke:(JotStroke*)stroke withTouch:(JotTouch*)touch{
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
    if(self.shouldUseVelocity){
        CGFloat segmentAlpha = (velocity - 1);
        if(segmentAlpha > 0) segmentAlpha = 0;
        segmentAlpha = minAlpha + ABS(segmentAlpha) * (maxAlpha - minAlpha);
        
        UIColor* currColor = color;
        currColor = [UIColor colorWithCGColor:currColor.CGColor];
        UIColor* ret = [currColor colorWithAlphaComponent:segmentAlpha];
        return ret;
    }else{
        CGFloat segmentAlpha = minAlpha + (maxAlpha-minAlpha) * touch.pressure / JOT_MAX_PRESSURE;
        if(segmentAlpha < minAlpha) segmentAlpha = minAlpha;
        UIColor* ret = [color colorWithAlphaComponent:segmentAlpha];
        return ret;
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
    if(self.shouldUseVelocity){
        CGFloat width = (velocity - 1);
        if(width > 0) width = 0;
        width = minSize + ABS(width) * (maxSize - minSize);
        if(width < 1) width = 1;
        
        return width;
    }else{
        CGFloat newWidth = minSize + (maxSize-minSize) * touch.pressure / (CGFloat) JOT_MAX_PRESSURE;
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

-(NSArray*) willAddElementsToStroke:(NSArray *)elements fromPreviousElement:(AbstractBezierPathElement*)previousElement{
    return elements;
}

@end
