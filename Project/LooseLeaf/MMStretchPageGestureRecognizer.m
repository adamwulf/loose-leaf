//
//  MMStretchPageGestureRecognizer.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/16/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMStretchPageGestureRecognizer.h"
#import "MMStretchHelper.h"

@implementation MMStretchPageGestureRecognizer{
    NSMutableOrderedSet* additionalTouches;
}

-(id) init{
    self = [super init];
    if(self){
        additionalTouches = [[NSMutableOrderedSet alloc] init];
        [self reset];
        self.delegate = self;
    }
    return self;
}

-(id) initWithTarget:(id)target action:(SEL)action{
    self = [super initWithTarget:target action:action];
    if(self){
        additionalTouches = [[NSMutableOrderedSet alloc] init];
        [self reset];
        self.delegate = self;
    }
    return self;
}


#pragma mark - Touch Methods

-(void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    for (UITouch* touch in touches) {
        if([validTouches count] < 2){
            [super touchesBegan:[NSSet setWithObject:touch] withEvent:event];
        }else if([additionalTouches count] < 2){
            CGPoint locationInPage = [touch locationInView:pinchedPage];

            if(CGRectContainsPoint([pinchedPage bounds], locationInPage)){
                [additionalTouches addObject:touch];
            }else{
                [self ignoreTouch:touch forEvent:event];
            }
        }else{
            [self ignoreTouch:touch forEvent:event];
        }
    }
}

-(void) touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    for (UITouch* touch in touches) {
        if([validTouches containsObject:touch]){
            [super touchesMoved:[NSSet setWithObject:touch] withEvent:event];
        }else if([additionalTouches count] == 2){
            NSMutableOrderedSet* allFourTouches = [NSMutableOrderedSet orderedSetWithOrderedSet:validTouches];
            [allFourTouches addObjectsInOrderedSet:additionalTouches];
            [MMStretchHelper sortTouchesClockwise:allFourTouches];
            
            
            
            
            NSLog(@"additional behavior for touch moved");
        }
    }
}

-(void) touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    for (UITouch* touch in touches) {
        if([validTouches containsObject:touch]){
            [super touchesEnded:[NSSet setWithObject:touch] withEvent:event];
        }else{
            NSLog(@"additional behavior for touch ended");
        }
    }
}

-(void) touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    for (UITouch* touch in touches) {
        if([validTouches containsObject:touch]){
            [super touchesCancelled:[NSSet setWithObject:touch] withEvent:event];
        }else{
            NSLog(@"additional behavior for touch cancelled");
        }
    }
}

#pragma mark - UIGestureRecognizerSubclass

-(CGPoint) locationInView:(UIView *)view{
    CGPoint p = CGPointZero;
    for (UITouch* touch in validTouches) {
        CGPoint loc = [touch locationInView:view];
        p.x += loc.x;
        p.y += loc.y;
    }
    if([validTouches count]){
        p.x /= [validTouches count];
        p.y /= [validTouches count];
    }
    return p;
}

@end
