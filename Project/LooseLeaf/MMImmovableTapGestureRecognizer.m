//
//  MMImmovableTapGestureRecognizer.m
//  Loose Leaf
//
//  Created by Adam Wulf on 10/19/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "MMImmovableTapGestureRecognizer.h"
#import "Constants.h"

@interface MMImmovableTapGestureRecognizer (Private)

@property (nonatomic, readonly) NSMutableDictionary* touchLocations;
@property (nonatomic, readonly) CGFloat allowableMovement;

@end

@implementation MMImmovableTapGestureRecognizer

-(id) init{
    if(self = [super init]){
        self.delegate = self;
    }
    return self;
}

-(id) initWithTarget:(id)target action:(SEL)action{
    if(self = [super initWithTarget:target action:action]){
        self.delegate = self;
    }
    return self;
}

-(CGFloat) allowableMovement{
    return 10;
}

-(NSMutableDictionary*)touchLocations{
    if(!touchLocations){
        touchLocations = [[NSMutableDictionary alloc] init];
    }
    return touchLocations;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    for(UITouch* touch in touches){
        [self.touchLocations setObject:[NSValue valueWithCGPoint:[touch locationInView:self.view]]
                                forKey:[NSNumber numberWithInteger:[touch hash]]];
    }
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    BOOL didChangeState = NO;
    if(self.state == UIGestureRecognizerStatePossible){
        for(UITouch* touch in touches){
            CGPoint initialLocation = [[self.touchLocations objectForKey:[NSNumber numberWithInteger:[touch hash]]] CGPointValue];
            CGPoint currentLocation = [touch locationInView:self.view];
            CGFloat distance = DistanceBetweenTwoPoints(initialLocation, currentLocation);
            if(distance > self.allowableMovement && self.state == UIGestureRecognizerStatePossible){
                self.state = UIGestureRecognizerStateFailed;
                didChangeState = YES;
            }
        }
    }
    if(!didChangeState){
        [super touchesMoved:touches withEvent:event];
    }
}

-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesCancelled:touches withEvent:event];
    for(UITouch* touch in touches){
        [self.touchLocations removeObjectForKey:[NSNumber numberWithInteger:[touch hash]]];
    }
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    for(UITouch* touch in touches){
        [self.touchLocations removeObjectForKey:[NSNumber numberWithInteger:[touch hash]]];
    }
}

-(void) setState:(UIGestureRecognizerState)state{
    [super setState:state];
    if(state == UIGestureRecognizerStateEnded ||
       state == UIGestureRecognizerStateFailed ||
       state == UIGestureRecognizerStateCancelled){
        [self.touchLocations removeAllObjects];
    }
}

-(void) reset{
    [super reset];
    [self.touchLocations removeAllObjects];
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
