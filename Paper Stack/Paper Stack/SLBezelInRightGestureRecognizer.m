//
//  SLBezelGestureRecognizer.m
//  Paper Stack
//
//  Created by Adam Wulf on 6/19/12.
//  Copyright (c) 2012 Visere. All rights reserved.
//

#import "SLBezelInRightGestureRecognizer.h"
#import "Constants.h"

@implementation SLBezelInRightGestureRecognizer
@synthesize bezelDirectionMask;
@synthesize panDirection;

-(id) initWithTarget:(id)target action:(SEL)action{
    self = [super initWithTarget:target action:action];
    self.bezelDirectionMask = SLBezelDirectionFromBottomBezel | SLBezelDirectionFromLeftBezel | SLBezelDirectionFromRightBezel | SLBezelDirectionFromTopBezel;
    ignoredTouches = [[NSMutableSet alloc] init];
    return self;
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer{
    return YES;
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer{
    return NO;
}

/**
 * finds the touch that is furthest left
 *
 * right now, this gesture is effectively hard coded to
 * allow for bezeling in from the right.
 *
 * it would need a refactor to support gesturing from
 * other sides, despite what its API looks like
 */
-(CGPoint) furthestLeftTouchLocation{
    CGPoint ret = CGPointMake(CGFLOAT_MAX, CGFLOAT_MAX);
    for(int i=0;i<[self numberOfTouches];i++){
        CGPoint ret2 = [self locationOfTouch:i inView:self.view];
        BOOL isIgnoredTouchLocation = NO;
        if([self numberOfTouches] > 2){
            for(UITouch* touch in ignoredTouches){
                CGPoint igLoc = [touch locationInView:self.view];
                isIgnoredTouchLocation = isIgnoredTouchLocation || CGPointEqualToPoint(ret2, igLoc);
            }
        }
        if(!isIgnoredTouchLocation && ret2.x < ret.x){
            ret = ret2;
        }
    }
    return ret;
}
/**
 * returns the furthest right touch point of the gesture
 */
-(CGPoint) furthestRightTouchLocation{
    CGPoint ret = CGPointZero;
    for(int i=0;i<[self numberOfTouches];i++){
        CGPoint ret2 = [self locationOfTouch:i inView:self.view];
        BOOL isIgnoredTouchLocation = NO;
        if([self numberOfTouches] > 2){
            for(UITouch* touch in ignoredTouches){
                CGPoint igLoc = [touch locationInView:self.view];
                isIgnoredTouchLocation = isIgnoredTouchLocation || CGPointEqualToPoint(ret2, igLoc);
            }
        }
        if(!isIgnoredTouchLocation && ret2.x > ret.x){
            ret = ret2;
        }
    }
    return ret;
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
    if(view == self.view){
        CGPoint p = [self furthestLeftTouchLocation];
        return CGPointMake(p.x - firstKnownLocation.x, p.y - firstKnownLocation.y);
    }
    return [super translationInView:view];
}

/**
 * the first touch of a gesture.
 * this touch may interrupt an animation on this frame, so set the frame
 * to match that of the animation.
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    for(UITouch* touch in touches){
        CGPoint point = [touch locationInView:self.view];
        if(point.x < kBezelInGestureWidth && !((self.bezelDirectionMask & SLBezelDirectionFromLeftBezel) == SLBezelDirectionFromLeftBezel)){
            [self ignoreTouch:touch forEvent:event];
        }else if(point.y < kBezelInGestureWidth && !((self.bezelDirectionMask & SLBezelDirectionFromTopBezel) == SLBezelDirectionFromTopBezel)){
            [self ignoreTouch:touch forEvent:event];
        }else if(point.x > self.view.frame.size.width - kBezelInGestureWidth && !((self.bezelDirectionMask & SLBezelDirectionFromRightBezel) == SLBezelDirectionFromRightBezel)){
            [self ignoreTouch:touch forEvent:event];
        }else if(point.y > self.view.frame.size.height - kBezelInGestureWidth && !((self.bezelDirectionMask & SLBezelDirectionFromBottomBezel) == SLBezelDirectionFromBottomBezel)){
            [self ignoreTouch:touch forEvent:event];
        }else if(point.x > kBezelInGestureWidth && point.y > kBezelInGestureWidth && point.x < self.view.frame.size.width - kBezelInGestureWidth && point.y < self.view.frame.size.height - kBezelInGestureWidth){
            // ignore touch inside main view, only accept bezel touches
            [self ignoreTouch:touch forEvent:event];
        }else{
            //            debug_NSLog(@"point for bezel: %f %f", point.x, point.y);
        }
    }
    panDirection = SLBezelDirectionNone;
    lastKnownLocation = [self furthestLeftTouchLocation];
    [super touchesBegan:touches withEvent:event];
    debug_NSLog(@"points: %d", self.numberOfTouches);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    CGPoint p = [self furthestLeftTouchLocation];
    if(p.x != lastKnownLocation.x){
        panDirection = SLBezelDirectionNone;
        if(p.x < lastKnownLocation.x){
            panDirection = panDirection | SLBezelDirectionLeft;
        }
        if(p.x > lastKnownLocation.x){
            panDirection = panDirection | SLBezelDirectionRight;
        }
        if(p.y > lastKnownLocation.y){
            panDirection = panDirection | SLBezelDirectionDown;
        }
        if(p.y < lastKnownLocation.y){
            panDirection = panDirection | SLBezelDirectionUp;
        }
        lastKnownLocation = p;
    }
    [super touchesMoved:touches withEvent:event];
    if(self.state == UIGestureRecognizerStateBegan){
        firstKnownLocation = [self furthestRightTouchLocation];
    }
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if(self.state == UIGestureRecognizerStateChanged ||
       self.state == UIGestureRecognizerStateBegan){
        self.state = UIGestureRecognizerStateEnded;
    }
    [super touchesEnded:touches withEvent:event];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    if(self.state == UIGestureRecognizerStateChanged ||
       self.state == UIGestureRecognizerStateBegan){
        self.state = UIGestureRecognizerStateCancelled;
    }
    [super touchesCancelled:touches withEvent:event];
}
-(void)ignoreTouch:(UITouch *)touch forEvent:(UIEvent *)event{
    [ignoredTouches addObject:touch];
    [super ignoreTouch:touch forEvent:event];
}
- (void)reset{
    [super reset];
    panDirection = SLBezelDirectionNone;
    [ignoredTouches removeAllObjects];
}
@end
