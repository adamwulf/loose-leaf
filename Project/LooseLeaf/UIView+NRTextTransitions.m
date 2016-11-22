//
//  UIView+NRTextTransitions.m
//  NRTextTransitionsExample
//
//  Created by Natan Rolnik on 2/26/14.
//
//

#import "UIView+NRTextTransitions.h"
#import "NRTextTransitionCompletionManager.h"


@implementation UIView (NRTextTransitions)

+ (void)animateTextTransitionForObjects:(NSArray*)textObjects withDuration:(NSTimeInterval)duration animations:(void (^)(void))animations {
    [self animateTextTransitionForObjects:textObjects withDuration:duration animations:animations completion:nil];
}

+ (void)animateTextTransitionForObjects:(NSArray*)textObjects withDuration:(NSTimeInterval)duration animations:(void (^)(void))animations completion:(void (^)(void))completion {
    [self animateTextTransitionForObjects:textObjects withDuration:duration delay:0 animations:animations completion:nil];
}

+ (void)animateTextTransitionForObjects:(NSArray*)textObjects withDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay animations:(void (^)(void))animations completion:(void (^)(void))completion {
    NSAssert(textObjects != nil, @"NRTextTransitions: the textObjects parameter must not be nil and should contain the objects you want to apply the transitions to.");
    NSAssert([textObjects count] > 0, @"NRTextTransitions: the textObjects parameter must not contain at least one object you want to apply the transitions to.");

    NSTimeInterval timeIntervalDelay = delay;
    if (timeIntervalDelay < 0) {
        timeIntervalDelay = 0;
    }

    if (timeIntervalDelay > 0) {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeIntervalDelay * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
            [self NRanimateTextTransitionForObjects:textObjects withDuration:duration animations:animations completion:completion];
        });
    } else {
        [self NRanimateTextTransitionForObjects:textObjects withDuration:duration animations:animations completion:completion];
    }
}

+ (void)NRanimateTextTransitionForObjects:(NSArray*)textObjects withDuration:(NSTimeInterval)duration animations:(void (^)(void))animations completion:(void (^)(void))completion {
    NSString* uuidString;

    if (completion) {
        uuidString = [[NSUUID UUID] UUIDString];
    }

    [textObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL* stop) {
        UIView* viewForTransition = obj;

        CATransition* animation = [CATransition animation];
        animation.duration = duration;
        animation.type = kCATransitionFade;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

        if (idx == [textObjects count] - 1 && completion) {
            [animation setValue:uuidString forKey:@"id"];
            [[NRTextTransitionCompletionManager sharedManager] setCompletionBlock:completion forKey:uuidString];
            animation.delegate = [NRTextTransitionCompletionManager sharedManager];
        }

        [viewForTransition.layer addAnimation:animation forKey:uuidString];
    }];

    if (animations) {
        animations();
    }
}

@end
