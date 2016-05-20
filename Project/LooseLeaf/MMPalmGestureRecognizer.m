//
//  MMPalmGestureRecognizer.m
//  LooseLeaf
//
//  Created by Adam Wulf on 4/29/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMPalmGestureRecognizer.h"

@interface MMPalmGestureRecognizer ()<UIGestureRecognizerDelegate>

@end

@implementation MMPalmGestureRecognizer{
    NSMutableSet* liveTouches;
}

#pragma mark - Singleton and Init

static MMPalmGestureRecognizer* _instance = nil;

-(id) init{
    if(_instance) return _instance;
    if((self = [super init])){
        _instance = self;
        self.delaysTouchesBegan = NO;
        self.delaysTouchesEnded = NO;
        self.cancelsTouchesInView = NO;
        liveTouches = [NSMutableSet set];
        
        self.enabled = NO;
    }
    return _instance;
}

+(MMPalmGestureRecognizer*) sharedInstance{
    if(!_instance){
        _instance = [[MMPalmGestureRecognizer alloc]init];
        _instance.delegate = _instance;
    }
    return _instance;
}

#pragma mark - Debug Helpers

-(void) printInfoForTouch:(UITouch*)touch inState:(NSString*)state{
    CGPoint loc = [touch locationInView:nil];
    NSLog(@"Touch %p %@: %.2f %.2f radius: %.2f tol: %.2f", touch, state, loc.x, loc.y, touch.majorRadius, touch.majorRadiusTolerance);
}

-(void) signalPalmDetectedForTouch:(UITouch*)touch{
    NSLog(@"****");
    CGPoint loc = [touch locationInView:nil];
    NSLog(@"Palm touch %p at: %.2f %.2f with radius: %.2f tol: %.2f", touch, loc.x, loc.y, touch.majorRadius, touch.majorRadiusTolerance);
    NSLog(@"****");
}

#pragma mark - Touch Lifecycle

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    for(UITouch* touch in touches){
        [liveTouches addObject:touch];
        
        [self printInfoForTouch:touch inState:@"began"];
    }
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    for(UITouch* touch in touches){
        [self printInfoForTouch:touch inState:@"moved"];
        for(UITouch* t in [event coalescedTouchesForTouch:touch]){
            CGPoint loc = [t locationInView:nil];
            NSLog(@"coalesced: %p %.2f %.2f", t, loc.x, loc.y);
        }
    }
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    for(UITouch* touch in touches){
        [liveTouches removeObject:touch];
        [self printInfoForTouch:touch inState:@"ended"];
        for(UITouch* t in [event coalescedTouchesForTouch:touch]){
            CGPoint loc = [t locationInView:nil];
            NSLog(@"coalesced: %p %.2f %.2f", t, loc.x, loc.y);
        }
    }
}

-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    for(UITouch* touch in touches){
        [liveTouches removeObject:touch];
        [self printInfoForTouch:touch inState:@"cancelled"];
    }
}


#pragma mark - UIGestureRecognizer Subclass

-(BOOL) canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer{
    return NO;
}

-(BOOL) shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return NO;
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
        //        DebugLog(@"ignore touch in %@", NSStringFromClass([self class]));
        return NO;
    }
    return YES;
}


@end
