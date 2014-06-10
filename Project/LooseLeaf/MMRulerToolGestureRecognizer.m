//
//  MMRulerToolGestureRecognizer.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/10/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMRulerToolGestureRecognizer.h"
#import <QuartzCore/QuartzCore.h>
#import "MMBezelInGestureRecognizer.h"
#import "MMObjectSelectLongPressGestureRecognizer.h"
#import "NSMutableSet+Extras.h"
#import "NSArray+MapReduce.h"
#import "MMShadowedView.h"
#import <JotUI/JotUI.h>

@implementation MMRulerToolGestureRecognizer{
    __weak NSObject<MMPanAndPinchScrapGestureRecognizerDelegate>* rulerDelegate;
}

-(id) init{
    if(self = [super init]){
        self.cancelsTouchesInView = NO;
        self.scrapDelegate = self;
        self.delegate = self;
    }
    return self;
}

-(id) initWithTarget:(id)target action:(SEL)action{
    if(self = [super initWithTarget:target action:action]){
        self.cancelsTouchesInView = NO;
        self.scrapDelegate = self;
        self.delegate = self;
    }
    return self;
}

-(void) setScrapDelegate:(NSObject<MMPanAndPinchScrapGestureRecognizerDelegate> *)_scrapDelegate{
    if(!scrapDelegate){
        [super setScrapDelegate:_scrapDelegate];
    }else{
        rulerDelegate = _scrapDelegate;
    }
}

-(CGFloat) initialDistance{
    return initialDistance;
}

-(void) cancel{
    if(self.enabled){
        self.enabled = NO;
        self.enabled = YES;
    }
}


-(BOOL) containsTouch:(UITouch*)touch{
    return [validTouches containsObject:touch];
}

#pragma mark - Public Interface

/**
 * return the two locations of the ruler in
 * the input view
 */
-(CGPoint) point1InView:(UIView*)view{
    return [[validTouches firstObject] locationInView:view];
}

-(CGPoint) point2InView:(UIView*)view{
    return [[validTouches lastObject] locationInView:view];
}


#pragma mark - Private Helpers


-(CGFloat) distanceBetweenTouches:(NSOrderedSet*) touches{
    if([touches count] >= 2){
        UITouch* touch1 = [touches objectAtIndex:0];
        UITouch* touch2 = [touches objectAtIndex:1];
        CGPoint initialPoint1 = [touch1 locationInView:self.view.superview];
        CGPoint initialPoint2 = [touch2 locationInView:self.view.superview];
        return DistanceBetweenTwoPoints(initialPoint1, initialPoint2);
    }
    return 0;
}

#pragma mark - MMPanAndPinchScrapGestureRecognizerDelegate

-(NSArray*) scrapsToPan{
    return [rulerDelegate scrapsToPan];
}

-(BOOL) panScrapRequiresLongPress{
    return [rulerDelegate panScrapRequiresLongPress];
}

-(CGFloat) topVisiblePageScaleForScrap:(MMScrapView*)scrap{
    return [rulerDelegate topVisiblePageScaleForScrap:scrap];
}

-(CGPoint) convertScrapCenterToScrapContainerCoordinate:(MMScrapView*)scrap{
    return [rulerDelegate convertScrapCenterToScrapContainerCoordinate:scrap];
}

-(BOOL) isAllowedToPan{
    return ![rulerDelegate isAllowedToPan];
}

-(BOOL) allowsHoldingScrapsWithTouch:(UITouch*)touch{
    return [rulerDelegate allowsHoldingScrapsWithTouch:touch];
}

-(void) ownershipOfTouches:(NSSet*)touches isGesture:(UIGestureRecognizer*)gesture{
    [rulerDelegate ownershipOfTouches:touches isGesture:gesture];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // Disallow recognition of tap gestures in the segmented control.
    if ([touch.view isKindOfClass:[UIControl class]]) {
        NSLog(@"ignore touch in %@", NSStringFromClass([self class]));
        return NO;
    }
    return YES;
}

@end
