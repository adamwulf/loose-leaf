//
//  SLBezelGestureRecognizer.m
//  Paper Stack
//
//  Created by Adam Wulf on 6/19/12.
//  Copyright (c) 2012 Visere. All rights reserved.
//

#import "SLBezelInGestureRecognizer.h"
#import "Constants.h"

@implementation SLBezelInGestureRecognizer
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
        if(point.x < 10 && !((self.bezelDirectionMask & SLBezelDirectionFromLeftBezel) == SLBezelDirectionFromLeftBezel)){
            [self ignoreTouch:touch forEvent:event];
        }else if(point.y < 10 && !((self.bezelDirectionMask & SLBezelDirectionFromTopBezel) == SLBezelDirectionFromTopBezel)){
            [self ignoreTouch:touch forEvent:event];
        }else if(point.x > self.view.frame.size.width - 10 && !((self.bezelDirectionMask & SLBezelDirectionFromRightBezel) == SLBezelDirectionFromRightBezel)){
            [self ignoreTouch:touch forEvent:event];
        }else if(point.y > self.view.frame.size.height - 10 && !((self.bezelDirectionMask & SLBezelDirectionFromBottomBezel) == SLBezelDirectionFromBottomBezel)){
            [self ignoreTouch:touch forEvent:event];
        }else if(point.x > 10 && point.y > 10 && point.x < self.view.frame.size.width - 10 && point.y < self.view.frame.size.height - 10){
            // ignore touch inside main view, only accept bezel touches
            [self ignoreTouch:touch forEvent:event];
        }else{
//            debug_NSLog(@"point for bezel: %f %f", point.x, point.y);
        }
    }
    panDirection = SLBezelDirectionNone;
    lastKnownLocation = [self furthestLeftTouchLocation];
    [super touchesBegan:touches withEvent:event];
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
