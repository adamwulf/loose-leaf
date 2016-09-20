//
//  MMPalmGestureRecognizer.m
//  LooseLeaf
//
//  Created by Adam Wulf on 4/29/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMPalmGestureRecognizer.h"
#import "Constants.h"

#define kDurationToWaitAfterPalm .3


@interface MMPalmGestureRecognizer () <UIGestureRecognizerDelegate>

@end


@implementation MMPalmGestureRecognizer {
    NSMutableSet* liveTouches;
    NSMutableSet* suspectTouches;
    NSMutableSet* palmTouches;
    NSMutableDictionary* averageTouchRadius;
    NSMutableDictionary* averageTouchRadiusCount;

    NSTimeInterval lastPalmSession;
}

@synthesize hasSeenPalmDuringTouchSession = _hasSeenPalmDuringTouchSession;

#pragma mark - Singleton and Init

static MMPalmGestureRecognizer* _instance = nil;

- (id)init {
    if (_instance)
        return _instance;
    if ((self = [super init])) {
        _instance = self;
        self.delaysTouchesBegan = NO;
        self.delaysTouchesEnded = NO;
        self.cancelsTouchesInView = NO;
        liveTouches = [NSMutableSet set];
        suspectTouches = [NSMutableSet set];
        palmTouches = [NSMutableSet set];
        averageTouchRadius = [NSMutableDictionary dictionary];
        averageTouchRadiusCount = [NSMutableDictionary dictionary];

        self.enabled = YES;
    }
    return _instance;
}

+ (MMPalmGestureRecognizer*)sharedInstance {
    if (!_instance) {
        _instance = [[MMPalmGestureRecognizer alloc] init];
        _instance.delegate = _instance;
    }
    return _instance;
}

- (BOOL)hasSeenPalmDuringTouchSession {
    return _hasSeenPalmDuringTouchSession || [NSDate timeIntervalSinceReferenceDate] - lastPalmSession < kDurationToWaitAfterPalm;
}

#pragma mark - Touch Lifecycle

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    for (UITouch* touch in touches) {
        [liveTouches addObject:touch];

        if ([touch majorRadius] > 50) {
            [suspectTouches addObject:touch];
        }

        if ([touch force]) {
            // when using the apple pencil, always assume the palm is down
            _hasSeenPalmDuringTouchSession = YES;
        }

        if ([touch majorRadius] > 90) {
            [palmTouches addObject:touch];
        } else {
            for (UITouch* suspect in [palmTouches copy]) {
                if (touch != suspect) {
                    if (DistanceBetweenTwoPoints([touch locationInView:self.view], [suspect locationInView:self.view]) < 90) {
                        [palmTouches addObject:touch];
                        [palmTouches addObject:suspect];
                    }
                }
            }
            for (UITouch* suspect in [suspectTouches copy]) {
                if (touch != suspect) {
                    if (DistanceBetweenTwoPoints([touch locationInView:self.view], [suspect locationInView:self.view]) < 60) {
                        [palmTouches addObject:touch];
                        [suspectTouches addObject:touch];
                        [palmTouches addObject:suspect];
                    }
                }
            }
        }

        averageTouchRadius[@((int)touch)] = @([touch majorRadius]);
        averageTouchRadiusCount[@((int)touch)] = @(0);
    }

    if ([palmTouches count]) {
        [[self panDelegate] ownershipOfTouches:palmTouches isGesture:self];
        _hasSeenPalmDuringTouchSession = YES;
        DebugLog(@"**** %ld/%ld Palm Touches", (unsigned long)[palmTouches count], (unsigned long)[liveTouches count]);
    }
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
    for (UITouch* touch in touches) {
        for (UITouch* suspect in [palmTouches copy]) {
            if (touch != suspect) {
                if (DistanceBetweenTwoPoints([touch locationInView:self.view], [suspect locationInView:self.view]) < 90) {
                    [palmTouches addObject:suspect];
                    [palmTouches addObject:touch];
                }
            }
        }
        for (UITouch* suspect in [suspectTouches copy]) {
            if (touch != suspect) {
                if (DistanceBetweenTwoPoints([touch locationInView:self.view], [suspect locationInView:self.view]) < 60) {
                    [palmTouches addObject:suspect];
                    [suspectTouches addObject:touch];
                    [palmTouches addObject:touch];
                }
            }
        }

        if (![suspectTouches containsObject:touch]) {
            if ([averageTouchRadiusCount[@((int)touch)] integerValue] < 10) {
                NSInteger count = [averageTouchRadiusCount[@((int)touch)] integerValue];
                CGFloat radius = [averageTouchRadius[@((int)touch)] floatValue];
                radius = radius * [averageTouchRadiusCount[@((int)touch)] integerValue] + [touch majorRadius];
                radius = radius / (count + 1);

                averageTouchRadius[@((int)touch)] = @(radius);
                averageTouchRadiusCount[@((int)touch)] = @(count + 1);

                if (radius > 60) {
                    [suspectTouches addObject:touch];
                    [palmTouches addObject:touch];
                }
            }
        }
    }

    if ([palmTouches count]) {
        [[self panDelegate] ownershipOfTouches:palmTouches isGesture:self];
        _hasSeenPalmDuringTouchSession = YES;
        DebugLog(@"**** %ld/%ld Palm Touches", (unsigned long)[palmTouches count], (unsigned long)[liveTouches count]);
    }
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
    for (UITouch* touch in touches) {
        [liveTouches removeObject:touch];
        [suspectTouches removeObject:touch];
        [palmTouches removeObject:touch];
    }

    if (![liveTouches count]) {
        if (_hasSeenPalmDuringTouchSession) {
            lastPalmSession = [NSDate timeIntervalSinceReferenceDate];
        }
        _hasSeenPalmDuringTouchSession = NO;
    }
}

- (void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event {
    for (UITouch* touch in touches) {
        if ([suspectTouches containsObject:touch]) {
            // Apple cancel's UITouches if they detect a palm,
            // so if we thought it was probably a palm too,
            // then we should mark it as such.
            _hasSeenPalmDuringTouchSession = YES;
        }
        [liveTouches removeObject:touch];
        [suspectTouches removeObject:touch];
        [palmTouches removeObject:touch];
    }

    if (![liveTouches count]) {
        if (_hasSeenPalmDuringTouchSession) {
            lastPalmSession = [NSDate timeIntervalSinceReferenceDate];
        }
        _hasSeenPalmDuringTouchSession = NO;
    }
}


#pragma mark - UIGestureRecognizer Subclass

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer*)preventingGestureRecognizer {
    return NO;
}

- (BOOL)shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer*)otherGestureRecognizer {
    return NO;
}


#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer*)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer*)otherGestureRecognizer {
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer*)otherGestureRecognizer {
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldReceiveTouch:(UITouch*)touch {
    // Disallow recognition of tap gestures in the segmented control.
    if ([touch.view isKindOfClass:[UIControl class]]) {
        //        DebugLog(@"ignore touch in %@", NSStringFromClass([self class]));
        return NO;
    }
    return YES;
}


@end
