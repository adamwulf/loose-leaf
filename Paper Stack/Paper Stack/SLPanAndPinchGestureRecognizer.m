//
//  SLPanGestureRecognizer.m
//  Paper Stack
//
//  Created by Adam Wulf on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SLPanAndPinchGestureRecognizer.h"
#import <QuartzCore/QuartzCore.h>
#import "SLBezelInRightGestureRecognizer.h"
#import "NSMutableSet+Extras.h"

@implementation SLPanAndPinchGestureRecognizer

@synthesize scale;
@synthesize bezelDirectionMask;
@synthesize didExitToBezel;

-(id) init{
    self = [super init];
    if(self){
        validTouchesOnly = [[NSMutableOrderedSet alloc] init];
    }
    return self;
}

-(id) initWithTarget:(id)target action:(SEL)action{
    self = [super initWithTarget:target action:action];
    if(self){
        validTouchesOnly = [[NSMutableOrderedSet alloc] init];
    }
    return self;
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer{
    return NO;
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer{
    return [preventingGestureRecognizer isKindOfClass:[SLBezelInRightGestureRecognizer class]];
}

/**
 * the first touch of a gesture.
 * this touch may interrupt an animation on this frame, so set the frame
 * to match that of the animation.
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSMutableOrderedSet* validTouchesCurrentlyBeginning = [NSMutableOrderedSet orderedSetWithSet:touches];
    // ignore all the touches that could be bezel touches
    for(UITouch* touch in touches){
        CGPoint point = [touch locationInView:self.view.superview];
        if(point.x < kBezelInGestureWidth){
            [self ignoreTouch:touch forEvent:event];
            [validTouchesCurrentlyBeginning removeObject:touch];
        }else if(point.y < kBezelInGestureWidth){
            [self ignoreTouch:touch forEvent:event];
            [validTouchesCurrentlyBeginning removeObject:touch];
        }else if(point.x > self.view.frame.size.width - kBezelInGestureWidth){
            [self ignoreTouch:touch forEvent:event];
            [validTouchesCurrentlyBeginning removeObject:touch];
        }else if(point.y > self.view.frame.size.height - kBezelInGestureWidth){
            [self ignoreTouch:touch forEvent:event];
            [validTouchesCurrentlyBeginning removeObject:touch];
        }else{
            // debug_NSLog(@"point for panandpinch: %f %f", point.x, point.y);
        }
    }
    if([validTouchesCurrentlyBeginning count]){
        // look at the presentation of the view (as would be seen during animation)
        CGRect lFrame = [self.view.layer.presentationLayer frame];
        // look at the view frame to compare
        CGRect vFrame = self.view.frame;
        if(!CGRectEqualToRect(lFrame, vFrame)){
            // if they're not equal, then remove all animations
            // and set the frame to the presentation layer's frame
            // so that the gesture will pick up in the middle
            // of the animation instead of immediately reset to
            // its end state
            self.view.frame = lFrame;
        }
        [self.view.layer removeAllAnimations];
        [super touchesBegan:[validTouchesCurrentlyBeginning set] withEvent:event];
        [validTouchesOnly addObjectsFromArray:[validTouchesCurrentlyBeginning array]];
        if([validTouchesOnly count] >= self.minimumNumberOfTouches && self.state == UIGestureRecognizerStatePossible){
            self.state = UIGestureRecognizerStateBegan;
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    NSMutableOrderedSet* validTouchesCurrentlyMoving = [NSMutableOrderedSet orderedSetWithOrderedSet:validTouchesOnly];
    [validTouchesCurrentlyMoving intersectSet:touches];
    if([validTouchesCurrentlyMoving count]){
        [super touchesMoved:[validTouchesCurrentlyMoving set] withEvent:event];
        if(self.state == UIGestureRecognizerStateBegan){
            initialDistance = 0;
        }
        if(self.numberOfTouches == 1){
            initialDistance = 0;
            scale = 1;
        }
        if([validTouchesOnly count] >= 2 && !initialDistance){
            initialDistance = [self distanceBetweenTouches:validTouchesOnly];
        }
        if([validTouchesOnly count] >= 2 && initialDistance){
            scale = [self distanceBetweenTouches:validTouchesOnly] / initialDistance;
        }
    }
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    // pan and pinch and bezel
    NSMutableOrderedSet* validTouchesCurrentlyEnding = [NSMutableOrderedSet orderedSetWithOrderedSet:validTouchesOnly];
    [validTouchesCurrentlyEnding intersectSet:touches];
    if([validTouchesCurrentlyEnding count]){
        for(UITouch* touch in validTouchesCurrentlyEnding){
            CGPoint point = [touch locationInView:self.view.superview];
            BOOL bezelDirHasLeft = ((self.bezelDirectionMask & SLBezelDirectionLeft) == SLBezelDirectionLeft);
            BOOL bezelDirHasRight = ((self.bezelDirectionMask & SLBezelDirectionRight) == SLBezelDirectionRight);
            BOOL bezelDirHasUp = ((self.bezelDirectionMask & SLBezelDirectionUp) == SLBezelDirectionUp);
            BOOL bezelDirHasDown = ((self.bezelDirectionMask & SLBezelDirectionDown) == SLBezelDirectionDown);
            if(point.x < kBezelInGestureWidth && bezelDirHasLeft){
                didExitToBezel = didExitToBezel | SLBezelDirectionLeft;
                [super touchesCancelled:[NSSet setWithObject:touch] withEvent:event];
            }else if(point.y < kBezelInGestureWidth && bezelDirHasUp){
                didExitToBezel = didExitToBezel | SLBezelDirectionUp;
                [super touchesCancelled:[NSSet setWithObject:touch] withEvent:event];
            }else if(point.x > self.view.superview.frame.size.width - kBezelInGestureWidth && bezelDirHasRight){
                didExitToBezel = didExitToBezel | SLBezelDirectionRight;
                [super touchesCancelled:[NSSet setWithObject:touch] withEvent:event];
            }else if(point.y > self.view.superview.frame.size.height - kBezelInGestureWidth && bezelDirHasDown){
                didExitToBezel = didExitToBezel | SLBezelDirectionDown;
                [super touchesCancelled:[NSSet setWithObject:touch] withEvent:event];
            }else{
                [super touchesEnded:[NSSet setWithObject:touch] withEvent:event];
            }
        }
        if(self.numberOfTouches == 1 && self.state == UIGestureRecognizerStateChanged){
            self.state = UIGestureRecognizerStatePossible;
        }
        [validTouchesOnly minusOrderedSet:validTouchesCurrentlyEnding];
    }
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    NSMutableOrderedSet* validTouchesCurrentlyCancelling = [NSMutableOrderedSet orderedSetWithOrderedSet:validTouchesOnly];
    [validTouchesCurrentlyCancelling intersectSet:touches];
    if([validTouchesCurrentlyCancelling count]){
        [super touchesCancelled:touches withEvent:event];
        if(self.numberOfTouches == 1 && self.state == UIGestureRecognizerStateChanged){
            self.state = UIGestureRecognizerStatePossible;
        }
        [validTouchesOnly minusOrderedSet:validTouchesCurrentlyCancelling];
    }
}
- (void)reset{
    [super reset];
    initialDistance = 0;
    scale = 1;
    [validTouchesOnly removeAllObjects];
    didExitToBezel = SLBezelDirectionNone;
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
