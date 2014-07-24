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
#import "NSMutableSet+Extras.h"
#import "NSArray+MapReduce.h"
#import "MMShadowedView.h"
#import <JotUI/JotUI.h>

@implementation MMRulerToolGestureRecognizer{
    __weak NSObject<MMPanAndPinchScrapGestureRecognizerDelegate>* rulerDelegate;
}

#pragma mark - Properties

-(CGFloat) initialDistance{
    return initialDistance;
}


#pragma mark - Init

-(id) init{
    if(self = [super init]){
        self.cancelsTouchesInView = NO;
        self.scrapDelegate = self;
    }
    return self;
}

-(id) initWithTarget:(id)target action:(SEL)action{
    if(self = [super initWithTarget:target action:action]){
        self.cancelsTouchesInView = NO;
        self.scrapDelegate = self;
    }
    return self;
}

#pragma mark - Helper Methods

-(void) setScrapDelegate:(NSObject<MMPanAndPinchScrapGestureRecognizerDelegate> *)_scrapDelegate{
    if(!self.scrapDelegate){
        [super setScrapDelegate:_scrapDelegate];
    }else{
        rulerDelegate = _scrapDelegate;
    }
}


#pragma mark - Public Interface

-(BOOL) containsTouch:(UITouch*)touch{
    return [validTouches containsObject:touch];
}

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
    // ruler works when used over scraps, so send an empty/nil array
    // so we don't filter any touches out that occur over scraps
    return nil;
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
    return ![rulerDelegate isAllowedToPan] && [rulerDelegate isAllowedToBezel];
}

-(BOOL) isAllowedToBezel{
    return [rulerDelegate isAllowedToBezel];
}

-(BOOL) allowsHoldingScrapsWithTouch:(UITouch*)touch{
    return [rulerDelegate allowsHoldingScrapsWithTouch:touch];
}

@end
