//
//  MMTouchDotGestureRecognizer.m
//  LooseLeaf
//
//  Created by Adam Wulf on 4/5/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMTouchDotGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@implementation MMTouchDotGestureRecognizer{
    NSMutableSet* activeTouches;
}

@synthesize touchDelegate;

-(id) init{
    if((self = [super init])){
        self.delaysTouchesBegan = NO;
        self.delaysTouchesEnded = NO;
        self.cancelsTouchesInView = NO;
        
        activeTouches = [NSMutableSet set];
    }
    return self;
}

@synthesize activeTouches;

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [activeTouches unionSet:touches];
    if(self.state == UIGestureRecognizerStatePossible){
        self.state = UIGestureRecognizerStateBegan;
    }else{
        self.state = UIGestureRecognizerStateChanged;
    }
    [touchDelegate touchesBegan:touches withEvent:event];
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    self.state = UIGestureRecognizerStateChanged;
    [touchDelegate touchesMoved:touches withEvent:event];
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [activeTouches minusSet:touches];
    if(![activeTouches count]){
        self.state = UIGestureRecognizerStateEnded;
    }
    [touchDelegate touchesEnded:touches withEvent:event];
}

-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [activeTouches minusSet:touches];
    if(![activeTouches count]){
        self.state = UIGestureRecognizerStateEnded;
    }
    [touchDelegate touchesCancelled:touches withEvent:event];
}

#pragma mark - UIGestureRecognizer

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


@end
