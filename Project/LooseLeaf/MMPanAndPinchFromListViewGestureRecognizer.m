//
//  MMPanFromListViewGestureRecognizer.m
//  Loose Leaf
//
//  Created by Adam Wulf on 8/31/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "MMPanAndPinchFromListViewGestureRecognizer.h"

@implementation MMPanAndPinchFromListViewGestureRecognizer

@synthesize scale;
@synthesize initialPageScale;
@synthesize scaleDirection;
@synthesize pinchDelegate;
@synthesize pinchedPage;
@synthesize normalizedLocationOfScale;


-(id) init{
    self = [super init];
    if(self){
        validTouches = [[NSMutableOrderedSet alloc] init];
        [self reset];
    }
    return self;
}

-(id) initWithTarget:(id)target action:(SEL)action{
    self = [super initWithTarget:target action:action];
    if(self){
        validTouches = [[NSMutableOrderedSet alloc] init];
        [self reset];
    }
    return self;
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer{
    return NO;
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer{
    return NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//    debug_NSLog(@"touchesBegan");
    [touches enumerateObjectsUsingBlock:^(id obj, BOOL *stop){
        UITouch* touch = obj;
        MMPaperView* page = [pinchDelegate pageForPointInList:[touch locationInView:self.view]];
        if(page && (!pinchedPage || pinchedPage == page)){
            if(!pinchedPage){
                pinchedPage = page;
            }
            if([validTouches count] == 2){
                [self ignoreTouch:touch forEvent:event];
            }else if([validTouches count] < 2){
                [validTouches addObject:touch];
            }
            if([validTouches count] == 2 && self.state == UIGestureRecognizerStatePossible){
                CGPoint lastLocationInPage = [self locationInView:pinchedPage];
                if([pinchedPage isKindOfClass:[MMShadowedView class]]){
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
        }else{
            [self ignoreTouch:touch forEvent:event];
        }
    }];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if([validTouches count] == 2 && self.state != UIGestureRecognizerStateBegan){
//        debug_NSLog(@"touchesMoved");
        CGFloat newScale = initialPageScale * [self distanceBetweenTouches:validTouches] / initialDistance;
        if(newScale > scale){
            scaleDirection = MMScaleDirectionLarger;
        }else if(newScale < scale){
            scaleDirection = MMScaleDirectionSmaller;
        }else{
            
        }
        scale = newScale;
        self.state = UIGestureRecognizerStateChanged;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if([validTouches count] == 2){
//        debug_NSLog(@"touchesEnded");
        [validTouches removeObjectsInSet:touches];
        self.state = UIGestureRecognizerStateEnded;
    }else{
        self.state = UIGestureRecognizerStateFailed;
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
//    debug_NSLog(@"touchesCancelled");
    [validTouches removeObjectsInSet:touches];
    self.state = UIGestureRecognizerStateCancelled;
}

- (void)ignoreTouch:(UITouch *)touch forEvent:(UIEvent *)event{
//    debug_NSLog(@"ignoreTouch");
    [super ignoreTouch:touch forEvent:event];
}

-(void) reset{
//    debug_NSLog(@"reset");
    [validTouches removeAllObjects];
    pinchedPage = nil;
    scaleDirection = MMBezelDirectionNone;
    scale = 1.0;
    normalizedLocationOfScale = CGPointZero;
    [super reset];
}

-(void) cancel{
    self.enabled = NO;
    self.enabled = YES;
}








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
