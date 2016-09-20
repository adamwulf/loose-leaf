//
//  MMContinuousSwipeGestureRecognizer.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/6/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMContinuousSwipeGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>
#import "Constants.h"


@implementation MMContinuousSwipeGestureRecognizer {
    CGPoint startingLocation;
    UITouch* currTouch;
    CGFloat distNeeded;
}

@synthesize angleBuffer;

#pragma mark - Init

- (id)initWithTarget:(id)target action:(SEL)action {
    self = [super initWithTarget:target action:action];
    self.cancelsTouchesInView = NO;
    self.delaysTouchesEnded = NO;
    self.delaysTouchesBegan = YES;
    self.maximumNumberOfTouches = 1;
    angleBuffer = 20;
    distNeeded = 10;
    return self;
}

- (CGPoint)distanceSinceBegin {
    CGPoint currLoc = [currTouch locationInView:self.view];
    return CGPointMake(currLoc.x - startingLocation.x, currLoc.y - startingLocation.y);
}

#pragma mark - UITouch Events

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    if (!currTouch) {
        currTouch = [touches anyObject];
        startingLocation = [currTouch locationInView:self.view];
    }
    NSSet* otherTouches = [touches objectsPassingTest:^BOOL(id obj, BOOL* stop) {
        return obj != currTouch;
    }];

    [otherTouches enumerateObjectsUsingBlock:^(id obj, BOOL* stop) {
        [self ignoreTouch:obj forEvent:event];
    }];
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
    if (![touches containsObject:currTouch]) {
        return;
    }
    CGPoint currLoc = [currTouch locationInView:self.view];
    CGPoint diff = CGPointMake(currLoc.x - startingLocation.x, currLoc.y - startingLocation.y);
    CGFloat theta = atan2f(diff.x, diff.y) * 180 / M_PI;

    if (self.state == UIGestureRecognizerStatePossible) {
        if (diff.x < -distNeeded || diff.x > distNeeded) {
            if ((theta > -90 - angleBuffer && theta < -90 + angleBuffer) || (theta < 90 + angleBuffer && theta > 90 - angleBuffer)) {
                self.state = UIGestureRecognizerStateBegan;
            }
        }
        if (DistanceBetweenTwoPoints(startingLocation, currLoc) > 2 * distNeeded) {
            if (self.state == UIGestureRecognizerStatePossible) {
                self.state = UIGestureRecognizerStateFailed;
            }
        }
    } else if (self.state == UIGestureRecognizerStateBegan ||
               self.state == UIGestureRecognizerStateChanged) {
        self.state = UIGestureRecognizerStateChanged;
    }
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
    if ([touches containsObject:currTouch] && self.state == UIGestureRecognizerStateChanged) {
        self.state = UIGestureRecognizerStateEnded;
        currTouch = nil;
    } else {
        self.state = UIGestureRecognizerStateFailed;
    }
}

- (void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event {
    if ([touches containsObject:currTouch] && self.state == UIGestureRecognizerStateChanged) {
        self.state = UIGestureRecognizerStateCancelled;
        currTouch = nil;
    } else {
        self.state = UIGestureRecognizerStateFailed;
    }
}

- (UITouch*)touch {
    return currTouch;
}

- (void)reset {
    [super reset];
    currTouch = nil;
}

- (CGPoint)locationInView:(UIView*)view {
    return [self locationOfTouch:0 inView:view];
}

- (CGPoint)locationOfTouch:(NSUInteger)touchIndex inView:(UIView*)view {
    return [currTouch locationInView:view];
}

#pragma mark - UIGestureRecognizer Subclass

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer*)preventedGestureRecognizer {
    return NO;
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer*)preventingGestureRecognizer {
    return NO;
}

- (NSString*)description {
    return [NSString stringWithFormat:@"[%@ %p]", NSStringFromClass([self class]), self];
}

@end
