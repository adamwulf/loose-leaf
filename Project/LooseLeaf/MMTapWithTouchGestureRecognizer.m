//
//  MMTapWithTouchGestureRecognizer.m
//  LooseLeaf
//
//  Created by Adam Wulf on 11/21/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMTapWithTouchGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>


@implementation MMTapWithTouchGestureRecognizer {
    NSMutableSet* myTouches;
}

- (instancetype)initWithTarget:(id)target action:(SEL)action {
    if (self = [super initWithTarget:target action:action]) {
        myTouches = [NSMutableSet set];
    }
    return self;
}

- (NSArray<UITouch*>*)touches {
    return [myTouches allObjects];
}

- (void)touchesBegan:(NSSet<UITouch*>*)touches withEvent:(UIEvent*)event {
    [myTouches addObjectsFromArray:[touches allObjects]];
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch*>*)touches withEvent:(UIEvent*)event {
    [super touchesEnded:touches withEvent:event];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (UITouch* touch in [touches allObjects]) {
            [myTouches removeObject:touch];
        }
    });
}

- (void)touchesCancelled:(NSSet<UITouch*>*)touches withEvent:(UIEvent*)event {
    [super touchesCancelled:touches withEvent:event];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (UITouch* touch in [touches allObjects]) {
            [myTouches removeObject:touch];
        }
    });
}

- (void)ignoreTouch:(UITouch*)touch forEvent:(UIEvent*)event {
    [super ignoreTouch:touch forEvent:event];
    [myTouches removeObject:touch];
}


@end
