//
//  MMPanFromListViewGestureRecognizer.m
//  Loose Leaf
//
//  Created by Adam Wulf on 8/31/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "MMPanAndPinchFromListViewGestureRecognizer.h"
#import "MMLongPressFromListViewGestureRecognizer.h"


@implementation MMPanAndPinchFromListViewGestureRecognizer

#pragma mark - Properties

@synthesize scale;
@synthesize initialPageScale;
@synthesize scaleDirection;
@synthesize pinchDelegate;
@synthesize pinchedPage;
@synthesize normalizedLocationOfScale;

#pragma mark - Init

- (id)init {
    self = [super init];
    if (self) {
        validTouches = [[NSMutableOrderedSet alloc] init];
        [self reset];
        self.delegate = self;
    }
    return self;
}

- (id)initWithTarget:(id)target action:(SEL)action {
    self = [super initWithTarget:target action:action];
    if (self) {
        validTouches = [[NSMutableOrderedSet alloc] init];
        [self reset];
        self.delegate = self;
    }
    return self;
}

- (NSArray*)validTouches {
    return [validTouches array];
}

#pragma mark - Touch Methods

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    [touches enumerateObjectsUsingBlock:^(id obj, BOOL* stop) {
        UITouch* touch = obj;
        MMPaperView* page = [pinchDelegate pageForPointInList:[touch locationInView:self.view]];
        if (page && (!pinchedPage || pinchedPage == page)) {
            if (!pinchedPage) {
                pinchedPage = page;
            }
            if ([validTouches count] == 2) {
                [self ignoreTouch:touch forEvent:event];
            } else if ([validTouches count] < 2) {
                [validTouches addObject:touch];
            }
            if ([validTouches count] == 2 && self.state == UIGestureRecognizerStatePossible) {
                CGPoint lastLocationInPage = [self locationInView:pinchedPage];
                if ([pinchedPage isKindOfClass:[MMShadowedView class]]) {
                    // the location needs to take into account the shadow
                    lastLocationInPage.x -= [MMShadowedView shadowWidth];
                    lastLocationInPage.y -= [MMShadowedView shadowWidth];
                }
                normalizedLocationOfScale = CGPointMake(lastLocationInPage.x / pinchedPage.frame.size.width,
                                                        lastLocationInPage.y / pinchedPage.frame.size.height);
                initialDistance = [self distanceBetweenTouches:validTouches];
                CGSize fullPageSize = [pinchDelegate sizeOfFullscreenPage];
                CGSize initialPageSize = pinchedPage.frame.size;
                initialPageScale = initialPageSize.width / fullPageSize.width;
                scale = initialPageScale;
                self.state = UIGestureRecognizerStateBegan;
            }
        } else {
            [self ignoreTouch:touch forEvent:event];
        }
    }];
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
    if ([validTouches count] == 2 && self.state != UIGestureRecognizerStateBegan) {
        //        DebugLog(@"touchesMoved");
        CGFloat newScale = initialPageScale * [self distanceBetweenTouches:validTouches] / initialDistance;
        if (newScale > scale) {
            scaleDirection = MMScaleDirectionLarger;
        } else if (newScale < scale) {
            scaleDirection = MMScaleDirectionSmaller;
        } else {
        }
        scale = newScale;
        self.state = UIGestureRecognizerStateChanged;
    }
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
    NSUInteger validTouchCount = [validTouches count];
    [validTouches removeObjectsInSet:touches];
    if (validTouchCount == 2) {
        self.state = UIGestureRecognizerStateEnded;
    } else {
        self.state = UIGestureRecognizerStateFailed;
    }
}

- (void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event {
    NSUInteger validTouchCount = [validTouches count];
    [validTouches removeObjectsInSet:touches];
    if (validTouchCount == 2) {
        self.state = UIGestureRecognizerStateCancelled;
    } else {
        self.state = UIGestureRecognizerStateFailed;
    }
}

- (void)ignoreTouch:(UITouch*)touch forEvent:(UIEvent*)event {
    //    DebugLog(@"ignoreTouch");
    [super ignoreTouch:touch forEvent:event];
}

#pragma mark - UIGestureRecognzier Subclass

- (void)reset {
    [validTouches removeAllObjects];
    pinchedPage = nil;
    scaleDirection = MMBezelDirectionNone;
    scale = 1.0;
    normalizedLocationOfScale = CGPointZero;
    [super reset];
}

// kill the gesture, and make sure that any events
// that fire after this won't include the pinchedPage
- (void)killTheGestureCold {
    pinchedPage = nil;
    [self cancel];
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer*)preventedGestureRecognizer {
    return [preventedGestureRecognizer isKindOfClass:[MMLongPressFromListViewGestureRecognizer class]];
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer*)preventingGestureRecognizer {
    return [preventingGestureRecognizer isKindOfClass:[MMLongPressFromListViewGestureRecognizer class]];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer*)otherGestureRecognizer {
    return ![otherGestureRecognizer isKindOfClass:[MMLongPressFromListViewGestureRecognizer class]];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer*)otherGestureRecognizer {
    return [otherGestureRecognizer isKindOfClass:[MMLongPressFromListViewGestureRecognizer class]];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer*)otherGestureRecognizer {
    return [otherGestureRecognizer isKindOfClass:[MMLongPressFromListViewGestureRecognizer class]];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldReceiveTouch:(UITouch*)touch {
    // Disallow recognition of tap gestures in the segmented control.
    if ([touch.view isKindOfClass:[UIControl class]]) {
        //        DebugLog(@"ignore touch in %@", NSStringFromClass([self class]));
        return NO;
    }
    return YES;
}


#pragma mark - Helper

- (CGFloat)distanceBetweenTouches:(NSOrderedSet*)touches {
    if ([touches count] >= 2) {
        UITouch* touch1 = [touches objectAtIndex:0];
        UITouch* touch2 = [touches objectAtIndex:1];
        CGPoint initialPoint1 = [touch1 locationInView:self.view.superview];
        CGPoint initialPoint2 = [touch2 locationInView:self.view.superview];
        return DistanceBetweenTwoPoints(initialPoint1, initialPoint2);
    }
    return 0;
}

@end
