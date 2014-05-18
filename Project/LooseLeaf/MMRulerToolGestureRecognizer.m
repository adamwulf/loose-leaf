//
//  MMRulerToolGestureRecognizer.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/10/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMRulerToolGestureRecognizer.h"
#import <QuartzCore/QuartzCore.h>
#import "MMBezelInRightGestureRecognizer.h"
#import "MMBezelInLeftGestureRecognizer.h"
#import "MMObjectSelectLongPressGestureRecognizer.h"
#import "NSMutableSet+Extras.h"
#import "NSArray+MapReduce.h"
#import "MMShadowedView.h"
#import <JotUI/JotUI.h>

@implementation MMRulerToolGestureRecognizer

-(id) init{
    if(self = [super init]){
        self.cancelsTouchesInView = NO;
    }
    return self;
}

-(id) initWithTarget:(id)target action:(SEL)action{
    if(self = [super initWithTarget:target action:action]){
        self.cancelsTouchesInView = NO;
    }
    return self;
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

@end
