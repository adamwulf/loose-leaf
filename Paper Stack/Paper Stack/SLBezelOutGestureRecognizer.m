//
//  SLBezelOutGestureRecognizer.m
//  Paper Stack
//
//  Created by Adam Wulf on 6/19/12.
//  Copyright (c) 2012 Visere. All rights reserved.
//

#import "SLBezelOutGestureRecognizer.h"

@implementation SLBezelOutGestureRecognizer

@synthesize bezelDirectionMask;


-(id) init{
    self = [super init];
    if(self){
        validTouches = [[NSMutableSet alloc] init];
        validatedEndedTouches = [[NSMutableSet alloc] init];
        knownTouches = [[NSMutableSet alloc] init];
    }
    return self;
}

-(id) initWithTarget:(id)target action:(SEL)action{
    self = [super initWithTarget:target action:action];
    if(self){
        validTouches = [[NSMutableSet alloc] init];
        validatedEndedTouches = [[NSMutableSet alloc] init];
        knownTouches = [[NSMutableSet alloc] init];
    }
    return self;
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer{
    return NO;
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer{
    return NO;
}

/**
 * the first touch of a gesture.
 * this touch may interrupt an animation on this frame, so set the frame
 * to match that of the animation.
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [knownTouches addObjectsFromArray:[touches allObjects]];
    debug_NSLog(@"%d known touches", [knownTouches count]);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    for(UITouch* touch in touches){
        CGPoint point = [touch locationInView:self.view];
        if(point.x < 10 && ((self.bezelDirectionMask & SLBezelDirectionFromLeftBezel) == SLBezelDirectionFromLeftBezel)){
            [validTouches addObject:touch];
        }else if(point.y < 10 && ((self.bezelDirectionMask & SLBezelDirectionFromTopBezel) == SLBezelDirectionFromTopBezel)){
            [validTouches addObject:touch];
        }else if(point.x > self.view.frame.size.width - 10 && ((self.bezelDirectionMask & SLBezelDirectionFromRightBezel) == SLBezelDirectionFromRightBezel)){
            [validTouches addObject:touch];
        }else if(point.y > self.view.frame.size.height - 10 && ((self.bezelDirectionMask & SLBezelDirectionFromBottomBezel) == SLBezelDirectionFromBottomBezel)){
            [validTouches addObject:touch];
        }else{
            [validTouches removeObject:touch];
        }
    }
    debug_NSLog(@"%d known touches", [knownTouches count]);
    debug_NSLog(@"%d valid touches", [validTouches count]);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    for(UITouch* touch in touches){
        if([validTouches containsObject:touch]){
            [validatedEndedTouches addObject:touch];
            if([validatedEndedTouches count] >= 2){
                self.state = UIGestureRecognizerStateRecognized;
            }
        }
        [validTouches removeObject:touch];
        [knownTouches removeObject:touch];
    }
    debug_NSLog(@"%d known touches", [knownTouches count]);
    debug_NSLog(@"%d valid touches", [validTouches count]);
    debug_NSLog(@"%d valid end touches", [validatedEndedTouches count]);
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    for(UITouch* touch in touches){
        [validTouches removeObject:touch];
        [knownTouches removeObject:touch];
    }
    debug_NSLog(@"%d known touches", [knownTouches count]);
    debug_NSLog(@"%d valid touches", [validTouches count]);
    debug_NSLog(@"%d valid end touches", [validatedEndedTouches count]);
}
- (void)reset{
    [validTouches removeAllObjects];
    [validatedEndedTouches removeAllObjects];
    self.state = UIGestureRecognizerStatePossible;
}

-(void) cancel{
    self.enabled = NO;
    self.enabled = YES;
}

@end
