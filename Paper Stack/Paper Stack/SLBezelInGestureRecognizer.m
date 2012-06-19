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

-(id) init{
    self = [super init];
    self.bezelDirectionMask = SLBezelDirectionFromBottomBezel | SLBezelDirectionFromLeftBezel | SLBezelDirectionFromRightBezel | SLBezelDirectionFromTopBezel;
    return self;
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer{
    return YES;
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer{
    return NO;
}

-(CGPoint) translationInView:(UIView *)view{
    if(view == self.view){
        CGPoint p = [self locationInView:view];
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
            debug_NSLog(@"point for bezel: %f %f", point.x, point.y);
        }
    }
    panDirection = SLBezelDirectionNone;
    lastKnownLocation = [self locationInView:self.view];
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    CGPoint p = [self locationInView:self.view];
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
    [super touchesMoved:touches withEvent:event];
    if(self.state == UIGestureRecognizerStateBegan){
        firstKnownLocation = lastKnownLocation;
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
- (void)reset{
    [super reset];
}
@end
